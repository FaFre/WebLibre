import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'overlay.g.dart';

@Riverpod()
class OverlayController extends _$OverlayController {
  @override
  Widget? build() {
    return null;
  }

  // ignore: use_setters_to_change_properties api decision
  void show(Widget dialog) {
    state = dialog;
  }

  void dismiss() {
    state = null;
  }
}
