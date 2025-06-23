import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'tree_view.g.dart';

@Riverpod(keepAlive: true)
class TreeViewController extends _$TreeViewController {
  void toggle() {
    state = !state;
  }

  @override
  bool build() {
    return false;
  }
}
