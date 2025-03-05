import 'dart:async';

import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:lensai/extensions/nullable.dart';
import 'package:lensai/features/geckoview/domain/entities/states/find_result.dart';
import 'package:lensai/features/geckoview/domain/entities/states/history.dart';
import 'package:lensai/features/geckoview/domain/entities/states/readerable.dart';
import 'package:lensai/features/geckoview/domain/entities/states/security.dart';
import 'package:lensai/features/geckoview/domain/entities/states/tab.dart';
import 'package:lensai/features/geckoview/domain/providers.dart';
import 'package:lensai/features/geckoview/domain/providers/selected_tab.dart';
import 'package:lensai/features/geckoview/utils/image_helper.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'tab_state.g.dart';

@Riverpod(keepAlive: true)
class TabStates extends _$TabStates {
  void _onTabContentStateChange(TabContentState contentState) {
    final current =
        state[contentState.id] ?? TabState.$default(contentState.id);
    state = {...state}
      ..[contentState.id] = current.copyWith(
        contextId: contentState.contextId,
        url: Uri.parse(contentState.url),
        title:
            (contentState.title.isNotEmpty)
                ? contentState.title
                : current.title,
        progress: contentState.progress,
        isPrivate: contentState.isPrivate,
        isFullScreen: contentState.isFullScreen,
        isLoading: contentState.isLoading,
      );
  }

  Future<void> _onIconChange(IconChangeEvent event) async {
    final IconChangeEvent(:tabId, :bytes) = event;

    final image = await bytes.mapNotNull((bytes) => tryDecodeImage(bytes));

    final current = state[tabId] ?? TabState.$default(tabId);
    state = {...state}..[tabId] = current.copyWith.icon(image);
  }

  Future<void> _onThumbnailChange(ThumbnailEvent event) async {
    final ThumbnailEvent(:tabId, :bytes) = event;

    final image = await bytes.mapNotNull((bytes) => tryDecodeImage(bytes));

    final current = state[tabId] ?? TabState.$default(tabId);
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
          items:
              history.items.nonNulls
                  .map(
                    (item) => HistoryItem(
                      url: Uri.parse(item.url),
                      title: item.title,
                    ),
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

    if (results.isNotEmpty) {
      final result = results.last;

      final current = state[tabId] ?? TabState.$default(tabId);
      state = {...state}
        ..[tabId] = current.copyWith.findResultState(
          FindResultState(
            activeMatchOrdinal: result.activeMatchOrdinal,
            numberOfMatches: result.numberOfMatches,
            isDoneCounting: result.isDoneCounting,
          ),
        );
    }
  }

  @override
  Map<String, TabState> build() {
    final eventService = ref.watch(eventServiceProvider);

    final subscriptions = [
      eventService.tabContentEvents.listen((event) {
        _onTabContentStateChange(event);
      }),
      eventService.iconChangeEvents.listen((event) async {
        await _onIconChange(event);
      }),
      eventService.thumbnailEvents.listen((event) async {
        await _onThumbnailChange(event);
      }),
      eventService.securityInfoEvents.listen((event) {
        _onSecurityInfoStateChange(event);
      }),
      eventService.historyEvents.listen((event) {
        _onHistoryStateChange(event);
      }),
      eventService.readerableEvents.listen((event) {
        _onReaderableStateChange(event);
      }),
      eventService.findResultsEvent.listen((event) {
        _onFindResultsChange(event);
      }),
    ];

    ref.listen(fireImmediately: true, engineReadyStateProvider, (
      previous,
      next,
    ) async {
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
    });

    ref.onDispose(() async {
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
TabState? selectedTabState(Ref ref) {
  final tabId = ref.watch(selectedTabProvider);
  return ref.watch(tabStateProvider(tabId));
}
