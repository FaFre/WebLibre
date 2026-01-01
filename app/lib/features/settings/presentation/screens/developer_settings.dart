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
import 'dart:developer';

import 'package:fading_scroll/fading_scroll.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:weblibre/core/logger.dart';
import 'package:weblibre/core/providers/app_state.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/features/settings/presentation/controllers/save_settings.dart';
import 'package:weblibre/features/settings/presentation/dialogs/user_agent_restart_dialog.dart';
import 'package:weblibre/features/settings/presentation/widgets/custom_list_tile.dart';
import 'package:weblibre/features/user/data/models/engine_settings.dart';
import 'package:weblibre/features/user/domain/repositories/engine_settings.dart';
import 'package:weblibre/utils/exit_app.dart';
import 'package:weblibre/utils/ui_helper.dart';

class DeveloperSettingsScreen extends HookConsumerWidget {
  const DeveloperSettingsScreen();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final engineSettings = ref.watch(engineSettingsWithDefaultsProvider);

    final userAgentTextController = useTextEditingController(
      text: engineSettings.userAgent,
      keys: [engineSettings.userAgent],
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Developer Settings')),
      body: FadingScroll(
        fadingSize: 25,
        builder: (context, controller) {
          return ListView(
            controller: controller,
            children: [
              SwitchListTile.adaptive(
                title: const Text('Enable JavaScript'),
                subtitle: const Text(
                  'While turning off JavaScript can boost security, privacy, and speed, it may cause some sites to not work as intended.',
                ),
                // ignore: deprecated_member_use use this icon for now
                secondary: const Icon(MdiIcons.languageJavascript),
                value: engineSettings.javascriptEnabled,
                onChanged: (value) async {
                  await ref
                      .read(saveEngineSettingsControllerProvider.notifier)
                      .save(
                        (currentSettings) =>
                            currentSettings.copyWith.javascriptEnabled(value),
                      );
                },
              ),
              ListTile(
                leading: const Icon(MdiIcons.cardAccountDetails),
                title: TextField(
                  controller: userAgentTextController,
                  decoration: const InputDecoration(
                    labelText: 'Custom User Agent',
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    hintText: 'Mozilla/5.0 …',
                  ),
                  onSubmitted: (value) async {
                    await ref
                        .read(saveEngineSettingsControllerProvider.notifier)
                        .save(
                          (currentSettings) =>
                              currentSettings.copyWith.userAgent(value),
                        );

                    if (context.mounted) {
                      final restart = await showUserAgentRestartDialog(context);

                      if (restart == true) {
                        await exitApp(ref.container);
                      }
                    }
                  },
                ),
              ),
              SwitchListTile.adaptive(
                title: const Text('Use third party CA certificates'),
                subtitle: const Text(
                  'Allows the use of third party certificates from the Android CA store',
                ),
                secondary: const Icon(MdiIcons.certificate),
                value: engineSettings.enterpriseRootsEnabled,
                onChanged: (value) async {
                  await ref
                      .read(saveEngineSettingsControllerProvider.notifier)
                      .save(
                        (currentSettings) => currentSettings.copyWith
                            .enterpriseRootsEnabled(value),
                      );
                },
              ),
              ListTile(
                title: const Text('Fingerprint Protection'),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 8.0,
                  horizontal: 16.0,
                ),
                leading: const Icon(MdiIcons.fingerprint),
                trailing: const Icon(Icons.chevron_right),
                onTap: () async {
                  await FingerprintSettingsRoute().push(context);
                },
              ),
              CustomListTile(
                title: 'Error Logs',
                subtitle: 'Copy logs for issue reporting',
                prefix: Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: Icon(
                    Icons.bug_report,
                    size: 24,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                suffix: FilledButton.icon(
                  onPressed: () async {
                    await Clipboard.setData(
                      ClipboardData(
                        text: loggerMemory.buffer
                            .map((e) => e.lines.join('\n'))
                            .join('\n\n'),
                      ),
                    );

                    if (context.mounted) {
                      showInfoMessage(context, 'Logs copied');
                    }
                  },
                  icon: const Icon(Icons.copy),
                  label: const Text('Copy'),
                ),
              ),
              if (kDebugMode)
                CustomListTile(
                  title: 'Dart VM',
                  subtitle: 'Copy Dart VM service URL',
                  prefix: Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: Icon(
                      Icons.bug_report,
                      size: 24,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  suffix: FilledButton.icon(
                    onPressed: () async {
                      final serviceProtocolInfo = await Service.getInfo();

                      await Clipboard.setData(
                        ClipboardData(
                          text:
                              serviceProtocolInfo.serverUri?.toString() ??
                              'Error',
                        ),
                      );

                      if (context.mounted) {
                        showInfoMessage(context, 'Service URL copied');
                      }
                    },
                    icon: const Icon(Icons.copy),
                    label: const Text('Copy'),
                  ),
                ),
              ListTile(
                leading: const Icon(MdiIcons.puzzle),
                title: const Text('Custom Extension Collection'),
                subtitle: const Text(
                  'Custom Add-on Collections are curated lists of extensions that users can create and share.',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () async {
                  await AddonCollectionRoute().push(context);
                },
              ),
              CustomListTile(
                title: 'Reset UI',
                subtitle: 'Rebuild the entire browser UI',
                prefix: Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: Icon(
                    Icons.bug_report,
                    size: 24,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                suffix: FilledButton.icon(
                  onPressed: () {
                    ref.read(appStateKeyProvider.notifier).reset();
                  },
                  icon: const Icon(Icons.restore),
                  label: const Text('Reset'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
