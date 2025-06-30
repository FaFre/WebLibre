import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/features/geckoview/domain/providers.dart';

part 'selected_tab.g.dart';

@Riverpod(keepAlive: true)
class SelectedTab extends _$SelectedTab {
  @override
  String? build() {
    final eventSerivce = ref.watch(eventServiceProvider);

    ref.listen(
      fireImmediately: true,
      engineReadyStateProvider,
      (previous, next) async {
        if (next) {
          await GeckoTabService().syncEvents(onSelectedTabChange: true);
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

    final selectedTabSub = eventSerivce.selectedTabEvents.listen((tabId) {
      state = tabId;
    });

    ref.onDispose(() async {
      await selectedTabSub.cancel();
    });

    return null;
  }
}
