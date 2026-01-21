/*
 * Copyright (c) 2024-2025 Fabian Freund.
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
import 'package:nullability/nullability.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rxdart/rxdart.dart';
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/features/geckoview/domain/entities/states/find_result.dart';
import 'package:weblibre/features/geckoview/domain/entities/states/history.dart';
import 'package:weblibre/features/geckoview/domain/entities/states/readerable.dart';
import 'package:weblibre/features/geckoview/domain/entities/states/security.dart';
import 'package:weblibre/features/geckoview/domain/entities/states/tab.dart';
import 'package:weblibre/features/geckoview/domain/providers.dart';
import 'package:weblibre/features/geckoview/domain/providers/selected_tab.dart';
import 'package:weblibre/features/geckoview/features/find_in_page/domain/repositories/find_in_page.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/providers.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/repositories/gecko_inference.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/repositories/tab.dart';
import 'package:weblibre/features/geckoview/utils/image_helper.dart';
import 'package:weblibre/features/user/data/models/tor_settings.dart';
import 'package:weblibre/features/user/domain/repositories/tor_settings.dart';

part 'tab_state.g.dart';

@Riverpod(keepAlive: true)
class TabStates extends _$TabStates {
  /// Disposes images from a TabState to free GPU memory.
  void _disposeTabImages(TabState tab) {
    tab.icon?.dispose();
    tab.thumbnail?.dispose();
  }

  /// Updates state while disposing images from removed tabs.
  void _updateState(Map<String, TabState> newState) {
    // Find and dispose images from tabs that are being removed
    for (final tabId in state.keys) {
      if (!newState.containsKey(tabId)) {
        _disposeTabImages(state[tabId]!);
      }
    }

    state = newState;
  }

  Future<void> _onTabContentStateChange(TabContentState contentState) async {
    final current = await patchedState(contentState.id);

    final url = Uri.parse(contentState.url);

    // Determine title based on priority: new non-empty title > existing title if URL authority unchanged > new title
    final String resolvedTitle;
    if (contentState.title.isNotEmpty) {
      resolvedTitle = contentState.title;
    } else if (current.url.authority == url.authority) {
      resolvedTitle = current.title;
    } else {
      resolvedTitle = contentState.title;
    }

    final newState = current.copyWith(
      parentId: contentState.parentId,
      contextId: contentState.contextId,
      url: url,
      title: resolvedTitle,
      progress: contentState.progress,
      isPrivate: contentState.isPrivate,
      isFullScreen: contentState.isFullScreen,
      isLoading: contentState.isLoading,
    );

    _updateState({...state}..[contentState.id] = newState);

    if (newState.isFinishedLoading) {
      ref
          .read(geckoInferenceRepositoryProvider.notifier)
          .markInitialLoadComplete();
    }
  }

  Future<TabState> patchedState(String id) async {
    var current = stateOrNull?[id];

    if (current == null || current.url == TabState.defaultUrl) {
      current ??= TabState.$default(id);

      final tabData = await ref
          .read(tabDataRepositoryProvider.notifier)
          .getTabDataById(id);

      if (tabData?.url != null) {
        current = current.copyWith(
          title: tabData!.title ?? current.title,
          url: tabData.url ?? current.url,
        );
      }
    }

    return current;
  }

  Future<void> _onIconChange(IconChangeEvent event) async {
    final IconChangeEvent(:tabId, :bytes) = event;

    final image = await bytes.mapNotNull((bytes) => tryDecodeImage(bytes));
    final current = state[tabId] ?? TabState.$default(tabId);

    // Dispose old icon only after successfully creating new one
    current.icon?.dispose();

    state = {...state}..[tabId] = current.copyWith.icon(image);
  }

  Future<void> _onThumbnailChange(ThumbnailEvent event) async {
    final ThumbnailEvent(:tabId, :bytes) = event;

    final image = await bytes.mapNotNull((bytes) => tryDecodeImage(bytes));
    final current = state[tabId] ?? TabState.$default(tabId);

    // Dispose old thumbnail only after successfully creating new one
    current.thumbnail?.dispose();

    state = {...state}..[tabId] = current.copyWith.thumbnail(image);
  }

  void _onSecurityInfoStateChange(SecurityInfoEvent event) {
    final SecurityInfoEvent(:tabId, :securityInfo) = event;

    final current = state[tabId] ?? TabState.$default(tabId);
    state = {...state}
      ..[tabId] = current.copyWith.securityInfoState(
        SecurityState(
          secure: securityInfo.secure,
          host: securityInfo.host,
          issuer: securityInfo.issuer,
        ),
      );
  }

  void _onHistoryStateChange(HistoryEvent event) {
    final HistoryEvent(:tabId, :history) = event;

    final current = state[tabId] ?? TabState.$default(tabId);
    state = {...state}
      ..[tabId] = current.copyWith.historyState(
        HistoryState(
          items: history.items.nonNulls
              .map(
                (item) =>
                    HistoryItem(url: Uri.parse(item.url), title: item.title),
              )
              .toList(),
          currentIndex: history.currentIndex,
          canGoBack: history.canGoBack,
          canGoForward: history.canGoForward,
        ),
      );
  }

  void _onReaderableStateChange(ReaderableEvent event) {
    final ReaderableEvent(:tabId, :readerable) = event;

    final current = state[tabId] ?? TabState.$default(tabId);
    state = {...state}
      ..[tabId] = current.copyWith.readerableState(
        ReaderableState(
          readerable: readerable.readerable,
          active: readerable.active,
        ),
      );
  }

  void _onFindResultsChange(FindResultsEvent event) {
    final FindResultsEvent(:tabId, :results) = event;
    final current = state[tabId] ?? TabState.$default(tabId);

    if (results.isNotEmpty) {
      final result = results.last;

      state = {...state}
        ..[tabId] = current.copyWith.findResultState(
          FindResultState(
            lastSearchText: ref.read(findInPageRepositoryProvider(tabId)),
            activeMatchOrdinal: result.activeMatchOrdinal,
            numberOfMatches: result.numberOfMatches,
            isDoneCounting: result.isDoneCounting,
          ),
        );
    } else if (current.findResultState.hasMatches) {
      state = {
        ...state,
      }..[tabId] = current.copyWith.findResultState(FindResultState.$default());
    }
  }

  @override
  Map<String, TabState> build() {
    final eventService = ref.watch(eventServiceProvider);

    final subscriptions = [
      eventService.tabContentEvents.listen(
        (event) async {
          await _onTabContentStateChange(event);
        },
        onError: (Object error, StackTrace stackTrace) {
          logger.e(
            'Error in tab content events',
            error: error,
            stackTrace: stackTrace,
          );
        },
      ),
      eventService.iconChangeEvents.listen(
        (event) async {
          await _onIconChange(event);
        },
        onError: (Object error, StackTrace stackTrace) {
          logger.e(
            'Error in icon change events',
            error: error,
            stackTrace: stackTrace,
          );
        },
      ),
      eventService.thumbnailEvents.listen(
        (event) async {
          await _onThumbnailChange(event);
        },
        onError: (Object error, StackTrace stackTrace) {
          logger.e(
            'Error in thumbnail events',
            error: error,
            stackTrace: stackTrace,
          );
        },
      ),
      eventService.securityInfoEvents.listen(
        (event) {
          _onSecurityInfoStateChange(event);
        },
        onError: (Object error, StackTrace stackTrace) {
          logger.e(
            'Error in security info events',
            error: error,
            stackTrace: stackTrace,
          );
        },
      ),
      eventService.historyEvents.listen(
        (event) {
          _onHistoryStateChange(event);
        },
        onError: (Object error, StackTrace stackTrace) {
          logger.e(
            'Error in history events',
            error: error,
            stackTrace: stackTrace,
          );
        },
      ),
      eventService.readerableEvents.listen(
        (event) {
          _onReaderableStateChange(event);
        },
        onError: (Object error, StackTrace stackTrace) {
          logger.e(
            'Error in readerable events',
            error: error,
            stackTrace: stackTrace,
          );
        },
      ),
      eventService.findResultsEvent
          .debounceTime(const Duration(milliseconds: 25))
          .listen(
            (event) {
              _onFindResultsChange(event);
            },
            onError: (Object error, StackTrace stackTrace) {
              logger.e(
                'Error in find results events',
                error: error,
                stackTrace: stackTrace,
              );
            },
          ),
    ];

    ref.listen(
      fireImmediately: true,
      engineReadyStateProvider,
      (previous, next) async {
        if (next) {
          await GeckoTabService().syncEvents(
            onTabContentStateChange: true,
            onIconChange: true,
            onThumbnailChange: true,
            onSecurityInfoStateChange: true,
            onHistoryStateChange: true,
            onFindResults: true,
          );
        }
      },
      onError: (error, stackTrace) {
        logger.e(
          'Error listening to engineReadyStateProvider',
          error: error,
          stackTrace: stackTrace,
        );
      },
    );

    ref.onDispose(() async {
      // Dispose all images from all tabs
      for (final tab in state.values) {
        _disposeTabImages(tab);
      }

      // Cancel all stream subscriptions
      for (final sub in subscriptions) {
        await sub.cancel();
      }
    });

    return {};
  }
}

@Riverpod()
TabState? tabState(Ref ref, String? tabId) {
  if (tabId == null) {
    return null;
  }

  return ref.watch(tabStatesProvider.select((tabs) => tabs[tabId]));
}

@Riverpod()
Future<TabState> tabStateWithFallback(Ref ref, String tabId) async {
  final state = ref.watch(tabStateProvider(tabId));

  if (state != null) {
    return state;
  }

  return await ref.read(tabStatesProvider.notifier).patchedState(tabId);
}

@Riverpod()
Future<bool> isTabTunneled(Ref ref, String? tabId) async {
  final tabState = ref.watch(tabStateProvider(tabId));
  final torSettings = ref.watch(torSettingsWithDefaultsProvider);

  if (tabState != null) {
    if (tabState.isPrivate) {
      return torSettings.proxyPrivateTabsTor;
    } else {
      switch (torSettings.proxyRegularTabsMode) {
        case TorRegularTabProxyMode.container:
          final containerData = await ref
              .read(tabDataRepositoryProvider.notifier)
              .getTabContainerData(tabState.id);

          if (!ref.mounted) return false;

          return containerData?.metadata.useProxy ?? false;
        case TorRegularTabProxyMode.all:
          return true;
      }
    }
  }

  return false;
}

@Riverpod()
TabState? selectedTabState(Ref ref) {
  final tabId = ref.watch(selectedTabProvider);
  return ref.watch(tabStateProvider(tabId));
}

@Riverpod()
TabType? selectedTabType(Ref ref) {
  final isPrivate = ref.watch(
    selectedTabStateProvider.select((value) => value?.isPrivate),
  );

  return isPrivate.mapNotNull(
    (isCurrentPrivate) => isCurrentPrivate ? TabType.private : TabType.regular,
  );
}

@Riverpod()
AsyncValue<String?> selectedTabContainerId(Ref ref) {
  final tabId = ref.watch(selectedTabProvider);
  if (tabId != null) {
    return ref.watch(watchContainerTabIdProvider(tabId));
  }

  return const AsyncData(null);
}

// @Riverpod()
// Stream<int> tabScrollY(Ref ref, String? tabId, Duration sampleTime) {
//   final eventService = ref.watch(eventServiceProvider);

//   return eventService.scrollEvent
//       .where((event) => event.tabId == tabId)
//       .sampleTime(sampleTime)
//       .map((event) => event.scrollY)
//       .asBroadcastStream();
// }
