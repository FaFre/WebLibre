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
import 'package:weblibre/core/design/app_colors.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/features/settings/presentation/controllers/save_settings.dart';
import 'package:weblibre/features/tor/domain/services/tor_proxy.dart';
import 'package:weblibre/features/tor/presentation/screens/country_picker.dart';
import 'package:weblibre/features/user/data/models/tor_settings.dart';
import 'package:weblibre/features/user/domain/repositories/tor_settings.dart';
import 'package:weblibre/presentation/hooks/on_initialization.dart';
import 'package:weblibre/utils/ui_helper.dart';

class TorProxyScreen extends HookConsumerWidget {
  const TorProxyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appColors = AppColors.of(context);
    final bootstrapProgress = ref.watch(
      torProxyServiceProvider.select(
        (value) => value.value?.bootstrapProgress ?? 0,
      ),
    );

    final torPendingRequest = useState<bool?>(null);
    ref.listen(torProxyServiceProvider, (previous, next) {
      if (next.hasValue && torPendingRequest.value != null) {
        if (next.requireValue.isRunning != previous?.value?.isRunning ||
            next.requireValue.bootstrapProgress !=
                previous?.value?.bootstrapProgress) {
          if (torPendingRequest.value == true) {
            if (next.requireValue.bootstrapProgress > 0) {
              torPendingRequest.value = null;
            }
          } else {
            torPendingRequest.value = null;
          }
        }
      }
    });

    final torIsRunning = ref.watch(
      torProxyServiceProvider.select(
        (value) => value.value?.isRunning ?? false,
      ),
    );

    final torIsBootstrapped = ref.watch(
      torProxyServiceProvider.select(
        (value) => value.value?.bootstrapProgress == 100,
      ),
    );

    final torIsBusy =
        torPendingRequest.value != null ||
        bootstrapProgress > 0 && bootstrapProgress < 100;

    final torSettings = ref.watch(torSettingsWithDefaultsProvider);

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

