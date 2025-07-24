import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'tab_suggestions.g.dart';

@Riverpod(keepAlive: true)
class TabSuggestionsController extends _$TabSuggestionsController {
  void toggle() {
    state = !state;
  }

  void hide() {
    if (state) {
      state = false;
    }
  }

  @override
  bool build() {
    return false;
  }
}
