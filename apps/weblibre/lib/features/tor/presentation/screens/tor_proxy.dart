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
import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nullability/nullability.dart';
import 'package:weblibre/core/branding/proxy_brands.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/features/settings/presentation/controllers/save_settings.dart';
import 'package:weblibre/features/settings/presentation/widgets/settings_detail.dart';
import 'package:weblibre/features/tor/domain/extensions/tor_status_x.dart';
import 'package:weblibre/features/tor/domain/services/tor_proxy.dart';
import 'package:weblibre/features/tor/presentation/screens/country_picker.dart';
import 'package:weblibre/features/user/data/models/tor_settings.dart';
import 'package:weblibre/features/user/domain/repositories/tor_settings.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';
import 'package:weblibre/presentation/hooks/on_initialization.dart';
import 'package:weblibre/presentation/icons/tor_icons.dart';
import 'package:weblibre/utils/ui_helper.dart';

List<SettingsSectionDefinition> _torProxySettingsSections(
  AppLocalizations l10n,
) => [
  SettingsSectionDefinition(
    title: l10n.tor_sectionService,
    keywords: settingsKeywords(l10n.tor_sectionServiceKeywords),
    entries: [
      SettingsEntryDefinition(
        title: l10n.tor_serviceLabel(torBrand),
        subtitle: l10n.tor_serviceSubtitle(torBrand),
        keywords: settingsKeywords(l10n.tor_serviceLabelKeywords),
        child: const _TorServiceTile(),
      ),
      SettingsEntryDefinition(
        title: l10n.tor_startAutomaticallyTitle,
        subtitle: l10n.tor_startAutomaticallySectionSubtitle(torBrand),
        keywords: settingsKeywords(l10n.tor_startAutomaticallyKeywords),
        child: const _TorAutostartTile(),
      ),
      SettingsEntryDefinition(
        title: l10n.tor_requestNewIdentityTitle,
        subtitle: l10n.tor_requestNewIdentitySubtitle,
        keywords: settingsKeywords(l10n.tor_requestNewIdentityKeywords),
        child: const _RequestNewIdentityTile(),
      ),
    ],
  ),
  SettingsSectionDefinition(
    title: l10n.tor_sectionCircumvention,
    keywords: settingsKeywords(l10n.tor_sectionCircumventionKeywords),
    entries: [
      SettingsEntryDefinition(
        title: l10n.tor_autoConfigureTransportTitle,
        subtitle: l10n.tor_autoConfigureSectionSubtitle,
        keywords: settingsKeywords(l10n.tor_autoConfigureTransportKeywords),
        child: const _AutoConfigureTransportTile(),
      ),
      SettingsEntryDefinition(
        title: l10n.tor_transportTitle,
        subtitle: l10n.tor_transportSectionSubtitle(torBrand),
        keywords: settingsKeywords(l10n.tor_transportKeywords),
        child: const _TransportSection(),
      ),
    ],
  ),
  SettingsSectionDefinition(
    title: l10n.tor_sectionCountryRestrictions,
    keywords: settingsKeywords(l10n.tor_sectionCountryRestrictionsKeywords),
    entries: [
      SettingsEntryDefinition(
        title: _NodeRole.entry.title(l10n),
        subtitle: l10n.tor_entryCountrySubtitle,
        keywords: settingsKeywords(l10n.tor_entryCountryKeywords),
        child: const _CountryPickerTile(role: _NodeRole.entry),
      ),
      SettingsEntryDefinition(
        title: _NodeRole.exit.title(l10n),
        subtitle: l10n.tor_exitCountrySubtitle,
        keywords: settingsKeywords(l10n.tor_exitCountryKeywords),
        child: const _CountryPickerTile(role: _NodeRole.exit),
      ),
    ],
  ),
  SettingsSectionDefinition(
    title: l10n.tor_sectionAbout,
    keywords: settingsKeywords(l10n.tor_sectionAboutKeywords),
    entries: [
      SettingsEntryDefinition(
        title: l10n.tor_trademarkTitle,
        keywords: settingsKeywords(l10n.tor_trademarkKeywords),
        child: ListTile(
          leading: const Icon(Icons.info_outline),
          title: Text(l10n.tor_trademarkTitle),
          subtitle: Text(l10n.tor_trademarkDisclaimer(torBrand)),
          isThreeLine: true,
        ),
      ),
    ],
  ),
];

class TorProxyScreen extends HookConsumerWidget {
  const TorProxyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    useOnInitialization(() async {
      await ref.read(torProxyServiceProvider.notifier).requestSync();
    });

