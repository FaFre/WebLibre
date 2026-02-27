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
import 'package:weblibre/features/geckoview/features/tabs/data/models/container_data.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/entities/container_selection_result.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/providers/selected_container.dart';
import 'package:weblibre/features/geckoview/features/tabs/presentation/widgets/container_title.dart';
import 'package:weblibre/features/geckoview/features/tabs/utils/container_colors.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';

/// A compact container selector that displays only the currently selected
/// container (or "unassigned" if none selected) without counts.
/// Tapping opens the container selection screen.
/// Long pressing opens the edit screen for the selected container.
class CompactContainerSelector extends ConsumerWidget {
  final ContainerData? selectedContainer;

  const CompactContainerSelector({super.key, this.selectedContainer});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final containerUiEnabled = ref.watch(
      generalSettingsWithDefaultsProvider.select(
        (settings) => settings.showContainerUi,
      ),
    );
    if (!containerUiEnabled) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final isSelected = selectedContainer != null;

    return GestureDetector(
      onLongPress: isSelected
          ? () async {
              await ContainerEditRoute(
                containerData: jsonEncode(selectedContainer!.toJson()),
              ).push(context);
            }
          : null,
      child: ActionChip(
        avatar: isSelected ? null : const Icon(MdiIcons.folderHidden),
        label: isSelected
            ? ContainerTitle(container: selectedContainer!)
            : const Text('Unassigned'),
        backgroundColor: isSelected
            ? ContainerColors.forChip(selectedContainer!.color)
            : null,
        side: isSelected ? BorderSide(color: theme.colorScheme.primary) : null,
        onPressed: () async {
          final selection = await const ContainerSelectionRoute()
              .push<ContainerSelectionResult?>(context);

          switch (selection) {
            case ContainerSelectionSelected(:final containerId):
              await ref
                  .read(selectedContainerProvider.notifier)
                  .setContainerId(containerId);
            case ContainerSelectionUnassigned():
              ref.read(selectedContainerProvider.notifier).clearContainer();
            case null:
              break;
          }
        },
      ),
    );
  }
}
