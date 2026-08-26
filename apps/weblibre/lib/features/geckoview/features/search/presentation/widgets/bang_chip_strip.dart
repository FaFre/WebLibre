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
import 'package:weblibre/features/bangs/data/models/bang_data.dart';
import 'package:weblibre/features/bangs/data/models/bang_key.dart';
import 'package:weblibre/features/bangs/presentation/widgets/bang_label.dart';
import 'package:weblibre/features/geckoview/features/search/presentation/widgets/bang_chip_menu.dart';
import 'package:weblibre/presentation/widgets/selectable_chips.dart';
import 'package:weblibre/presentation/widgets/url_icon.dart';

// Conceptually `BangChipStrip`-private — this captures the chip's own
// selection rule and is not part of the public bang API. The
// `@visibleForTesting` annotation keeps it reachable from
// `frequent_bangs_section_test.dart` (which asserts the rule directly)
// without inviting unrelated call sites.
@visibleForTesting
bool isSelectedBangChip(BangData bang, BangData? selectedBang) =>
    selectedBang != null && bang.toKey() == selectedBang.toKey();

/// Pinned bangs first, then whatever of [rest] they do not already cover.
///
/// Dedup is by full [BangKey]: the same trigger in two groups is two different
/// bangs and both may legitimately appear.
List<BangData> mergePinnedBangs({
  required List<BangData> pinned,
  required List<BangData> rest,
}) {
  if (pinned.isEmpty) {
    return rest;
  }

  final pinnedKeys = pinned.map((bang) => bang.toKey()).toSet();

  return [
    ...pinned,
    ...rest.where((bang) => !pinnedKeys.contains(bang.toKey())),
  ];
}

class BangChipStrip extends StatelessWidget {
  final List<BangData> bangs;

  /// The chip drawn as the active one. Not necessarily a selection: a strip
  /// may render the standing default provider as active.
  final BangData? selectedBang;

  /// The chip that actually holds the selection, and therefore the only one
  /// whose trailing `x` appears. Null means nothing is selected — no chip
  /// offers to clear, not even the one [selectedBang] draws as active. Passed
  /// separately rather than derived so a default-as-active chip can't end up
  /// with an `x` that deselects nothing.
  final BangData? clearableBang;

  final int? maxCount;
  final List<Widget> prefixItems;
  final bool showTrailingMenu;
  final bool sortSelectedFirst;
  final VoidCallback? onMenuPressed;
  final void Function(BangData bang) onSelected;

  /// Invoked by the trailing `x`, which only ever means "clear the selection".
  /// Everything else a chip can do lives in its long-press [BangChipMenu].
  final void Function(BangData bang) onDeleted;

  const BangChipStrip({
    required this.bangs,
    required this.selectedBang,
    required this.onSelected,
    required this.onDeleted,
    required this.clearableBang,
    this.maxCount,
    this.prefixItems = const [],
    this.showTrailingMenu = false,
    this.sortSelectedFirst = true,
    this.onMenuPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final hasContent = selectedBang != null || bangs.isNotEmpty;

    return SizedBox(
      height: 48,
      child: Row(
        children: [
          if (hasContent)
            Expanded(
              child: SelectableChips<BangData, BangData, BangKey>(
                // Keyed by the full key, not the trigger: a user bang
                // overriding a synced one shares its trigger, and two chips
                // sharing an id collapse into one.
                itemId: (bang) => bang.toKey(),
                itemAvatar: (bang) =>
                    UrlIcon([bang.getDefaultUrl()], iconSize: 20),
                itemLabel: (bang) => BangLabel(bang),
                itemTooltip: (bang) => bang.trigger,
                availableItems: bangs,
                selectedItem: selectedBang,
                maxCount: maxCount,
                sortSelectedFirst: sortSelectedFirst,
                decoration: SelectableChipDecoration(
                  // The trailing button means one thing only: drop the
                  // selection. So only the selected chip carries one.
                  canDelete: (bang) => isSelectedBangChip(bang, clearableBang),
                  deleteIcon: (_) => const Icon(Icons.clear),
                ),
                itemWrap: (child, bang) =>
                    BangChipMenu(bang: bang, child: child),
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
