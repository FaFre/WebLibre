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
import 'package:fading_scroll/fading_scroll.dart';
import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/features/settings/presentation/controllers/save_settings.dart';
import 'package:weblibre/features/settings/presentation/widgets/sections.dart';
import 'package:weblibre/features/user/data/models/engine_settings.dart';
import 'package:weblibre/features/user/domain/presentation/dialogs/quit_browser_dialog.dart';
import 'package:weblibre/features/user/domain/repositories/engine_settings.dart';
import 'package:weblibre/utils/exit_app.dart';

class ExperimentalSettingsScreen extends StatelessWidget {
  const ExperimentalSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Experimental')),
      body: SafeArea(
        child: FadingScroll(
          fadingSize: 25,
          builder: (context, controller) {
            return ListView(
              controller: controller,
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              children: const [
                SettingSection(name: 'Web Push'),
                _UnifiedPushDistributorTile(),
                SettingSection(name: 'Runtime & Startup'),
                _IsolatedProcessEnabledTile(),
                _AppZygoteProcessEnabledTile(),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _UnifiedPushDistributorTile extends StatelessWidget {
  const _UnifiedPushDistributorTile();

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(MdiIcons.bellBadgeOutline),
      title: const Text('Choose UnifiedPush Distributor'),
      subtitle: const Text(
        'Select the app that should deliver website push notifications to WebLibre.',
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () async {
        final messenger = ScaffoldMessenger.of(context);
        final success = await GeckoBrowserService()
            .pickUnifiedPushDistributor();

        if (!context.mounted) {
          return;
        }

        messenger.showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'UnifiedPush distributor configured.'
                  : 'Could not configure UnifiedPush. Install a distributor and try again.',
            ),
          ),
        );
      },
    );
  }
}

class _IsolatedProcessEnabledTile extends HookConsumerWidget {
  const _IsolatedProcessEnabledTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isolatedProcessEnabled = ref.watch(
      engineSettingsWithDefaultsProvider.select(
        (s) => s.isolatedProcessEnabled,
      ),
    );

    return SwitchListTile.adaptive(
      title: const Text('Isolated Content Process'),
      subtitle: const Text(
        'Run web content in an isolated process. Requires app restart.',
      ),
      secondary: const Icon(MdiIcons.shieldCheck),
      value: isolatedProcessEnabled,
      onChanged: (value) async {
        await ref
            .read(saveEngineSettingsControllerProvider.notifier)
            .save(
              (currentSettings) =>
                  currentSettings.copyWith.isolatedProcessEnabled(value),
            );
        if (context.mounted) {
          await _showRestartDialog(context);
        }
      },
    );
  }
}

class _AppZygoteProcessEnabledTile extends HookConsumerWidget {
  const _AppZygoteProcessEnabledTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appZygoteProcessEnabled = ref.watch(
      engineSettingsWithDefaultsProvider.select(
        (s) => s.appZygoteProcessEnabled,
      ),
    );

    return SwitchListTile.adaptive(
      title: const Text('App Zygote Process'),
      subtitle: const Text(
        'Preload the content service for faster isolated process startup. Requires Android 10+ and app restart.',
      ),
      secondary: const Icon(MdiIcons.rocketLaunch),
      value: appZygoteProcessEnabled,
      onChanged: (value) async {
        await ref
            .read(saveEngineSettingsControllerProvider.notifier)
            .save(
              (currentSettings) =>
                  currentSettings.copyWith.appZygoteProcessEnabled(value),
            );
        if (context.mounted) {
          await _showRestartDialog(context);
        }
      },
    );
  }
}

Future<void> _showRestartDialog(BuildContext context) async {
  final result = await showQuitBrowserDialog(context);
  if (result == true && context.mounted) {
    await exitApp(ProviderScope.containerOf(context));
  }
}
