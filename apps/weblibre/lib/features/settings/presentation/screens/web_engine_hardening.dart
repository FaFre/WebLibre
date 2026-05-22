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
import 'package:fast_equatable/fast_equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nullability/nullability.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/features/geckoview/features/preferences/data/repositories/preference_settings.dart';
import 'package:weblibre/features/geckoview/features/tabs/utils/setting_groups_serializer.dart';
import 'package:weblibre/features/settings/presentation/widgets/hardening_group_icon.dart';
import 'package:weblibre/features/settings/presentation/widgets/settings_detail.dart';
import 'package:weblibre/presentation/widgets/failure_widget.dart';

class WebEngineHardeningScreen extends HookConsumerWidget {
  const WebEngineHardeningScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preferenceGroups = ref.watch(
      unifiedPreferenceSettingsRepositoryProvider(PreferencePartition.user),
    );

    final allGroupsActive = useMemoized(
      () =>
          preferenceGroups.value?.values.every(
            (element) => element.isActiveOrOptional,
          ) ??
          false,
      [EquatableValue(preferenceGroups.value)],
    );

    final theme = Theme.of(context);
    final search = useSettingsSearch();
    final query = search.normalizedQuery;

    return SettingsCustomScrollScaffold(
      title: 'Web Engine Hardening',
      searchController: search.controller,
      searchHintText: 'Search hardening groups',
      actions: [
        MenuAnchor(
          menuChildren: [
            MenuItemButton(
              leadingIcon: const Icon(Icons.restore),
              child: const Text('Reset all preferences'),
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Reset all preferences?'),
                    content: const Text(
                      'This will reset all user-defined web engine preferences to their defaults.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text('Reset'),
                      ),
                    ],
                  ),
                );
                if (confirmed == true) {
                  await ref
                      .read(
                        unifiedPreferenceSettingsRepositoryProvider(
                          PreferencePartition.user,
                        ).notifier,
                      )
                      .reset();
                }
              },
            ),
          ],
          builder: (context, controller, child) => IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              if (controller.isOpen) {
                controller.close();
              } else {
                controller.open();
              }
            },
          ),
        ),
      ],
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 20),
          sliver: SliverToBoxAdapter(
            child: preferenceGroups.when(
              skipLoadingOnReload: true,
              data: (data) {
                final overviewMatches =
                    query.isEmpty ||
                    matchesSettingsSearch(query, const [
                      'overview',
                      'complete hardening',
                      'apply reset all grouped hardening preferences',
                    ]);
                final filteredGroups = data.entries.where((group) {
                  if (query.isEmpty) return true;
                  return matchesSettingsSearch(query, [
                    group.key,
                    if (group.value.description != null)
                      group.value.description!,
                  ]);
                }).toList();

                final sections = <SettingsSectionDefinition>[
                  if (overviewMatches)
                    SettingsSectionDefinition(
                      title: 'Overview',
                      entries: [
                        SettingsEntryDefinition(
                          title: 'Complete Hardening',
                          subtitle:
                              'Apply or reset all grouped hardening preferences',
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: SwitchListTile.adaptive(
                                value: allGroupsActive,
                                title: Text(
                                  'Complete Hardening',
                                  style: TextStyle(
                                    color: theme.colorScheme.onPrimaryContainer,
                                  ),
                                ),
                                subtitle: Text(
                                  'Toggle all grouped hardening preferences at once.',
                                  style: TextStyle(
                                    color: theme.colorScheme.onPrimaryContainer,
                                  ),
                                ),
                                onChanged: (value) async {
                                  final notifier = ref.read(
                                    unifiedPreferenceSettingsRepositoryProvider(
                                      PreferencePartition.user,
                                    ).notifier,
                                  );

                                  if (value) {
                                    await notifier.apply();
                                  } else {
                                    await notifier.reset();
                                  }
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  if (filteredGroups.isNotEmpty)
                    SettingsSectionDefinition(
                      title: 'Hardening Groups',
                      entries: [
                        for (final group in filteredGroups)
                          SettingsEntryDefinition(
                            title: group.key,
                            subtitle: group.value.description,
                            child: ListTile(
                              title: Text(group.key),
                              subtitle: group.value.description.mapNotNull(
                                (description) => Text(description),
                              ),
                              leading: Badge(
                                isLabelVisible: group.value.hasInactiveOptional,
                                child: HardeningGroupIcon(
                                  isActive: group.value.isActiveOrOptional,
                                  isPartlyActive: group.value.isPartlyActive,
                                ),
                              ),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () async {
                                await WebEngineHardeningGroupRoute(
                                  group: group.key,
                                ).push(context);
                              },
                            ),
                          ),
                      ],
                    ),
                ];

                return SettingsSectionList(
                  sections: sections,
                  query: search.rawQuery,
                );
              },
              error: (error, stackTrace) => FailureWidget(
                title: 'Could not load preference settings',
                exception: error,
                onRetry: () => ref.refresh(
                  unifiedPreferenceSettingsRepositoryProvider(
                    PreferencePartition.user,
                  ),
                ),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
            ),
          ),
        ),
      ],
    );
  }
}
