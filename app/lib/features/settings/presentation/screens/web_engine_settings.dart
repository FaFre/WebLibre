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
import 'package:fading_scroll/fading_scroll.dart';
import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nullability/nullability.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/dialogs/delete_data.dart';
import 'package:weblibre/features/settings/presentation/controllers/save_settings.dart';
import 'package:weblibre/features/user/data/models/engine_settings.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';
import 'package:weblibre/features/user/domain/repositories/engine_settings.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';

class WebEngineSettingsScreen extends HookConsumerWidget {
  const WebEngineSettingsScreen();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final generalSettings = ref.watch(generalSettingsWithDefaultsProvider);
    final engineSettings = ref.watch(engineSettingsWithDefaultsProvider);

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
                  'Deletes selected browsing data upon app restart for enhanced privacy.',
                ),
                secondary: const Icon(MdiIcons.incognito),
                value: generalSettings.deleteBrowsingDataOnQuit != null,
                onChanged: (value) async {
                  await ref
                      .read(saveGeneralSettingsControllerProvider.notifier)
                      .save(
                        (currentSettings) => value
                            ? currentSettings.copyWith.deleteBrowsingDataOnQuit(
                                {},
                              )
                            : currentSettings.copyWith.deleteBrowsingDataOnQuit(
                                null,
                              ),
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
              ListTile(
                title: const Text('Delete Browsing Data'),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 8.0,
                  horizontal: 16.0,
                ),
                leading: const Icon(Icons.cleaning_services),
                trailing: const Icon(Icons.chevron_right),
                onTap: () async {
                  await showDialog(
                    context: context,
                    builder: (context) {
                      return const DeleteDataDialog(initialSettings: {});
                    },
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
                      title: Text('Auto-Clear History'),
                      subtitle: Text(
                        'Automatically delete browsing history older than the selected time period',
                      ),
                      leading: Icon(MdiIcons.deleteClock),
                      contentPadding: EdgeInsets.zero,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 40.0),
                      child: DropdownMenu(
                        initialSelection:
                            generalSettings.historyAutoCleanInterval,
                        inputDecorationTheme: InputDecorationTheme(
                          prefixIconConstraints: BoxConstraints.tight(
                            const Size.square(24),
                          ),
                        ),
                        width: double.infinity,
                        dropdownMenuEntries: const [
                          DropdownMenuEntry(
                            value: Duration.zero,
                            label: 'Never',
                          ),
                          DropdownMenuEntry(
                            value: Duration(days: 1),
                            label: '1 Day',
                          ),
                          DropdownMenuEntry(
                            value: Duration(days: 7),
                            label: '1 Week',
                          ),
                          DropdownMenuEntry(
                            value: Duration(days: 14),
                            label: '2 Weeks',
                          ),
                          DropdownMenuEntry(
                            value: Duration(days: 30),
                            label: '1 Month',
                          ),
                          DropdownMenuEntry(
                            value: Duration(days: 90),
                            label: '3 Months',
                          ),
                        ],
                        onSelected: (value) async {
                          await ref
                              .read(
                                saveGeneralSettingsControllerProvider.notifier,
                              )
                              .save(
                                (currentSettings) => currentSettings.copyWith
                                    .historyAutoCleanInterval(
                                      value ?? Duration.zero,
                                    ),
                              );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              ListTile(
                title: const Text('Browser Languages'),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 8.0,
                  horizontal: 16.0,
                ),
                leading: const Icon(MdiIcons.translate),
                trailing: const Icon(Icons.chevron_right),
                onTap: () async {
                  await LocaleSettingsRoute().push(context);
                },
              ),
              SwitchListTile.adaptive(
                title: const Text('Global Privacy Control (GPC)'),
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
              ListTile(
                title: const Text('DNS over HTTPS'),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 8.0,
                  horizontal: 16.0,
                ),
                leading: const Icon(MdiIcons.dns),
                trailing: const Icon(Icons.chevron_right),
                onTap: () async {
                  await DohSettingsRoute().push(context);
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
                      title: Text('Enhanced Tracking Protection'),
                      leading: Icon(MdiIcons.incognitoCircleOff),
                      contentPadding: EdgeInsets.zero,
                    ),
                    RadioGroup(
                      groupValue: engineSettings.trackingProtectionPolicy,
                      onChanged: (value) async {
                        await ref
                            .read(saveEngineSettingsControllerProvider.notifier)
                            .save(
                              (currentSettings) => currentSettings.copyWith
                                  .trackingProtectionPolicy(value),
                            );
                      },
                      child: const Column(
                        children: [
                          RadioListTile<TrackingProtectionPolicy>.adaptive(
                            value: TrackingProtectionPolicy.none,
                            title: Text('Disabled'),
                          ),
                          RadioListTile<TrackingProtectionPolicy>.adaptive(
                            value: TrackingProtectionPolicy.recommended,
                            title: Text('Standard'),
                            subtitle: Text(
                              'Pages will load normally, but block fewer trackers.',
                            ),
                          ),
                          RadioListTile<TrackingProtectionPolicy>.adaptive(
                            value: TrackingProtectionPolicy.strict,
                            title: Text('Strict'),
                            subtitle: Text(
                              'Stronger tracking protection and faster performance, but some sites may not work properly.',
                            ),
                          ),
                          RadioListTile<TrackingProtectionPolicy>.adaptive(
                            value: TrackingProtectionPolicy.custom,
                            title: Text('Custom'),
                            subtitle: Text(
                              'Choose which trackers and scripts to block.',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Padding(
              //   padding: const EdgeInsets.symmetric(
              //     horizontal: 16.0,
              //     vertical: 8,
              //   ),
              //   child: Column(
              //     mainAxisSize: MainAxisSize.min,
              //     crossAxisAlignment: CrossAxisAlignment.start,
              //     children: [
              //       const ListTile(
              //         title: Text('Cookie Banner Blocker'),
              //         leading: Icon(MdiIcons.cookieSettings),
              //         contentPadding: EdgeInsets.zero,
              //       ),
              //       CheckboxListTile.adaptive(
              //         value:
              //             engineSettings.cookieBannerHandlingMode ==
              //             CookieBannerHandlingMode.rejectAll,
              //         title: const Text('In normal browsing'),
              //         controlAffinity: ListTileControlAffinity.leading,
              //         onChanged: (value) async {
              //           await ref
              //               .read(saveEngineSettingsControllerProvider.notifier)
              //               .save(
              //                 (currentSettings) => currentSettings.copyWith
              //                     .cookieBannerHandlingMode(
              //                       value!
              //                           ? CookieBannerHandlingMode.rejectAll
              //                           : CookieBannerHandlingMode.disabled,
              //                     ),
              //               );
              //         },
              //       ),
              //       CheckboxListTile.adaptive(
              //         value:
              //             engineSettings
              //                 .cookieBannerHandlingModePrivateBrowsing ==
              //             CookieBannerHandlingMode.rejectAll,
              //         title: const Text('In private browsing'),
              //         controlAffinity: ListTileControlAffinity.leading,
              //         onChanged: (value) async {
              //           await ref
              //               .read(saveEngineSettingsControllerProvider.notifier)
              //               .save(
              //                 (currentSettings) => currentSettings.copyWith
              //                     .cookieBannerHandlingModePrivateBrowsing(
              //                       value!
              //                           ? CookieBannerHandlingMode.rejectAll
              //                           : CookieBannerHandlingMode.disabled,
              //                     ),
              //               );
              //         },
              //       ),
              //     ],
              //   ),
              // ),
              SwitchListTile.adaptive(
                title: const Text('Bounce Tracking Protection'),
                subtitle: const Text(
                  'Blocks redirect trackers that collect data through intermediate URL redirects between websites',
                ),
                secondary: const Icon(MdiIcons.securityNetwork),
                value: switch (engineSettings
                    .contentBlocking
                    .bounceTrackingProtectionMode) {
                  BounceTrackingProtectionMode.disabled => false,
                  BounceTrackingProtectionMode.enabled => true,
                  BounceTrackingProtectionMode.enabledStandby => false,
                  BounceTrackingProtectionMode.enabledDryRun => false,
                },
                onChanged: (value) async {
                  await ref
                      .read(saveEngineSettingsControllerProvider.notifier)
                      .save(
                        (currentSettings) => currentSettings.copyWith
                            .bounceTrackingProtectionMode(
                              value
                                  ? BounceTrackingProtectionMode.enabled
                                  : BounceTrackingProtectionMode.disabled,
                            ),
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
                      title: Text('Query Parameter Stripping'),
                      subtitle: Text(
                        'Removes tracking parameters from URLs to prevent cross-site user tracking',
                      ),
                      leading: Icon(MdiIcons.closeNetwork),
                      contentPadding: EdgeInsets.zero,
                    ),
                    Center(
                      child: SegmentedButton<QueryParameterStripping>(
                        segments: const [
                          ButtonSegment(
                            value: QueryParameterStripping.disabled,
                            label: Text('Disabled'),
                          ),
                          ButtonSegment(
                            value: QueryParameterStripping.enabled,
                            label: Text('Enabled'),
                          ),
                          ButtonSegment(
                            value: QueryParameterStripping.privateOnly,
                            label: Text('Private mode only'),
                          ),
                        ],
                        selected: {engineSettings.queryParameterStripping},
                        onSelectionChanged: (value) async {
                          await ref
                              .read(
                                saveEngineSettingsControllerProvider.notifier,
                              )
                              .save(
                                (currentSettings) => currentSettings.copyWith
                                    .queryParameterStripping(value.first),
                              );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              SwitchListTile.adaptive(
                title: const Text('Built-in PDF Viewer'),
                subtitle: const Text(
                  'Open PDF files directly in the browser without downloading',
                ),
                secondary: const Icon(MdiIcons.filePdfBox),
                value: engineSettings.enablePdfJs,
                onChanged: (value) async {
                  await ref
                      .read(saveEngineSettingsControllerProvider.notifier)
                      .save(
                        (currentSettings) =>
                            currentSettings.copyWith.enablePdfJs(value),
                      );
                },
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
