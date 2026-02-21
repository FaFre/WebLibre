import 'dart:async';

import 'package:fading_scroll/fading_scroll.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';
import 'package:weblibre/core/providers/format.dart';
import 'package:weblibre/features/qr_scanner/presentation/dialogs/qr_scanner_dialog.dart';
import 'package:weblibre/features/settings/presentation/controllers/save_settings.dart';
import 'package:weblibre/features/settings/presentation/widgets/sections.dart';
import 'package:weblibre/features/sync/domain/entities/sync_repository_state.dart';
import 'package:weblibre/features/sync/domain/repositories/sync.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/utils/ui_helper.dart' as ui_helper;

class SyncSettingsScreen extends HookConsumerWidget {
  const SyncSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncInfo = ref.watch(
      syncRepositoryProvider.select((value) => value.value?.account),
    );

    final generalSettings = ref.watch(generalSettingsWithDefaultsProvider);

    final syncStarted = ref.watch(
      syncEventProvider.select(
        (value) => value.isLoading || value.value?.$1 == SyncEvent.started,
      ),
    );
    final isSyncing = syncStarted || syncInfo?.syncing == true;

    final syncText = useMemoized(() {
      if (isSyncing) {
        return 'Synchronization in progress';
      }

      final timestamp = syncInfo?.lastSyncedAt;
      if (timestamp == null || timestamp <= 0) {
        return 'Never synced';
      }

      final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
      final formattedDate = ref
          .read(formatProvider.notifier)
          .fullDateTime(date.toLocal());

      return 'Last synced: $formattedDate';
    }, [syncInfo, isSyncing]);

    final syncController = useAnimationController(
      duration: const Duration(seconds: 2),
    );

    useEffect(() {
      if (isSyncing) {
        unawaited(syncController.repeat());
      } else {
        syncController.stop();
        syncController.reset();
      }
      return null;
    }, [isSyncing]);

