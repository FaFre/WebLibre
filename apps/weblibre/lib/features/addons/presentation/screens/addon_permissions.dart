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
import 'package:url_launcher/url_launcher.dart';
import 'package:weblibre/features/addons/domain/providers.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';

const _permissionsLearnMoreUrl =
    'https://support.mozilla.org/kb/permission-request-messages-firefox-extensions';

class AddonPermissionsScreen extends ConsumerWidget {
  final String addonId;

  const AddonPermissionsScreen({required this.addonId, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final addonAsync = ref.watch(addonDetailsProvider(addonId));
    final addon = addonAsync.value;

    final permissions = addon?.translatedPermissions.toList() ?? <String>[];
    permissions.sort();

    final dataCollection =
        addon?.translatedRequiredDataCollectionPermissions.toList() ??
        <String>[];
    dataCollection.sort();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          addon == null
              ? l10n.addons_permissionsTitleGeneric
              : l10n.addons_permissionsTitleNamed(addon.displayName),
        ),
      ),
      body: switch (addonAsync) {
        AsyncLoading() when addon == null => const Center(
          child: CircularProgressIndicator(),
        ),
        AsyncError(:final error) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              l10n.addons_permissionsLoadFailed(error.toString()),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        _ when addon == null => Center(child: Text(l10n.addons_notFound)),
        _ => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (permissions.isEmpty && dataCollection.isEmpty)
              Card(
                color: Theme.of(context).colorScheme.surfaceContainerHigh,
                child: ListTile(
                  leading: const Icon(Icons.verified_user_outlined),
                  title: Text(l10n.addons_noSpecialPermissions),
                  subtitle: Text(l10n.addons_noTranslatedPermissionDetails),
                ),
              ),
            if (permissions.isNotEmpty) ...[
              Text(
                l10n.addons_permissionsTitle,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Card(
                color: Theme.of(context).colorScheme.surfaceContainerHigh,
                child: Column(
                  children: [
                    for (final permission in permissions)
                      ListTile(
                        leading: const Icon(Icons.check_circle_outline),
                        title: Text(permission),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            if (dataCollection.isNotEmpty) ...[
              Text(
                l10n.addons_requiredDataCollectionTitle,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Card(
                color: Theme.of(context).colorScheme.surfaceContainerHigh,
                child: Column(
                  children: [
                    for (final permission in dataCollection)
                      ListTile(
                        leading: const Icon(Icons.data_usage_outlined),
                        title: Text(permission),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            FilledButton.icon(
              onPressed: () async {
                await launchUrl(Uri.parse(_permissionsLearnMoreUrl));
              },
              icon: const Icon(Icons.open_in_new),
              label: Text(l10n.addons_actionLearnMore),
            ),
          ],
        ),
      },
    );
  }
}
