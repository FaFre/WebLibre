/*
 * Copyright (c) 2024-2026 Fabian Freund.
 *
 * This file is part of WebLibre
 * (see https://weblibre.eu).
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */
import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/features/geckoview/domain/controllers/bottom_sheet.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_state.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/entities/sheet.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/browser_menu_sheet.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/share_bottom_sheet.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/tab_creation_menu.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/tabs_action_button.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/toolbar_button.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/presentation/hooks/menu_controller.dart';

class ShareMenuButton extends StatelessWidget {
  final String? selectedTabId;

  const ShareMenuButton({super.key, required this.selectedTabId});

  @override
  Widget build(BuildContext context) {
    return ShareMenuButtonView(
      onPressed: () async {
        final tabId = selectedTabId;
        if (tabId != null) {
          await showShareBottomSheet(context, selectedTabId: tabId);
        }
      },
    );
  }
}

class ShareMenuButtonView extends StatelessWidget {
  const ShareMenuButtonView({super.key, this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(onPressed: onPressed, icon: const Icon(Icons.share));
  }
}

class NavigationMenuButton extends StatelessWidget {
  final String? selectedTabId;

  const NavigationMenuButton({super.key, required this.selectedTabId});

  @override
  Widget build(BuildContext context) {
    return NavigationMenuButtonView(
      onTap: () async {
        await showBrowserMenuSheet(context);
      },
    );
  }
}

class NavigationMenuButtonView extends StatelessWidget {
  const NavigationMenuButtonView({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ToolbarButton(onTap: onTap, child: const Icon(Icons.more_vert));
  }
}

class AddTabButton extends HookConsumerWidget {
  const AddTabButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabMenuController = useMenuController();

    return TabCreationMenu(
      controller: tabMenuController,
      child: AddTabButtonView(
        onPressed: () async {
          final settings = ref.read(generalSettingsWithDefaultsProvider);

          await SearchRoute(
            tabType:
                ref.read(selectedTabTypeProvider) ??
                settings.effectiveDefaultCreateTabType,
          ).push(context);

          if (context.mounted) {
            const BrowserRoute().go(context);
          }
        },
        onLongPress: () {
          if (tabMenuController.isOpen) {
            tabMenuController.close();
          } else {
            tabMenuController.open();
          }
        },
      ),
    );
  }
}

class AddTabButtonView extends StatelessWidget {
  const AddTabButtonView({super.key, this.onPressed, this.onLongPress});

  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: const Icon(MdiIcons.tabPlus),
      onLongPress: onLongPress,
    );
  }
}

class TabsCountButtonView extends StatelessWidget {
  const TabsCountButtonView({
    super.key,
    required this.isActive,
    required this.onTap,
    this.onLongPress,
    this.buttonBuilder,
  });

  final bool isActive;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final Widget Function(
    bool isActive,
    VoidCallback onTap,
    VoidCallback? onLongPress,
  )?
  buttonBuilder;

  @override
  Widget build(BuildContext context) {
    return (buttonBuilder != null)
        ? buttonBuilder!(isActive, onTap, onLongPress)
        : TabsActionButton(
            isActive: isActive,
            onTap: onTap,
            onLongPress: onLongPress,
          );
  }
}

class TabsCountButton extends HookConsumerWidget {
  const TabsCountButton({
    super.key,
    required this.selectedTabId,
    required this.displayedSheet,
    required this.showLongPressMenu,
  });

  final String? selectedTabId;
  final Sheet? displayedSheet;
  final bool showLongPressMenu;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabMenuController = useMenuController();

    return TabCreationMenu(
      controller: tabMenuController,
      child: TabsCountButtonView(
        isActive: displayedSheet is ViewTabsSheet,
        onTap: () async {
          final tabViewBottomSheet = ref
              .read(generalSettingsWithDefaultsProvider)
              .tabViewBottomSheet;

          if (tabViewBottomSheet) {
            if (displayedSheet case ViewTabsSheet()) {
              ref.read(bottomSheetControllerProvider.notifier).requestDismiss();
            } else {
              ref
                  .read(bottomSheetControllerProvider.notifier)
                  .show(ViewTabsSheet());
            }
          } else {
            await const TabViewRoute().push(context);
          }
        },
        onLongPress: showLongPressMenu
            ? () {
                if (tabMenuController.isOpen) {
                  tabMenuController.close();
                } else {
                  tabMenuController.open();
                }
              }
            : null,
      ),
    );
  }
}
