import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_list.dart';

class TabsActionButton extends HookConsumerWidget {
  final bool isActive;
  final VoidCallback? onTap;
  final VoidCallback? onDoubleTap;
  final VoidCallback? onLongPress;

  const TabsActionButton({
    this.onTap,
    this.onDoubleTap,
    this.onLongPress,
    this.isActive = false,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    final tabCount = ref.watch(
      tabListProvider.select((tabs) => tabs.value.length),
    );

    return InkWell(
      onTap: onTap,
      onDoubleTap: onDoubleTap,
      onLongPress: onLongPress,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 15.0),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              width: 2.0,
              color:
                  isActive
                      ? theme.colorScheme.primary
                      : DefaultTextStyle.of(context).style.color!,
            ),
            borderRadius: BorderRadius.circular(5.0),
          ),
          constraints: const BoxConstraints(minWidth: 25.0),
          child: Center(
            child: Text(
              tabCount.toString(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14.0,
                color: isActive ? theme.colorScheme.primary : null,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
