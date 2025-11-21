/*
 * Copyright (c) 2024-2025 Fabian Freund.
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
      generalSettingsWithDefaultsProvider.select(
        (value) => value.createChildTabsOption,
      ),
    );

    return MenuAnchor(
      controller: controller,
      builder: (context, controller, child) {
        return child!;
      },
      menuChildren: [
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
