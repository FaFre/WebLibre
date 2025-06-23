import 'package:fast_equatable/fast_equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:graphview/GraphView.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:vector_math/vector_math_64.dart' show Vector3;
import 'package:weblibre/features/geckoview/domain/controllers/bottom_sheet.dart';
import 'package:weblibre/features/geckoview/domain/providers/selected_tab.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/tab_preview.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/providers.dart';

class TabTreeDialog extends HookConsumerWidget {
  final String tabId;
  final Size childSize;

  const TabTreeDialog(
    this.tabId, {
    super.key,
    this.childSize = const Size(200, 300),
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transforamtionController = useTransformationController();

    final builder = useMemoized(() {
      final config = BuchheimWalkerConfiguration()
        ..siblingSeparation = 100
        ..levelSeparation = 150
        ..subtreeSeparation = 150
        ..orientation = BuchheimWalkerConfiguration.ORIENTATION_TOP_BOTTOM;

      return BuchheimWalkerAlgorithm(config, TreeEdgeRenderer(config));
    });

    final selectedTabId = ref.watch(selectedTabProvider);
    final tabs = ref.watch(tabDescendantsProvider(tabId));

    final graph = useMemoized(() {
      final graph = Graph();
      graph.isTree = true;

      if (tabs.hasValue) {
        for (final MapEntry(:key, :value) in tabs.valueOrNull!.entries) {
          if (value != null) {
            final current = Node.Id(key);
            final parent = Node.Id(value);

            graph.addEdge(parent, current);
          }
        }
      }

      return graph;
    }, [EquatableValue(tabs.valueOrNull)]);

    return Dialog.fullscreen(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0x44000000),
          elevation: 0,
          leading: IconButton(
            onPressed: () {
              context.pop();
            },
            icon: const Icon(Icons.close),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          child: const Icon(MdiIcons.target),
          onPressed: () {
            final node = graph.getNodeUsingId(selectedTabId);
            final scale = transforamtionController.value.getMaxScaleOnAxis();
            final newPosition =
                (node.position -
                    Offset(childSize.width / 2, childSize.height / 2)) *
                scale;

            transforamtionController.value =
                transforamtionController.value.clone()..setTranslation(
                  Vector3(-newPosition.dx, -newPosition.dy, 0),
                );
          },
        ),
        extendBodyBehindAppBar: true,
        body: InteractiveViewer(
          transformationController: transforamtionController,
          constrained: false,
          boundaryMargin: const EdgeInsets.all(250),
          minScale: 0.1,
          maxScale: 5.0,
          child: Skeletonizer(
            enabled: !tabs.hasValue || tabs.valueOrNull?.isEmpty == true,
            child: Skeleton.replace(
              replacement: const Bone.square(),
              child: GraphView(
                graph: graph,
                algorithm: builder,
                paint: Paint()
                  ..color = Theme.of(context).colorScheme.outline
                  ..strokeWidth = 1
                  ..style = PaintingStyle.stroke,
                builder: (Node node) {
                  final id = node.key!.value as String;
                  return SizedBox.fromSize(
                    size: childSize,
                    child: SingleTabPreview(
                      tabId: id,
                      activeTabId: selectedTabId,
                      onClose: () {
                        context.pop();
                        ref
                            .read(bottomSheetControllerProvider.notifier)
                            .dismiss();
                      },
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
