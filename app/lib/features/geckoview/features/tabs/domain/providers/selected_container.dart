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

import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:riverpod/experimental/persist.dart';
import 'package:riverpod_annotation/experimental/persist.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/features/geckoview/domain/providers/selected_tab.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_state.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/entities/container_filter.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/models/container_data.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/providers.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/providers.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/repositories/container.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/repositories/tab.dart';
import 'package:weblibre/features/user/data/providers.dart';

part 'selected_container.g.dart';

enum SetContainerResult { failed, success, successHasProxy }

@Riverpod(keepAlive: true)
class SelectedContainer extends _$SelectedContainer {
  Future<ContainerData?> fetchData() async {
    if (state != null) {
      return await ref
          .read(containerRepositoryProvider.notifier)
          .getContainerData(state!);
    }

    return null;
  }

  Future<SetContainerResult> setContainerId(String id) async {
    final container = await ref
        .read(containerRepositoryProvider.notifier)
        .getContainerData(id);

    if (ref.mounted && container != null) {
      if (container.metadata.useProxy) {
        final proxyPluginHealthy = await GeckoContainerProxyService()
            .healthcheck();

        if (proxyPluginHealthy) {
          state = id;
          return SetContainerResult.successHasProxy;
        }
      } else {
        state = id;
        return SetContainerResult.success;
      }
    }

    return SetContainerResult.failed;
  }

  void clearContainer() {
    state = null;
  }

  @override
  String? build() {
    final persistCompleter = Completer();

    final persistResult = persist(
      ref.watch(riverpodDatabaseStorageProvider),
      key: 'SelectedContainer',
      encode: (state) => jsonEncode([state]),
      decode: (encoded) =>
          (jsonDecode(encoded) as List<dynamic>).first as String?,
    );

    unawaited(
      (persistResult.future ?? Future.value()).whenComplete(
        () => persistCompleter.complete(),
      ),
    );

    ref.listen(
      fireImmediately: true,
      watchContainersWithCountProvider,
      (previous, next) {
        if (stateOrNull != null && next.value != null) {
          if (!next.value!.any((container) => container.id == state)) {
            clearContainer();
          }
        }
      },
      onError: (error, stackTrace) {
        logger.e(
          'Error listening to containersWithCountProvider',
          error: error,
          stackTrace: stackTrace,
        );
      },
    );

    ref.listen(
      fireImmediately: true,
      selectedTabProvider,
      (previous, next) async {
        if (next != null) {
          if (!persistCompleter.isCompleted) {
            await persistCompleter.future;
          }

          final tabData = await ref
              .read(tabDataRepositoryProvider.notifier)
              .getTabDataById(next);

          if (ref.mounted &&
              tabData != null &&
              tabData.containerId != stateOrNull) {
            if (tabData.containerId != null) {
              await setContainerId(tabData.containerId!);
            } else {
              clearContainer();
            }
          }
        }
      },
      onError: (error, stackTrace) {
        logger.e(
          'Error listening to selectedTabProvider',
          error: error,
          stackTrace: stackTrace,
        );
      },
    );

    return stateOrNull;
  }
}

@Riverpod()
Stream<ContainerData?> selectedContainerData(Ref ref) {
  final db = ref.watch(tabDatabaseProvider);
  final selectedContainer = ref.watch(selectedContainerProvider);

  if (selectedContainer != null) {
    return db.containerDao
        .getContainerData(selectedContainer)
        .watchSingleOrNull();
  }

  return Stream.value(null);
}

/// Whether the browser home screen should be displayed instead of the
/// active tab's content.
///
/// Returns `true` when any of the following hold:
/// 1. No tab is selected at all (app just started or all tabs closed).
/// 2. The selected tab belongs to a different container than the currently
///    selected container – this implies the user manually switched
///    containers after selecting a tab, because tab selection automatically
///    syncs the selected container to match the tab's container.
///
/// Condition (2) also implicitly covers the case where the selected
/// container has zero tabs: if the container has no tabs, the selected tab
/// (if any) necessarily belongs to a different container.
@Riverpod()
bool shouldShowBrowserHome(Ref ref) {
  final selectedTab = ref.watch(selectedTabProvider);

  // No tab selected → always show home.
  if (selectedTab == null) return true;

  final selectedContainer = ref.watch(selectedContainerProvider);
  final tabContainerId = ref.watch(selectedTabContainerIdProvider);

  // Once we know the tab's container, compare with the selected container.
  return switch (tabContainerId) {
    AsyncData(:final value) => value != selectedContainer,
    // While loading, keep the current view to avoid flashing.
    _ => false,
  };
}

@Riverpod()
Future<int> selectedContainerTabCount(Ref ref) async {
  final selectedContainer = ref.watch(selectedContainerProvider);

  return ref.watch(
    watchContainerTabIdsProvider(
      // ignore: provider_parameters
      ContainerFilterById(containerId: selectedContainer),
    ).selectAsync((tabs) => tabs.length),
  );
}
