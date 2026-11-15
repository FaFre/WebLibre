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
import 'package:weblibre/features/app_update/data/providers.dart';
import 'package:weblibre/features/app_update/domain/entities/distribution_policy.dart';
import 'package:weblibre/features/app_update/domain/entities/installed_build_info.dart';
import 'package:weblibre/features/app_update/domain/entities/update_state.dart';
import 'package:weblibre/features/app_update/domain/providers.dart';
import 'package:weblibre/features/app_update/domain/services/update_coordinator.dart';
import 'package:weblibre/features/app_update/presentation/widgets/update_details.dart';
import 'package:weblibre/features/app_update/presentation/widgets/update_status_card.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';
import 'package:weblibre/presentation/widgets/failure_widget.dart';

/// Settings → General → Updates → App updates (8.1).
class AppUpdateSettingsScreen extends HookConsumerWidget {
  const AppUpdateSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final snapshot = ref.watch(appUpdateControllerProvider);
    final policy = ref.watch(distributionPolicyProvider.select((p) => p.value));
    final installed = ref.watch(
      installedBuildInfoProvider.select((b) => b.value),
    );
    final coordinatorError = ref.watch(
      appUpdateCoordinatorProvider.select((c) => c.error),
    );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.appUpdate_appUpdates)),
      body: switch ((snapshot, policy)) {
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
        _ when coordinatorError != null => FailureWidget(
          exception: coordinatorError,
          onRetry: () => ref.invalidate(appUpdateCoordinatorProvider),
        ),
        (_, null) || (null, DistributionPolicy(hasUpdater: true)) =>
          const Center(child: CircularProgressIndicator()),
        _ => const SizedBox.shrink(),
      },
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

    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        if (installed != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Text(
              l10n.appUpdate_installedVersion(installed!.versionName),
              style: theme.textTheme.titleLarge,
            ),
          ),
        if (preferences.recoveryRequired)
          _RecoveryCard(
            message: l10n.appUpdate_preferencesUnreadable,
            actions: [
              TextButton(
                onPressed: () => controller.setAutomaticChecks(enabled: false),
                child: Text(l10n.appUpdate_actionKeepOff),
              ),
              FilledButton(
                onPressed: () => controller.setAutomaticChecks(enabled: true),
                child: Text(l10n.appUpdate_actionTurnOnChecks),
              ),
            ],
          ),
        // Beside the status card, never instead of it: its actions still
        // work (Play's descriptions are not a condition for updating).
        if (snapshot.trustDamaged)
          _RecoveryCard(
            message: l10n.appUpdate_detailsDataDamaged,
            actions: [
              TextButton(
                onPressed: controller.resetTrustAndCheck,
                child: Text(l10n.appUpdate_actionResetTrust),
              ),
            ],
          ),
        UpdateStatusCard(
          state: state,
          policy: policy,
          lastSuccess: snapshot.lastSuccess,
        ),
        if (assessment != null) ...[
          ReleaseNotesView(assessment: assessment, onOpenUrl: onOpenUrl),
          ComponentChangesList(changes: assessment.componentChanges),
        ],
        const Divider(),
        SwitchListTile.adaptive(
          secondary: const Icon(Icons.update),
          title: Text(l10n.appUpdate_automaticChecksTitle),
          subtitle: Text(l10n.appUpdate_automaticChecksSubtitle),
          value: preferences.automaticChecks,
          onChanged: (value) => controller.setAutomaticChecks(enabled: value),
        ),
        if (state is! UpdateIdle && state is! UpdateUpToDate)
          ListTile(
            leading: const Icon(Icons.refresh),
            title: Text(l10n.appUpdate_actionCheckNow),
            subtitle: switch (snapshot.lastSuccess) {
              final time? => Text(lastCheckedText(context, ref, time)),
              null => null,
            },
            // No check starts while a session holds the install slot, also
            // beneath a failure: the coordinator would ignore the tap.
            enabled:
                state is! UpdateChecking &&
                !state.userInitiated &&
                state.underlying is! UpdateInstalling &&
                state.underlying is! UpdateAwaitingUserAction,
            onTap: controller.checkNow,
          ),
        if (otherInstaller != null)
          ListTile(
            key: const ValueKey('installed-by-other'),
            leading: const Icon(Icons.info_outline),
            title: Text(
              l10n.appUpdate_installedByOther(otherInstaller),
              style: theme.textTheme.bodySmall,
            ),
          ),
      ],
    );
  }
}

class _RecoveryCard extends StatelessWidget {
  const _RecoveryCard({required this.message, required this.actions});

  final String message;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: theme.colorScheme.errorContainer,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(message),
            const SizedBox(height: 12),
            Wrap(spacing: 8, children: actions),
          ],
        ),
      ),
    );
  }
}
