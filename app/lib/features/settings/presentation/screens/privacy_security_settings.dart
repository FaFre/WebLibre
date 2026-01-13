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
import 'package:weblibre/features/settings/presentation/widgets/sections.dart';
import 'package:weblibre/features/user/data/models/engine_settings.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';
import 'package:weblibre/features/user/domain/repositories/engine_settings.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';

class PrivacySecuritySettingsScreen extends StatelessWidget {
  const PrivacySecuritySettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy & Security')),
      body: SafeArea(
        child: FadingScroll(
          fadingSize: 25,
          builder: (context, controller) {
            return ListView(
              controller: controller,
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              children: const [
                _PrivacyModesSection(),
                _TrackingProtectionSection(),
                _ConnectionSecuritySection(),
                _DataManagementSection(),
                _AdvancedSection(),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _PrivacyModesSection extends StatelessWidget {
  const _PrivacyModesSection();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        SettingSection(name: 'Privacy Modes'),
        _IncognitoModeSection(),
        _GlobalPrivacyControlTile(),
      ],
    );
  }
}

class _TrackingProtectionSection extends StatelessWidget {
  const _TrackingProtectionSection();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        SettingSection(name: 'Tracking Protection'),
        _EnhancedTrackingProtectionSection(),
        _BounceTrackingProtectionTile(),
        _QueryParameterStrippingSection(),
      ],
    );
  }
}

class _ConnectionSecuritySection extends StatelessWidget {
  const _ConnectionSecuritySection();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        SettingSection(name: 'Connection Security'),
        _HttpsOnlyModeSection(),
        _DnsTile(),
      ],
    );
  }
}

class _DataManagementSection extends StatelessWidget {
  const _DataManagementSection();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        SettingSection(name: 'Data Management'),
        _DeleteBrowsingDataTile(),
        _AutoClearHistorySection(),
      ],
    );
  }
}

class _AdvancedSection extends StatelessWidget {
  const _AdvancedSection();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        SettingSection(name: 'Advanced'),
        _WebEngineHardeningTile(),
      ],
    );
  }
}

class _IncognitoModeSection extends HookConsumerWidget {
  const _IncognitoModeSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deleteBrowsingDataOnQuit = ref.watch(
      generalSettingsWithDefaultsProvider.select(
        (s) => s.deleteBrowsingDataOnQuit,
      ),
    );

    return Column(
      children: [
        SwitchListTile.adaptive(
          title: const Text('Incognito Mode'),
          subtitle: const Text(
            'Deletes selected browsing data upon app restart for enhanced privacy.',
          ),
          secondary: const Icon(MdiIcons.incognito),
          value: deleteBrowsingDataOnQuit != null,
          onChanged: (value) async {
            await ref
                .read(saveGeneralSettingsControllerProvider.notifier)
                .save(
                  (currentSettings) => value
                      ? currentSettings.copyWith.deleteBrowsingDataOnQuit({})
                      : currentSettings.copyWith.deleteBrowsingDataOnQuit(null),
                );
          },
        ),
        if (deleteBrowsingDataOnQuit != null)
          _DeleteBrowsingDataTypes(selectedTypes: deleteBrowsingDataOnQuit),
      ],
    );
  }
}

class _DeleteBrowsingDataTypes extends HookConsumerWidget {
  final Set<DeleteBrowsingDataType> selectedTypes;

  const _DeleteBrowsingDataTypes({required this.selectedTypes});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Column(
        children: [
          for (final type in DeleteBrowsingDataType.values)
            CheckboxListTile.adaptive(
              value: selectedTypes.contains(type),
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
                    (currentSettings) =>
                        currentSettings.copyWith.deleteBrowsingDataOnQuit({
                          ...currentSettings.deleteBrowsingDataOnQuit!,
                          type,
                        }),
                  );
                } else {
                  await notifier.save(
                    (currentSettings) =>
                        currentSettings.copyWith.deleteBrowsingDataOnQuit(
                          {...currentSettings.deleteBrowsingDataOnQuit!}
                            ..remove(type),
                        ),
                  );
                }
              },
            ),
        ],
      ),
    );
  }
}

class _DeleteBrowsingDataTile extends StatelessWidget {
  const _DeleteBrowsingDataTile();

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: const Text('Delete Browsing Data'),
      contentPadding: const EdgeInsets.symmetric(
        vertical: 8.0,
        horizontal: 16.0,
      ),
      leading: const Icon(MdiIcons.databaseRemove),
      trailing: const Icon(Icons.chevron_right),
      onTap: () async {
        await showDialog(
          context: context,
          builder: (context) {
            return const DeleteDataDialog(initialSettings: {});
          },
        );
      },
    );
  }
}

