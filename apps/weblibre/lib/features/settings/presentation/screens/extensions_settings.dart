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
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/core/design/display_features.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/services/browser_addon.dart';
import 'package:weblibre/features/settings/presentation/screens/protection_coherence_settings.dart';
import 'package:weblibre/features/settings/presentation/widgets/settings_detail.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';

List<SettingsSectionDefinition> extensionsSettingsSections(
  BuildContext context,
) {
  final l10n = AppLocalizations.of(context);

  return [
    SettingsSectionDefinition(
      title: l10n.settings_extensionsSectionTitle,
      entries: [
        SettingsEntryDefinition(
          title: l10n.settings_manageExtensionsTitle,
          subtitle: l10n.settings_manageExtensionsSubtitle,
          keywords: settingsKeywords(l10n.settings_manageExtensionsKeywords),
          child: const _ManageExtensionsTile(),
        ),
        SettingsEntryDefinition(
          title: l10n.settings_customCollectionTitle,
          subtitle: l10n.settings_customCollectionSubtitle,
          keywords: settingsKeywords(l10n.settings_customCollectionKeywords),
          child: const _AddonCollectionTile(),
        ),
      ],
    ),
    SettingsSectionDefinition(
      title: l10n.settings_updatesSectionTitle,
      entries: [
        SettingsEntryDefinition(
          title: l10n.settings_automaticUpdatesTitle,
          subtitle: l10n.settings_automaticUpdatesSubtitle,
          keywords: settingsKeywords(l10n.settings_automaticUpdatesKeywords),
          child: const _AutoUpdateTile(),
        ),
      ],
    ),
    SettingsSectionDefinition(
      title: l10n.settings_securitySectionTitle,
      entries: [
        SettingsEntryDefinition(
          title: l10n.settings_allowUnsignedExtensionsTitle,
          subtitle: l10n.settings_allowUnsignedExtensionsSubtitle,
          keywords: settingsKeywords(
            l10n.settings_allowUnsignedExtensionsKeywords,
          ),
          child: const _AllowUnsignedExtensionsTile(),
        ),
      ],
    ),
    ...protectionCoherenceSections(context),
  ];
}

class ExtensionsSettingsScreen extends StatelessWidget {
  const ExtensionsSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SettingsDetailScaffold(
      title: l10n.settings_extensionsTitle,
      subtitle: l10n.settings_extensionsSubtitle,
      icon: MdiIcons.puzzleOutline,
      sections: extensionsSettingsSections(context),
    );
  }
}

class _ManageExtensionsTile extends StatelessWidget {
  const _ManageExtensionsTile();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return ListTile(
      leading: Icon(
        MdiIcons.puzzleEdit,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      title: Text(l10n.settings_manageExtensionsTitle),
      subtitle: Text(l10n.settings_manageExtensionsSubtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: () async {
        await const AddonManagerRoute().push<void>(context);
      },
    );
  }
}

class _AddonCollectionTile extends StatelessWidget {
  const _AddonCollectionTile();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return ListTile(
      leading: Icon(
        MdiIcons.folderMultiple,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      title: Text(l10n.settings_customCollectionTitle),
      subtitle: Text(l10n.settings_customCollectionSubtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: () async {
        await AddonCollectionRoute().push(context);
      },
    );
  }
}

class _AutoUpdateTile extends ConsumerWidget {
  const _AutoUpdateTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final autoUpdate = ref.watch(addonAutoUpdateProvider);
    final l10n = AppLocalizations.of(context);

