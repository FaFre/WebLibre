import 'package:fading_scroll/fading_scroll.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:universal_io/io.dart';
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/features/settings/presentation/controllers/save_settings.dart';
import 'package:weblibre/features/settings/presentation/widgets/custom_list_tile.dart';
import 'package:weblibre/features/user/data/models/engine_settings.dart';
import 'package:weblibre/features/user/domain/repositories/engine_settings.dart';
import 'package:weblibre/utils/ui_helper.dart';

class DeveloperSettingsScreen extends HookConsumerWidget {
  const DeveloperSettingsScreen();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final engineSettings = ref.watch(engineSettingsRepositoryProvider);

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
                      final restart = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('User Agent Changed'),
                          content: const Text(
                            'The app needs to restart for the new user agent to take effect',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                context.pop(false);
                              },
                              child: const Text('Later'),
                            ),
                            TextButton(
                              onPressed: () {
                                context.pop(true);
                              },
                              child: const Text('Restart Now'),
                            ),
                          ],
                        ),
                      );

                      if (restart == true) {
                        exit(0);
                      }
                    }
                  },
                ),
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
            ],
          );
        },
      ),
    );
  }
}
