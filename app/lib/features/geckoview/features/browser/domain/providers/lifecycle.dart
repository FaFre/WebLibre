import 'dart:ui';

import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'lifecycle.g.dart';

@Riverpod(keepAlive: true)
class BrowserViewLifecycle extends _$BrowserViewLifecycle {
  // ignore: use_setters_to_change_properties
  void update(AppLifecycleState? newState) {
    state = newState;
  }

  @override
  AppLifecycleState? build() {
    return null;
  }
}
