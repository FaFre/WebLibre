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
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/controllers/tab_view_controllers.dart';

enum TabGroupToggleStyle {
  /// Standard `IconButton`, sits inside a list-tile trailing row alongside
  /// the close button.
  list,

  /// 28x28 square button that mirrors the grid cell close button — same
  /// surface tint, alpha, radius, and icon size.
  grid,
}

class TabGroupExpandToggle extends ConsumerWidget {
  final String parentId;
  final int childCount;
  final TabGroupToggleStyle style;

  const TabGroupExpandToggle({
    required this.parentId,
    required this.childCount,
    this.style = TabGroupToggleStyle.list,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isCollapsed = ref.watch(
      collapsedGroupsProvider.select((set) => set.contains(parentId)),
    );

    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final chevron = isCollapsed
        ? Icons.keyboard_arrow_down_rounded
        : Icons.keyboard_arrow_up_rounded;
    final tooltip = isCollapsed ? 'Expand group' : 'Collapse group';

    void onTap() {
      ref.read(collapsedGroupsProvider.notifier).toggle(parentId);
    }

    return switch (style) {
      // Unified pill: count + chevron live inside one Material/InkWell so
      // the whole badge is the toggle target.
      TabGroupToggleStyle.list => Tooltip(
        message: tooltip,
        child: Material(
          color: scheme.secondaryContainer.withAlpha(204),
          borderRadius: BorderRadius.circular(20),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$childCount',
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: scheme.onSecondaryContainer,
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(chevron, size: 18, color: scheme.onSecondaryContainer),
                ],
              ),
            ),
          ),
        ),
      ),
      // Grid: unified pill with count + chevron — height matches the 28px
      // close button at top-right; tint, alpha, and radius mirror it so
      // the two corners stay balanced.
      TabGroupToggleStyle.grid => Tooltip(
        message: tooltip,
        child: SizedBox(
          height: 28,
          child: Material(
            color: scheme.surfaceContainerHighest.withAlpha(200),
            borderRadius: const BorderRadius.all(Radius.circular(8.0)),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$childCount',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(width: 2),
                    Icon(chevron, size: 16, color: scheme.onSurfaceVariant),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    };
  }
}
