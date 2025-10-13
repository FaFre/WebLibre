import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_state.g.dart';

@Riverpod(keepAlive: true)
class AppStateKey extends _$AppStateKey {
  void reset() {
    state = GlobalKey(debugLabel: 'RootKey');
  }

  @override
  GlobalKey build() {
    return GlobalKey(debugLabel: 'RootKey');
  }
}
