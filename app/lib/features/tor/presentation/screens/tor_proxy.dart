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

    return Scaffold(
      appBar: AppBar(title: const Text('Tor™ Proxy')),
      body: SafeArea(
        child: ColoredBox(
          color: const Color(0xFF7D4698),
          child: Column(
            children: [
              Flexible(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Icon(TorIcons.onionAlt, size: 84),
                    const SizedBox(height: 16),
                    ListTileTheme(
                      iconColor: Colors.white,
                      textColor: Colors.white,
                      child: SwitchListTile.adaptive(
                        inactiveThumbColor: Colors.white,
                        activeColor: const Color(0xFF68B030),
                        trackColor: WidgetStateProperty.resolveWith<Color?>((
                          Set<WidgetState> states,
                        ) {
                          if (states.isEmpty) {
                            return const Color(0xFF333A41);
                          }
                          return null; // Use the default color.
                        }),
                        trackOutlineColor:
                            WidgetStateProperty.resolveWith<Color?>((
                              Set<WidgetState> states,
                            ) {
                              if (states.isEmpty) {
                                return Colors.white;
                              }
                              return null; // Use the default color.
                            }),
                        thumbIcon: WidgetStateProperty.resolveWith<Icon?>((
                          Set<WidgetState> states,
                        ) {
                          if (states.contains(WidgetState.selected)) {
                            return const Icon(MdiIcons.axisArrowLock);
                          }
                          return null; // Use the default color.
                        }),
                        value: torProxyPort.valueOrNull != null,
                        title: const Text('Tor™ Proxy'),
                        secondary: const Icon(MdiIcons.power),
                        onChanged: torProxyPort.isLoading
                            ? null
                            : (value) async {
                                if (value) {
                                  await ref
                                      .read(torProxyServiceProvider.notifier)
                                      .connect();
                                } else {
                                  await ref
                                      .read(torProxyServiceProvider.notifier)
                                      .disconnect();
                                }
                              },
                      ),
                    ),
                    ListTileTheme(
                      iconColor: Colors.white,
                      textColor: Colors.white,
                      child: SwitchListTile.adaptive(
                        inactiveThumbColor: Colors.white,
                        activeColor: const Color(0xFF68B030),
                        trackColor: WidgetStateProperty.resolveWith<Color?>((
                          Set<WidgetState> states,
                        ) {
                          if (states.isEmpty) {
                            return const Color(0xFF333A41);
                          }
                          return null; // Use the default color.
                        }),
                        trackOutlineColor:
                            WidgetStateProperty.resolveWith<Color?>((
                              Set<WidgetState> states,
                            ) {
                              if (states.isEmpty) {
                                return Colors.white;
                              }
                              return null; // Use the default color.
                            }),
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
                        secondary: const Icon(MdiIcons.arrowDecision),
                        onChanged: (value) async {
                          await ref
                              .read(saveTorSettingsControllerProvider.notifier)
                              .save(
                                (currentSettings) => currentSettings.copyWith
                                    .proxyPrivateTabsTor(value),
                              );
                        },
                      ),
                    ),
                    ListTileTheme(
                      iconColor: Colors.white,
                      textColor: Colors.white,
                      child: SwitchListTile.adaptive(
                        inactiveThumbColor: Colors.white,
                        activeColor: const Color(0xFF68B030),
                        trackColor: WidgetStateProperty.resolveWith<Color?>((
                          Set<WidgetState> states,
                        ) {
                          if (states.isEmpty) {
                            return const Color(0xFF333A41);
                          }
                          return null; // Use the default color.
                        }),
                        trackOutlineColor:
                            WidgetStateProperty.resolveWith<Color?>((
                              Set<WidgetState> states,
                            ) {
                              if (states.isEmpty) {
                                return Colors.white;
                              }
                              return null; // Use the default color.
                            }),
                        thumbIcon: WidgetStateProperty.resolveWith<Icon?>((
                          Set<WidgetState> states,
                        ) {
                          if (states.contains(WidgetState.selected)) {
                            return const Icon(MdiIcons.arrowDecisionAuto);
                          }
                          return null; // Use the default color.
                        }),
                        value: torSettings.autoConfig,
                        title: const Text('Configure Transport Automatically'),
                        subtitle: const Text(
                          'From some locations, it is necessary to use a pluggable transport to connect to the Tor network that is otherwise blocked. Turn off automatic configuration to manually configure how Tor connects.',
                        ),
                        secondary: const Icon(MdiIcons.arrowDecision),
                        onChanged: (value) async {
                          await ref
                              .read(saveTorSettingsControllerProvider.notifier)
                              .save(
                                (currentSettings) =>
                                    currentSettings.copyWith.autoConfig(value),
                              );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: Column(
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
                    if (torProxyPort.valueOrNull != null)
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
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
