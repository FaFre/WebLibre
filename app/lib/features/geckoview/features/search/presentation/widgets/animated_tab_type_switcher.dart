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
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/presentation/icons/weblibre_icons.dart';

/// An animated tab type switcher that only shows the label for the currently
/// active option. Inactive options collapse to show only their icon.
class AnimatedTabTypeSwitcher extends StatelessWidget {
  final TabType selected;
  final ValueChanged<TabType> onChanged;
  final bool showChildOption;
  final Color? selectedBackgroundColor;

  const AnimatedTabTypeSwitcher({
    super.key,
    required this.selected,
    required this.onChanged,
    this.showChildOption = false,
    this.selectedBackgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final borderColor = colorScheme.outline;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(24),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(23),
        child: IntrinsicHeight(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _Segment(
                tabType: TabType.regular,
                icon: MdiIcons.tab,
                label: 'Regular',
                isSelected: selected == TabType.regular,
                selectedBackgroundColor: selectedBackgroundColor,
                onTap: () => onChanged(TabType.regular),
              ),
              _divider(borderColor),
              _Segment(
                tabType: TabType.private,
                icon: WebLibreIcons.privateTab,
                label: 'Private',
                isSelected: selected == TabType.private,
                selectedBackgroundColor: selectedBackgroundColor,
                onTap: () => onChanged(TabType.private),
              ),
              if (showChildOption) ...[
                _divider(borderColor),
                _Segment(
                  tabType: TabType.child,
                  icon: MdiIcons.fileTree,
                  label: 'Child',
                  isSelected: selected == TabType.child,
                  selectedBackgroundColor: selectedBackgroundColor,
                  onTap: () => onChanged(TabType.child),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _divider(Color color) {
    return VerticalDivider(width: 1, thickness: 1, color: color);
  }
}

class _Segment extends StatelessWidget {
  final TabType tabType;
  final IconData icon;
  final String label;
  final bool isSelected;
  final Color? selectedBackgroundColor;
  final VoidCallback onTap;

  const _Segment({
    required this.tabType,
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.selectedBackgroundColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final bgColor = isSelected
        ? (selectedBackgroundColor ?? colorScheme.secondaryContainer)
        : Colors.transparent;
    final fgColor = isSelected
        ? colorScheme.onSecondaryContainer
        : colorScheme.onSurfaceVariant;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        color: bgColor,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: fgColor, size: 18),
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              child: isSelected
                  ? Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text(
                        label,
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: fgColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.clip,
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
