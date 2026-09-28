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
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/core/design/display_features.dart';
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/core/providers/format.dart';
import 'package:weblibre/features/qr_scanner/presentation/dialogs/qr_scanner_dialog.dart';
import 'package:weblibre/features/settings/presentation/controllers/save_settings.dart';
import 'package:weblibre/features/settings/presentation/widgets/settings_detail.dart';
import 'package:weblibre/features/sync/domain/entities/sync_repository_state.dart';
import 'package:weblibre/features/sync/domain/repositories/sync.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';
import 'package:weblibre/utils/ui_helper.dart' as ui_helper;

class SyncSettingsScreen extends HookConsumerWidget {
  const SyncSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final syncInfo = ref.watch(
      syncRepositoryProvider.select((value) => value.value?.account),
    );

    final generalSettings = ref.watch(generalSettingsWithDefaultsProvider);

    final lastSyncEvent = ref.watch(
      syncEventProvider.select((value) => value.value?.$1),
    );

    // `account.syncing` is the primary signal: it rides the auth-state stream, which
    // is a BehaviorSubject, so it is replayed to whoever subscribes late and carries
    // the value the native sync callback actually knew.
    //
    // The start/complete events cannot play that role — they are PublishSubjects, so
    // anything emitted before the repository subscribes is gone, which is why
    // `started` must never latch the spinner on by itself. A *finished* event is
    // only used in the other direction, as a release: having observed a sync end is
    // proof we are idle even if the flag has gone stale.
    //
    // Deliberately not keyed off `AsyncValue.isLoading` any more: that is true while
    // the provider recomputes after *any* repository change, which made an unrelated
    // refresh look like a sync in progress.
    final isSyncing = switch (lastSyncEvent) {
      SyncEvent.completed || SyncEvent.error => false,
      _ => syncInfo?.syncing == true,
    };

    final syncText = useMemoized(() {
      if (isSyncing) {
        return l10n.sync_statusSyncing;
      }

      final timestamp = syncInfo?.lastSyncedAt;
      if (timestamp == null || timestamp <= 0) {
        return l10n.sync_statusNeverSynced;
      }

      final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
      final formattedDate = ref
          .read(formatProvider.notifier)
          .fullDateTime(date.toLocal());

      return l10n.sync_statusLastSynced(formattedDate);
    }, [syncInfo, isSyncing, l10n]);

    // `authenticated` is the only trustworthy signal for "is there an account".
    // The email comes from the FxA profile, which is absent whenever the profile
    // fetch has not succeeded — keying the card off it rendered a perfectly
    // signed-in account as "Not signed in". `needsReauth` still means an account
    // exists, just an expired one.
    final hasAccount =
        syncInfo?.authenticated == true || syncInfo?.needsReauth == true;

    final disableAnimations = MediaQuery.disableAnimationsOf(context);

    final syncController = useAnimationController(
      duration: disableAnimations ? Duration.zero : const Duration(seconds: 2),
    );
    final search = useSettingsSearch();

    useEffect(() {
      if (isSyncing && !disableAnimations) {
        syncController.repeat();
      } else {
        syncController.stop();
        syncController.reset();
      }
      return null;
    }, [isSyncing, disableAnimations]);

