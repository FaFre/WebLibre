import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/features/settings/presentation/controllers/save_settings.dart';
import 'package:weblibre/features/tor/domain/services/tor_proxy.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/presentation/hooks/on_initialization.dart';

class TorProxyScreen extends HookConsumerWidget {
  const TorProxyScreen();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final torProxyPort = ref.watch(torProxyServiceProvider);
    final proxyPrivateTabsTor = ref.watch(
      generalSettingsRepositoryProvider.select(
        (value) => value.proxyPrivateTabsTor,
      ),
    );

    useOnInitialization(() async {
      await ref.read(torProxyServiceProvider.notifier).requestSync();
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Tor Proxy')),
      body: ColoredBox(
        color: const Color(0xFF7D4698),
        child: Column(
          children: [
            Flexible(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SvgPicture.asset('assets/images/tor_white.svg', width: 200),
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
                      title: const Text('Tor Proxy'),
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
                      value: proxyPrivateTabsTor,
                      title: const Text('Proxy Private Tabs'),
                      subtitle: const Text(
                        'When enabled, all Private Tabs will be tunneled through Tor',
                      ),
                      secondary: const Icon(MdiIcons.arrowDecision),
                      onChanged: (value) async {
                        await ref
                            .read(
                              saveGeneralSettingsControllerProvider.notifier,
                            )
                            .save(
                              (currentSettings) => currentSettings.copyWith
                                  .proxyPrivateTabsTor(value),
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
          ],
        ),
      ),
    );
  }
}
