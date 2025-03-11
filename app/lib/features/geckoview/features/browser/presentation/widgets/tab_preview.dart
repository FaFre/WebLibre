import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lensai/features/geckoview/domain/entities/states/tab.dart';
import 'package:lensai/features/geckoview/domain/providers/tab_state.dart';
import 'package:lensai/features/geckoview/domain/repositories/tab.dart';
import 'package:lensai/features/geckoview/features/browser/presentation/widgets/tab_icon.dart';

class TabPreview extends StatelessWidget {
  final TabState tab;
  final bool isActive;

  final VoidCallback? onTap;
  final VoidCallback? onDoubleTap;
  final VoidCallback? onDelete;

  const TabPreview({
    required this.tab,
    required this.isActive,
    this.onTap,
    this.onDoubleTap,
    this.onDelete,
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: isActive ? colorScheme.primary : colorScheme.outline,
          width: isActive ? 2.0 : 1.0,
        ),
        borderRadius: const BorderRadius.all(Radius.circular(16.0)),
      ),
      child: Material(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: const BorderRadius.all(Radius.circular(16.0)),
        child: InkWell(
          borderRadius: const BorderRadius.all(Radius.circular(16.0)),
          onTap: onTap,
          onDoubleTap: onDoubleTap,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 6.0),
                      child: Text(
                        overflow: TextOverflow.ellipsis,
                        tab.title,
                        maxLines: 2,
                      ),
                    ),
                  ),
                  IconButton(
                    visualDensity: const VisualDensity(
                      horizontal: -4.0,
                      vertical: -4.0,
                    ),
                    onPressed: onDelete,
                    icon: const Icon(Icons.close),
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
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              if (tab.thumbnail != null)
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(16.0),
                      bottomRight: Radius.circular(16.0),
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
