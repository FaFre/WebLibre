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

import 'package:fading_scroll/fading_scroll.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/services/browser_addon.dart';
import 'package:weblibre/features/settings/presentation/widgets/custom_list_tile.dart';
import 'package:weblibre/features/settings/presentation/widgets/sections.dart';

class ExtensionsSettingsScreen extends StatelessWidget {
  const ExtensionsSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Extensions')),
      body: SafeArea(
        child: FadingScroll(
          fadingSize: 25,
          builder: (context, controller) {
            return ListView(
              controller: controller,
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              children: const [
                SettingSection(name: 'Extensions'),
                _ManageExtensionsTile(),
                _AddonCollectionTile(),
                SettingSection(name: 'Updates'),
                _AutoUpdateTile(),
                SettingSection(name: 'Security'),
                _AllowUnsignedExtensionsTile(),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ManageExtensionsTile extends StatelessWidget {
  const _ManageExtensionsTile();

  @override
  Widget build(BuildContext context) {
    return CustomListTile(
      title: 'Manage Extensions',
      subtitle:
          'Browse installed, disabled, available, and unsupported extensions',
      prefix: Padding(
        padding: const EdgeInsets.only(right: 16.0),
        child: Icon(
          MdiIcons.puzzleEdit,
          size: 24,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
      suffix: FilledButton.icon(
        onPressed: () async {
          await const AddonManagerRoute().push<void>(context);
        },
        icon: const Icon(Icons.open_in_new),
        label: const Text('Open'),
      ),
    );
  }
}

class _AddonCollectionTile extends StatelessWidget {
  const _AddonCollectionTile();

  @override
  Widget build(BuildContext context) {
    return CustomListTile(
      title: 'Custom Collection',
      subtitle: 'Use a custom Mozilla addon collection',
      prefix: Padding(
        padding: const EdgeInsets.only(right: 16.0),
        child: Icon(
          MdiIcons.folderMultiple,
          size: 24,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
      suffix: FilledButton.icon(
        onPressed: () async {
          await AddonCollectionRoute().push(context);
        },
        icon: const Icon(Icons.settings),
        label: const Text('Configure'),
      ),
    );
  }
}

class _AutoUpdateTile extends ConsumerWidget {
  const _AutoUpdateTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final autoUpdate = ref.watch(addonAutoUpdateProvider);

    return autoUpdate.when(
      data: (enabled) => SwitchListTile.adaptive(
        title: const Text('Automatic updates'),
        subtitle: const Text(
          'Automatically check for and install extension updates every 12 hours',
        ),
        secondary: const Icon(Icons.system_update_alt),
        value: enabled,
        onChanged: (value) async {
          await ref
              .read(addonAutoUpdateProvider.notifier)
              .setEnabled(enabled: value);
        },
      ),
      loading: () => const SwitchListTile.adaptive(
        title: Text('Automatic updates'),
        subtitle: Text(
          'Automatically check for and install extension updates every 12 hours',
        ),
        secondary: Icon(Icons.system_update_alt),
        value: true,
        onChanged: null,
      ),
      error: (error, stack) => ListTile(
        leading: const Icon(Icons.error_outline),
        title: const Text('Automatic updates'),
        subtitle: Text('Failed to load: $error'),
      ),
    );
  }
}

class _AllowUnsignedExtensionsTile extends ConsumerWidget {
  const _AllowUnsignedExtensionsTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allowUnsigned = ref.watch(allowUnsignedExtensionsProvider);

    return allowUnsigned.when(
      data: (allowed) => Column(
        children: [
          SwitchListTile.adaptive(
            title: const Text('Allow unsigned extensions'),
            subtitle: const Text(
              'Unsigned extensions have not been verified by Mozilla',
            ),
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
                        'Only install unsigned extensions from sources you trust. '
                        'They may contain malicious code.',
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
      loading: () => const SwitchListTile.adaptive(
        title: Text('Allow unsigned extensions'),
        subtitle: Text('Unsigned extensions have not been verified by Mozilla'),
        secondary: Icon(Icons.extension_off),
        value: false,
        onChanged: null,
      ),
      error: (error, stack) => ListTile(
        leading: const Icon(Icons.error_outline),
        title: const Text('Allow unsigned extensions'),
        subtitle: Text('Failed to load: $error'),
      ),
    );
  }
}

Future<bool?> _showAllowUnsignedConfirmationDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
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

    return AlertDialog(
      icon: Icon(
        Icons.warning_amber_rounded,
        color: theme.colorScheme.error,
        size: 40,
      ),
      title: const Text('Allow unsigned extensions?'),
      content: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text:
                  "Warning: This significantly weakens your browser's security."
                  '\n\n',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.error,
              ),
            ),
            const TextSpan(
              text:
                  "Unsigned extensions bypass Mozilla's safety review process. "
                  'Malicious extensions can:\n\n'
                  '\u2022 Read and modify everything you see on any website\n'
                  '\u2022 Steal passwords, banking details, and personal data\n'
                  '\u2022 Monitor your browsing activity silently\n'
                  '\u2022 Install additional malware on your device\n\n',
            ),
            const TextSpan(
              text:
                  'Only enable this if you are a developer installing your own '
                  'extension or absolutely trust the source.',
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: canConfirm ? () => Navigator.of(context).pop(true) : null,
          style: FilledButton.styleFrom(
            backgroundColor: theme.colorScheme.error,
            foregroundColor: theme.colorScheme.onError,
          ),
          child: Text(canConfirm ? 'Allow' : 'Allow (${remaining.value})'),
        ),
      ],
    );
  }
}
