import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'tab_bar_dismissable.g.dart';

@Riverpod()
class TabBarDismissableController extends _$TabBarDismissableController {
  void show() {
    state = false;
  }

  void dismiss() {
    if (!state) {
      state = true;
    }
  }

  @override
  bool build() {
    return false;
  }
}
