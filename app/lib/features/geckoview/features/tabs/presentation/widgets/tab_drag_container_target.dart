import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/core/providers/global_drop.dart';
import 'package:weblibre/data/models/drag_data.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/models/container_data.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/repositories/tab.dart';

class TabDragContainerTarget extends HookConsumerWidget {
  final ContainerData? container;
  final Widget child;

  const TabDragContainerTarget({
    super.key,
    required this.container,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overlayController = useOverlayPortalController();

    return DragTarget<TabDragData>(
      onMove: (details) {
        ref
            .read(willAcceptDropProvider.notifier)
            .setData(ContainerDropData(details.data.tabId));

        overlayController.show();
      },
      onLeave: (data) {
        ref.read(willAcceptDropProvider.notifier).clear();

        overlayController.hide();
      },
      onAcceptWithDetails: (details) async {
        ref.read(willAcceptDropProvider.notifier).clear();
        overlayController.hide();

        if (container != null) {
          await ref
              .read(tabDataRepositoryProvider.notifier)
              .assignContainer(details.data.tabId, container!);
        } else {
          await ref
              .read(tabDataRepositoryProvider.notifier)
              .unassignContainer(details.data.tabId);
        }
      },
      builder: (context, candidateData, rejectedData) {
        final renderBox = context.findRenderObject() as RenderBox?;
        final position = renderBox?.localToGlobal(Offset.zero) ?? Offset.zero;

        return OverlayPortal(
          controller: overlayController,
          overlayChildBuilder: (context) => Positioned(
            top: position.dy,
            left: position.dx,
            child: IgnorePointer(
              child: Transform.scale(scale: 1.1, child: child),
            ),
          ),
          child: Consumer(
            child: child,
            builder: (context, ref, child) {
              final dragTabId = ref.watch(willAcceptDropProvider);

              return Opacity(
                opacity: (dragTabId == null) ? 1.0 : 0.0,
                child: child,
              );
            },
          ),
        );
      },
    );
  }
}
