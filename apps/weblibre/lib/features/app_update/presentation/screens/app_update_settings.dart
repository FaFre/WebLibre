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
import 'package:weblibre/domain/feature_policy/feature_policy.dart';
import 'package:weblibre/features/app_update/data/providers.dart';
import 'package:weblibre/features/app_update/domain/entities/distribution_policy.dart';
import 'package:weblibre/features/app_update/domain/entities/installed_build_info.dart';
import 'package:weblibre/features/app_update/domain/entities/update_state.dart';
import 'package:weblibre/features/app_update/domain/providers.dart';
import 'package:weblibre/features/app_update/domain/services/update_coordinator.dart';
import 'package:weblibre/features/app_update/presentation/widgets/update_details.dart';
import 'package:weblibre/features/app_update/presentation/widgets/update_status_entry.dart';
import 'package:weblibre/features/settings/presentation/widgets/settings_detail.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';
import 'package:weblibre/presentation/widgets/failure_widget.dart';

/// What the settings search indexes of this screen.
///
/// The screen builds its sections from the live update state, so only its
/// Settings section is indexed, as search-only entries with the titles the
/// screen draws: the search opens the screen and highlights the row.
List<SettingsSectionDefinition> appUpdateSettingsSearchSections(
  BuildContext context,
) {
  final l10n = AppLocalizations.of(context);
  final keywords = settingsKeywords(l10n.appUpdate_sectionKeywords);

  return [
    SettingsSectionDefinition(
      title: l10n.appUpdate_settingsSectionTitle,
      feature: FeatureId.appUpdates,
      keywords: keywords,
      entries: [
        SettingsEntryDefinition.searchOnly(
          title: l10n.appUpdate_automaticChecksTitle,
          subtitle: l10n.appUpdate_automaticChecksSubtitle,
          keywords: keywords,
        ),
        SettingsEntryDefinition.searchOnly(
          title: l10n.appUpdate_actionCheckNow,
          keywords: keywords,
        ),
      ],
    ),
  ];
}

/// Settings → General → Updates → App updates (8.1).
class AppUpdateSettingsScreen extends HookConsumerWidget {
  const AppUpdateSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshot = ref.watch(appUpdateControllerProvider);
    final policy = ref.watch(distributionPolicyProvider.select((p) => p.value));
    final installed = ref.watch(
      installedBuildInfoProvider.select((b) => b.value),
    );
    final coordinatorError = ref.watch(
      appUpdateCoordinatorProvider.select((c) => c.error),
    );

    return switch ((snapshot, policy)) {
      (final UpdateSnapshot snapshot, final DistributionPolicy policy)
          when policy.hasUpdater =>
        AppUpdateSettingsBody(
          snapshot: snapshot,
          policy: policy,
          installed: installed,
          onOpenUrl: (url) => openReleaseNotes(context, ref, url),
        ),
      // The updater couldn't be set up (its directories, say): the entry
      // points stay, so the screen says so instead of staying blank.
      _ when coordinatorError != null => _AppUpdateScaffold(
        sliver: SliverFillRemaining(
          hasScrollBody: false,
          child: FailureWidget(
            exception: coordinatorError,
            onRetry: () => ref.invalidate(appUpdateCoordinatorProvider),
          ),
        ),
      ),
      (_, null) ||
      (null, DistributionPolicy(hasUpdater: true)) => const _AppUpdateScaffold(
        sliver: SliverFillRemaining(
          hasScrollBody: false,
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
      _ => const _AppUpdateScaffold(sliver: SliverToBoxAdapter()),
    };
  }
}

/// The settings scaffold every state of the screen shares, so its title stays
/// while it loads or fails.
class _AppUpdateScaffold extends StatelessWidget {
  const _AppUpdateScaffold({required this.sliver});

  final Widget sliver;

  @override
  Widget build(BuildContext context) {
    return SettingsCustomScrollScaffold(
      title: AppLocalizations.of(context).appUpdate_appUpdates,
      slivers: [sliver],
    );
  }
}

/// The screen's content, separate so widget tests can drive it with any
/// snapshot.
class AppUpdateSettingsBody extends HookConsumerWidget {
  const AppUpdateSettingsBody({
    super.key,
    required this.snapshot,
    required this.policy,
    required this.installed,
    required this.onOpenUrl,
  });

