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
import 'package:nullability/nullability.dart';
import 'package:weblibre/features/geckoview/features/preferences/data/models/preference_setting.dart';
import 'package:weblibre/features/geckoview/features/preferences/data/repositories/preference_settings.dart';
import 'package:weblibre/features/geckoview/features/tabs/utils/setting_groups_serializer.dart';
import 'package:weblibre/features/settings/presentation/widgets/hardening_group_icon.dart';
import 'package:weblibre/features/settings/presentation/widgets/settings_detail.dart';
import 'package:weblibre/presentation/widgets/failure_widget.dart';

class WebEngineHardeningGroupScreen extends HookConsumerWidget {
  final String groupName;

  const WebEngineHardeningGroupScreen({super.key, required this.groupName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(
      preferenceSettingsGroupRepositoryProvider(
        PreferencePartition.user,
        groupName,
      ),
    );

    final theme = Theme.of(context);
    final search = useSettingsSearch();
    final query = search.normalizedQuery;

    return SettingsCustomScrollScaffold(
      title: groupName,
      searchController: search.controller,
      searchHintText: 'Search hardening settings',
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 20),
          sliver: SliverToBoxAdapter(
            child: settings.when(
              skipLoadingOnReload: true,
              data: (group) {
                final groupControlMatches =
                    query.isEmpty ||
                    matchesSettingsSearch(query, [
                      groupName,
                      if (group.description != null) group.description!,
                      'group controls complete hardening',
                    ]);
                final filteredSettings = group.settings.entries.where((
                  setting,
                ) {
                  if (query.isEmpty) return true;
                  return matchesSettingsSearch(query, [
                    setting.key,
                    if (setting.value.title != null) setting.value.title!,
                    if (setting.value.description != null)
                      setting.value.description!,
                  ]);
                }).toList();

                final sections = <SettingsSectionDefinition>[
                  if (group.showMasterSwitch && groupControlMatches)
                    SettingsSectionDefinition(
                      title: 'Group Controls',
                      entries: [
                        SettingsEntryDefinition(
                          title: groupName,
                          subtitle: group.description,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: SwitchListTile.adaptive(
                                value: group.isActiveOrOptional,
                                title: Text(
                                  groupName,
                                  style: TextStyle(
                                    color: theme.colorScheme.onPrimaryContainer,
                                  ),
                                ),
                                subtitle: group.description.mapNotNull(
                                  (description) => Text(
                                    description,
                                    style: TextStyle(
                                      color:
                                          theme.colorScheme.onPrimaryContainer,
                                    ),
                                  ),
                                ),
                                onChanged: (value) async {
                                  final notifier = ref.read(
                                    preferenceSettingsGroupRepositoryProvider(
                                      PreferencePartition.user,
                                      groupName,
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
                  if (filteredSettings.isNotEmpty)
                    SettingsSectionDefinition(
                      title: 'Preference Settings',
                      entries: [
                        for (final setting in filteredSettings)
                          SettingsEntryDefinition(
                            title: setting.value.title ?? setting.key,
                            subtitle: setting.value.description,
                            child: _HardeningSettingTile(
                              groupName: groupName,
                              settingKey: setting.key,
                              settingValue: setting.value,
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
                  preferenceSettingsGroupRepositoryProvider(
                    PreferencePartition.user,
                    groupName,
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

class _HardeningSettingTile extends ConsumerWidget {
  const _HardeningSettingTile({
    required this.groupName,
    required this.settingKey,
    required this.settingValue,
  });

  final String groupName;
  final String settingKey;
  final PreferenceSetting settingValue;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    var value = settingValue.value.toString();
    if (value.length > 160) {
      value = '${value.substring(0, 160)}…';
    }

    return Tooltip(
      message: '$settingKey: $value',
      child: (!settingValue.shouldBeDefault || !settingValue.isActive)
          ? SwitchListTile.adaptive(
              value: settingValue.isActive,
              title: Text(settingValue.title ?? settingKey),
              subtitle: Text.rich(
                TextSpan(
                  children: [
                    if (settingValue.requireUserOptIn)
                      WidgetSpan(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.error,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Optional',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: theme.colorScheme.onError,
                            ),
                          ),
                        ),
                      ),
                    if (settingValue.description != null)
                      TextSpan(text: settingValue.description),
                  ],
                ),
              ),
              secondary: HardeningGroupIcon(isActive: settingValue.isActive),
              onChanged: (value) async {
                final notifier = ref.read(
                  preferenceSettingsGroupRepositoryProvider(
                    PreferencePartition.user,
                    groupName,
                  ).notifier,
                );

                if (value) {
                  await notifier.apply(filter: [settingKey]);
                } else {
                  await notifier.reset(filter: [settingKey]);
                }
              },
            )
          : ListTile(
              title: Text(settingValue.title ?? settingKey),
              subtitle: settingValue.description.mapNotNull(
                (description) => Text(description),
              ),
              leading: HardeningGroupIcon(isActive: settingValue.isActive),
              trailing: const Padding(
                padding: EdgeInsets.only(right: 18.0),
                child: Icon(Icons.check),
              ),
            ),
    );
  }
}
