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
import 'package:weblibre/features/account/presentation/utils/account_auth_error_l10n.dart';
import 'package:weblibre/features/account/presentation/widgets/account_auth_status_card.dart';
import 'package:weblibre/features/account/presentation/widgets/subscription_card.dart';
import 'package:weblibre/features/account/presentation/widgets/sync_document_list_section.dart';
import 'package:weblibre/features/account/presentation/widgets/sync_setup_card.dart';
import 'package:weblibre/features/search_credits/presentation/widgets/search_credits_section.dart';
import 'package:weblibre/features/settings/presentation/widgets/settings_detail.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';

class AccountSettingsScreen extends HookConsumerWidget {
  const AccountSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final authAsync = ref.watch(accountAuthRepositoryProvider);
    final subscriptionAsync = ref.watch(subscriptionRepositoryProvider);
    final search = useSettingsSearch();

    Widget buildBody(Widget sliver) {
      return SettingsCustomScrollScaffold(
        title: l10n.account_screenTitle,
        searchController: search.controller,
        searchHintText: l10n.account_searchHint,
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
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(child: Text(l10n.account_loadFailed)),
        ),
      ),
      data: (authState) {
        final sections = _buildSections(
          l10n: l10n,
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
    required AppLocalizations l10n,
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
    final sourceDeviceId = ref
        .read(androidDeviceInfoProvider)
        .value
        ?.deviceName;
    final sourceAppVersion = _appVersion(ref);

    return <SettingsSectionDefinition>[
      SettingsSectionDefinition(
        title: l10n.account_sectionAccount,
        entries: [
          SettingsEntryDefinition(
            title: switch (authState.status) {
              AccountAuthStatus.signedOut => l10n.account_signInTitle,
              AccountAuthStatus.signingIn => l10n.account_signingInTitle,
              AccountAuthStatus.signedIn => l10n.account_signedInTitle,
              AccountAuthStatus.error => l10n.account_signInFailedTitle,
            },
            subtitle: switch (authState.status) {
              AccountAuthStatus.signedOut =>
                l10n.account_syncAcrossDevicesSubtitle,
              AccountAuthStatus.signingIn => l10n.account_signingInSubtitle,
              AccountAuthStatus.signedIn =>
                authState.displayName ??
                    authState.email ??
                    l10n.account_signedInFallback,
              AccountAuthStatus.error => authState.lastError?.describe(l10n),
            },
            keywords: [
              ...settingsKeywords(l10n.account_signInKeywords),
              if (authState.hasSyncKey)
                ...settingsKeywords(l10n.account_signInSyncKeyKeywords),
            ],
            child: AccountAuthStatusCard(authState: authState),
          ),
        ],
      ),
      if (authState.isSignedIn)
        SettingsSectionDefinition(
          title: l10n.account_sectionSubscription,
          entries: [
            SettingsEntryDefinition(
              title: l10n.account_entrySupporterSubscriptionTitle,
              subtitle: l10n.account_entrySupporterSubscriptionSubtitle,
              keywords: settingsKeywords(
                l10n.account_entrySupporterSubscriptionKeywords,
              ),
              child: SubscriptionCard(subscriptionAsync: subscriptionAsync),
            ),
          ],
        ),
      if (authState.isSignedIn)
        SettingsSectionDefinition(
          title: l10n.account_sectionSearchCredits,
          entries: [
            SettingsEntryDefinition(
              title: l10n.account_entrySearchCreditsTitle,
              subtitle: l10n.account_entrySearchCreditsSubtitle,
              keywords: settingsKeywords(
                l10n.account_entrySearchCreditsKeywords,
              ),
              child: const SearchCreditsSection(embedded: true),
            ),
          ],
        ),
      if (showSyncSnapshots && syncRepo != null)
        if (authState.hasSyncKey) ...[
          SettingsSectionDefinition(
            title: l10n.account_sectionSettingsSnapshots,
            entries: [
              SettingsEntryDefinition(
                title: l10n.account_entrySettingsSnapshotsTitle,
                subtitle: l10n.account_entrySettingsSnapshotsSubtitle,
                keywords: settingsKeywords(
                  l10n.account_entrySettingsSnapshotsKeywords,
                ),
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
            title: l10n.account_sectionPreferencesSnapshots,
            entries: [
              SettingsEntryDefinition(
                title: l10n.account_entryPreferencesSnapshotsTitle,
                subtitle: l10n.account_entryPreferencesSnapshotsSubtitle,
                keywords: settingsKeywords(
                  l10n.account_entryPreferencesSnapshotsKeywords,
                ),
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
            title: l10n.account_sectionEncryptedSync,
            entries: [
              SettingsEntryDefinition(
                title: l10n.account_entrySetupEncryptedSyncTitle,
                subtitle: l10n.account_entrySetupEncryptedSyncSubtitle,
                keywords: settingsKeywords(
                  l10n.account_entrySetupEncryptedSyncKeywords,
                ),
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