  final UpdateSnapshot snapshot;
  final DistributionPolicy policy;
  final InstalledBuildInfo? installed;
  final void Function(Uri url) onOpenUrl;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final state = snapshot.state;
    final preferences = snapshot.preferences;
    final assessment = state.assessment;
    final controller = ref.read(appUpdateControllerProvider.notifier);
    final otherInstaller = policy is GithubUpdates
        ? installed?.otherInstallerLabel
        : null;
    final notes = assessment == null
        ? null
        : releaseNotesSection(
            context,
            assessment: assessment,
            onOpenUrl: onOpenUrl,
          );

    final sections = [
      SettingsSectionDefinition(
        title: l10n.appUpdate_statusSectionTitle,
        entries: [
          if (preferences.recoveryRequired)
            SettingsEntryDefinition(
              title: l10n.appUpdate_preferencesUnreadable,
              child: UpdateRecoveryEntry(
                icon: Icons.update_disabled,
                message: l10n.appUpdate_preferencesUnreadable,
                actions: [
                  TextButton(
                    onPressed: () =>
                        controller.setAutomaticChecks(enabled: false),
                    child: Text(l10n.appUpdate_actionKeepOff),
                  ),
                  FilledButton(
                    onPressed: () =>
                        controller.setAutomaticChecks(enabled: true),
                    child: Text(l10n.appUpdate_actionTurnOnChecks),
                  ),
                ],
              ),
            ),
          // Beside the status, never instead of it: its actions still work
          // (Play's descriptions are not a condition for updating).
          if (snapshot.trustDamaged)
            SettingsEntryDefinition(
              title: l10n.appUpdate_detailsDataDamaged,
              child: UpdateRecoveryEntry(
                icon: Icons.gpp_maybe_outlined,
                message: l10n.appUpdate_detailsDataDamaged,
                actions: [
                  TextButton(
                    onPressed: controller.resetTrustAndCheck,
                    child: Text(l10n.appUpdate_actionResetTrust),
                  ),
                ],
              ),
            ),
          SettingsEntryDefinition(
            title: l10n.appUpdate_statusSectionTitle,
            child: UpdateStatusEntry(
              state: state,
              policy: policy,
              installed: installed,
              lastSuccess: snapshot.lastSuccess,
            ),
          ),
        ],
      ),
      ?notes,
      if (assessment != null)
        componentChangesSection(context, changes: assessment.componentChanges),
      SettingsSectionDefinition(
        title: l10n.appUpdate_settingsSectionTitle,
        entries: [
          SettingsEntryDefinition(
            title: l10n.appUpdate_automaticChecksTitle,
            subtitle: l10n.appUpdate_automaticChecksSubtitle,
            child: SwitchListTile.adaptive(
              secondary: const Icon(Icons.update),
              title: Text(l10n.appUpdate_automaticChecksTitle),
              subtitle: Text(l10n.appUpdate_automaticChecksSubtitle),
              value: preferences.automaticChecks,
              onChanged: (value) =>
                  controller.setAutomaticChecks(enabled: value),
            ),
          ),
          if (state is! UpdateIdle && state is! UpdateUpToDate)
            SettingsEntryDefinition(
              title: l10n.appUpdate_actionCheckNow,
              child: ListTile(
                leading: const Icon(Icons.refresh),
                title: Text(l10n.appUpdate_actionCheckNow),
                subtitle: switch (snapshot.lastSuccess) {
                  final time? => Text(lastCheckedText(context, ref, time)),
                  null => null,
                },
                // No check starts while a session holds the install slot,
                // also beneath a failure: the coordinator would ignore the
                // tap.
                enabled:
                    state is! UpdateChecking &&
                    !state.userInitiated &&
                    state.underlying is! UpdateInstalling &&
                    state.underlying is! UpdateAwaitingUserAction,
                onTap: controller.checkNow,
              ),
            ),
          if (otherInstaller != null)
            SettingsEntryDefinition(
              title: l10n.appUpdate_installedByOther(otherInstaller),
              child: ListTile(
                key: const ValueKey('installed-by-other'),
                leading: const Icon(Icons.info_outline),
                title: Text(
                  l10n.appUpdate_installedByOther(otherInstaller),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
        ],
      ),
    ];

    return SettingsCustomScrollScaffold(
      title: l10n.appUpdate_appUpdates,
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
          sliver: SliverToBoxAdapter(
            child: SettingsSectionList(sections: sections, query: ''),
          ),
        ),
      ],
    );
  }
}
