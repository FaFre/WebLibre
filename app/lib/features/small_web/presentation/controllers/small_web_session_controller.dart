// ignore_for_file: avoid_redundant_argument_values

/*
 * Copyright (c) 2024-2026 Fabian Freund.
 *
 * This file is part of WebLibre
 * (see https://weblibre.eu).
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */
import 'dart:async';
import 'dart:convert';

import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:fast_equatable/fast_equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:riverpod/experimental/persist.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_session.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_state.dart';
import 'package:weblibre/features/small_web/data/models/kagi_small_web_mode.dart';
import 'package:weblibre/features/small_web/data/models/small_web_source_kind.dart';
import 'package:weblibre/features/small_web/domain/providers.dart';
import 'package:weblibre/features/small_web/presentation/controllers/small_web_mode_controller.dart';
import 'package:weblibre/features/user/data/providers.dart';

part 'small_web_session_controller.g.dart';

@CopyWith()
@JsonSerializable()
class SmallWebSessionState with FastEquatable {
  final SmallWebSourceKind sourceKind;
  final KagiSmallWebMode? mode;
  final String? currentCategory;
  final String? currentItemId;
  final Uri? currentItemUrl;
  final Uri? currentConsoleUrl;
  @JsonKey(includeToJson: false, includeFromJson: false)
  final String? infoMessage;

  static KagiSmallWebMode? _defaultModeForSourceKind(
    SmallWebSourceKind sourceKind,
  ) {
    return sourceKind == SmallWebSourceKind.wander
        ? null
        : KagiSmallWebMode.web;
  }

  SmallWebSessionState({
    this.sourceKind = SmallWebSourceKind.kagi,
    this.mode,
    this.currentCategory,
    this.currentItemId,
    this.currentItemUrl,
    this.currentConsoleUrl,
    this.infoMessage,
  });

  factory SmallWebSessionState.fromJson(Map<String, dynamic> json) =>
      _$SmallWebSessionStateFromJson(json);

  Map<String, dynamic> toJson() => _$SmallWebSessionStateToJson(this);

  factory SmallWebSessionState.initial(SmallWebSourceKind sourceKind) {
    return SmallWebSessionState(
      sourceKind: sourceKind,
      mode: _defaultModeForSourceKind(sourceKind),
    );
  }

  factory SmallWebSessionState.forSourceKind({
    required SmallWebSourceKind sourceKind,
    Uri? currentConsoleUrl,
  }) {
    return SmallWebSessionState(
      sourceKind: sourceKind,
      mode: _defaultModeForSourceKind(sourceKind),
      currentConsoleUrl: sourceKind == SmallWebSourceKind.wander
          ? currentConsoleUrl
          : null,
    );
  }

  @override
  bool get cacheHash => true;

  @override
  List<Object?> get hashParameters => [
    sourceKind,
    mode,
    currentCategory,
    currentItemId,
    currentItemUrl,
    currentConsoleUrl,
    infoMessage,
  ];
}

@Riverpod(keepAlive: true)
class SmallWebSessionController extends _$SmallWebSessionController {
  @override
  AsyncValue<SmallWebSessionState> build() {
    final persistFuture = persist(
      ref.watch(riverpodDatabaseStorageProvider),
      key: 'SmallWebSessionState',
      encode: (state) => jsonEncode(
        (state.value ?? SmallWebSessionState.initial(SmallWebSourceKind.kagi))
            .toJson(),
      ),
      decode: (encoded) {
        try {
          final decoded = SmallWebSessionState.fromJson(
            jsonDecode(encoded) as Map<String, dynamic>,
          );

          return AsyncData(decoded);
        } catch (_) {
          return AsyncData(
            SmallWebSessionState.initial(SmallWebSourceKind.kagi),
          );
        }
      },
    );

    listenSelf((previous, next) {
      next.whenData((data) async {
        if (data.currentItemUrl != null &&
            data.currentItemUrl != previous?.value?.currentItemUrl) {
          final smallWebTabId = ref.read(smallWebModeControllerProvider);
          var state = ref.read(tabStatesProvider)[smallWebTabId];

          if (smallWebTabId != null) {
            if (state == null) {
              for (var i = 0; i < 25; i++) {
                await Future.delayed(const Duration(milliseconds: 100));

                state = ref.read(tabStatesProvider)[smallWebTabId];

                if (state != null) {
                  break;
                }
              }
            }

            if (state == null) return;

            await ref
                .read(tabSessionProvider(tabId: smallWebTabId).notifier)
                .loadUrl(url: data.currentItemUrl!);
          }
        }
      });
    });

    if (persistFuture.future != null) {
      unawaited(
        persistFuture.future!.whenComplete(() {
          //When nothing got decoded dont stay stale
          if (stateOrNull == null || state.isLoading) {
            state = AsyncData(
              SmallWebSessionState.initial(SmallWebSourceKind.kagi),
            );
          }
        }),
      );

      return const AsyncLoading();
    }

    return AsyncData(SmallWebSessionState.initial(SmallWebSourceKind.kagi));
  }