    return Scaffold(
      body: Theme(
        data: Theme.of(context).copyWith(
          listTileTheme: ListTileTheme.of(
            context,
          ).copyWith(iconColor: Colors.white, textColor: Colors.white),
          switchTheme: SwitchTheme.of(context).copyWith(
            trackColor: WidgetStateProperty.resolveWith<Color?>((
              Set<WidgetState> states,
            ) {
              if (states.isEmpty) {
                return appColors.torBackgroundGrey;
              }
              return null; // Use the default color.
            }),
            trackOutlineColor: WidgetStateProperty.resolveWith<Color?>((
              Set<WidgetState> states,
            ) {
              if (states.isEmpty) {
                return Colors.white;
              }
              return null; // Use the default color.
            }),
          ),
          radioTheme: RadioTheme.of(context).copyWith(
            fillColor: WidgetStateColor.resolveWith((states) {
              return Colors.white;
            }),
          ),
          checkboxTheme: CheckboxTheme.of(context).copyWith(
            fillColor: WidgetStateColor.resolveWith((states) {
              return Colors.white;
            }),
            checkColor: WidgetStateProperty.all(appColors.torPurple),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        child: SafeArea(
          child: ColoredBox(
            color: appColors.torPurple,
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  pinned: true,
                  title: SwitchListTile.adaptive(
                    inactiveThumbColor: Colors.white,
                    activeThumbColor: appColors.torActiveGreen,
                    thumbIcon: WidgetStateProperty.resolveWith<Icon?>((
                      Set<WidgetState> states,
                    ) {
                      if (states.contains(WidgetState.selected)) {
                        return const Icon(MdiIcons.axisArrowLock);
                      }
                      return null; // Use the default color.
                    }),
                    value: torPendingRequest.value ?? torIsRunning,
                    title: const Text('Tor™ Service'),
                    secondary: const Icon(MdiIcons.power),
                    onChanged: torIsBusy
                        ? null
                        : (value) async {
                            if (value) {
                              torPendingRequest.value = true;

                              await ref
                                  .read(torProxyServiceProvider.notifier)
                                  .startOrReconfigure(
                                    reconfigureIfRunning: false,
                                  );
                            } else {
                              torPendingRequest.value = false;

                              await ref
                                  .read(torProxyServiceProvider.notifier)
                                  .disconnect();
                            }
                          },
                  ),
                  bottom: PreferredSize(
                    preferredSize: const Size.fromHeight(4 + 40 + 8),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (torPendingRequest.value != false && torIsBusy)
                          LinearProgressIndicator(
                            backgroundColor: appColors.torBackgroundGrey,
                            color: appColors.torActiveGreen,
                            value: bootstrapProgress / 100,
                          ),
                        Padding(
                          padding: const EdgeInsets.only(
                            top: 4.0,
                            right: 16,
                            left: 16,
                            bottom: 4,
                          ),
                          child: SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              onPressed:
                                  torIsRunning &&
                                      torIsBootstrapped &&
                                      !torIsBusy
                                  ? () async {
                                      await ref
                                          .read(
                                            torProxyServiceProvider.notifier,
                                          )
                                          .requestNewIdentity();

                                      if (context.mounted) {
                                        showInfoMessage(
                                          context,
                                          'Requesting new Tor identity...',
                                        );
                                      }
                                    }
                                  : null,
                              icon: const Icon(MdiIcons.refresh),
                              label: const Text('Request New Identity'),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverList.list(
                  children: [
                    const SizedBox(height: 16),
                    const Padding(
                      padding: EdgeInsets.only(left: 24.0),
                      child: Text(
                        'Routing',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    RadioGroup(
                      groupValue: torSettings.proxyRegularTabsMode,
                      onChanged: (value) async {
                        if (value != null) {
                          await ref
                              .read(saveTorSettingsControllerProvider.notifier)
                              .save(
                                (currentSettings) => currentSettings.copyWith
                                    .proxyRegularTabsMode(value),
                              );
                        }
                      },
                      child: const Column(
                        children: [
                          RadioListTile.adaptive(
                            value: TorRegularTabProxyMode.container,
                            title: Text('Container-Based Routing'),
                            subtitle: Text(
                              'Route only tabs in Tor containers through the Tor network. Private tabs remain unaffected.',
                            ),
                          ),
                          RadioListTile.adaptive(
                            value: TorRegularTabProxyMode.all,
                            title: Text('Global Routing'),
                            subtitle: Text(
                              'Route all regular tabs through the Tor network. Private tabs remain unaffected.',
                            ),
                          ),
                        ],
                      ),
                    ),

                    SwitchListTile.adaptive(
                      inactiveThumbColor: Colors.white,
                      activeThumbColor: appColors.torActiveGreen,
                      thumbIcon: WidgetStateProperty.resolveWith<Icon?>((
                        Set<WidgetState> states,
                      ) {
                        if (states.contains(WidgetState.selected)) {
                          return const Icon(MdiIcons.incognito);
                        }
                        return null; // Use the default color.
                      }),
                      value: torSettings.proxyPrivateTabsTor,
                      title: const Text('Proxy Private Tabs'),
                      subtitle: const Text(
                        'When enabled, all Private Tabs will be tunneled through Tor',
                      ),
                      secondary: const Icon(MdiIcons.incognito),
                      onChanged: (value) async {
                        await ref
                            .read(saveTorSettingsControllerProvider.notifier)
                            .save(
                              (currentSettings) => currentSettings.copyWith
                                  .proxyPrivateTabsTor(value),
                            );
                      },
                    ),
                    const SizedBox(height: 16),
                    const Padding(
                      padding: EdgeInsets.only(left: 24.0),
                      child: Text(
                        'Circumvention',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    SwitchListTile.adaptive(
                      inactiveThumbColor: Colors.white,
                      activeThumbColor: appColors.torActiveGreen,
                      thumbIcon: WidgetStateProperty.resolveWith<Icon?>((
                        Set<WidgetState> states,
                      ) {
                        if (states.contains(WidgetState.selected)) {
                          return const Icon(MdiIcons.arrowDecisionAuto);
                        }
                        return null; // Use the default color.
                      }),
                      value: torSettings.config == TorConnectionConfig.auto,
                      title: const Text('Auto Configure Transport'),
                      subtitle: const Text(
                        'From some locations, it is necessary to use a pluggable transport to connect to Tor',
                      ),
                      secondary: const Icon(MdiIcons.arrowDecisionAuto),
                      onChanged: torIsBusy
                          ? null
                          : (value) async {
                              await ref
                                  .read(
                                    saveTorSettingsControllerProvider.notifier,
                                  )
                                  .save(
                                    (currentSettings) =>
                                        currentSettings.copyWith.config(
                                          value
                                              ? TorConnectionConfig.auto
                                              : TorConnectionConfig.direct,
                                        ),
                                  );
                            },
                    ),
                    if (torSettings.config == TorConnectionConfig.auto) ...[
                      SwitchListTile.adaptive(
                        inactiveThumbColor: Colors.white,
                        activeThumbColor: appColors.torActiveGreen,
                        value: torSettings.requireBridge,
                        contentPadding: const EdgeInsets.only(
                          left: 56,
                          right: 24,
                        ),
                        onChanged: torIsBusy
                            ? null
                            : (value) async {
                                await ref
                                    .read(
                                      saveTorSettingsControllerProvider
                                          .notifier,
                                    )
                                    .save(
                                      (currentSettings) => currentSettings
                                          .copyWith
                                          .requireBridge(value),
                                    );
                              },
                        title: const Text(
                          "I'm sure I cannot connect without a bridge",
                        ),
                      ),
                    ] else ...[
                      RadioGroup(
                        groupValue: torSettings.config,
                        onChanged: (value) async {
                          if (value != null) {
                            await ref
                                .read(
                                  saveTorSettingsControllerProvider.notifier,
                                )
                                .save(
                                  (currentSettings) =>
                                      currentSettings.copyWith.config(value),
                                );
                          }
                        },
                        child: Column(
                          children: [
                            RadioListTile.adaptive(
                              value: TorConnectionConfig.direct,
                              enabled: !torIsBusy,
                              contentPadding: const EdgeInsets.only(
                                left: 56,
                                right: 24,
                              ),
                              title: const Text('Direct Connection'),
                              subtitle: const Text(
                                'The best way to connect to Tor if Tor is not blocked',
                              ),
                            ),
                            RadioListTile.adaptive(
                              value: TorConnectionConfig.obfs4,
                              enabled: !torIsBusy,
                              contentPadding: const EdgeInsets.only(
                                left: 56,
                                right: 24,
                              ),
                              title: const Text('obfs4'),
                              subtitle: const Text(
                                'Suitable for light censorship and high bandwidth needs',
                              ),
                            ),
                            RadioListTile.adaptive(
                              value: TorConnectionConfig.snowflake,
                              enabled: !torIsBusy,
                              contentPadding: const EdgeInsets.only(
                                left: 56,
                                right: 24,
                              ),
                              title: const Text('Snowflake'),
                              subtitle: const Text(
                                'Suitable for heavy censorship',
                              ),
                            ),
                          ],
                        ),
                      ),
                      CheckboxListTile.adaptive(
                        value: torSettings.fetchRemoteBridges,
                        controlAffinity: ListTileControlAffinity.leading,
                        enabled:
                            torSettings.config != TorConnectionConfig.direct,
                        contentPadding: const EdgeInsets.only(
                          left: 56,
                          right: 24,
                        ),
                        onChanged: torIsBusy
                            ? null
                            : (value) async {
                                if (value != null) {
                                  await ref
                                      .read(
                                        saveTorSettingsControllerProvider
                                            .notifier,
                                      )
                                      .save(
                                        (currentSettings) => currentSettings
                                            .copyWith
                                            .fetchRemoteBridges(value),
                                      );
                                }
                              },
                        title: const Text(
                          "Fetch fresh Bridges before connecting",
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    const Padding(
                      padding: EdgeInsets.only(left: 24.0),
                      child: Text(
                        'Country Restrictions',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    ListTile(
                      enabled: !torIsBusy,
                      leading:
                          torSettings.entryNodeCountry.mapNotNull(
                            (code) => CountryFlag.fromCountryCode(
                              code,
                              theme: const EmojiTheme(size: 28),
                            ),
                          ) ??
                          const Icon(Icons.public, color: Colors.white),
                      title: const Text('Entry Country'),
                      subtitle: Text(
                        torSettings.entryNodeCountry ?? 'Automatic',
                      ),
                      trailing: const Icon(
                        MdiIcons.chevronRight,
                        color: Colors.white,
                      ),
                      onTap: () async {
                        final result = await TorCountryPickerRoute(
                          title: 'Entry Country',
                          $extra: torSettings.entryNodeCountry,
                        ).push<String>(context);
                        if (result == null) return;
                        final value = result == automaticCountry
                            ? null
                            : result;
                        await ref
                            .read(saveTorSettingsControllerProvider.notifier)
                            .save(
                              (currentSettings) => currentSettings.copyWith
                                  .entryNodeCountry(value),
                            );
                      },
                    ),
                    ListTile(
                      enabled: !torIsBusy,
                      leading:
                          torSettings.exitNodeCountry.mapNotNull(
                            (code) => CountryFlag.fromCountryCode(
                              code,
                              theme: const EmojiTheme(size: 28),
                            ),
                          ) ??
                          const Icon(Icons.public, color: Colors.white),
                      title: const Text('Exit Country'),
                      subtitle: Text(
                        torSettings.exitNodeCountry ?? 'Automatic',
                      ),
                      trailing: const Icon(
                        MdiIcons.chevronRight,
                        color: Colors.white,
                      ),
                      onTap: () async {
                        final result = await TorCountryPickerRoute(
                          title: 'Exit Country',
                          $extra: torSettings.exitNodeCountry,
                        ).push<String>(context);
                        if (result == null) return;
                        final value = result == automaticCountry
                            ? null
                            : result;
                        await ref
                            .read(saveTorSettingsControllerProvider.notifier)
                            .save(
                              (currentSettings) => currentSettings.copyWith
                                  .exitNodeCountry(value),
                            );
                      },
                    ),
                  ],
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: 32.0,
                      right: 12.0,
                      left: 12.0,
                      bottom: 8.0,
                    ),
                    child: Text(
                      'Tor is a trademark of The Tor Project; all rights reserved. WebLibre is not endorsed or sponsored by, or affiliated with, the Tor Project.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontStyle: FontStyle.italic,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
