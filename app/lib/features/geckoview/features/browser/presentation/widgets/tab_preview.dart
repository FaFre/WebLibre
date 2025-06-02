import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nullability/nullability.dart';
import 'package:weblibre/features/geckoview/domain/entities/states/tab.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_state.dart';
import 'package:weblibre/features/geckoview/domain/repositories/tab.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/tab_icon.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/repositories/tab.dart';
import 'package:weblibre/presentation/hooks/menu_controller.dart';

class TabPreview extends HookWidget {
  final TabState tab;
  final bool isActive;

  final VoidCallback? onTap;
  final VoidCallback? onDoubleTap;
  final VoidCallback? onDelete;
  final void Function(String host)? onDeleteAll;

  const TabPreview({
    required this.tab,
    required this.isActive,
    this.onTap,
    this.onDoubleTap,
    this.onDelete,
    this.onDeleteAll,
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final extendedDeleteMenuController = useMenuController();

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: isActive ? colorScheme.primary : colorScheme.outline,
          width: isActive ? 2.0 : 1.0,
        ),
        borderRadius: const BorderRadius.all(Radius.circular(16.0)),
      ),
      child: Material(
        color:
            tab.isPrivate
                ? const Color(0xFF25003E)
                : colorScheme.surfaceContainerHighest,
        borderRadius: const BorderRadius.all(Radius.circular(14.0)),
        child: InkWell(
          borderRadius: const BorderRadius.all(Radius.circular(14.0)),
          onTap: onTap,
          onDoubleTap: onDoubleTap,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 6.0, top: 2.0),
                      child: Text(
                        overflow: TextOverflow.ellipsis,
                        tab.title,
                        maxLines: 2,
                        style:
                            tab.isPrivate
                                ? const TextStyle(color: Colors.white)
                                : null,
                      ),
                    ),
                  ),
                  MenuAnchor(
                    controller: extendedDeleteMenuController,
                    builder: (context, controller, child) {
                      return child!;
                    },
                    menuChildren: [
                      MenuItemButton(
                        onPressed: onDeleteAll.mapNotNull(
                          (p0) => () {
                            p0(tab.url.host);
                          },
                        ),
                        leadingIcon: const Icon(MdiIcons.closeBoxMultiple),
                        child: Text('Close all from ${tab.url.host}'),
                      ),
                    ],
                    child: IconButton(
                      visualDensity: const VisualDensity(
                        horizontal: -4.0,
                        vertical: -4.0,
                      ),
                      onPressed: onDelete,
                      onLongPress: () {
                        if (extendedDeleteMenuController.isOpen) {
                          extendedDeleteMenuController.close();
                        } else {
                          extendedDeleteMenuController.open();
                        }
                      },
                      icon: const Icon(Icons.close),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  const SizedBox(width: 6.0),
                  TabIcon(state: tab),
                  const SizedBox(width: 6.0),
                  Expanded(
                    child: Text(
                      tab.url.authority,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: tab.isPrivate ? Colors.white : null,
                      ),
                    ),
                  ),
                  if (tab.isPrivate) ...[
                    const SizedBox(width: 6.0),
                    const SizedBox(
                      height: 16,
                      width: 24,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Positioned(
                            top: -4,
                            child: Icon(
                              MdiIcons.dominoMask,
                              color: Color(0xFF8000D7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(width: 8.0),
                ],
              ),
              const SizedBox(height: 6),
              if (tab.thumbnail != null)
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(14.0),
                      bottomRight: Radius.circular(14.0),
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: RepaintBoundary(
                        child: RawImage(
                          image: tab.thumbnail!.value,
                          fit: BoxFit.fitWidth,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class TabPreviewDraggable extends HookConsumerWidget {
  final String tabId;
  final String? activeTabId;

  final void Function() onClose;

  TabPreviewDraggable({
    required this.tabId,
    required this.activeTabId,
    required this.onClose,
  }) : super(key: ValueKey(tabId));

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tab = ref.watch(tabStateProvider(tabId));

    if (tab == null) {
      return const SizedBox.shrink();
    }

    return TabPreview(
      tab: tab,
      isActive: tabId == activeTabId,
      onTap: () async {
        if (tabId != activeTabId) {
          //Close first to avoid rebuilds
          onClose();
          await ref.read(tabRepositoryProvider.notifier).selectTab(tab.id);
        } else {
          onClose();
        }
      },
      onDeleteAll: (host) async {
        final containerId = await ref
            .read(tabDataRepositoryProvider.notifier)
            .containerTabId(tab.id);

        await ref
            .read(tabDataRepositoryProvider.notifier)
            .closeAllTabsByHost(containerId, host);
      },
      // onDoubleTap: () {
      //   ref.read(overlayDialogControllerProvider.notifier).show(
      //         TabActionDialog(
      //           initialTab: tab,
      //           onDismiss:
      //               ref.read(overlayDialogControllerProvider.notifier).dismiss,
      //         ),
      //       );
      // },
      onDelete: () async {
        await ref.read(tabRepositoryProvider.notifier).closeTab(tab.id);
      },
    );
  }
}
