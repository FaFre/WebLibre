import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:lensai/features/geckoview/domain/providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'selected_tab.g.dart';

@Riverpod(keepAlive: true)
class SelectedTab extends _$SelectedTab {
  @override
  String? build() {
    final eventSerivce = ref.watch(eventServiceProvider);

    ref.listen(fireImmediately: true, engineReadyStateProvider, (
      previous,
      next,
    ) async {
      if (next) {
        await GeckoTabService().syncEvents(onSelectedTabChange: true);
      }
    });

    final selectedTabSub = eventSerivce.selectedTabEvents.listen((tabId) {
      state = tabId;
    });

    ref.onDispose(() async {
      await selectedTabSub.cancel();
    });

    return null;
  }
}
