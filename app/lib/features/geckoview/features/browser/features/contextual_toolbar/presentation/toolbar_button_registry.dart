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
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/features/geckoview/features/browser/features/contextual_toolbar/domain/entities/toolbar_button_spec.dart';
import 'package:weblibre/features/geckoview/features/browser/features/contextual_toolbar/presentation/models/contextual_toolbar_scope.dart';
import 'package:weblibre/features/geckoview/features/browser/features/contextual_toolbar/presentation/widgets/contextual_bar_buttons.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/navigation_buttons.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/tabs_action_button.dart';

class ToolbarButtonDefinition {
  final ToolbarButtonSpec spec;
  final String label;
  final IconData icon;
  final bool Function(ContextualToolbarScope scope, WidgetRef ref)?
  isPrimaryAvailable;
  final Widget Function(
    ContextualToolbarScope scope,
    BuildContext context,
    WidgetRef ref,
  )
  builder;

  const ToolbarButtonDefinition({
    required this.spec,
    required this.label,
    required this.icon,
    this.isPrimaryAvailable,
    required this.builder,
  });
}

final List<ToolbarButtonDefinition> toolbarButtonRegistry = [
  ToolbarButtonDefinition(
    spec: backToolbarButtonSpec,
    label: 'Back',
    icon: Icons.arrow_back,
    isPrimaryAvailable: (scope, ref) =>
        scope.tabState?.historyState.canGoBack == true ||
        scope.tabState?.isLoading == true,
    builder: (scope, context, ref) {
      if (scope.isPreview) {
        return NavigateBackButtonView(
          canGoBack: true,
          isLoading: false,
          onPressed: () {},
          onLongPress: () {},
        );
      }
      return NavigateBackButton(
        selectedTabId: scope.selectedTabId,
        isLoading: scope.tabState?.isLoading ?? false,
      );
    },
  ),
  ToolbarButtonDefinition(
    spec: forwardToolbarButtonSpec,
    label: 'Forward',
    icon: Icons.arrow_forward,
    isPrimaryAvailable: (scope, ref) =>
        scope.tabState?.historyState.canGoForward == true,
    builder: (scope, context, ref) {
      if (scope.isPreview) {
        return NavigateForwardButtonView(
          canGoForward: true,
          onPressed: () {},
          onLongPress: () {},
        );
      }
      return NavigateForwardButton(selectedTabId: scope.selectedTabId);
    },
  ),
  ToolbarButtonDefinition(
    spec: bookmarksToolbarButtonSpec,
    label: 'Bookmarks',
    icon: MdiIcons.bookmarkMultiple,
    builder: (scope, context, ref) {
      return IconButton(
        onPressed: scope.isPreview
            ? () {}
            : () async {
                await BookmarkListRoute(
                  entryGuid: BookmarkRoot.root.id,
                ).push(context);
              },
        icon: const Icon(MdiIcons.bookmarkMultiple),
      );
    },
  ),
  ToolbarButtonDefinition(
    spec: shareToolbarButtonSpec,
    label: 'Share',
    icon: Icons.share,
    builder: (scope, context, ref) => scope.isPreview
        ? ShareMenuButtonView(onPressed: () {})
        : ShareMenuButton(selectedTabId: scope.selectedTabId),
  ),
  ToolbarButtonDefinition(
    spec: addTabToolbarButtonSpec,
    label: 'New Tab',
    icon: MdiIcons.tabPlus,
    builder: (scope, context, ref) => scope.isPreview
        ? AddTabButtonView(onPressed: () {}, onLongPress: () {})
        : const AddTabButton(),
  ),
  ToolbarButtonDefinition(
    spec: tabsCountToolbarButtonSpec,
    label: 'Tabs',
    icon: MdiIcons.tab,
    builder: (scope, context, ref) => scope.isPreview
        ? TabsCountButtonView(
            isActive: false,
            onTap: () {},
            onLongPress: () {},
            buttonBuilder: (isActive, onTap, onLongPress) {
              return TabsActionButtonView(
                isActive: isActive,
                tabCountText: '5',
                onTap: onTap,
                onLongPress: onLongPress,
              );
            },
          )
        : TabsCountButton(
            selectedTabId: scope.selectedTabId,
            displayedSheet: scope.displayedSheet,
            showLongPressMenu: false,
          ),
  ),
  ToolbarButtonDefinition(
    spec: navigationMenuToolbarButtonSpec,
    label: 'Menu',
    icon: Icons.more_vert,
    builder: (scope, context, ref) => scope.isPreview
        ? NavigationMenuButtonView(onTap: () {})
        : NavigationMenuButton(selectedTabId: scope.selectedTabId),
  ),
];

final Map<String, ToolbarButtonDefinition> toolbarButtonRegistryById = {
  for (final def in toolbarButtonRegistry) def.spec.id.name: def,
};
