import 'dart:math';

import 'package:flutter/material.dart';

class DraggableScrollableHeader extends StatelessWidget {
  final DraggableScrollableController controller;
  final Widget child;

  const DraggableScrollableHeader({
    super.key,
    required this.controller,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragUpdate: (details) {
        // Use the DraggableScrollableSheet's controller
        controller.jumpTo(
          min(1, controller.pixelsToSize(controller.pixels - details.delta.dy)),
        );
      },
      child: child,
    );
  }
}
