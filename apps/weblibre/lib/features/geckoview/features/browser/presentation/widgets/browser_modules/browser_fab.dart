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
import 'package:weblibre/features/geckoview/domain/entities/states/readerable.dart';
import 'package:weblibre/features/geckoview/domain/providers/selected_tab.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_state.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/controllers/toolbar_visibility.dart';
import 'package:weblibre/features/geckoview/features/readerview/domain/providers/readerable.dart';

class BrowserFab extends HookConsumerWidget {
  const BrowserFab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTabId = ref.watch(selectedTabProvider);
    final toolbarState = ref.watch(
      toolbarVisibilityControllerProvider(selectedTabId),
    );

    final appearanceButtonVisible = ref.watch(
      appearanceButtonVisibilityProvider.select(
        (value) => value.value ?? false,
      ),
    );

    final readerabilityState = ref.watch(
      selectedTabStateProvider.select(
        (state) => state?.readerableState ?? ReaderableState.$default(),
      ),
    );

    final showAppearance = readerabilityState.active && appearanceButtonVisible;
    final showDock = toolbarState == ToolbarVisibility.dismissed;

    void forceShowToolbar() {
      ref
          .read(toolbarVisibilityControllerProvider(selectedTabId).notifier)
          .forceShow();
    }

    // Re-show the hidden tab bar / toolbar. Kept available even while reading,
    // where the reader appearance button would otherwise take the FAB's slot
    // and leave no way to bring the toolbar back. Rendered smaller when paired
    // with the appearance button to mark it as the secondary action.
    Widget buildDockFab({required bool small}) {
      const icon = Icon(MdiIcons.dockBottom);
      return small
          ? FloatingActionButton.small(
              key: const ValueKey('dock_fab'),
              heroTag: 'dock_fab',
              onPressed: forceShowToolbar,
              child: icon,
            )
          : FloatingActionButton(
              key: const ValueKey('dock_fab'),
              heroTag: 'dock_fab',
              onPressed: forceShowToolbar,
              child: icon,
            );
    }

    Widget buildAppearanceFab() {
      return FloatingActionButton(
        key: const ValueKey('appearance_fab'),
        heroTag: 'appearance_fab',
        onPressed: () async {
          await ref.read(readerableServiceProvider).onAppearanceButtonTap();
        },
        child: const Icon(MdiIcons.formatFont),
      );
    }

    if (showAppearance && showDock) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          buildDockFab(small: true),
          const SizedBox(height: 12),
          buildAppearanceFab(),
        ],
      );
    } else if (showAppearance) {
      return buildAppearanceFab();
    } else if (showDock) {
      return buildDockFab(small: false);
    } else {
      return const SizedBox.shrink(key: ValueKey('no_fab'));
    }
  }
}