    ref.listen(torSettingsRepositoryProvider, (previous, next) async {
      final previousSettings = previous?.value;
      final nextSettings = next.value;

      // Autostart only decides whether we connect at app start, so flipping it
      // must not tear down and rebuild a running circuit.
      if (previousSettings != null &&
          nextSettings != null &&
          previousSettings.copyWith.autostart(false) ==
              nextSettings.copyWith.autostart(false)) {
        return;
      }

      final torService = ref.read(torProxyServiceProvider.notifier);
      final currentStatus = await torService.requestSync();

      if (currentStatus.isRunning) {
        await torService.startOrReconfigure(reconfigureIfRunning: true);
      }
    });

    return SettingsDetailScaffold(
      title: l10n.tor_proxyLabel(torBrand),
      subtitle: l10n.tor_screenSubtitle,
      icon: TorIcons.onionAlt,
      sections: _torProxySettingsSections(l10n),
    );
  }
}

class _TorServiceTile extends HookConsumerWidget {
  const _TorServiceTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final status = ref.watch(
      torProxyServiceProvider.select((value) => value.value),
    );
    final pendingRequest = useState<bool?>(null);

    ref.listen(torProxyServiceProvider, (previous, next) {
      if (next.hasValue && pendingRequest.value != null) {
        final current = next.requireValue;
        final prev = previous?.value;
        if (current.isRunning != prev?.isRunning ||
            current.bootstrapProgress != prev?.bootstrapProgress) {
          if (pendingRequest.value == true) {
            if (current.bootstrapProgress > 0) {
              pendingRequest.value = null;
            }
          } else {
            pendingRequest.value = null;
          }
        }
      }
    });

    final isRunning = status?.isRunning ?? false;
    final progress = status?.bootstrapProgress ?? 0;
    final isBusy = pendingRequest.value != null || (status?.isBusy ?? false);

    return Column(
      children: [
        SwitchListTile.adaptive(
          secondary: const Icon(MdiIcons.power),
          title: Text(l10n.tor_serviceLabel(torBrand)),
          subtitle: Text(l10n.tor_serviceSubtitle(torBrand)),
          value: pendingRequest.value ?? isRunning,
          onChanged: isBusy
              ? null
              : (value) async {
                  if (value) {
                    pendingRequest.value = true;
                    await ref
                        .read(torProxyServiceProvider.notifier)
                        .startOrReconfigure(reconfigureIfRunning: false);
                  } else {
                    pendingRequest.value = false;
                    await ref
                        .read(torProxyServiceProvider.notifier)
                        .disconnect();
                  }
                },
        ),
        if (pendingRequest.value != false && isBusy)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: LinearProgressIndicator(value: progress / 100),
          ),
      ],
    );
  }
}

class _TorAutostartTile extends ConsumerWidget {
  const _TorAutostartTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final autostart = ref.watch(
      torSettingsWithDefaultsProvider.select((value) => value.autostart),
    );

    return SwitchListTile.adaptive(
      secondary: const Icon(MdiIcons.rocketLaunchOutline),
      title: Text(l10n.tor_startAutomaticallyTitle),
      subtitle: Text(l10n.tor_startAutomaticallySubtitle(torBrand)),
      value: autostart,
      onChanged: (value) async {
        await ref
            .read(saveTorSettingsControllerProvider.notifier)
            .save((current) => current.copyWith.autostart(value));
      },
    );
  }
}

class _RequestNewIdentityTile extends ConsumerWidget {
  const _RequestNewIdentityTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final status = ref.watch(
      torProxyServiceProvider.select((value) => value.value),
    );
    final enabled = status?.isReady ?? false;

    return ListTile(
      enabled: enabled,
      leading: const Icon(MdiIcons.refresh),
      title: Text(l10n.tor_requestNewIdentityTitle),
      subtitle: Text(l10n.tor_requestNewIdentitySubtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: () async {
        await ref.read(torProxyServiceProvider.notifier).requestNewIdentity();
        if (context.mounted) {
          showInfoMessage(
            context,
            l10n.tor_requestingNewIdentityMessage(torBrand),
          );
        }
      },
    );
  }
}

class _AutoConfigureTransportTile extends ConsumerWidget {
  const _AutoConfigureTransportTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final torSettings = ref.watch(torSettingsWithDefaultsProvider);
    final isBusy = ref.watch(
      torProxyServiceProvider.select((value) => value.isBusy),
    );

