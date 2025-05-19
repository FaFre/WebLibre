import 'package:fast_equatable/fast_equatable.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/features/geckoview/domain/providers.dart';

part 'tab_list.g.dart';

@Riverpod(keepAlive: true)
class TabList extends _$TabList {
  @override
  EquatableValue<List<String>> build() {
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
      final equatableTabs = EquatableValue(tabs);

      if (equatableTabs != state) {
        state = equatableTabs;
      }
    });

    ref.onDispose(() async {
      await tabListSub.cancel();
    });

    return EquatableValue([]);
  }
}
