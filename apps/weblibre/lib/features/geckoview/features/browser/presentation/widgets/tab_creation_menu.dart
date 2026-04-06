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
import 'package:weblibre/core/design/app_colors.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';

class TabCreationMenu extends HookConsumerWidget {
  final Widget child;
  final MenuController controller;

  const TabCreationMenu({
    super.key,
    required this.child,
    required this.controller,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final createChildTabsOption = ref.watch(
      generalSettingsWithDefaultsProvider.select(
        (value) => value.createChildTabsOption,
      ),
    );
    final showIsolatedTabUi = ref.watch(
      generalSettingsWithDefaultsProvider.select(
        (value) => value.showIsolatedTabUi,
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
          leadingIcon: const Icon(MdiIcons.tab),
          child: const Text('Add Regular Tab'),
        ),
        if (createChildTabsOption)
          MenuItemButton(
            onPressed: () async {
              await const SearchRoute(tabType: TabType.child).push(context);
            },
            leadingIcon: const Icon(MdiIcons.fileTree),
            child: const Text('Add Child Tab'),
          ),
        MenuItemButton(
          onPressed: () async {
            await const SearchRoute(tabType: TabType.private).push(context);
          },
          leadingIcon: Icon(
            MdiIcons.dominoMask,
            color: AppColors.of(context).privateTabPurple,
          ),
          child: const Text('Add Private Tab'),
        ),
        if (showIsolatedTabUi)
          MenuItemButton(
            onPressed: () async {
              await const SearchRoute(tabType: TabType.isolated).push(context);
            },
            leadingIcon: Icon(
              MdiIcons.snowflake,
              color: AppColors.of(context).isolatedTabTeal,
            ),
            child: const Text('Add Isolated Tab'),
          ),
      ],
      child: child,
    );
  }
}
