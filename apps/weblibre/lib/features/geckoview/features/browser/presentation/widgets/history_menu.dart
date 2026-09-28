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
import 'package:weblibre/features/geckoview/domain/entities/states/history.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_detail_state.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/history_menu_item.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';

enum HistoryMenuDirection { back, forward }

class HistoryMenu extends HookConsumerWidget {
  const HistoryMenu({
    super.key,
    required this.selectedTabId,
    required this.controller,
    required this.direction,
    required this.child,
  });

  final String? selectedTabId;
  final MenuController controller;
  final HistoryMenuDirection direction;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final historyState = ref.watch(tabHistoryStateProvider(selectedTabId));

    final menuItems = useMemoized(() => _buildMenuItems(l10n, historyState), [
      historyState,
    ]);

    return MenuAnchor(
      controller: controller,
      consumeOutsideTap: true,
      menuChildren: menuItems,
      child: child,
    );
  }

  List<Widget> _buildMenuItems(
    AppLocalizations l10n,
    HistoryState historyState,
  ) {
    if (historyState.items.isEmpty) {
      return [
        MenuItemButton(
          child: Text(
            direction == HistoryMenuDirection.back
                ? l10n.browser_historyNoPreviousPages
                : l10n.browser_historyNoForwardPages,
          ),
        ),
      ];
    }

    final items = historyState.items.indexed;
    final currentIndex = historyState.currentIndex;

    final historyItems = switch (direction) {
      // Back: oldest at top, newest at bottom (close to button)
      HistoryMenuDirection.back => items.where((e) => e.$1 < currentIndex),
      // Forward: furthest at top, closest at bottom (close to button)
      HistoryMenuDirection.forward =>
        items.where((e) => e.$1 > currentIndex).toList().reversed,
    };

    if (historyItems.isEmpty) {
      final message = direction == HistoryMenuDirection.back
          ? l10n.browser_historyNoPreviousPages
          : l10n.browser_historyNoForwardPages;
      return [MenuItemButton(child: Text(message))];
    }

    return historyItems
        .map(
          (e) => HistoryMenuItem(
            selectedTabId: selectedTabId,
            item: e.$2,
            historyIndex: e.$1,
          ),
        )
        .toList();
  }
}