    final sections = <SettingsSectionDefinition>[
      SettingsSectionDefinition(
        title: l10n.sync_sectionAccount,
        entries: [
          SettingsEntryDefinition(
            title: syncInfo?.authenticated == true
                ? l10n.sync_entrySignedInAccountTitle
                : l10n.sync_entrySignInTitle,
            subtitle: l10n.sync_entryAccountSubtitle,
            keywords: settingsKeywords(l10n.sync_sectionAccountKeywords),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.account_circle_outlined),
                  title: Text(
                    syncInfo?.email ??
                        (hasAccount
                            ? l10n.sync_signedIn
                            : l10n.sync_notSignedIn),
                  ),
                  subtitle: Text(
                    syncInfo?.needsReauth == true
                        ? l10n.sync_authExpired
                        : syncInfo?.authenticated == true
                        ? (syncInfo?.displayName ??
                              l10n.sync_syncingTabsBookmarksHistory)
                        : l10n.sync_signInPrompt,
                  ),
                  trailing: syncInfo?.authenticated == true
                      ? IconButton(
                          icon: const Icon(Icons.logout),
                          tooltip: l10n.sync_actionSignOut,
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
                if (syncInfo?.authenticated != true && !isSyncing) ...[
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.qr_code_scanner),
                    title: Text(l10n.sync_scanQrTitle),
                    subtitle: Text(l10n.sync_scanQrSubtitle),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () async {
                      final barcode = await showQrScannerDialog(context);

                      final code = barcode?.code;
                      if (code == null || code.isEmpty) return;

                      final uri = Uri.tryParse(code);
                      if (uri == null || !uri.hasScheme) {
                        if (context.mounted) {
                          ui_helper.showErrorMessage(
                            context,
                            l10n.sync_invalidQrCode,
                          );
                        }

                        return;
                      }

                      await ref
                          .read(syncRepositoryProvider.notifier)
                          .signInWithPairing(code);
                    },
                  ),
                ],
                if (syncInfo?.authenticated == true) ...[
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.devices),
                    title: Text(l10n.sync_deviceNameTitle),
                    subtitle: ref
                        .watch(syncDeviceNameProvider)
                        .when(
                          data: (name) => Text(name ?? l10n.sync_unknown),
                          loading: () => Text(l10n.common_loading),
                          error: (_, _) => Text(l10n.sync_unknown),
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
                ],
              ],
            ),
          ),
        ],
      ),
      SettingsSectionDefinition(
        title: l10n.sync_sectionSynchronization,
        entries: [
          SettingsEntryDefinition(
            title: l10n.sync_syncNowTitle,
            subtitle: syncText,
            keywords: settingsKeywords(l10n.sync_syncNowKeywords),
            child: Column(
              children: [
                ListTile(
                  leading: RotationTransition(
                    turns: Tween<double>(
                      begin: 0,
                      end: -1,
                    ).animate(syncController),
                    child: const Icon(Icons.sync),
                  ),
                  title: Text(l10n.sync_syncNowTitle),
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
                const Divider(height: 1),
                SwitchListTile.adaptive(
                  title: Text(l10n.sync_syncHistoryTitle),
                  value: _engineEnabled(syncInfo, SyncEngineValue.history),
                  onChanged: (syncInfo == null || isSyncing)
                      ? null
                      : (value) async {
                          await ref
                              .read(syncRepositoryProvider.notifier)
                              .setEngineEnabled(SyncEngineValue.history, value);
                        },
                ),
                const Divider(height: 1),
                SwitchListTile.adaptive(
                  title: Text(l10n.sync_syncBookmarksTitle),
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
                const Divider(height: 1),
                SwitchListTile.adaptive(
                  title: Text(l10n.sync_syncOpenTabsTitle),
                  value: _engineEnabled(syncInfo, SyncEngineValue.tabs),
                  onChanged: (syncInfo == null || isSyncing)
                      ? null
                      : (value) async {
                          await ref
                              .read(syncRepositoryProvider.notifier)
                              .setEngineEnabled(SyncEngineValue.tabs, value);
                        },
                ),
              ],
            ),
          ),
        ],
      ),
      SettingsSectionDefinition(
        title: l10n.sync_sectionServerOverrides,
        entries: [
          SettingsEntryDefinition(
            title: l10n.sync_entryServerOverridesTitle,
            subtitle: l10n.sync_entryServerOverridesSubtitle,
            keywords: settingsKeywords(l10n.sync_entryServerOverridesKeywords),
            child: Column(
              children: [
                ListTile(
                  title: Text(l10n.sync_fxaServerOverrideTitle),
                  subtitle: Text(
                    generalSettings.syncServerOverride.isEmpty
                        ? l10n.sync_defaultMozillaServer
                        : generalSettings.syncServerOverride,
                  ),
                  trailing: const Icon(Icons.edit_outlined),
                  onTap: isSyncing
                      ? null
                      : () => _showTextSettingDialog(
                          context,
                          title: l10n.sync_fxaServerOverrideTitle,
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
                const Divider(height: 1),
                ListTile(
                  title: Text(l10n.sync_tokenServerOverrideTitle),
                  subtitle: Text(
                    generalSettings.syncTokenServerOverride.isEmpty
                        ? l10n.sync_automaticFromFxaServer
                        : generalSettings.syncTokenServerOverride,
                  ),
                  trailing: const Icon(Icons.edit_outlined),
                  onTap: isSyncing
                      ? null
                      : () => _showTextSettingDialog(
                          context,
                          title: l10n.sync_tokenServerOverrideTitle,
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
                const Divider(height: 1),
                ListTile(
                  dense: true,
                  title: Text(
                    l10n.sync_restartAppNotice,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ];

    final filteredSections = filterSettingsSections(
      sections: sections,
      query: search.rawQuery,
    );

    return SettingsCustomScrollScaffold(
      title: l10n.sync_screenTitle,
      searchController: search.controller,
      searchHintText: l10n.sync_searchHint,
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 20),
          sliver: SliverToBoxAdapter(
            child: SettingsSectionList(
              sections: filteredSections,
              query: search.rawQuery,
            ),
          ),
        ),
      ],
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
      anchorPoint: preferredAnchorPoint(MediaQuery.of(context)),
      builder: (context) {
        final l10n = AppLocalizations.of(context);

        return AlertDialog(
          title: Text(l10n.sync_signOutDialogTitle),
          content: Text(l10n.sync_signOutDialogContent),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.common_cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.sync_actionSignOut),
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
      anchorPoint: preferredAnchorPoint(MediaQuery.of(context)),
      builder: (context) {
        final l10n = AppLocalizations.of(context);

        return AlertDialog(
          title: Text(l10n.sync_deviceNameTitle),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(hintText: l10n.sync_deviceNameHint),
            autofocus: true,
            inputFormatters: [LengthLimitingTextInputFormatter(128)],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.common_cancel),
            ),
            FilledButton(
              onPressed: () async {
                final newName = controller.text.trim();
                if (newName.isEmpty) {
                  if (context.mounted) {
                    ui_helper.showErrorMessage(
                      context,
                      l10n.sync_deviceNameEmpty,
                    );
                  }
                  return;
                }

                final success = await onSave(newName).catchError((
                  Object error,
                  StackTrace stackTrace,
                ) {
                  logger.e(
                    'Failed to update device name',
                    error: error,
                    stackTrace: stackTrace,
                  );
                  return false;
                });

                if (!success) {
                  if (context.mounted) {
                    ui_helper.showErrorMessage(
                      context,
                      l10n.sync_deviceNameUpdateFailed,
                    );
                  }
                  return;
                }

                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              },
              child: Text(l10n.common_save),
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
      anchorPoint: preferredAnchorPoint(MediaQuery.of(context)),
      builder: (context) {
        final l10n = AppLocalizations.of(context);

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
              child: Text(l10n.common_cancel),
            ),
            FilledButton(
              onPressed: () async {
                final value = controller.text.trim();
                if (value.isNotEmpty) {
                  final uri = Uri.tryParse(value);
                  if (uri == null || uri.scheme != 'https') {
                    if (context.mounted) {
                      ui_helper.showErrorMessage(
                        context,
                        l10n.sync_mustBeValidHttpsUrl,
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
              child: Text(l10n.common_save),
            ),
          ],
        );
      },
    );
  }
}
