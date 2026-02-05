/*
 * Copyright (c) 2024-2025 Fabian Freund.
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
import 'package:weblibre/features/geckoview/features/preferences/data/repositories/preference_settings.dart';
import 'package:weblibre/features/geckoview/features/tabs/utils/setting_groups_serializer.dart';
import 'package:weblibre/features/settings/presentation/widgets/hardening_group_icon.dart';
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

    return Scaffold(
      appBar: AppBar(title: Text(groupName)),
      body: settings.when(
        skipLoadingOnReload: true,
        data: (group) {
          return Column(
            children: [
              if (group.showMasterSwitch)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    color: theme.colorScheme.primaryContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SwitchListTile(
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
                              color: theme.colorScheme.onPrimaryContainer,
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
              Expanded(
                child: ListView(
                  children: group.settings.entries.map((setting) {
                    var value = setting.value.value.toString();
                    if (value.length > 160) {
                      value = '${value.substring(0, 160)}…';
                    }

                    return Tooltip(
                      message: '${setting.key}: $value',
                      child: Row(
                        children: [
                          if (!setting.value.shouldBeDefault ||
                              !setting.value.isActive)
                            Expanded(
                              child: SwitchListTile(
                                value: setting.value.isActive,
                                title: Text(setting.value.title ?? setting.key),
                                subtitle: Text.rich(
                                  TextSpan(
                                    children: [
                                      if (setting.value.requireUserOptIn)
                                        WidgetSpan(
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 2,
                                            ),
                                            margin: const EdgeInsets.only(
                                              right: 8,
                                            ),
                                            decoration: BoxDecoration(
                                              color: theme.colorScheme.error,
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              'Optional',
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w500,
                                                color:
                                                    theme.colorScheme.onError,
                                              ),
                                            ),
                                          ),
                                        ),
                                      if (setting.value.description != null)
                                        TextSpan(
                                          text: setting.value.description,
                                          // style: theme.textTheme.bodyMedium,
                                        ),
                                    ],
                                  ),
                                ),
                                secondary: HardeningGroupIcon(
                                  isActive: setting.value.isActive,
                                ),
                                onChanged: (value) async {
                                  final notifier = ref.read(
                                    preferenceSettingsGroupRepositoryProvider(
                                      PreferencePartition.user,
                                      groupName,
                                    ).notifier,
                                  );

                                  if (value) {
                                    await notifier.apply(filter: [setting.key]);
                                  } else {
                                    await notifier.reset(filter: [setting.key]);
                                  }
                                },
                              ),
                            )
                          else
                            Expanded(
                              child: ListTile(
                                title: Text(setting.value.title ?? setting.key),
                                subtitle: setting.value.description.mapNotNull(
                                  (description) => Text(description),
                                ),
                                leading: HardeningGroupIcon(
                                  isActive: setting.value.isActive,
                                ),
                                trailing: const Padding(
                                  padding: EdgeInsets.only(right: 18.0),
                                  child: Icon(Icons.check),
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
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
    );
  }
}
