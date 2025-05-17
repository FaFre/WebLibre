import 'package:lensai/features/geckoview/domain/providers/selected_tab.dart';
import 'package:lensai/features/geckoview/domain/providers/tab_state.dart';
import 'package:lensai/features/geckoview/features/find_in_page/domain/entities/find_in_page_state.dart';
import 'package:lensai/features/geckoview/features/find_in_page/domain/repositories/find_in_page.dart';
import 'package:nullability/nullability.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'find_in_page.g.dart';

@Riverpod()
class FindInPageController extends _$FindInPageController {
  void show() {
    state = state.copyWith.visible(true);
  }

  Future<void> hide() async {
    await clearMatches();
    state = FindInPageState.hidden();
  }

  Future<void> findAll({required String text}) {
    final tabId = ref.read(selectedTabProvider);
    final service = ref.read(findInPageRepositoryProvider(tabId).notifier);

    state = FindInPageState(visible: true, lastSearchText: text);

    return service.findAll(text);
  }

  Future<void> findNext({bool forward = true}) {
    final tabId = ref.read(selectedTabProvider);
    final service = ref.read(findInPageRepositoryProvider(tabId).notifier);

    state = state.copyWith.visible(true);

    return service.findNext(forward);
  }

  Future<void> clearMatches() {
    final tabId = ref.read(selectedTabProvider);
    final service = ref.read(findInPageRepositoryProvider(tabId).notifier);

    return service.clearMatches();
  }

  @override
  FindInPageState build() {
    ref.listen(selectedTabStateProvider, (previous, next) async {
      if (state.visible && state.lastSearchText.isNotEmpty) {
        if (previous != null && next != null) {
          final loadingOrReloading =
              previous.isLoading == true && next.isLoading == false;
          final tabSwitchWithoutResults =
              previous.id != next.id && !next.findResultState.hasMatches;

          if (loadingOrReloading || tabSwitchWithoutResults) {
            await findAll(text: state.lastSearchText!);
          }
        }
      }
    });

    return FindInPageState.hidden();
  }
}
