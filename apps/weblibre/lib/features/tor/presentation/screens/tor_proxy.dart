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
import 'package:weblibre/presentation/hooks/on_initialization.dart';
import 'package:weblibre/presentation/icons/tor_icons.dart';
import 'package:weblibre/utils/ui_helper.dart';

const List<SettingsSectionDefinition> torProxySettingsSections = [
  SettingsSectionDefinition(
    title: 'Service',
    keywords: ['power', 'start', 'stop'],
    entries: [
      SettingsEntryDefinition(
        title: torServiceLabel,
        subtitle: 'Start or stop the $torBrand service',
        keywords: ['enable', 'connect'],
        child: _TorServiceTile(),
      ),
      SettingsEntryDefinition(
        title: 'Request New Identity',
        subtitle: 'Use a fresh circuit for new connections',
        keywords: ['circuit'],
        child: _RequestNewIdentityTile(),
      ),
    ],
  ),
  SettingsSectionDefinition(
    title: 'Circumvention',
    keywords: ['bridges', 'transport', 'obfs4', 'snowflake'],
    entries: [
      SettingsEntryDefinition(
        title: 'Auto Configure Transport',
        subtitle:
            'Pick the right pluggable transport for your network automatically',
        keywords: ['auto'],
        child: _AutoConfigureTransportTile(),
      ),
      SettingsEntryDefinition(
        title: 'Transport',
        subtitle:
            'Choose how to reach the $torNetworkLabel when not auto-configured',
        keywords: ['direct', 'obfs4', 'snowflake'],
        child: _TransportSection(),
      ),
    ],
  ),
  SettingsSectionDefinition(
    title: 'Country Restrictions',
    keywords: ['entry', 'exit', 'country'],
    entries: [
      SettingsEntryDefinition(
        title: 'Entry Country',
        subtitle: 'Choose the country of the entry guard',
        keywords: ['guard'],
        child: _CountryPickerTile(role: _NodeRole.entry),
      ),
      SettingsEntryDefinition(
        title: 'Exit Country',
        subtitle: 'Choose the country of the exit node',
        keywords: ['exit'],
        child: _CountryPickerTile(role: _NodeRole.exit),
      ),
    ],
  ),
  SettingsSectionDefinition(
    title: 'About',
    keywords: ['trademark', 'legal'],
    entries: [
      SettingsEntryDefinition(
        title: 'Trademark',
        keywords: ['legal'],
        child: ListTile(
          leading: Icon(Icons.info_outline),
          title: Text('Trademark'),
          subtitle: Text(
            '$torBrand is a trademark of The Tor Project; all rights reserved. '
            'WebLibre is not endorsed or sponsored by, or affiliated with, '
            'the Tor Project.',
          ),
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
    useOnInitialization(() async {
      await ref.read(torProxyServiceProvider.notifier).requestSync();
    });

    ref.listen(torSettingsRepositoryProvider, (previous, next) async {
      final torService = ref.read(torProxyServiceProvider.notifier);
      final currentStatus = await torService.requestSync();

      if (currentStatus.isRunning) {
        await torService.startOrReconfigure(reconfigureIfRunning: true);
      }
    });

    return const SettingsDetailScaffold(
      title: torProxyLabel,
      subtitle:
          'Onion routing, pluggable transports, bridges and country restrictions.',
      icon: TorIcons.onionAlt,
      sections: torProxySettingsSections,
    );
  }
}

class _TorServiceTile extends HookConsumerWidget {
  const _TorServiceTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          title: const Text(torServiceLabel),
          subtitle: const Text('Start or stop the $torBrand service'),
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

class _RequestNewIdentityTile extends ConsumerWidget {
  const _RequestNewIdentityTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(
      torProxyServiceProvider.select((value) => value.value),
    );
    final enabled = status?.isReady ?? false;

    return ListTile(
      enabled: enabled,
      leading: const Icon(MdiIcons.refresh),
      title: const Text('Request New Identity'),
      subtitle: const Text('Use a fresh circuit for new connections'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () async {
        await ref.read(torProxyServiceProvider.notifier).requestNewIdentity();
        if (context.mounted) {
          showInfoMessage(context, 'Requesting new $torBrand identity...');
        }
      },
    );
  }
}

class _AutoConfigureTransportTile extends ConsumerWidget {
  const _AutoConfigureTransportTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final torSettings = ref.watch(torSettingsWithDefaultsProvider);
    final isBusy = ref.watch(
      torProxyServiceProvider.select((value) => value.isBusy),
    );

    return Column(
      children: [
        SwitchListTile.adaptive(
          secondary: const Icon(MdiIcons.arrowDecisionAuto),
          title: const Text('Auto Configure Transport'),
          subtitle: const Text(
            'From some locations, it is necessary to use a pluggable transport to connect to $torBrand',
          ),
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
            title: const Text("I'm sure I cannot connect without a bridge"),
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
    final torSettings = ref.watch(torSettingsWithDefaultsProvider);
    final isBusy = ref.watch(
      torProxyServiceProvider.select((value) => value.isBusy),
    );

    if (torSettings.config == TorConnectionConfig.auto) {
      return const ListTile(
        leading: Icon(Icons.info_outline),
        title: Text('Auto-configured'),
        subtitle: Text(
          'Disable auto-configure above to pick a transport manually.',
        ),
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
                title: const Text('Direct Connection'),
                subtitle: const Text(
                  'The best way to connect to $torBrand if $torBrand is not blocked',
                ),
              ),
              RadioListTile<TorConnectionConfig>.adaptive(
                value: TorConnectionConfig.obfs4,
                enabled: !isBusy,
                title: const Text('obfs4'),
                subtitle: const Text(
                  'Suitable for light censorship and high bandwidth needs',
                ),
              ),
              RadioListTile<TorConnectionConfig>.adaptive(
                value: TorConnectionConfig.snowflake,
                enabled: !isBusy,
                title: const Text('Snowflake'),
                subtitle: const Text('Suitable for heavy censorship'),
              ),
            ],
          ),
        ),
        CheckboxListTile.adaptive(
          controlAffinity: ListTileControlAffinity.leading,
          enabled: !isBusy && torSettings.config != TorConnectionConfig.direct,
          value: torSettings.fetchRemoteBridges,
          title: const Text('Fetch fresh Bridges before connecting'),
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
  entry(title: 'Entry Country'),
  exit(title: 'Exit Country');

  const _NodeRole({required this.title});

  final String title;
}

class _CountryPickerTile extends ConsumerWidget {
  const _CountryPickerTile({required this.role});

  final _NodeRole role;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
      title: Text(role.title),
      subtitle: Text(country ?? 'Automatic'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () async {
        final result = await TorCountryPickerRoute(
          title: role.title,
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
