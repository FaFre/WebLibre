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
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/features/settings/presentation/controllers/save_settings.dart';
import 'package:weblibre/features/tor/domain/services/tor_proxy.dart';
import 'package:weblibre/features/user/data/models/tor_settings.dart';
import 'package:weblibre/features/user/domain/repositories/tor_settings.dart';
import 'package:weblibre/presentation/hooks/on_initialization.dart';
import 'package:weblibre/presentation/icons/tor_icons.dart';

class TorProxyScreen extends HookConsumerWidget {
  const TorProxyScreen();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final torProxyPort = ref.watch(torProxyServiceProvider);
    final torSettings = ref.watch(torSettingsWithDefaultsProvider);

    useOnInitialization(() async {
      await ref.read(torProxyServiceProvider.notifier).requestSync();
    });

    ref.listen(torSettingsRepositoryProvider, (previous, next) async {
      final torService = ref.read(torProxyServiceProvider.notifier);

      if (await torService.requestSync() != null) {
        await torService.startOrReconfigure();
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Tor™ Proxy')),
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
                return const Color(0xFF333A41);
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
          ),
        ),
        child: SafeArea(
          child: ColoredBox(
            color: const Color(0xFF7D4698),
            child: Column(
              children: [
                const SizedBox(height: 16),
                const Icon(TorIcons.onionAlt, size: 84),
                const SizedBox(height: 16),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: SwitchListTile.adaptive(
                    inactiveThumbColor: Colors.white,
                    activeThumbColor: const Color(0xFF68B030),
                    thumbIcon: WidgetStateProperty.resolveWith<Icon?>((
                      Set<WidgetState> states,
                    ) {
                      if (states.contains(WidgetState.selected)) {
                        return const Icon(MdiIcons.axisArrowLock);
                      }
                      return null; // Use the default color.
                    }),
                    value: torProxyPort.value != null,
                    title: const Text('Tor™ Proxy'),
                    secondary: const Icon(MdiIcons.power),
                    onChanged: torProxyPort.isLoading
                        ? null
                        : (value) async {
                            if (value) {
                              await ref
                                  .read(torProxyServiceProvider.notifier)
                                  .startOrReconfigure();
                            } else {
                              await ref
                                  .read(torProxyServiceProvider.notifier)
                                  .disconnect();
                            }
                          },
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: FadingScroll(
                    fadingSize: 25,
                    builder: (context, controller) {
                      return FadingScroll(
                        controller: controller,
                        fadingSize: 25,
                        builder: (context, controller) {
                          return ListView(
                            controller: controller,
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
                                        .read(
                                          saveTorSettingsControllerProvider
                                              .notifier,
                                        )
                                        .save(
                                          (currentSettings) => currentSettings
                                              .copyWith
                                              .proxyRegularTabsMode(value),
                                        );
                                  }
                                },
                                child: const RadioListTile.adaptive(
                                  value: TorRegularTabProxyMode.container,
                                  title: Text('Container-Based Routing'),
                                  subtitle: Text(
                                    'Route only tabs in Tor containers through the Tor network. Private tabs remain unaffected.',
                                  ),
                                ),
                              ),
                              RadioGroup(
                                groupValue: torSettings.proxyRegularTabsMode,
                                onChanged: (value) async {
                                  if (value != null) {
                                    await ref
                                        .read(
                                          saveTorSettingsControllerProvider
                                              .notifier,
                                        )
                                        .save(
                                          (currentSettings) => currentSettings
                                              .copyWith
                                              .proxyRegularTabsMode(value),
                                        );
                                  }
                                },
                                child: const RadioListTile.adaptive(
                                  value: TorRegularTabProxyMode.all,
                                  title: Text('Global Routing'),
                                  subtitle: Text(
                                    'Route all regular tabs through the Tor network. Private tabs remain unaffected.',
                                  ),
                                ),
                              ),
                              SwitchListTile.adaptive(
                                inactiveThumbColor: Colors.white,
                                activeThumbColor: const Color(0xFF68B030),
                                thumbIcon:
                                    WidgetStateProperty.resolveWith<Icon?>((
                                      Set<WidgetState> states,
                                    ) {
                                      if (states.contains(
                                        WidgetState.selected,
                                      )) {
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
                                      .read(
                                        saveTorSettingsControllerProvider
                                            .notifier,
                                      )
                                      .save(
                                        (currentSettings) => currentSettings
                                            .copyWith
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
                                activeThumbColor: const Color(0xFF68B030),
                                thumbIcon:
                                    WidgetStateProperty.resolveWith<Icon?>((
                                      Set<WidgetState> states,
                                    ) {
                                      if (states.contains(
                                        WidgetState.selected,
                                      )) {
                                        return const Icon(
                                          MdiIcons.arrowDecisionAuto,
                                        );
                                      }
                                      return null; // Use the default color.
                                    }),
                                value:
                                    torSettings.config ==
                                    TorConnectionConfig.auto,
                                title: const Text('Auto Configure Transport'),
                                subtitle: const Text(
                                  'From some locations, it is necessary to use a pluggable transport to connect to Tor',
                                ),
                                secondary: const Icon(
                                  MdiIcons.arrowDecisionAuto,
                                ),
                                onChanged: torProxyPort.isLoading
                                    ? null
                                    : (value) async {
                                        await ref
                                            .read(
                                              saveTorSettingsControllerProvider
                                                  .notifier,
                                            )
                                            .save(
                                              (
                                                currentSettings,
                                              ) => currentSettings.copyWith
                                                  .config(
                                                    value
                                                        ? TorConnectionConfig
                                                              .auto
                                                        : TorConnectionConfig
                                                              .direct,
                                                  ),
                                            );
                                      },
                              ),
                              if (torSettings.config ==
                                  TorConnectionConfig.auto) ...[
                                SwitchListTile.adaptive(
                                  inactiveThumbColor: Colors.white,
                                  activeThumbColor: const Color(0xFF68B030),
                                  value: torSettings.requireBridge,
                                  contentPadding: const EdgeInsets.only(
                                    left: 56,
                                    right: 24,
                                  ),
                                  onChanged: torProxyPort.isLoading
                                      ? null
                                      : (value) async {
                                          await ref
                                              .read(
                                                saveTorSettingsControllerProvider
                                                    .notifier,
                                              )
                                              .save(
                                                (currentSettings) =>
                                                    currentSettings.copyWith
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
                                            saveTorSettingsControllerProvider
                                                .notifier,
                                          )
                                          .save(
                                            (currentSettings) => currentSettings
                                                .copyWith
                                                .config(value),
                                          );
                                    }
                                  },
                                  child: RadioListTile.adaptive(
                                    value: TorConnectionConfig.direct,
                                    enabled: !torProxyPort.isLoading,
                                    contentPadding: const EdgeInsets.only(
                                      left: 56,
                                      right: 24,
                                    ),
                                    title: const Text('Direct Connection'),
                                    subtitle: const Text(
                                      'The best way to connect to Tor if Tor is not blocked',
                                    ),
                                  ),
                                ),
                                RadioGroup(
                                  groupValue: torSettings.config,
                                  onChanged: (value) async {
                                    if (value != null) {
                                      await ref
                                          .read(
                                            saveTorSettingsControllerProvider
                                                .notifier,
                                          )
                                          .save(
                                            (currentSettings) => currentSettings
                                                .copyWith
                                                .config(value),
                                          );
                                    }
                                  },
                                  child: RadioListTile.adaptive(
                                    value: TorConnectionConfig.obfs4,
                                    enabled: !torProxyPort.isLoading,
                                    contentPadding: const EdgeInsets.only(
                                      left: 56,
                                      right: 24,
                                    ),
                                    title: const Text('obfs4'),
                                    subtitle: const Text(
                                      'Suitable for light censorship and high bandwidth needs',
                                    ),
                                  ),
                                ),
                                RadioGroup(
                                  groupValue: torSettings.config,
                                  onChanged: (value) async {
                                    if (value != null) {
                                      await ref
                                          .read(
                                            saveTorSettingsControllerProvider
                                                .notifier,
                                          )
                                          .save(
                                            (currentSettings) => currentSettings
                                                .copyWith
                                                .config(value),
                                          );
                                    }
                                  },
                                  child: RadioListTile.adaptive(
                                    value: TorConnectionConfig.snowflake,
                                    enabled: !torProxyPort.isLoading,
                                    contentPadding: const EdgeInsets.only(
                                      left: 56,
                                      right: 24,
                                    ),
                                    title: const Text('Snowflake'),
                                    subtitle: const Text(
                                      'Suitable for heavy censorship',
                                    ),
                                  ),
                                ),
                                CheckboxListTile.adaptive(
                                  value: torSettings.fetchRemoteBridges,
                                  controlAffinity:
                                      ListTileControlAffinity.leading,
                                  enabled:
                                      torSettings.config !=
                                      TorConnectionConfig.direct,
                                  contentPadding: const EdgeInsets.only(
                                    left: 56,
                                    right: 24,
                                  ),
                                  onChanged: torProxyPort.isLoading
                                      ? null
                                      : (value) async {
                                          if (value != null) {
                                            await ref
                                                .read(
                                                  saveTorSettingsControllerProvider
                                                      .notifier,
                                                )
                                                .save(
                                                  (currentSettings) =>
                                                      currentSettings.copyWith
                                                          .fetchRemoteBridges(
                                                            value,
                                                          ),
                                                );
                                          }
                                        },
                                  title: const Text(
                                    "Fetch fresh Bridges before connecting",
                                  ),
                                ),
                              ],
                            ],
                          );
                        },
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (torProxyPort.isLoading)
                        const Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(height: 8),
                            LinearProgressIndicator(
                              backgroundColor: Color(0xFF333A41),
                              color: Color(0xFF68B030),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Establishing connection...',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      if (torProxyPort.value != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 24.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                MdiIcons.shieldLockOutline,
                                color: Color(0xFF68B030),
                                size: 32,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Connected to the Tor Network',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(color: const Color(0xFF68B030)),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    right: 8.0,
                    left: 8.0,
                    bottom: 8.0,
                  ),
                  child: Text(
                    'Tor is a trademark of The Tor Project; all rights reserved. WebLibre is not endorsed or sponsored by, or affiliated with, the Tor Project.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontStyle: FontStyle.italic,
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