    return Scaffold(
      appBar: AppBar(title: const Text('Firefox Sync')),
      body: SafeArea(
        child: FadingScroll(
          fadingSize: 25,
          builder: (context, controller) {
            return ListView(
              controller: controller,
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              children: [
                const SettingSection(name: 'Account'),
                ListTile(
                  leading: const Icon(Icons.account_circle_outlined),
                  title: Text(syncInfo?.email ?? 'Not signed in'),
                  subtitle: Text(
                    syncInfo?.needsReauth == true
                        ? 'Authentication expired. Sign in again to continue syncing.'
                        : syncInfo?.authenticated == true
                        ? (syncInfo?.displayName ?? 'Signed in')
                        : 'Sign in to synchronize tabs, bookmarks, and history',
                  ),
                  trailing: syncInfo?.authenticated == true
                      ? IconButton(
                          icon: const Icon(Icons.logout),
                          tooltip: 'Sign Out',
                          onPressed: isSyncing
                              ? null
                              : () async {
                                  final confirmed =
                                      await _showSignOutConfirmation(context);
                                  if (confirmed == true) {
                                    await ref
                                        .read(syncRepositoryProvider.notifier)
                                        .signOut();
                                  }
                                },
                        )
                      : const Icon(Icons.login),
                  onTap: (syncInfo?.authenticated == true || isSyncing)
                      ? null
                      : () async {
                          await ref
                              .read(syncRepositoryProvider.notifier)
                              .signIn();
                        },
                ),
                if (syncInfo?.authenticated != true && !isSyncing)
                  ListTile(
                    leading: const Icon(Icons.qr_code_scanner),
                    title: const Text('Scan QR Code to pair'),
                    subtitle: const Text(
                      'Scan a QR code from firefox.com/pair on desktop',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () async {
                      final barcode = await showDialog<Barcode>(
                        context: context,
                        builder: (_) => const QrScannerDialog(),
                      );

                      final code = barcode?.code;
                      if (code == null || code.isEmpty) return;

                      final uri = Uri.tryParse(code);
                      if (uri == null || !uri.hasScheme) {
                        if (context.mounted) {
                          ui_helper.showErrorMessage(
                            context,
                            'Invalid QR code: not a valid URL',
                          );
                        }

                        return;
                      }

                      await ref
                          .read(syncRepositoryProvider.notifier)
                          .signInWithPairing(code);
                    },
                  ),
                if (syncInfo?.authenticated == true)
                  ListTile(
                    leading: const Icon(Icons.devices),
                    title: const Text('Device Name'),
                    subtitle: ref
                        .watch(syncDeviceNameProvider)
                        .when(
                          data: (name) => Text(name ?? 'Unknown'),
                          loading: () => const Text('Loading...'),
                          error: (_, _) => const Text('Unknown'),
                        ),
                    trailing: const Icon(Icons.edit_outlined),
                    onTap: isSyncing
                        ? null
                        : () async {
                            final currentName = ref
                                .read(syncRepositoryProvider)
                                .value
                                ?.deviceName;

                            if (currentName != null && context.mounted) {
                              await _showDeviceNameDialog(
                                context,
                                currentName: currentName,
                                onSave: (newName) {
                                  return ref
                                      .read(syncRepositoryProvider.notifier)
                                      .setDeviceName(newName);
                                },
                              );
                            }
                          },
                  ),
                const SettingSection(name: 'Synchronization'),
                ListTile(
                  leading: RotationTransition(
                    turns: Tween<double>(
                      begin: 0,
                      end: -1,
                    ).animate(syncController),
                    child: const Icon(Icons.sync),
                  ),
                  title: const Text('Sync Now'),
                  subtitle: Text(syncText),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: isSyncing
                      ? null
                      : () async {
                          await ref
                              .read(syncRepositoryProvider.notifier)
                              .syncNow();
                        },
                ),
                SwitchListTile.adaptive(
                  title: const Text('Sync History'),
                  value: _engineEnabled(syncInfo, SyncEngineValue.history),
                  onChanged: (syncInfo == null || isSyncing)
                      ? null
                      : (value) async {
                          await ref
                              .read(syncRepositoryProvider.notifier)
                              .setEngineEnabled(SyncEngineValue.history, value);
                        },
                ),
                SwitchListTile.adaptive(
                  title: const Text('Sync Bookmarks'),
                  value: _engineEnabled(syncInfo, SyncEngineValue.bookmarks),
                  onChanged: (syncInfo == null || isSyncing)
                      ? null
                      : (value) async {
                          await ref
                              .read(syncRepositoryProvider.notifier)
                              .setEngineEnabled(
                                SyncEngineValue.bookmarks,
                                value,
                              );
                        },
                ),
                SwitchListTile.adaptive(
                  title: const Text('Sync Open Tabs'),
                  value: _engineEnabled(syncInfo, SyncEngineValue.tabs),
                  onChanged: (syncInfo == null || isSyncing)
                      ? null
                      : (value) async {
                          await ref
                              .read(syncRepositoryProvider.notifier)
                              .setEngineEnabled(SyncEngineValue.tabs, value);
                        },
                ),
                const SettingSection(name: 'Server Overrides'),
                ListTile(
                  title: const Text('FxA Server Override'),
                  subtitle: Text(
                    generalSettings.syncServerOverride.isEmpty
                        ? 'Default Mozilla server'
                        : generalSettings.syncServerOverride,
                  ),
                  trailing: const Icon(Icons.edit_outlined),
                  onTap: isSyncing
                      ? null
                      : () => _showTextSettingDialog(
                          context,
                          title: 'FxA Server Override',
                          initialValue: generalSettings.syncServerOverride,
                          hint: 'https://accounts.firefox.com',
                          onSave: (value) {
                            return ref
                                .read(
                                  saveGeneralSettingsControllerProvider
                                      .notifier,
                                )
                                .save(
                                  (current) => current.copyWith
                                      .syncServerOverride(value.trim()),
                                );
                          },
                        ),
                ),
                ListTile(
                  title: const Text('Sync Token Server Override'),
                  subtitle: Text(
                    generalSettings.syncTokenServerOverride.isEmpty
                        ? 'Automatic from FxA server'
                        : generalSettings.syncTokenServerOverride,
                  ),
                  trailing: const Icon(Icons.edit_outlined),
                  onTap: isSyncing
                      ? null
                      : () => _showTextSettingDialog(
                          context,
                          title: 'Sync Token Server Override',
                          initialValue: generalSettings.syncTokenServerOverride,
                          hint:
                              'https://token.services.mozilla.com/1.0/sync/1.5',
                          onSave: (value) {
                            return ref
                                .read(
                                  saveGeneralSettingsControllerProvider
                                      .notifier,
                                )
                                .save(
                                  (current) => current.copyWith
                                      .syncTokenServerOverride(value.trim()),
                                );
                          },
                        ),
                ),
                const ListTile(
                  dense: true,
                  title: Text(
                    'Restart the app after changing server overrides.',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  static bool _engineEnabled(SyncAccountInfo? info, SyncEngineValue engine) {
    final engines = info?.engines;
    if (engines == null) {
      return true;
    }

    for (final status in engines) {
      if (status.engine == engine) {
        return status.enabled;
      }
    }

    return true;
  }

  static Future<bool?> _showSignOutConfirmation(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Sign out?'),
          content: const Text(
            'Are you sure you want to sign out of Firefox Sync?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Sign Out'),
            ),
          ],
        );
      },
    );
  }

  static Future<void> _showDeviceNameDialog(
    BuildContext context, {
    required String currentName,
    required Future<bool> Function(String name) onSave,
  }) async {
    final controller = TextEditingController(text: currentName);
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Device Name'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'Enter device name'),
            autofocus: true,
            inputFormatters: [LengthLimitingTextInputFormatter(128)],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                final newName = controller.text.trim();
                if (newName.isEmpty) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Device name cannot be empty'),
                      ),
                    );
                  }
                  return;
                }

                final success = await onSave(newName).catchError((_) => false);

                if (!success) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Failed to update device name'),
                      ),
                    );
                  }
                  return;
                }

                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  static Future<void> _showTextSettingDialog(
    BuildContext context, {
    required String title,
    required String initialValue,
    required String hint,
    required Future<void> Function(String value) onSave,
  }) async {
    final controller = TextEditingController(text: initialValue);
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(hintText: hint),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                final value = controller.text.trim();
                if (value.isNotEmpty) {
                  final uri = Uri.tryParse(value);
                  if (uri == null || uri.scheme != 'https') {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Must be a valid HTTPS URL'),
                        ),
                      );
                    }
                    return;
                  }
                }
                await onSave(controller.text);
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
