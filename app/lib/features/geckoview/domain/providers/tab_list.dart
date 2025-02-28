import 'dart:async';

import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:lensai/domain/entities/equatable_iterable.dart';
import 'package:lensai/features/geckoview/domain/providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'tab_list.g.dart';

@Riverpod(keepAlive: true)
class TabList extends _$TabList {
  @override
  EquatableCollection<List<String>> build() {
    final eventService = ref.watch(eventServiceProvider);

    ref.listen(fireImmediately: true, engineReadyStateProvider, (
      previous,
      next,
    ) async {
      if (next) {
        await GeckoTabService().syncEvents(onTabListChange: true);
      }
    });

    final tabListSub = eventService.tabListEvents.listen((tabs) {
      final equatableTabs = EquatableCollection(tabs, immutable: true);

      if (equatableTabs != state) {
        state = equatableTabs;
      }
    });

    ref.onDispose(() {
      unawaited(tabListSub.cancel());
    });

    return EquatableCollection([], immutable: true);
  }
}
