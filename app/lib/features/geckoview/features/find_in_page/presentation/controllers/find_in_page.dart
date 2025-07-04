import 'package:nullability/nullability.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_state.dart';
import 'package:weblibre/features/geckoview/features/find_in_page/domain/entities/find_in_page_state.dart';
import 'package:weblibre/features/geckoview/features/find_in_page/domain/repositories/find_in_page.dart';

part 'find_in_page.g.dart';

@Riverpod(keepAlive: true)
class FindInPageController extends _$FindInPageController {
  void show() {
    state = state.copyWith.visible(true);
  }

  Future<void> hide() async {
    await clearMatches();
    state = FindInPageState.hidden();
  }

  Future<void> findAll({required String text}) {
    final service = ref.read(findInPageRepositoryProvider(tabId).notifier);

    state = FindInPageState(visible: true, lastSearchText: text);

    return service.findAll(text);
  }

  Future<void> findNext({required String fallbackText, bool forward = true}) {
    final service = ref.read(findInPageRepositoryProvider(tabId).notifier);

    final hasMatches =
        ref.read(selectedTabStateProvider)?.findResultState.hasMatches == true;

    state = state.copyWith.visible(true);

    if (hasMatches) {
      return service.findNext(forward);
    } else {
      return service.findAll(fallbackText);
    }
  }

  Future<void> clearMatches() {
    final service = ref.read(findInPageRepositoryProvider(tabId).notifier);

    return service.clearMatches();
  }

  @override
  FindInPageState build(String tabId) {
    ref.listen(
      fireImmediately: true,
      tabStateProvider(tabId),
      (previous, next) async {
        //Ensure state is already initialized
        if (stateOrNull != null) {
          if (state.visible && state.lastSearchText.isNotEmpty) {
            if (previous != null && next != null) {
              final loadingOrReloading =
                  previous.isLoading == true && next.isLoading == false;

              if (loadingOrReloading) {
                await findAll(text: state.lastSearchText!);
              }
            }
          }
        }
      },
      onError: (error, stackTrace) {
        logger.e(
          'Error listening to selectedTabStateProvider',
          error: error,
          stackTrace: stackTrace,
        );
      },
    );

    return FindInPageState.hidden();
  }
}
