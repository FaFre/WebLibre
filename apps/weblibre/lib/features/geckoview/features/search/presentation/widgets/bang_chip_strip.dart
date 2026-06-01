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
import 'package:weblibre/features/bangs/data/models/bang_data.dart';
import 'package:weblibre/features/bangs/presentation/widgets/bang_label.dart';
import 'package:weblibre/presentation/widgets/selectable_chips.dart';
import 'package:weblibre/presentation/widgets/url_icon.dart';

// These helpers are conceptually `BangChipStrip`-private — they capture
// the chip's own selection / delete-affordance rules and are not part of
// the public bang API. The `@visibleForTesting` annotation keeps them
// reachable from `frequent_bangs_section_test.dart` (which asserts the
// rules directly) without inviting unrelated call sites.
@visibleForTesting
bool isSelectedBangChip(BangData bang, BangData? selectedBang) =>
    selectedBang != null && bang.toKey() == selectedBang.toKey();

@visibleForTesting
bool canDeleteBangChip(
  BangData bang, {
  BangData? selectedBang,
  required bool allowFrequencyResetAction,
}) => isSelectedBangChip(bang, selectedBang) || allowFrequencyResetAction;

@visibleForTesting
IconData? bangChipDeleteIcon(
  BangData bang, {
  BangData? selectedBang,
  required bool allowFrequencyResetAction,
}) {
  if (isSelectedBangChip(bang, selectedBang)) {
    return Icons.clear;
  }

  return allowFrequencyResetAction ? MdiIcons.restore : null;
}

class BangChipStrip extends StatelessWidget {
  final List<BangData> bangs;
  final BangData? selectedBang;
  final BangData? deletableSelectedBang;
  final bool Function(BangData bang)? canDeleteBang;
  final int? maxCount;
  final List<Widget> prefixItems;
  final bool showTrailingMenu;
  final bool sortSelectedFirst;
  final bool allowFrequencyResetAction;
  final VoidCallback? onMenuPressed;
  final void Function(BangData bang) onSelected;
  final void Function(BangData bang) onDeleted;

  const BangChipStrip({
    required this.bangs,
    required this.selectedBang,
    required this.onSelected,
    required this.onDeleted,
    this.deletableSelectedBang,
    this.canDeleteBang,
    this.maxCount,
    this.prefixItems = const [],
    this.showTrailingMenu = false,
    this.sortSelectedFirst = true,
    this.allowFrequencyResetAction = false,
    this.onMenuPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final hasContent = selectedBang != null || bangs.isNotEmpty;
    final resolvedDeletableSelectedBang = deletableSelectedBang ?? selectedBang;

    return SizedBox(
      height: 48,
      child: Row(
        children: [
          if (hasContent)
            Expanded(
              child: SelectableChips<BangData, BangData, String>(
                itemId: (bang) => bang.trigger,
                itemAvatar: (bang) =>
                    UrlIcon([bang.getDefaultUrl()], iconSize: 20),
                itemLabel: (bang) => BangLabel(bang),
                itemTooltip: (bang) => bang.trigger,
                availableItems: bangs,
                selectedItem: selectedBang,
                maxCount: maxCount,
                sortSelectedFirst: sortSelectedFirst,
                decoration: SelectableChipDecoration(
                  canDelete: (bang) =>
                      canDeleteBangChip(
                        bang,
                        selectedBang: resolvedDeletableSelectedBang,
                        allowFrequencyResetAction: allowFrequencyResetAction,
                      ) &&
                      (canDeleteBang?.call(bang) ?? true),
                  deleteIcon: (bang) {
                    final icon = bangChipDeleteIcon(
                      bang,
                      selectedBang: resolvedDeletableSelectedBang,
                      allowFrequencyResetAction: allowFrequencyResetAction,
                    );
                    return icon == null ? null : Icon(icon);
                  },
                ),
                onSelected: onSelected,
                onDeleted: onDeleted,
              ),
            )
          else if (prefixItems.isNotEmpty) ...[
            ...prefixItems,
            const Spacer(),
          ] else
            const Spacer(),
          if (showTrailingMenu)
            IconButton(
              onPressed: onMenuPressed,
              icon: const Icon(Icons.chevron_right),
            ),
        ],
      ),
    );
  }
}
