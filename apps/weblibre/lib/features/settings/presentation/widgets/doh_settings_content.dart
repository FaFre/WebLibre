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
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/core/design/display_features.dart';
import 'package:weblibre/extensions/uri.dart';
import 'package:weblibre/features/settings/presentation/controllers/save_settings.dart';
import 'package:weblibre/features/user/data/models/engine_settings.dart';
import 'package:weblibre/features/user/domain/repositories/engine_settings.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';
import 'package:weblibre/utils/form_validators.dart';

class DohSettingsContent extends HookConsumerWidget {
  const DohSettingsContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    final dohSettings = ref.watch(
      engineSettingsWithDefaultsProvider.select((value) => value.dohSettings),
    );
    // Already includes a resolver that predates saved resolvers — the model
    // adopts it out of `dohProviderUrl` on deserialization.
    final resolvers = ref.watch(
      engineSettingsWithDefaultsProvider.select(
        (value) => value.customDohProviders,
      ),
    );

    Future<void> save(UpdateEngineSettingsFunc updateSettings) {
      return ref
          .read(saveEngineSettingsControllerProvider.notifier)
          .save(updateSettings);
    }

    final selectedUrl = dohSettings.dohProviderUrl;

    return Column(
      children: [
        ListTile(
          leading: const Icon(MdiIcons.dns),
          title: Text(l10n.settings_protectionLevelTitle),
          subtitle: Text(l10n.settings_protectionLevelDescription),
        ),
        RadioGroup(
          groupValue: dohSettings.dohSettingsMode,
          onChanged: (value) async {
            if (value != null) {
              await save(
                (currentSettings) =>
                    currentSettings.copyWith.dohSettingsMode(value),
              );
            }
          },
          child: Column(
            children: [
              RadioListTile.adaptive(
                value: DohSettingsMode.geckoDefault,
                title: Text(l10n.settings_defaultProtectionTitle),
                subtitle: Text(l10n.settings_defaultProtectionSubtitle),
              ),
              RadioListTile.adaptive(
                value: DohSettingsMode.increased,
                title: Text(l10n.settings_increasedProtectionTitle),
                subtitle: Text(l10n.settings_increasedProtectionSubtitle),
              ),
              RadioListTile.adaptive(
                value: DohSettingsMode.max,
                title: Text(l10n.settings_maxProtectionTitle),
                subtitle: Text(l10n.settings_maxProtectionSubtitle),
              ),
              RadioListTile.adaptive(
                value: DohSettingsMode.off,
                title: Text(l10n.settings_protectionOffTitle),
                subtitle: Text(l10n.settings_protectionOffSubtitle),
              ),
            ],
          ),
        ),
        ListTile(
          leading: const Icon(MdiIcons.routerNetwork),
          title: Text(l10n.settings_dohProviderTitle),
        ),
        RadioGroup(
          groupValue: selectedUrl,
          onChanged: (value) async {
            if (value != null) {
              await save(
                (currentSettings) =>
                    currentSettings.copyWith.dohProviderUrl(value),
              );
            }
          },
          child: Column(
            children: [
              ...BuiltInDohProviders.values.map(
                (provider) => RadioListTile.adaptive(
                  value: provider.url,
                  title: Text(provider.name),
                  subtitle: Text(provider.url.uriDisplayString),
                ),
              ),
              if (resolvers.isNotEmpty)
                ListTile(
                  dense: true,
                  title: Text(
                    l10n.settings_yourResolvers,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ...resolvers.map(
                (provider) => RadioListTile.adaptive(
                  value: provider.url,
                  title: Text(provider.displayName),
                  subtitle: Text(provider.url.uriDisplayString),
                  secondary: _ResolverActions(
                    onEdit: () async {
                      final result = await _promptForResolver(
                        context,
                        existing: resolvers,
                        initial: provider,
                      );
                      if (result == null) {
                        return;
                      }

                      await save((currentSettings) {
                        final updated = [...currentSettings.customDohProviders];
                        final index = updated.indexWhere(
                          (entry) => entry.url == provider.url,
                        );
                        if (index >= 0) {
                          updated[index] = result;
                        } else {
                          updated.add(result);
                        }

                        final settings = currentSettings.copyWith
                            .customDohProviders(updated);

                        return currentSettings.dohProviderUrl == provider.url
                            ? settings.copyWith.dohProviderUrl(result.url)
                            : settings;
                      });
                    },
                    onDelete: () async {
                      await save((currentSettings) {
                        final updated = [...currentSettings.customDohProviders]
                          ..removeWhere((entry) => entry.url == provider.url);

                        final settings = currentSettings.copyWith
                            .customDohProviders(updated);

                        // Never leave the engine pointed at a resolver that no
                        // longer exists — under max protection there is no
                        // fallback, so name resolution would stop entirely.
                        return currentSettings.dohProviderUrl == provider.url
                            ? settings.copyWith.dohProviderUrl(
                                currentSettings.dohDefaultProviderUrl,
                              )
                            : settings;
                      });
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: SizedBox(
            width: double.infinity,
            child: FilledButton.tonalIcon(
              icon: const Icon(Icons.add),
              label: Text(l10n.settings_addCustomResolver),
              onPressed: resolvers.length >= kMaxCustomDohProviders
                  ? null
                  : () async {
                      final result = await _promptForResolver(
                        context,
                        existing: resolvers,
                      );
                      if (result == null) {
                        return;
                      }

                      await save(
                        (currentSettings) => currentSettings.copyWith
                            .customDohProviders([
                              ...currentSettings.customDohProviders,
                              result,
                            ])
                            .copyWith
                            .dohProviderUrl(result.url),
                      );
                    },
            ),
          ),
        ),
      ],
    );
  }
}

class _ResolverActions extends StatelessWidget {
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ResolverActions({required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.edit_outlined),
          color: colorScheme.onSurfaceVariant,
          tooltip: l10n.common_edit,
          visualDensity: VisualDensity.compact,
          onPressed: onEdit,
        ),
        IconButton(
          icon: const Icon(Icons.delete_outline),
          color: colorScheme.onSurfaceVariant,
          tooltip: l10n.common_remove,
          visualDensity: VisualDensity.compact,
          onPressed: onDelete,
        ),
      ],
    );
  }
}

Future<CustomDohProvider?> _promptForResolver(
  BuildContext context, {
  required List<CustomDohProvider> existing,
  CustomDohProvider? initial,
}) {
  return showDialog<CustomDohProvider>(
    context: context,
    anchorPoint: preferredAnchorPoint(MediaQuery.of(context)),
    builder: (context) =>
        _CustomResolverDialog(existing: existing, initial: initial),
  );
}

class _CustomResolverDialog extends HookWidget {
  final List<CustomDohProvider> existing;
  final CustomDohProvider? initial;

  const _CustomResolverDialog({required this.existing, this.initial});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isEdit = initial != null;
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final urlController = useTextEditingController(text: initial?.url ?? '');
    final nameController = useTextEditingController(text: initial?.name ?? '');

    return AlertDialog(
      title: Text(
        isEdit
            ? l10n.settings_editCustomResolverTitle
            : l10n.settings_addCustomResolver,
      ),
      content: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: urlController,
              autofocus: !isEdit,
              keyboardType: TextInputType.url,
              decoration: InputDecoration(
                labelText: l10n.settings_resolverUrlLabel,
                hintText: 'https://example.com/dns-query',
              ),
              validator: (value) {
                final trimmed = value?.trim() ?? '';

                final urlError = validateUrl(
                  trimmed,
                  onlyHttpProtocol: true,
                  eagerParsing: false,
                  l10n: l10n,
                );
                if (urlError != null) {
                  return urlError;
                }

                if (BuiltInDohProviders.isBuiltin(trimmed)) {
                  return l10n.settings_alreadyBuiltInProvider;
                }

                final clash = existing.any(
                  (entry) => entry.url == trimmed && entry.url != initial?.url,
                );
                if (clash) {
                  return l10n.settings_alreadyAdded;
                }

                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: nameController,
              autofocus: isEdit,
              maxLength: 40,
              decoration: InputDecoration(
                labelText: l10n.settings_resolverNameLabel,
                hintText: l10n.settings_resolverNameHint,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.common_cancel),
        ),
        FilledButton(
          onPressed: () {
            if (formKey.currentState?.validate() == true) {
              final name = nameController.text.trim();

              Navigator.of(context).pop(
                CustomDohProvider(
                  url: urlController.text.trim(),
                  name: name.isEmpty ? null : name,
                ),
              );
            }
          },
          child: Text(isEdit ? l10n.common_save : l10n.settings_saveAndUse),
        ),
      ],
    );
  }
}
