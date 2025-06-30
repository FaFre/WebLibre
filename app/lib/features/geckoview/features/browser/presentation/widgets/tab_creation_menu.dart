import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/features/geckoview/domain/repositories/tab.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';

class TabCreationMenu extends HookConsumerWidget {
  final Widget child;
  final MenuController controller;
  final String? selectedTabId;

  const TabCreationMenu({
    super.key,
    required this.child,
    required this.controller,
    required this.selectedTabId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final createChildTabsOption = ref.watch(
      generalSettingsRepositoryProvider.select(
        (value) => value.createChildTabsOption,
      ),
    );

    return MenuAnchor(
      controller: controller,
      builder: (context, controller, child) {
        return child!;
      },
      menuChildren: [
        if (selectedTabId != null) ...[
          MenuItemButton(
            onPressed: () async {
              await ref
                  .read(tabRepositoryProvider.notifier)
                  .closeTab(selectedTabId!);
            },
            leadingIcon: const Icon(Icons.close),
            child: const Text('Close Tab'),
          ),
          const Divider(),
        ],
        MenuItemButton(
          onPressed: () async {
            await const SearchRoute(tabType: TabType.regular).push(context);
          },
          leadingIcon: const Icon(MdiIcons.tabPlus),
          child: const Text('Add Regular Tab'),
        ),
        MenuItemButton(
          onPressed: () async {
            await const SearchRoute(tabType: TabType.private).push(context);
          },
          leadingIcon: const Icon(MdiIcons.tabUnselected),
          child: const Text('Add Private Tab'),
        ),
        if (createChildTabsOption)
          MenuItemButton(
            onPressed: () async {
              await const SearchRoute(tabType: TabType.child).push(context);
            },
            leadingIcon: const Icon(MdiIcons.fileTree),
            child: const Text('Add Child Tab'),
          ),
      ],
      child: child,
    );
  }
}
