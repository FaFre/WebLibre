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
  /// The trailing "Show all / Show less" button is hidden when
  /// totalCount <= this value (or when [showPagination] is false).
  final int previewLimit;

  /// Set false for modules that render a single non-paginated body
  /// (e.g. a chip strip with its own scrolling). Hides the
  /// "Show all N / Show less" affordance regardless of [totalCount].
  final bool showPagination;

  /// Called when the header is long-pressed (e.g. to enter reorder mode).
  final VoidCallback? onLongPress;

  /// Optional widget between the collapse chevron and the title.
  final Widget? leading;

  /// Titles the section as an object rather than as a list: sentence case at
  /// [TextTheme.titleMedium] instead of the uppercase micro-label, and flush
  /// insets so it sits correctly inside a card that supplies its own padding.
  ///
  /// The uppercase label is a list heading — it works because it is one of
  /// several running down a feed. On its own inside a card it reads as a
  /// caption for something missing.
  final bool emphasized;

  const SearchModuleHeader({
    super.key,
    required this.title,
    required this.totalCount,
    required this.displayState,
    required this.onToggleCollapse,
    required this.onToggleExpansion,
    this.headerTrailing,
    this.previewLimit = 3,
    this.showPagination = true,
    this.onLongPress,
    this.leading,
    this.emphasized = false,
  });

  @override
  Widget build(BuildContext context) {
    final disableAnimations = MediaQuery.disableAnimationsOf(context);
    final isCollapsed = displayState == SearchModuleDisplayState.collapsed;
    final isExpanded = displayState == SearchModuleDisplayState.expanded;
    final showTrailing =
        showPagination && !isCollapsed && totalCount > previewLimit;

    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(right: emphasized ? 0.0 : 8.0),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: onToggleCollapse,
              onLongPress: onLongPress,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                // Tighter when collapsed: a run of collapsed sections is
                // otherwise a stack of full-height bands with nothing in them.
                padding: EdgeInsets.symmetric(
                  vertical: isCollapsed ? 4.0 : 8.0,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!emphasized) const SizedBox(width: 4),
                    AnimatedRotation(
                      turns: isCollapsed ? -0.25 : 0,
                      duration: disableAnimations
                          ? Duration.zero
                          : const Duration(milliseconds: 200),
                      child: Icon(
                        Icons.expand_more,
                        size: 20,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (leading != null) ...[
                      leading!,
                      const SizedBox(width: 12),
                    ],
                    Flexible(
                      child: Text(
                        emphasized ? title : title.toUpperCase(),
                        overflow: TextOverflow.ellipsis,
                        style: emphasized
                            ? theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              )
                            : theme.textTheme.labelMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.8,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (headerTrailing != null) headerTrailing!,
          if (showTrailing)
            // Borderless: an outlined pill next to an 11px label reads as the
            // most important thing in the row, which it is not.
            TextButton(
              onPressed: onToggleExpansion,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                foregroundColor: Theme.of(context).colorScheme.primary,
              ),
              child: Text(
                isExpanded ? 'Show less' : 'Show all $totalCount',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
