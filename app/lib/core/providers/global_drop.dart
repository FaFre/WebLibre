import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/data/models/drag_data.dart';

part 'global_drop.g.dart';

@Riverpod()
class WillAcceptDrop extends _$WillAcceptDrop {
  // ignore: use_setters_to_change_properties api decision
  void setData(DropTargetData data) {
    state = data;
  }

  void clear() {
    state = null;
  }

  @override
  DropTargetData? build() {
    return null;
  }
}
