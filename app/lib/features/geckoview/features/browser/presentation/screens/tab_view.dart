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
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_state.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/controllers/tab_view_controllers.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/tab_view/tab_grid_view.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/tab_view/tab_list_view.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/tab_view/tab_tree_view.dart';
import 'package:weblibre/features/sync/domain/repositories/sync.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/presentation/widgets/floating_action_button_inset.dart';

class TabViewScreen extends HookConsumerWidget {
  const TabViewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabsViewMode = ref.watch(tabsViewModeControllerProvider);
    final tabsReorderable = ref.watch(tabsReorderableControllerProvider);

    final isSyncedScope = ref.watch(
      effectiveTabsTrayScopeProvider.select(
        (scope) => scope == TabsTrayScope.synced,
      ),
    );

    final effectiveTabsViewMode = isSyncedScope
        ? TabsViewMode.list
        : tabsViewMode;

    final scrollController = useScrollController(keys: [tabsReorderable]);

    return Dialog.fullscreen(
      child: Scaffold(
        body: SafeArea(
          child: Builder(
            builder: (safeAreaContext) {
              return Padding(
                padding: EdgeInsets.only(
                  bottom: isSyncedScope
                      ? 0
                      : floatingActionButtonBottomInset(safeAreaContext),
                ),
                child: switch (effectiveTabsViewMode) {
                  TabsViewMode.list => ViewTabListWidget(
                    key: ValueKey(tabsReorderable),
                    scrollController: scrollController,
                    tabsReorderable: tabsReorderable,
                    showNewTabFab: false,
                    onClose: () {
                      const BrowserRoute().go(context);
                    },
                  ),
                  TabsViewMode.grid => ViewTabGridWidget(
                    key: ValueKey(tabsReorderable),
                    scrollController: scrollController,
                    tabsReorderable: tabsReorderable,
                    showNewTabFab: false,
                    onClose: () {
                      const BrowserRoute().go(context);
                    },
                  ),
                  TabsViewMode.tree => ViewTabTreesWidget(
                    scrollController: scrollController,
                    showNewTabFab: false,
                    onClose: () {
                      const BrowserRoute().go(context);
                    },
                  ),
                },
              );
            },
          ),
        ),
        floatingActionButton: isSyncedScope
            ? null
            : FloatingActionButton(
                onPressed: () async {
                  final settings = ref.read(
                    generalSettingsWithDefaultsProvider,
                  );

                  await SearchRoute(
                    tabType:
                        ref.read(selectedTabTypeProvider) ??
                        settings.effectiveDefaultCreateTabType,
                  ).push(context);

                  if (context.mounted) {
                    const BrowserRoute().go(context);
                  }
                },
                child: const Icon(Icons.add),
              ),
      ),
    );
  }
}
