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
import 'package:weblibre/features/settings/presentation/controllers/save_settings.dart';
import 'package:weblibre/features/settings/presentation/widgets/sections.dart';
import 'package:weblibre/features/user/data/models/engine_settings.dart';
import 'package:weblibre/features/user/domain/repositories/engine_settings.dart';

class CustomTrackingProtectionScreen extends StatelessWidget {
  const CustomTrackingProtectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Custom Tracking Protection')),
      body: SafeArea(
        child: FadingScroll(
          fadingSize: 25,
          builder: (context, controller) {
            return ListView(
              controller: controller,
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              children: const [
                _AllowlistSection(),
                _CookiesSection(),
                _TrackingContentSection(),
                _TrackersSection(),
                _AdvancedFingerprintingSection(),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _AllowlistSection extends HookConsumerWidget {
  const _AllowlistSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allowListBaseline = ref.watch(
      engineSettingsWithDefaultsProvider.select((s) => s.allowListBaseline),
    );
    final allowListConvenience = ref.watch(
      engineSettingsWithDefaultsProvider.select((s) => s.allowListConvenience),
    );

    return Column(
      children: [
        const SettingSection(name: 'Allowlist Exceptions'),
        SwitchListTile.adaptive(
          title: const Text('Fix website major issues'),
          subtitle: const Text(
            'Apply exceptions required to avoid major website breakage (recommended)',
          ),
          secondary: const Icon(MdiIcons.shieldCheck),
          value: allowListBaseline,
          onChanged: (value) async {
            await ref
                .read(saveEngineSettingsControllerProvider.notifier)
                .save((s) => s.copyWith.allowListBaseline(value));
          },
        ),
        SwitchListTile.adaptive(
          title: const Text('Fix website minor issues'),
          subtitle: const Text(
            'Apply exceptions to fix minor issues and enable convenience features',
          ),
          secondary: const Icon(MdiIcons.shieldHalfFull),
          value: allowListConvenience,
          onChanged: (value) async {
            await ref
                .read(saveEngineSettingsControllerProvider.notifier)
                .save((s) => s.copyWith.allowListConvenience(value));
          },
        ),
      ],
    );
  }
}

class _CookiesSection extends HookConsumerWidget {
  const _CookiesSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final blockCookies = ref.watch(
      engineSettingsWithDefaultsProvider.select((s) => s.blockCookies),
    );
    final customCookiePolicy = ref.watch(
      engineSettingsWithDefaultsProvider.select((s) => s.customCookiePolicy),
    );

    return Column(
      children: [
        const SettingSection(name: 'Cookies'),
        SwitchListTile.adaptive(
          title: const Text('Block Cookies'),
          subtitle: const Text('Block cookies based on the policy below'),
          secondary: const Icon(MdiIcons.cookie),
          value: blockCookies,
          onChanged: (value) async {
            await ref
                .read(saveEngineSettingsControllerProvider.notifier)
                .save((s) => s.copyWith.blockCookies(value));
          },
        ),
        if (blockCookies)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ListTile(
                  title: Text('Cookie Policy'),
                  contentPadding: EdgeInsets.zero,
                ),
                DropdownMenu<CustomCookiePolicy>(
                  initialSelection: customCookiePolicy,
                  width: double.infinity,
                  dropdownMenuEntries: const [
                    DropdownMenuEntry(
                      value: CustomCookiePolicy.totalProtection,
                      label: 'Total Cookie Protection (Recommended)',
                      leadingIcon: Icon(MdiIcons.shieldLock),
                    ),
                    DropdownMenuEntry(
                      value: CustomCookiePolicy.crossSiteTrackers,
                      label: 'Cross-site and social media trackers',
                      leadingIcon: Icon(MdiIcons.accountGroup),
                    ),
                    DropdownMenuEntry(
                      value: CustomCookiePolicy.unvisited,
                      label: 'Unvisited sites',
                      leadingIcon: Icon(MdiIcons.webOff),
                    ),
                    DropdownMenuEntry(
                      value: CustomCookiePolicy.thirdParty,
                      label: 'All third-party cookies',
                      leadingIcon: Icon(MdiIcons.cookieOff),
                    ),
                    DropdownMenuEntry(
                      value: CustomCookiePolicy.allCookies,
                      label: 'All cookies (may break sites)',
                      leadingIcon: Icon(MdiIcons.cookieRemove),
                    ),
                  ],
                  onSelected: (value) async {
                    if (value != null) {
                      await ref
                          .read(saveEngineSettingsControllerProvider.notifier)
                          .save((s) => s.copyWith.customCookiePolicy(value));
                    }
                  },
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _TrackingContentSection extends HookConsumerWidget {
  const _TrackingContentSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final blockTrackingContent = ref.watch(
      engineSettingsWithDefaultsProvider.select((s) => s.blockTrackingContent),
    );
    final trackingContentScope = ref.watch(
      engineSettingsWithDefaultsProvider.select((s) => s.trackingContentScope),
    );

    return Column(
      children: [
        const SettingSection(name: 'Tracking Content'),
        SwitchListTile.adaptive(
          title: const Text('Block Tracking Content'),
          subtitle: const Text(
            'Block tracking scripts and resources embedded in websites',
          ),
          secondary: const Icon(MdiIcons.scriptTextOutline),
          value: blockTrackingContent,
          onChanged: (value) async {
            await ref
                .read(saveEngineSettingsControllerProvider.notifier)
                .save((s) => s.copyWith.blockTrackingContent(value));
          },
        ),
        if (blockTrackingContent)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ListTile(
                  title: Text('Apply to'),
                  contentPadding: EdgeInsets.zero,
                ),
                SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<TrackingScope>(
                    segments: const [
                      ButtonSegment(
                        value: TrackingScope.all,
                        label: Text('All tabs'),
                      ),
                      ButtonSegment(
                        value: TrackingScope.privateOnly,
                        label: Text('Private tabs only'),
                      ),
                    ],
                    selected: {trackingContentScope},
                    onSelectionChanged: (value) async {
                      await ref
                          .read(saveEngineSettingsControllerProvider.notifier)
                          .save(
                            (s) => s.copyWith.trackingContentScope(value.first),
                          );
                    },
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _TrackersSection extends HookConsumerWidget {
  const _TrackersSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final blockCryptominers = ref.watch(
      engineSettingsWithDefaultsProvider.select((s) => s.blockCryptominers),
    );
    final blockFingerprinters = ref.watch(
      engineSettingsWithDefaultsProvider.select((s) => s.blockFingerprinters),
    );
    final blockRedirectTrackers = ref.watch(
      engineSettingsWithDefaultsProvider.select((s) => s.blockRedirectTrackers),
    );

    return Column(
      children: [
        const SettingSection(name: 'Trackers'),
        const ListTile(
          title: Text('Always Blocked'),
          subtitle: Text(
            'Ads, analytics, social trackers, and Mozilla social trackers are always blocked in Custom mode.',
          ),
          leading: Icon(MdiIcons.shieldLock),
        ),
        SwitchListTile.adaptive(
          title: const Text('Cryptominers'),
          subtitle: const Text(
            'Block scripts that use your device to mine cryptocurrency',
          ),
          secondary: const Icon(MdiIcons.currencyBtc),
          value: blockCryptominers,
          onChanged: (value) async {
            await ref
                .read(saveEngineSettingsControllerProvider.notifier)
                .save((s) => s.copyWith.blockCryptominers(value));
          },
        ),
        SwitchListTile.adaptive(
          title: const Text('Known Fingerprinters'),
          subtitle: const Text(
            'Block scripts that collect information to uniquely identify your device',
          ),
          secondary: const Icon(MdiIcons.fingerprint),
          value: blockFingerprinters,
          onChanged: (value) async {
            await ref
                .read(saveEngineSettingsControllerProvider.notifier)
                .save((s) => s.copyWith.blockFingerprinters(value));
          },
        ),
        SwitchListTile.adaptive(
          title: const Text('Redirect Trackers'),
          subtitle: const Text(
            'Block trackers that collect data through intermediate URL redirects',
          ),
          secondary: const Icon(MdiIcons.routerNetwork),
          value: blockRedirectTrackers,
          onChanged: (value) async {
            await ref
                .read(saveEngineSettingsControllerProvider.notifier)
                .save((s) => s.copyWith.blockRedirectTrackers(value));
          },
        ),
      ],
    );
  }
}

class _AdvancedFingerprintingSection extends HookConsumerWidget {
  const _AdvancedFingerprintingSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final blockSuspectedFingerprinters = ref.watch(
      engineSettingsWithDefaultsProvider.select(
        (s) => s.blockSuspectedFingerprinters,
      ),
    );
    final suspectedFingerprintersScope = ref.watch(
      engineSettingsWithDefaultsProvider.select(
        (s) => s.suspectedFingerprintersScope,
      ),
    );

    return Column(
      children: [
        const SettingSection(name: 'Advanced Fingerprinting Protection'),
        SwitchListTile.adaptive(
          title: const Text('Suspected Fingerprinters'),
          subtitle: const Text(
            'Block additional fingerprinting techniques that may be used to track you',
          ),
          secondary: const Icon(MdiIcons.shieldSearch),
          value: blockSuspectedFingerprinters,
          onChanged: (value) async {
            await ref
                .read(saveEngineSettingsControllerProvider.notifier)
                .save((s) => s.copyWith.blockSuspectedFingerprinters(value));
          },
        ),
        if (blockSuspectedFingerprinters)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ListTile(
                  title: Text('Apply to'),
                  contentPadding: EdgeInsets.zero,
                ),
                SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<TrackingScope>(
                    segments: const [
                      ButtonSegment(
                        value: TrackingScope.all,
                        label: Text('All tabs'),
                      ),
                      ButtonSegment(
                        value: TrackingScope.privateOnly,
                        label: Text('Private tabs only'),
                      ),
                    ],
                    selected: {suspectedFingerprintersScope},
                    onSelectionChanged: (value) async {
                      await ref
                          .read(saveEngineSettingsControllerProvider.notifier)
                          .save(
                            (s) => s.copyWith.suspectedFingerprintersScope(
                              value.first,
                            ),
                          );
                    },
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
