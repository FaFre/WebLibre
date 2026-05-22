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
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/core/providers/device_info.dart';
import 'package:weblibre/features/about/domain/providers.dart';
import 'package:weblibre/features/account/data/models/account_auth_state.dart';
import 'package:weblibre/features/account/data/models/subscription_status.dart';
import 'package:weblibre/features/account/data/repositories/account_sync_repository.dart';
import 'package:weblibre/features/account/domain/repositories/account_auth.dart';
import 'package:weblibre/features/account/domain/repositories/subscription_repository.dart';
import 'package:weblibre/features/account/domain/services/prefs_sync_service.dart';
import 'package:weblibre/features/account/domain/services/settings_sync_service.dart';
import 'package:weblibre/features/account/presentation/widgets/account_auth_status_card.dart';
import 'package:weblibre/features/account/presentation/widgets/subscription_card.dart';
import 'package:weblibre/features/account/presentation/widgets/sync_document_list_section.dart';
import 'package:weblibre/features/account/presentation/widgets/sync_setup_card.dart';
import 'package:weblibre/features/search_credits/presentation/widgets/search_credits_section.dart';
import 'package:weblibre/features/settings/presentation/widgets/settings_detail.dart';

class AccountSettingsScreen extends HookConsumerWidget {
  const AccountSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authAsync = ref.watch(accountAuthRepositoryProvider);
    final subscriptionAsync = ref.watch(subscriptionRepositoryProvider);
    final search = useSettingsSearch();

    Widget buildBody(Widget sliver) {
      return SettingsCustomScrollScaffold(
        title: 'WebLibre Account',
        searchController: search.controller,
        searchHintText: 'Search account settings',
        slivers: [sliver],
      );
    }

    return authAsync.when(
      loading: () => buildBody(
        const SliverFillRemaining(
          hasScrollBody: false,
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (_, _) => buildBody(
        const SliverFillRemaining(
          hasScrollBody: false,
          child: Center(child: Text('Failed to load account')),
        ),
      ),
      data: (authState) {
        final sections = _buildSections(
          ref: ref,
          authState: authState,
          subscriptionAsync: subscriptionAsync,
        );

        final filteredSections = filterSettingsSections(
          sections: sections,
          query: search.rawQuery,
        );

        return buildBody(
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 20),
            sliver: SliverToBoxAdapter(
              child: SettingsSectionList(
                sections: filteredSections,
                query: search.rawQuery,
              ),
            ),
          ),
        );
      },
    );
  }

  List<SettingsSectionDefinition> _buildSections({
    required WidgetRef ref,
    required AccountAuthState authState,
    required AsyncValue<SubscriptionStatus> subscriptionAsync,
  }) {
    final showSyncSnapshots =
        authState.isSignedIn && subscriptionAsync.value?.isActive == true;
    final syncClient = showSyncSnapshots
        ? ref.read(accountSyncRepositoryProvider)
        : null;
    final syncRepo = syncClient != null
        ? ref.read(accountSyncRepositoryProvider.notifier)
        : null;
    final sourceDeviceId = ref.read(androidDeviceInfoProvider).value?.deviceName;
    final sourceAppVersion = _appVersion(ref);

    return <SettingsSectionDefinition>[
      SettingsSectionDefinition(
        title: 'Account',
        entries: [
          SettingsEntryDefinition(
            title: switch (authState.status) {
              AccountAuthStatus.signedOut => 'Sign in to WebLibre Account',
              AccountAuthStatus.signingIn => 'Signing in',
              AccountAuthStatus.signedIn => 'Signed in account',
              AccountAuthStatus.error => 'Sign-in failed',
            },
            subtitle: switch (authState.status) {
              AccountAuthStatus.signedOut => 'Sync your settings across devices',
              AccountAuthStatus.signingIn => 'Complete sign-in in your browser',
              AccountAuthStatus.signedIn =>
                authState.displayName ?? authState.email ?? 'Signed in',
              AccountAuthStatus.error => authState.lastError,
            },
            keywords: [
              'sign in',
              'account',
              'authentication',
              if (authState.hasSyncKey) ...['sync key', 'reset sync key'],
            ],
            child: AccountAuthStatusCard(authState: authState),
          ),
        ],
      ),
      if (authState.isSignedIn)
        SettingsSectionDefinition(
          title: 'Subscription',
          entries: [
            SettingsEntryDefinition(
              title: 'Supporter subscription',
              subtitle: 'Status, billing, and subscription management',
              keywords: const ['billing', 'supporter'],
              child: SubscriptionCard(subscriptionAsync: subscriptionAsync),
            ),
          ],
        ),
      if (authState.isSignedIn)
        const SettingsSectionDefinition(
          title: 'Search Credits',
          entries: [
            SettingsEntryDefinition(
              title: 'Search credits',
              subtitle: 'Credits balance, token issuance, and purchases',
              keywords: ['tokens', 'search pack'],
              child: SearchCreditsSection(embedded: true),
            ),
          ],
        ),
      if (showSyncSnapshots && syncRepo != null)
        if (authState.hasSyncKey) ...[
          SettingsSectionDefinition(
            title: 'Settings Snapshots',
            entries: [
              SettingsEntryDefinition(
                title: 'Settings snapshots',
                subtitle: 'Store and restore synced application settings',
                keywords: const ['backups', 'settings sync'],
                child: SyncDocumentListSection(
                  service: ref.read(settingsSyncServiceProvider.notifier),
                  syncRepo: syncRepo,
                  syncKey: authState.syncKey!,
                  sourceDeviceId: sourceDeviceId,
                  sourceAppVersion: sourceAppVersion,
                  embedded: true,
                ),
              ),
            ],
          ),
          SettingsSectionDefinition(
            title: 'Preferences Snapshots',
            entries: [
              SettingsEntryDefinition(
                title: 'Preferences snapshots',
                subtitle: 'Store and restore synced preference documents',
                keywords: const ['backups', 'prefs sync'],
                child: SyncDocumentListSection(
                  service: ref.read(prefsSyncServiceProvider.notifier),
                  syncRepo: syncRepo,
                  syncKey: authState.syncKey!,
                  sourceDeviceId: sourceDeviceId,
                  sourceAppVersion: sourceAppVersion,
                  embedded: true,
                ),
              ),
            ],
          ),
        ] else
          SettingsSectionDefinition(
            title: 'Encrypted Sync',
            entries: [
              SettingsEntryDefinition(
                title: 'Set up encrypted sync',
                subtitle:
                    'Enable end-to-end encrypted sync using your account password',
                keywords: const ['sync key', 'backups', 'snapshots'],
                child: SyncSetupCard(email: authState.email),
              ),
            ],
          ),
    ];
  }
}

String? _appVersion(WidgetRef ref) {
  final info = ref.read(packageInfoProvider).value;
  if (info == null) return null;
  return '${info.version}+${info.buildNumber}';
}