    return autoUpdate.when(
      data: (enabled) => SwitchListTile.adaptive(
        title: Text(l10n.settings_automaticUpdatesTitle),
        subtitle: Text(l10n.settings_automaticUpdatesSubtitle),
        secondary: const Icon(Icons.system_update_alt),
        value: enabled,
        onChanged: (value) async {
          await ref
              .read(addonAutoUpdateProvider.notifier)
              .setEnabled(enabled: value);
        },
      ),
      loading: () => SwitchListTile.adaptive(
        title: Text(l10n.settings_automaticUpdatesTitle),
        subtitle: Text(l10n.settings_automaticUpdatesSubtitle),
        secondary: const Icon(Icons.system_update_alt),
        value: true,
        onChanged: null,
      ),
      error: (error, stack) => ListTile(
        leading: const Icon(Icons.error_outline),
        title: Text(l10n.settings_automaticUpdatesTitle),
        subtitle: Text(l10n.settings_failedToLoadMessage('$error')),
      ),
    );
  }
}

class _AllowUnsignedExtensionsTile extends ConsumerWidget {
  const _AllowUnsignedExtensionsTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allowUnsigned = ref.watch(allowUnsignedExtensionsProvider);
    final l10n = AppLocalizations.of(context);

    return allowUnsigned.when(
      data: (allowed) => Column(
        children: [
          SwitchListTile.adaptive(
            title: Text(l10n.settings_allowUnsignedExtensionsTitle),
            subtitle: Text(l10n.settings_allowUnsignedExtensionsSubtitle),
            secondary: const Icon(Icons.extension_off),
            value: allowed,
            onChanged: (value) async {
              if (value) {
                final confirmed = await _showAllowUnsignedConfirmationDialog(
                  context,
                );
                if (confirmed != true) return;
              }
              await ref
                  .read(allowUnsignedExtensionsProvider.notifier)
                  .setAllowUnsigned(allow: value);
            },
          ),
          if (allowed)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.errorContainer.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_amber,
                      color: Theme.of(context).colorScheme.error,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l10n.settings_allowUnsignedWarningText,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onErrorContainer,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      loading: () => SwitchListTile.adaptive(
        title: Text(l10n.settings_allowUnsignedExtensionsTitle),
        subtitle: Text(l10n.settings_allowUnsignedExtensionsSubtitle),
        secondary: const Icon(Icons.extension_off),
        value: false,
        onChanged: null,
      ),
      error: (error, stack) => ListTile(
        leading: const Icon(Icons.error_outline),
        title: Text(l10n.settings_allowUnsignedExtensionsTitle),
        subtitle: Text(l10n.settings_failedToLoadMessage('$error')),
      ),
    );
  }
}

Future<bool?> _showAllowUnsignedConfirmationDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    anchorPoint: preferredAnchorPoint(MediaQuery.of(context)),
    builder: (context) => const _AllowUnsignedConfirmationDialog(),
  );
}

class _AllowUnsignedConfirmationDialog extends HookWidget {
  const _AllowUnsignedConfirmationDialog();

  static const _countdownSeconds = 15;

  @override
  Widget build(BuildContext context) {
    final remaining = useState(_countdownSeconds);

    useEffect(() {
      final timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (remaining.value > 0) {
          remaining.value--;
        }
      });
      return timer.cancel;
    }, []);

    final theme = Theme.of(context);
    final canConfirm = remaining.value == 0;
    final l10n = AppLocalizations.of(context);

    return AlertDialog(
      icon: Icon(
        Icons.warning_amber_rounded,
        color: theme.colorScheme.error,
        size: 40,
      ),
      title: Text(l10n.settings_allowUnsignedConfirmDialogTitle),
      content: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: '${l10n.settings_allowUnsignedConfirmWarningBold}\n\n',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.error,
              ),
            ),
            TextSpan(text: '${l10n.settings_allowUnsignedConfirmBody}\n\n'),
            TextSpan(text: l10n.settings_allowUnsignedConfirmFooter),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.common_cancel),
        ),
        FilledButton(
          onPressed: canConfirm ? () => Navigator.of(context).pop(true) : null,
          style: FilledButton.styleFrom(
            backgroundColor: theme.colorScheme.error,
            foregroundColor: theme.colorScheme.onError,
          ),
          child: Text(
            canConfirm
                ? l10n.settings_allowAction
                : l10n.settings_allowActionCountdown(remaining.value),
          ),
        ),
      ],
    );
  }
}
