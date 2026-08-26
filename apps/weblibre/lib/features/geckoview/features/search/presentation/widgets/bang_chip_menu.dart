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
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/features/bangs/data/models/bang_data.dart';
import 'package:weblibre/features/bangs/data/models/bang_group.dart';
import 'package:weblibre/features/bangs/domain/providers/bangs.dart';
import 'package:weblibre/features/bangs/domain/repositories/data.dart';
import 'package:weblibre/features/geckoview/features/search/presentation/dialogs/reset_bang_dialog.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/presentation/hooks/menu_controller.dart';
import 'package:weblibre/presentation/widgets/reorderable_hold_drag.dart';

/// Whether resetting [bang]'s usage frequency is offered.
///
/// Two bangs are left out:
///   * one that was never used — there is nothing to reset, and the action
///     would read as a way to remove the chip, which it is not;
///   * the user's default search bang — dropping it out of the frecency-ranked
///     quick select would unanchor the very list this menu is opened from.
@visibleForTesting
bool canResetBangFrequency({
  required BangData bang,
  required BangData? defaultBang,
}) {
  if (bang.frequency <= 0) {
    return false;
  }

  return defaultBang?.toKey() != bang.toKey();
}

/// Long-press context menu for a bang chip.
///
/// The chip's trailing button is reserved for clearing the selection, so
/// everything else a chip can do lives here — the same split the container
/// chips use.
class BangChipMenu extends HookConsumerWidget {
  final BangData bang;
  final Widget child;

  const BangChipMenu({required this.bang, required this.child, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = useMenuController();

    final isPinned = ref.watch(
      generalSettingsWithDefaultsProvider.select(
        (settings) => settings.pinnedBangs.contains(bang.toKey()),
      ),
    );

    final defaultBang = ref.watch(
      defaultSearchBangDataProvider.select((value) => value.value),
    );

    final isUserBang = bang.group == BangGroup.user;

    return MenuAnchor(
      controller: controller,
      menuChildren: [
        MenuItemButton(
          leadingIcon: Icon(isPinned ? MdiIcons.pinOff : MdiIcons.pin),
          onPressed: () async {
            await ref.read(pinnedBangsProvider.notifier).toggle(bang.toKey());
          },
          child: Text(isPinned ? 'Unpin' : 'Pin'),
        ),
        if (canResetBangFrequency(bang: bang, defaultBang: defaultBang))
          MenuItemButton(
            leadingIcon: const Icon(MdiIcons.restore),
            onPressed: () async {
              final confirmed = await showResetBangDialog(
                context,
                triggerName: bang.trigger,
              );

              if (confirmed == true) {
                await ref
                    .read(bangDataRepositoryProvider.notifier)
                    .resetFrequency(bang.toKey());
              }
            },
            child: const Text('Reset frequency'),
          ),
        MenuItemButton(
          leadingIcon: const Icon(MdiIcons.pencilBoxOutline),
          onPressed: () async {
            // A synced bang is forked into a user bang rather than edited in
            // place; user bangs take precedence on the same trigger, so the
            // fork is what overrides the original.
            await EditUserBangRoute(
              initialBang: jsonEncode(bang.toJson()),
              fork: !isUserBang,
            ).push(context);
          },
          child: Text(isUserBang ? 'Edit bang' : 'Customize as your own bang'),
        ),
      ],
      builder: (context, controller, _) => HoldMenuListener(
        controller: controller,
        borderRadius: BorderRadius.circular(8.0),
        child: child,
      ),
    );
  }
}
