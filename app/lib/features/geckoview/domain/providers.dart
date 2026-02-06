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

import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/core/providers/router.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/features/bangs/domain/providers/bangs.dart';
import 'package:weblibre/features/geckoview/domain/providers/selected_tab.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_state.dart';
import 'package:weblibre/features/geckoview/domain/repositories/tab.dart';
import 'package:weblibre/features/geckoview/features/find_in_page/presentation/controllers/find_in_page.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';

part 'providers.g.dart';

@Riverpod(keepAlive: true)
GeckoSelectionActionService selectionActionService(Ref ref) {
  final service = GeckoSelectionActionService.setUp();

  unawaited(
    service.setActions([
      NewTabAction((text) async {
        if (ref.mounted) {
          final router = await ref.read(routerProvider.future);
          if (ref.mounted) {
            final settings = ref.read(generalSettingsWithDefaultsProvider);
            final route = SearchRoute(
              tabType:
                  // ignore: only_use_keep_alive_inside_keep_alive
                  ref.read(selectedTabTypeProvider) ??
                  settings.defaultCreateTabType,
              searchText: text,
            );

            await router.push(route.location);
          }
        }
      }),
      DefaultSearchAction((text) async {
        if (ref.mounted) {
          final defaultSearchBang = await ref.read(
            defaultSearchBangDataProvider.future,
          );

          if (ref.mounted && defaultSearchBang != null) {
            // ignore: only_use_keep_alive_inside_keep_alive
            final currentTab = ref.read(selectedTabStateProvider);
            final isPrivate =
                currentTab?.isPrivate ??
                ref
                        .read(generalSettingsWithDefaultsProvider)
                        .defaultCreateTabType ==
                    TabType.private;

            await ref
                .read(tabRepositoryProvider.notifier)
                .addTab(
                  url: defaultSearchBang.getTemplateUrl(text),
                  parentId: currentTab?.id,
                  private: isPrivate,
                  selectTab: true,
                );
          } else {
            logger.e('No default search bang found');
          }
        }
      }),
      FindInPageAction((text) async {
        if (ref.mounted) {
          final tabId = ref.read(selectedTabProvider);
          if (tabId != null) {
            // ignore: only_use_keep_alive_inside_keep_alive
            await ref
                .read(findInPageControllerProvider(tabId).notifier)
                .findAll(text: text);
          }
        }
      }),
      ShareAction((text) async {
        await SharePlus.instance.share(ShareParams(text: text));
      }),
      CallAction((text) async {
        final uri = Uri.tryParse('tel:${text.replaceAll(' ', '')}');

        if (uri != null) {
          final canLaunch = await canLaunchUrl(uri);
          if (canLaunch) {
            await launchUrl(uri);
          }
        }
      }),
      EmailAction((text) async {
        final uri = Uri.tryParse('mailto:$text');

        if (uri != null) {
          final canLaunch = await canLaunchUrl(uri);
          if (canLaunch) {
            await launchUrl(uri);
          }
        }
      }),
    ]),
  );

  return service;
}

@Riverpod(keepAlive: true)
GeckoEventService eventService(Ref ref) {
  final service = GeckoEventService.setUp();

  ref.onDispose(() async {
    await service.dispose();
  });

  return service;
}

@Riverpod(keepAlive: true)
GeckoAddonService addonService(Ref ref) {
  final service = GeckoAddonService.setUp();

  ref.onDispose(() async {
    await service.dispose();
  });

  return service;
}

@Riverpod(keepAlive: true)
GeckoTabContentService tabContentService(Ref ref) {
  final service = GeckoTabContentService.setUp();

  ref.onDispose(() async {
    await service.dispose();
  });

  return service;
}

@Riverpod(keepAlive: true)
GeckoSuggestionsService engineSuggestionsService(Ref ref) {
  final service = GeckoSuggestionsService.setUp();

  ref.onDispose(() async {
    await service.dispose();
  });

  return service;
}

@Riverpod(keepAlive: true)
GeckoViewportService viewportService(Ref ref) {
  final service = GeckoViewportService();
  service.setUp();

  ref.onDispose(() async {
    await service.dispose();
  });

  return service;
}

@Riverpod(keepAlive: true)
class EngineReadyState extends _$EngineReadyState {
  @override
  bool build() {
    final eventService = ref.watch(eventServiceProvider);

    final currentState =
        eventService.engineReadyStateEvents.valueOrNull ?? false;

    if (!currentState) {
      unawaited(
        eventService.engineReadyStateEvents
            .firstWhere((value) => value == true)
            .timeout(
              const Duration(seconds: 3),
              onTimeout: () {
                logger.w('Waiting for engine ready state timed out');
                return true;
              },
            )
            .whenComplete(() {
              if (ref.mounted) {
                state = true;
              }
            }),
      );
    }

    final sub = eventService.engineReadyStateEvents.listen((value) {
      if (ref.mounted) {
        state = value;
      }
    });

    ref.onDispose(() async {
      await sub.cancel();
    });

    return currentState;
  }
}

/// Stream of ML model progress events
@Riverpod(keepAlive: true)
Stream<MlProgressData> mlProgressEvents(Ref ref) {
  final service = ref.watch(eventServiceProvider);
  return service.mlProgressEvents;
}

/// Tracks active ML model downloads
@Riverpod()
class MlDownloadState extends _$MlDownloadState {
  Timer? _clearTimer;

  @override
  MlProgressData? build() {
    ref.listen(mlProgressEventsProvider, (previous, next) {
      next.whenData((progress) {
        if (!ref.mounted) return;

        if (progress.type == MlProgressType.downloading) {
          if (progress.status == MlProgressStatus.done) {
            // Keep showing for 2 seconds after completion
            _clearTimer?.cancel();
            _clearTimer = Timer(const Duration(seconds: 2), () {
              if (ref.mounted && state != null && state!.id == progress.id) {
                state = null;
              }
            });
          } else {
            state = progress;
          }
        }
      });
    });

    ref.onDispose(() {
      _clearTimer?.cancel();
      _clearTimer = null;
    });

    return null;
  }

  void clear() {
    _clearTimer?.cancel();
    _clearTimer = null;
    state = null;
  }
}