class _AutoClearHistorySection extends HookConsumerWidget {
  const _AutoClearHistorySection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAutoCleanInterval = ref.watch(
      generalSettingsWithDefaultsProvider.select(
        (s) => s.historyAutoCleanInterval,
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
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
            child: DropdownMenu<Duration>(
              initialSelection: historyAutoCleanInterval,
              inputDecorationTheme: InputDecorationTheme(
                prefixIconConstraints: BoxConstraints.tight(
                  const Size.square(24),
                ),
              ),
              width: double.infinity,
              dropdownMenuEntries: const [
                DropdownMenuEntry(value: Duration.zero, label: 'Never'),
                DropdownMenuEntry(value: Duration(days: 1), label: '1 Day'),
                DropdownMenuEntry(value: Duration(days: 7), label: '1 Week'),
                DropdownMenuEntry(value: Duration(days: 14), label: '2 Weeks'),
                DropdownMenuEntry(value: Duration(days: 30), label: '1 Month'),
                DropdownMenuEntry(value: Duration(days: 90), label: '3 Months'),
              ],
              onSelected: (value) async {
                await ref
                    .read(saveGeneralSettingsControllerProvider.notifier)
                    .save(
                      (currentSettings) => currentSettings.copyWith
                          .historyAutoCleanInterval(value ?? Duration.zero),
                    );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _GlobalPrivacyControlTile extends HookConsumerWidget {
  const _GlobalPrivacyControlTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final globalPrivacyControlEnabled = ref.watch(
      engineSettingsWithDefaultsProvider.select(
        (s) => s.globalPrivacyControlEnabled,
      ),
    );

    return SwitchListTile.adaptive(
      title: const Text('Global Privacy Control (GPC)'),
      secondary: const Icon(MdiIcons.incognitoCircleOff),
      value: globalPrivacyControlEnabled,
      onChanged: (value) async {
        await ref
            .read(saveEngineSettingsControllerProvider.notifier)
            .save(
              (currentSettings) =>
                  currentSettings.copyWith.globalPrivacyControlEnabled(value),
            );
      },
    );
  }
}

class _HttpsOnlyModeSection extends HookConsumerWidget {
  const _HttpsOnlyModeSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final httpsOnlyMode = ref.watch(
      engineSettingsWithDefaultsProvider.select((s) => s.httpsOnlyMode),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
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
              selected: {httpsOnlyMode},
              onSelectionChanged: (value) async {
                await ref
                    .read(saveEngineSettingsControllerProvider.notifier)
                    .save(
                      (currentSettings) =>
                          currentSettings.copyWith.httpsOnlyMode(value.first),
                    );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DnsTile extends StatelessWidget {
  const _DnsTile();

  @override
  Widget build(BuildContext context) {
    return ListTile(
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
    );
  }
}

class _EnhancedTrackingProtectionSection extends HookConsumerWidget {
  const _EnhancedTrackingProtectionSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trackingProtectionPolicy = ref.watch(
      engineSettingsWithDefaultsProvider.select(
        (s) => s.trackingProtectionPolicy,
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
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
            groupValue: trackingProtectionPolicy,
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
                  subtitle: Text('Choose which trackers and scripts to block.'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BounceTrackingProtectionTile extends HookConsumerWidget {
  const _BounceTrackingProtectionTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bounceTrackingProtectionMode = ref.watch(
      engineSettingsWithDefaultsProvider.select(
        (s) => s.contentBlocking.bounceTrackingProtectionMode,
      ),
    );

    final isEnabled = switch (bounceTrackingProtectionMode) {
      BounceTrackingProtectionMode.disabled => false,
      BounceTrackingProtectionMode.enabled => true,
      BounceTrackingProtectionMode.enabledStandby => false,
      BounceTrackingProtectionMode.enabledDryRun => false,
    };

    return SwitchListTile.adaptive(
      title: const Text('Bounce Tracking Protection'),
      subtitle: const Text(
        'Blocks redirect trackers that collect data through intermediate URL redirects between websites',
      ),
      secondary: const Icon(MdiIcons.securityNetwork),
      value: isEnabled,
      onChanged: (value) async {
        await ref
            .read(saveEngineSettingsControllerProvider.notifier)
            .save(
              (currentSettings) =>
                  currentSettings.copyWith.bounceTrackingProtectionMode(
                    value
                        ? BounceTrackingProtectionMode.enabled
                        : BounceTrackingProtectionMode.disabled,
                  ),
            );
      },
    );
  }
}

class _QueryParameterStrippingSection extends HookConsumerWidget {
  const _QueryParameterStrippingSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final queryParameterStripping = ref.watch(
      engineSettingsWithDefaultsProvider.select(
        (s) => s.queryParameterStripping,
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
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
              selected: {queryParameterStripping},
              onSelectionChanged: (value) async {
                await ref
                    .read(saveEngineSettingsControllerProvider.notifier)
                    .save(
                      (currentSettings) => currentSettings.copyWith
                          .queryParameterStripping(value.first),
                    );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _WebEngineHardeningTile extends StatelessWidget {
  const _WebEngineHardeningTile();

  @override
  Widget build(BuildContext context) {
    return ListTile(
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
    );
  }
}