    return Column(
      children: [
        SwitchListTile.adaptive(
          secondary: const Icon(MdiIcons.arrowDecisionAuto),
          title: Text(l10n.tor_autoConfigureTransportTitle),
          subtitle: Text(l10n.tor_autoConfigureSubtitle(torBrand)),
          value: torSettings.config == TorConnectionConfig.auto,
          onChanged: isBusy
              ? null
              : (value) async {
                  await ref
                      .read(saveTorSettingsControllerProvider.notifier)
                      .save(
                        (current) => current.copyWith.config(
                          value
                              ? TorConnectionConfig.auto
                              : TorConnectionConfig.direct,
                        ),
                      );
                },
        ),
        if (torSettings.config == TorConnectionConfig.auto)
          SwitchListTile.adaptive(
            contentPadding: const EdgeInsets.only(left: 56, right: 24),
            title: Text(l10n.tor_requireBridgeTitle),
            value: torSettings.requireBridge,
            onChanged: isBusy
                ? null
                : (value) async {
                    await ref
                        .read(saveTorSettingsControllerProvider.notifier)
                        .save(
                          (current) => current.copyWith.requireBridge(value),
                        );
                  },
          ),
      ],
    );
  }
}

class _TransportSection extends ConsumerWidget {
  const _TransportSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final torSettings = ref.watch(torSettingsWithDefaultsProvider);
    final isBusy = ref.watch(
      torProxyServiceProvider.select((value) => value.isBusy),
    );

    if (torSettings.config == TorConnectionConfig.auto) {
      return ListTile(
        leading: const Icon(Icons.info_outline),
        title: Text(l10n.tor_transportAutoConfiguredTitle),
        subtitle: Text(l10n.tor_transportAutoConfiguredSubtitle),
      );
    }

    return Column(
      children: [
        RadioGroup<TorConnectionConfig>(
          groupValue: torSettings.config,
          onChanged: (value) async {
            if (value != null) {
              await ref
                  .read(saveTorSettingsControllerProvider.notifier)
                  .save((current) => current.copyWith.config(value));
            }
          },
          child: Column(
            children: [
              RadioListTile<TorConnectionConfig>.adaptive(
                value: TorConnectionConfig.direct,
                enabled: !isBusy,
                title: Text(l10n.tor_transportDirectTitle),
                subtitle: Text(l10n.tor_transportDirectSubtitle(torBrand)),
              ),
              RadioListTile<TorConnectionConfig>.adaptive(
                value: TorConnectionConfig.obfs4,
                enabled: !isBusy,
                title: Text(l10n.tor_transportObfs4Title),
                subtitle: Text(l10n.tor_transportObfs4Subtitle),
              ),
              RadioListTile<TorConnectionConfig>.adaptive(
                value: TorConnectionConfig.snowflake,
                enabled: !isBusy,
                title: Text(l10n.tor_transportSnowflakeTitle),
                subtitle: Text(l10n.tor_transportSnowflakeSubtitle),
              ),
            ],
          ),
        ),
        CheckboxListTile.adaptive(
          controlAffinity: ListTileControlAffinity.leading,
          enabled: !isBusy && torSettings.config != TorConnectionConfig.direct,
          value: torSettings.fetchRemoteBridges,
          title: Text(l10n.tor_fetchFreshBridgesTitle),
          onChanged: isBusy
              ? null
              : (value) async {
                  if (value != null) {
                    await ref
                        .read(saveTorSettingsControllerProvider.notifier)
                        .save(
                          (current) =>
                              current.copyWith.fetchRemoteBridges(value),
                        );
                  }
                },
        ),
      ],
    );
  }
}

enum _NodeRole {
  entry,
  exit;

  String title(AppLocalizations l10n) => switch (this) {
    _NodeRole.entry => l10n.tor_entryCountryTitle,
    _NodeRole.exit => l10n.tor_exitCountryTitle,
  };
}

class _CountryPickerTile extends ConsumerWidget {
  const _CountryPickerTile({required this.role});

  final _NodeRole role;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final torSettings = ref.watch(torSettingsWithDefaultsProvider);
    final isBusy = ref.watch(
      torProxyServiceProvider.select((value) => value.isBusy),
    );
    final country = switch (role) {
      _NodeRole.entry => torSettings.entryNodeCountry,
      _NodeRole.exit => torSettings.exitNodeCountry,
    };

    return ListTile(
      enabled: !isBusy,
      leading:
          country.mapNotNull(
            (code) => CountryFlag.fromCountryCode(
              code,
              theme: const EmojiTheme(size: 28),
            ),
          ) ??
          const Icon(Icons.public),
      title: Text(role.title(l10n)),
      subtitle: Text(country ?? l10n.tor_automaticOption),
      trailing: const Icon(Icons.chevron_right),
      onTap: () async {
        final result = await TorCountryPickerRoute(
          title: role.title(l10n),
          $extra: country,
        ).push<String>(context);
        if (result == null) return;
        final value = result == automaticCountry ? null : result;
        await ref
            .read(saveTorSettingsControllerProvider.notifier)
            .save(
              (current) => switch (role) {
                _NodeRole.entry => current.copyWith.entryNodeCountry(value),
                _NodeRole.exit => current.copyWith.exitNodeCountry(value),
              },
            );
      },
    );
  }
}
