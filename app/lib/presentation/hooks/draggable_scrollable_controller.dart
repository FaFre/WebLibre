import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

DraggableScrollableController useDraggableScrollableController() {
  return use(const _DraggableScrollableControllerHook());
}

class _DraggableScrollableControllerHook
    extends Hook<DraggableScrollableController> {
  const _DraggableScrollableControllerHook();

  @override
  HookState<DraggableScrollableController, Hook<DraggableScrollableController>>
      createState() {
    return _DraggableScrollableControllerHookState();
  }
}

class _DraggableScrollableControllerHookState extends HookState<
    DraggableScrollableController, _DraggableScrollableControllerHook> {
  late final _controller = DraggableScrollableController();

  @override
  DraggableScrollableController build(BuildContext context) => _controller;

  @override
  void dispose() => _controller.dispose();

  @override
  String get debugLabel => 'useDraggableScrollableController';
}