  void setSourceKind(SmallWebSourceKind kind) {
    state = AsyncData(
      SmallWebSessionState.forSourceKind(
        sourceKind: kind,
        currentConsoleUrl: kind == SmallWebSourceKind.wander
            ? state.value?.currentConsoleUrl
            : null,
      ),
    );
  }

  void setMode(KagiSmallWebMode mode) {
    if (state.hasValue) {
      state = AsyncData(
        state.requireValue.copyWith(
          mode: mode,
          currentCategory: null,
          currentItemId: null,
          currentItemUrl: null,
          infoMessage: null,
        ),
      );
    }
  }

  void setCategory(String? category) {
    if (state.hasValue) {
      state = AsyncData(
        state.requireValue.copyWith(
          currentCategory: category,
          infoMessage: null,
        ),
      );
    }
  }

  Future<void> discover({bool forceNewConsole = false}) async {
    if (state.isLoading) return;
    if (!state.hasValue) return;

    final session = state.requireValue.copyWith(infoMessage: null);

    state = const AsyncLoading<SmallWebSessionState>();

    try {
      final discoverService = await ref.read(
        smallWebDiscoverServiceProvider.future,
      );

      if (session.sourceKind == SmallWebSourceKind.wander) {
        final result = await discoverService.discoverWander(
          currentConsoleUrl: session.currentConsoleUrl,
          forceNewConsole: forceNewConsole,
        );
        if (result != null) {
          state = AsyncData(
            session.copyWith(
              currentItemId: result.item.id,
              currentItemUrl: result.item.url,
              currentConsoleUrl: result.consoleUrl,
            ),
          );

          return;
        }
      } else {
        final item = await discoverService.discoverKagi(
          mode: session.mode!,
          category: session.currentCategory,
        );
        if (item != null) {
          state = AsyncData(
            session.copyWith(currentItemId: item.id, currentItemUrl: item.url),
          );

          return;
        }
      }

      state = AsyncData(
        session.copyWith(
          infoMessage: 'No new items found. Try a different mode or category.',
        ),
      );
    } catch (e, st) {
      logger.e('Discovery failed', error: e, stackTrace: st);
      state = AsyncError<SmallWebSessionState>(
        'Discovery failed. Please try again.',
        st,
      );
    }
  }

  void selectConsole(Uri consoleUrl) {
    if (state.hasValue) {
      state = AsyncData(
        state.requireValue.copyWith(
          currentConsoleUrl: consoleUrl,
          currentItemId: null,
          currentItemUrl: null,
        ),
      );
    }
  }

  Future<void> updateTitleFromTab(String title, {required Uri? tabUrl}) async {
    if (state.hasValue) {
      final session = state.requireValue;

      if (session.sourceKind != SmallWebSourceKind.wander) return;

      final itemId = session.currentItemId;
      final itemUrl = session.currentItemUrl;
      if (itemId == null || title.isEmpty) return;
      if (tabUrl == null || itemUrl == null || tabUrl != itemUrl) return;

      final discoverService = await ref.read(
        smallWebDiscoverServiceProvider.future,
      );

      await discoverService.updateItemTitle(itemId, title);
    }
  }

  Future<void> revisit({
    required String itemId,
    required Uri url,
    required SmallWebSourceKind sourceKind,
    required KagiSmallWebMode? mode,
    Uri? consoleUrl,
  }) async {
    if (state.hasValue) {
      final discoverService = await ref.read(
        smallWebDiscoverServiceProvider.future,
      );

      await discoverService.recordVisit(
        itemId: itemId,
        sourceKind: sourceKind,
        mode: mode,
        consoleUrl: consoleUrl,
      );

      state = AsyncData(
        state.requireValue.copyWith(
          currentItemId: itemId,
          currentItemUrl: url,
          currentConsoleUrl: consoleUrl,
          infoMessage: null,
        ),
      );
    }
  }
}
