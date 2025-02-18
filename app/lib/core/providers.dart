import 'package:go_router/go_router.dart';
import 'package:lensai/core/routing/routes.dart';
import 'package:lensai/data/models/drag_data.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'providers.g.dart';

@Riverpod(keepAlive: true)
GoRouter router(Ref ref) {
  return GoRouter(debugLogDiagnostics: true, routes: $appRoutes);
}

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
