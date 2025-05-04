import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:lensai/extensions/nullable.dart';
import 'package:lensai/features/geckoview/domain/providers/selected_tab.dart';
import 'package:lensai/features/geckoview/domain/providers/tab_state.dart';
import 'package:lensai/features/geckoview/features/find_in_page/presentation/domain/entities/find_in_page_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'find_in_page.g.dart';

@Riverpod()
class FindInPageController extends _$FindInPageController {
  void show() {
    state = state.copyWith.visible(true);
  }

  void hide() {
    state = FindInPageState.hidden();
  }

  Future<void> findAll({required String text}) {
    final service = GeckoFindInPageService(
      tabId: ref.read(selectedTabProvider),
    );

    state = FindInPageState(visible: true, searchText: text);

    return service.findAll(text);
  }

  Future<void> findNext({bool forward = true}) {
    final service = GeckoFindInPageService(
      tabId: ref.read(selectedTabProvider),
    );

    state = state.copyWith.visible(true);

    return service.findNext(forward);
  }

  Future<void> clearMatches() {
    final service = GeckoFindInPageService(
      tabId: ref.read(selectedTabProvider),
    );

    return service.clearMatches();
  }

  @override
  FindInPageState build() {
    ref.listen(selectedTabStateProvider, (previous, next) async {
      if (state.visible && state.searchText.isNotEmpty) {
        if (previous != null) {
          final loadingOrReloading =
              previous.isLoading == true && next?.isLoading == false;
          final tabSwitch = previous.id != next?.id;

          if (loadingOrReloading || tabSwitch) {
            await clearMatches();
            await findAll(text: state.searchText!);
          }
        }
      }
    });

    return FindInPageState.hidden();
  }
}
