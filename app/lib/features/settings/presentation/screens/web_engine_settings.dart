import 'package:fading_scroll/fading_scroll.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lensai/core/routing/routes.dart';
import 'package:lensai/extensions/nullable.dart';
import 'package:lensai/features/settings/presentation/controllers/save_settings.dart';
import 'package:lensai/features/user/data/models/engine_settings.dart';
import 'package:lensai/features/user/data/models/general_settings.dart';
import 'package:lensai/features/user/domain/repositories/engine_settings.dart';
import 'package:lensai/features/user/domain/repositories/general_settings.dart';
import 'package:universal_io/io.dart';

class WebEngineSettingsScreen extends HookConsumerWidget {
  const WebEngineSettingsScreen();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final generalSettings = ref.watch(generalSettingsRepositoryProvider);
    final engineSettings = ref.watch(engineSettingsRepositoryProvider);

    final userAgentTextController = useTextEditingController(
      text: engineSettings.userAgent,
      keys: [engineSettings.userAgent],
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Web Engine Settings')),
      body: FadingScroll(
        fadingSize: 25,
        builder: (context, controller) {
          return ListView(
            controller: controller,
            children: [
              SwitchListTile.adaptive(
                title: const Text('Incognito Mode'),
                subtitle: const Text(
                  'Deletes all browsing data upon app restart for enhanced privacy.',
                ),
                secondary: const Icon(MdiIcons.incognito),
                value: generalSettings.deleteBrowsingDataOnQuit != null,
                onChanged: (value) async {
                  await ref
                      .read(saveGeneralSettingsControllerProvider.notifier)
                      .save(
                        (currentSettings) =>
                            value
                                ? currentSettings.copyWith
                                    .deleteBrowsingDataOnQuit({})
                                : currentSettings.copyWith
                                    .deleteBrowsingDataOnQuit(null),
                      );
                },
              ),
              if (generalSettings.deleteBrowsingDataOnQuit != null)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8,
                  ),
                  child: Column(
                    children: [
                      for (final type in DeleteBrowsingDataType.values)
                        CheckboxListTile.adaptive(
                          value: generalSettings.deleteBrowsingDataOnQuit!
                              .contains(type),
                          controlAffinity: ListTileControlAffinity.leading,
                          title: Text(type.title),
                          subtitle: type.description.mapNotNull(
                            (description) => Text(description),
                          ),
                          onChanged: (value) async {
                            final notifier = ref.read(
                              saveGeneralSettingsControllerProvider.notifier,
                            );

                            if (value == true) {
                              await notifier.save(
                                (currentSettings) => currentSettings.copyWith
                                    .deleteBrowsingDataOnQuit({
                                      ...currentSettings
                                          .deleteBrowsingDataOnQuit!,
                                      type,
                                    }),
                              );
                            } else {
                              await notifier.save(
                                (currentSettings) => currentSettings.copyWith
                                    .deleteBrowsingDataOnQuit(
                                      {
                                        ...currentSettings
                                            .deleteBrowsingDataOnQuit!,
                                      }..remove(type),
                                    ),
                              );
                            }
                          },
                        ),
                    ],
                  ),
                ),
              SwitchListTile.adaptive(
                title: const Text('Enable JavaScript'),
                subtitle: const Text(
                  'While turning off JavaScript boosts security, privacy, and speed, it may cause some sites to not work as intended.',
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
              SwitchListTile.adaptive(
                title: const Text('Enable Global Privacy Control (GPC)'),
                secondary: const Icon(MdiIcons.incognitoCircleOff),
                value: engineSettings.globalPrivacyControlEnabled,
                onChanged: (value) async {
                  await ref
                      .read(saveEngineSettingsControllerProvider.notifier)
                      .save(
                        (currentSettings) => currentSettings.copyWith
                            .globalPrivacyControlEnabled(value),
                      );
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const ListTile(
                      title: Text('Block insecure HTTP connections'),
                      leading: Icon(MdiIcons.lockOpen),
                      contentPadding: EdgeInsets.zero,
                    ),
                    Center(
                      child: SegmentedButton<HttpsOnlyMode>(
                        segments: const [
                          ButtonSegment(
                            value: HttpsOnlyMode.disabled,
                            label: Text('Disabled'),
                          ),
                          ButtonSegment(
                            value: HttpsOnlyMode.enabled,
                            label: Text('Enabled'),
                          ),
                          ButtonSegment(
                            value: HttpsOnlyMode.privateOnly,
                            label: Text('Private mode only'),
                          ),
                        ],
                        selected: {engineSettings.httpsOnlyMode},
                        onSelectionChanged: (value) async {
                          await ref
                              .read(
                                saveEngineSettingsControllerProvider.notifier,
                              )
                              .save(
                                (currentSettings) => currentSettings.copyWith
                                    .httpsOnlyMode(value.first),
                              );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const ListTile(
                      title: Text('Enhanced Tracking Protection'),
                      leading: Icon(MdiIcons.incognitoCircleOff),
                      contentPadding: EdgeInsets.zero,
                    ),
                    RadioListTile<TrackingProtectionPolicy>.adaptive(
                      value: TrackingProtectionPolicy.none,
                      title: const Text('Disabled'),
                      groupValue: engineSettings.trackingProtectionPolicy,
                      onChanged: (value) async {
                        await ref
                            .read(saveEngineSettingsControllerProvider.notifier)
                            .save(
                              (currentSettings) => currentSettings.copyWith
                                  .trackingProtectionPolicy(value),
                            );
                      },
                    ),
                    RadioListTile<TrackingProtectionPolicy>.adaptive(
                      value: TrackingProtectionPolicy.recommended,
                      title: const Text('Standard'),
                      subtitle: const Text(
                        'Pages will load normally, but block fewer trackers.',
                      ),
                      groupValue: engineSettings.trackingProtectionPolicy,
                      onChanged: (value) async {
                        await ref
                            .read(saveEngineSettingsControllerProvider.notifier)
                            .save(
                              (currentSettings) => currentSettings.copyWith
                                  .trackingProtectionPolicy(value),
                            );
                      },
                    ),
                    RadioListTile<TrackingProtectionPolicy>.adaptive(
                      value: TrackingProtectionPolicy.strict,
                      title: const Text('Strict'),
                      subtitle: const Text(
                        'Stronger tracking protection and faster performance, but some sites may not work properly.',
                      ),
                      groupValue: engineSettings.trackingProtectionPolicy,
                      onChanged: (value) async {
                        await ref
                            .read(saveEngineSettingsControllerProvider.notifier)
                            .save(
                              (currentSettings) => currentSettings.copyWith
                                  .trackingProtectionPolicy(value),
                            );
                      },
                    ),
                    RadioListTile<TrackingProtectionPolicy>.adaptive(
                      value: TrackingProtectionPolicy.custom,
                      title: const Text('Custom'),
                      subtitle: const Text(
                        'Choose which trackers and scripts to block.',
                      ),
                      groupValue: engineSettings.trackingProtectionPolicy,
                      onChanged: null,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const ListTile(
                      title: Text('Cookie Banner Blocker'),
                      leading: Icon(MdiIcons.cookieSettings),
                      contentPadding: EdgeInsets.zero,
                    ),
                    CheckboxListTile.adaptive(
                      value:
                          engineSettings.cookieBannerHandlingMode ==
                          CookieBannerHandlingMode.rejectAll,
                      title: const Text('In normal browsing'),
                      controlAffinity: ListTileControlAffinity.leading,
                      onChanged: (value) async {
                        await ref
                            .read(saveEngineSettingsControllerProvider.notifier)
                            .save(
                              (currentSettings) => currentSettings.copyWith
                                  .cookieBannerHandlingMode(
                                    value!
                                        ? CookieBannerHandlingMode.rejectAll
                                        : CookieBannerHandlingMode.disabled,
                                  ),
                            );
                      },
                    ),
                    CheckboxListTile.adaptive(
                      value:
                          engineSettings
                              .cookieBannerHandlingModePrivateBrowsing ==
                          CookieBannerHandlingMode.rejectAll,
                      title: const Text('In private browsing'),
                      controlAffinity: ListTileControlAffinity.leading,
                      onChanged: (value) async {
                        await ref
                            .read(saveEngineSettingsControllerProvider.notifier)
                            .save(
                              (currentSettings) => currentSettings.copyWith
                                  .cookieBannerHandlingModePrivateBrowsing(
                                    value!
                                        ? CookieBannerHandlingMode.rejectAll
                                        : CookieBannerHandlingMode.disabled,
                                  ),
                            );
                      },
                    ),
                  ],
                ),
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
                        builder:
                            (context) => AlertDialog(
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
              ListTile(
                title: const Text('Web Engine Hardening'),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 8.0,
                  horizontal: 16.0,
                ),
                leading: const Icon(MdiIcons.shieldLock),
                trailing: const Icon(Icons.chevron_right),
                onTap: () async {
                  await WebEngineHardeningRoute().push(context);
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
