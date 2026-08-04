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
import 'package:weblibre/features/geckoview/domain/providers/tab_list.dart';
import 'package:weblibre/features/geckoview/features/search/domain/providers/search_modules_view.dart';
import 'package:weblibre/features/geckoview/features/search/presentation/widgets/search_modules/search_module_section.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/providers/selected_container.dart';

/// New tab / View tabs / Resume last tab.
///
/// Which buttons appear depends on what there is to act on: with no tabs at all
/// only "New tab" is meaningful, and "Resume last tab" resumes within the
/// selected container when there is one.
class QuickActionsSection extends ConsumerWidget {
  final VoidCallback onNewTab;
  final VoidCallback onViewTabs;
  final VoidCallback onResumeLastTab;

  const QuickActionsSection({
    super.key,
    required this.onNewTab,
    required this.onViewTabs,
    required this.onResumeLastTab,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasTabs = ref.watch(
      tabListProvider.select((tabs) => tabs.value.isNotEmpty),
    );
    final hasContainer = ref.watch(
      selectedContainerDataProvider.select((value) => value.value != null),
    );
    final hasContainerTabs = ref.watch(
      selectedContainerTabCountProvider.select(
        (data) => switch (data) {
          AsyncData(:final value) => value > 0,
          _ => false,
        },
      ),
    );

    // Resuming is offered for the container in scope, or globally when no
    // container is selected — never across a container boundary, which would
    // silently move the user somewhere else.
    final canResume = hasContainer ? hasContainerTabs : hasTabs;

    return SearchModuleSection(
      title: 'Quick Actions',
      moduleType: SearchModuleType.quickActions,
      totalCount: 0,
      showPagination: false,
      contentSliverBuilder: ({required isCollapsed, required visibleCount}) => [
        if (!isCollapsed)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  FilledButton.icon(
                    onPressed: onNewTab,
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('New tab'),
                  ),
                  if (hasTabs)
                    OutlinedButton.icon(
                      onPressed: onViewTabs,
                      icon: const Icon(Icons.tab_rounded),
                      label: const Text('View tabs'),
                    ),
                  if (canResume)
                    FilledButton.tonalIcon(
                      onPressed: onResumeLastTab,
                      icon: const Icon(Icons.history_rounded),
                      label: const Text('Resume last tab'),
                    ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
