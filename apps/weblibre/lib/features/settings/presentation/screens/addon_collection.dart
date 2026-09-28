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
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:weblibre/features/settings/presentation/widgets/settings_detail.dart';
import 'package:weblibre/features/user/data/models/engine_settings.dart';
import 'package:weblibre/features/user/domain/repositories/engine_settings.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';
import 'package:weblibre/utils/exit_app.dart';
import 'package:weblibre/utils/form_validators.dart';

const _defaultServerUrl = 'https://services.addons.mozilla.org';

class AddonCollectionScreen extends HookConsumerWidget {
  const AddonCollectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final formKey = useMemoized(() => GlobalKey<FormState>());

    final addonCollectionSetting = ref.watch(
      engineSettingsWithDefaultsProvider.select(
        (value) => value.addonCollection,
      ),
    );

    final serverURLController = useTextEditingController(
      text: addonCollectionSetting?.serverURL ?? _defaultServerUrl,
      keys: [addonCollectionSetting],
    );

    final collectionUserController = useTextEditingController(
      text: addonCollectionSetting?.collectionUser,
      keys: [addonCollectionSetting],
    );

    final collectionNameController = useTextEditingController(
      text: addonCollectionSetting?.collectionName,
      keys: [addonCollectionSetting],
    );

    return SettingsCustomScrollScaffold(
      title: l10n.settings_addonCollectionTitle,
      actions: [
        if (addonCollectionSetting != null)
          IconButton(
            onPressed: () async {
              await ref
                  .read(engineSettingsRepositoryProvider.notifier)
                  .updateSettings(
                    (currentSettings) =>
                        currentSettings.copyWith.addonCollection(null),
                  );

              await exitApp(ref.container);
            },
            icon: const Icon(Icons.delete),
          ),
      ],
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 20),
          sliver: SliverToBoxAdapter(
            child: Form(
              key: formKey,
              child: SettingsSectionList(
                sections: [
                  SettingsSectionDefinition(
                    title: l10n.settings_addonCollectionSourceSectionTitle,
                    entries: [
                      SettingsEntryDefinition(
                        title: l10n.settings_addonCollectionConfigTitle,
                        subtitle: l10n.settings_addonCollectionConfigSubtitle,
                        keywords: settingsKeywords(
                          l10n.settings_addonCollectionConfigKeywords,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              TextFormField(
                                controller: serverURLController,
                                decoration: InputDecoration(
                                  label: Text(
                                    l10n.settings_addonCollectionServerUrlLabel,
                                  ),
                                  hintText: _defaultServerUrl,
                                  floatingLabelBehavior:
                                      FloatingLabelBehavior.always,
                                ),
                                keyboardType: TextInputType.url,
                                validator: (value) {
                                  return validateUrl(
                                    value,
                                    onlyHttpProtocol: true,
                                    eagerParsing: false,
                                    l10n: l10n,
                                  );
                                },
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: collectionUserController,
                                decoration: InputDecoration(
                                  label: Text(
                                    l10n.settings_addonCollectionUserLabel,
                                  ),
                                  floatingLabelBehavior:
                                      FloatingLabelBehavior.always,
                                ),
                                validator: (value) =>
                                    validateRequired(value, l10n: l10n),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: collectionNameController,
                                decoration: InputDecoration(
                                  label: Text(
                                    l10n.settings_addonCollectionNameLabel,
                                  ),
                                  floatingLabelBehavior:
                                      FloatingLabelBehavior.always,
                                ),
                                validator: (value) =>
                                    validateRequired(value, l10n: l10n),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SettingsSectionDefinition(
                    title: l10n.settings_addonCollectionActionsSectionTitle,
                    entries: [
                      SettingsEntryDefinition(
                        title: l10n.settings_addonCollectionSaveRestartTitle,
                        subtitle:
                            l10n.settings_addonCollectionSaveRestartSubtitle,
                        keywords: settingsKeywords(
                          l10n.settings_addonCollectionSaveRestartKeywords,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              onPressed: () async {
                                if (formKey.currentState?.validate() == true) {
                                  await ref
                                      .read(
                                        engineSettingsRepositoryProvider
                                            .notifier,
                                      )
                                      .updateSettings(
                                        (currentSettings) => currentSettings
                                            .copyWith
                                            .addonCollection(
                                              AddonCollection(
                                                serverURL:
                                                    serverURLController.text,
                                                collectionUser:
                                                    collectionUserController
                                                        .text,
                                                collectionName:
                                                    collectionNameController
                                                        .text,
                                              ),
                                            ),
                                      );

                                  await exitApp(ref.container);
                                }
                              },
                              child: Text(
                                l10n.settings_addonCollectionSaveRestartTitle,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                query: '',
              ),
            ),
          ),
        ),
      ],
    );
  }
}
