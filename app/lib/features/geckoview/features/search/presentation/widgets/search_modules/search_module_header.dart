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
import 'package:weblibre/features/geckoview/features/search/domain/providers/search_modules_view.dart';

/// A reusable header widget for search modules that displays a collapse/expand
/// chevron on the left, the section title, and a "Show all N" / "Show less"
/// button on the right.
class SearchModuleHeader extends StatelessWidget {
  final String title;
  final int totalCount;
  final SearchModuleDisplayState displayState;
  final VoidCallback onToggleCollapse;
  final VoidCallback onToggleExpansion;

  /// Optional widget placed between the title area and the trailing button.
  final Widget? headerTrailing;

  /// The maximum number of items shown in preview mode.
  /// The trailing button is hidden when totalCount <= this value.
  final int previewLimit;

  /// Called when the header is long-pressed (e.g. to enter reorder mode).
  final VoidCallback? onLongPress;

  const SearchModuleHeader({
    super.key,
    required this.title,
    required this.totalCount,
    required this.displayState,
    required this.onToggleCollapse,
    required this.onToggleExpansion,
    this.headerTrailing,
    this.previewLimit = 3,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final isCollapsed = displayState == SearchModuleDisplayState.collapsed;
    final isExpanded = displayState == SearchModuleDisplayState.expanded;
    final showTrailing = !isCollapsed && totalCount > previewLimit;

    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: onToggleCollapse,
              onLongPress: onLongPress,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(width: 8),
                    AnimatedRotation(
                      turns: isCollapsed ? -0.25 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        Icons.expand_more,
                        size: 20,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      title.toUpperCase(),
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (headerTrailing != null) headerTrailing!,
          if (showTrailing)
            TextButton(
              onPressed: onToggleExpansion,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                  side: BorderSide(
                    color: Theme.of(context).colorScheme.outline,
                    width: 0.5,
                  ),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isExpanded ? 'Show less' : 'Show all $totalCount',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    size: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
