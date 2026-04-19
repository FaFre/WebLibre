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

const _permissionsLearnMoreUrl =
    'https://support.mozilla.org/kb/permission-request-messages-firefox-extensions';

class AddonPermissionsScreen extends ConsumerWidget {
  final String addonId;

  const AddonPermissionsScreen({required this.addonId, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
              ? 'Extension Permissions'
              : '${addon.displayName} Permissions',
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
              'Failed to load extension permissions: $error',
              textAlign: TextAlign.center,
            ),
          ),
        ),
        _ when addon == null => const Center(
          child: Text('This extension could not be found.'),
        ),
        _ => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (permissions.isEmpty && dataCollection.isEmpty)
              Card(
                color: Theme.of(context).colorScheme.surfaceContainerHigh,
                child: const ListTile(
                  leading: Icon(Icons.verified_user_outlined),
                  title: Text('No special permissions listed'),
                  subtitle: Text(
                    'This extension does not currently expose any translated permission details.',
                  ),
                ),
              ),
            if (permissions.isNotEmpty) ...[
              Text(
                'Permissions',
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
                'Required Data Collection',
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
              label: const Text('Learn More'),
            ),
          ],
        ),
      },
    );
  }
}
