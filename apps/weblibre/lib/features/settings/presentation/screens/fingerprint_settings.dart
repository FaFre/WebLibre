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
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nullability/nullability.dart';
import 'package:weblibre/features/settings/presentation/controllers/save_settings.dart';
import 'package:weblibre/features/settings/presentation/widgets/settings_detail.dart';
import 'package:weblibre/features/user/data/models/engine_settings.dart';
import 'package:weblibre/features/user/domain/entities/fingerprint_overrides.dart';
import 'package:weblibre/features/user/domain/providers.dart';
import 'package:weblibre/features/user/domain/services/fingerprinting.dart';
import 'package:weblibre/presentation/widgets/failure_widget.dart';

class FingerprintSettingsScreen extends HookConsumerWidget {
  const FingerprintSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final targetsAsync = ref.watch(fingerprintTargetsProvider);
    final settingsAsync = ref.watch(fingerprintOverrideSettingsProvider);
    final search = useSettingsSearch();

    return SettingsCustomScrollScaffold(
      title: 'Fingerprint Protection',
      searchController: search.controller,
      searchHintText: 'Search fingerprint override targets',
      actions: [
        MenuAnchor(
          builder: (context, controller, child) {
            return IconButton(
              onPressed: () {
                if (controller.isOpen) {
                  controller.close();
                } else {
                  controller.open();
                }
              },
              icon: const Icon(Icons.more_vert),
            );
          },
          menuChildren: [
            MenuItemButton(
              leadingIcon: const Icon(MdiIcons.restore),
              child: const Text('Load Defaults'),
              onPressed: () async {
                await ref
                    .read(saveEngineSettingsControllerProvider.notifier)
                    .save(
                      (currentSettings) => currentSettings.copyWith
                          .fingerprintingProtectionOverrides(
                            FingerprintOverrides.defaults().toString(),
                          ),
                    );
              },
            ),
            MenuItemButton(
              leadingIcon: const Icon(MdiIcons.restore),
              child: const Text('Load Hardened Defaults'),
              onPressed: () async {
                await ref
                    .read(saveEngineSettingsControllerProvider.notifier)
                    .save(
                      (currentSettings) => currentSettings.copyWith
                          .fingerprintingProtectionOverrides(
                            FingerprintOverrides.hardenedDefaults().toString(),
                          ),
                    );
              },
            ),
          ],
        ),
      ],
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 20),
          sliver: SliverToBoxAdapter(
            child: settingsAsync.when(
              skipLoadingOnReload: true,
              data: (result) {
                return result.fold(
                  (overrides) {
                    return targetsAsync.when(
                      skipLoadingOnReload: true,
                      data: (targets) {
                        final filteredTargets = targets.where((target) {
                          if (search.normalizedQuery.isEmpty) return true;
                          return matchesSettingsSearch(search.normalizedQuery, [
                            target.name,
                            if (target.description != null) target.description!,
                          ]);
                        }).toList();

                        return SettingsSectionList(
                          sections: filteredTargets.isEmpty
                              ? const []
                              : [
                                  SettingsSectionDefinition(
                                    title: 'Override Targets',
                                    entries: [
                                      for (final target in filteredTargets)
                                        SettingsEntryDefinition(
                                          title: target.name,
                                          subtitle: target.description,
                                          child: CheckboxListTile.adaptive(
                                            value:
                                                (overrides.allTargets == true &&
                                                    overrides.targets[target
                                                            .name] !=
                                                        false) ||
                                                overrides.targets[target
                                                        .name] ==
                                                    true,
                                            onChanged: (value) async {
                                              if (value != null) {
                                                final newOverrides = overrides
                                                    .copyWithTarget(
                                                      target.name,
                                                      value,
                                                    )
                                                    .toString();

                                                await ref
                                                    .read(
                                                      saveEngineSettingsControllerProvider
                                                          .notifier,
                                                    )
                                                    .save(
                                                      (
                                                        currentSettings,
                                                      ) => currentSettings
                                                          .copyWith
                                                          .fingerprintingProtectionOverrides(
                                                            newOverrides,
                                                          ),
                                                    );
                                              }
                                            },
                                            title: Text(target.name),
                                            subtitle: target.description
                                                .mapNotNull(
                                                  (desc) => Text(desc),
                                                ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                          query: search.rawQuery,
                        );
                      },
                      error: (error, stackTrace) {
                        return FailureWidget(
                          exception: error,
                          onRetry: () {
                            ref.invalidate(fingerprintTargetsProvider);
                          },
                        );
                      },
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                    );
                  },
                  onFailure: (errorMessage) {
                    return FailureWidget(
                      title: errorMessage.message,
                      exception: errorMessage.details,
                      onRetry: () {
                        ref.invalidate(fingerprintOverrideSettingsProvider);
                      },
                    );
                  },
                );
              },
              error: (error, stackTrace) {
                return FailureWidget(
                  exception: error,
                  onRetry: () {
                    ref.invalidate(fingerprintOverrideSettingsProvider);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
            ),
          ),
        ),
      ],
    );
  }
}
