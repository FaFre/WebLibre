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
import 'package:weblibre/features/geckoview/features/search/presentation/widgets/search_modules/search_module_section.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/models/container_data.dart';
import 'package:weblibre/features/geckoview/features/tabs/presentation/widgets/container_chips.dart';

class ContainersSection extends StatelessWidget {
  final void Function(ContainerDataWithCount container) onContainerSelected;

  const ContainersSection({super.key, required this.onContainerSelected});

  @override
  Widget build(BuildContext context) {
    return SearchModuleSection(
      title: 'Containers',
      moduleType: SearchModuleType.containers,
      totalCount: 1,
      contentSliverBuilder:
          ({required bool isCollapsed, required int visibleCount}) => [
            if (!isCollapsed)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: ContainerChips(
                    selectedContainer: null,
                    onSelected: (container) {
                      if (container != null) {
                        onContainerSelected(container);
                      }
                    },
                    onDeleted: null,
                    displayMenu: false,
                    showUnassignedChip: false,
                    enableDragAndDrop: false,
                  ),
                ),
              ),
          ],
    );
  }
}
