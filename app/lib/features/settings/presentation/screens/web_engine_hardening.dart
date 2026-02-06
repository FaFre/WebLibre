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
import 'package:weblibre/presentation/widgets/failure_widget.dart';

class WebEngineHardeningScreen extends HookConsumerWidget {
  const WebEngineHardeningScreen();

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

    return Scaffold(
      appBar: AppBar(title: const Text('Web Engine Hardening')),
      body: preferenceGroups.when(
        skipLoadingOnReload: true,
        data: (data) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  color: theme.colorScheme.primaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SwitchListTile(
                      value: allGroupsActive,
                      title: Text(
                        'Complete Hardening',
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
              Expanded(
                child: ListView(
                  children: data.entries.map((group) {
                    return Row(
                      children: [
                        Expanded(
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
            unifiedPreferenceSettingsRepositoryProvider(
              PreferencePartition.user,
            ),
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
