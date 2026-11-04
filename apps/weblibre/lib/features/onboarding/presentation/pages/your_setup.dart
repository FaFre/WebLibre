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
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/domain/feature_policy/feature_policy.dart';
import 'package:weblibre/features/onboarding/domain/entities/setup_goal.dart';
import 'package:weblibre/features/onboarding/domain/providers/setup_draft.dart';
import 'package:weblibre/features/onboarding/presentation/widgets/customize_setup.dart';
import 'package:weblibre/features/onboarding/presentation/widgets/setup_draft_scope.dart';
import 'package:weblibre/features/onboarding/presentation/widgets/setup_section.dart';
import 'package:weblibre/features/user/domain/repositories/engine_settings.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';
import 'package:weblibre/presentation/utils/visibility_switch_l10n.dart';
import 'package:weblibre/presentation/widgets/browser_page.dart';

/// "Your setup": what is on, the goals, what is hidden for now and the way
/// into Customize. The goals are its only switches: a hidden feature links to
/// its switch in Customize, which explains it.
///
/// Lives inside a `SetupDraftScope`, so what it reads is the draft as the
/// commit will write it.
class YourSetupPage extends ConsumerWidget {
  const YourSetupPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    final draft = ref.watch(setupDraftControllerProvider);
    final general = ref.watch(generalSettingsWithDefaultsProvider);
    final engine = ref.watch(engineSettingsWithDefaultsProvider);

    // A switch a goal stands for is already offered there, under the
    // goal's name, so it is not listed again. Connections and on-device AI
    // are: their goals ask for a setup or for AI itself, not to be shown.
    final coveredByGoal = {
      for (final goal in SetupGoal.values)
        if (goal.onlyShowsSwitches) ...goal.switches,
    };
    final hidden = [
      for (final visibilitySwitch in VisibilitySwitch.values)
        if (!general.isVisibilitySwitchShown(visibilitySwitch) &&
            !coveredByGoal.contains(visibilitySwitch))
          visibilitySwitch,
    ];
    final localAiOn =
        general.enableLocalAiFeatures &&
        general.isFeatureShown(FeatureId.aiLocalAi);
    final historyDays = general.historyAutoCleanInterval.inDays;

    return BrowserPage(
      child: BrowserPageContent(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            Center(
              child: Text(
                l10n.onboarding_yourSetupTitle,
                style: theme.textTheme.headlineMedium,
              ),
            ),
            const SizedBox(height: 24),
            SetupSection(
              title: l10n.onboarding_yourSetupOnTitle,
              children: [
                ListTile(
                  leading: const Icon(MdiIcons.shieldCheckOutline),
                  title: Text(l10n.onboarding_yourSetupProtections),
                ),
                if (draft.appliesHardeningBaseline)
                  ListTile(
                    leading: const Icon(MdiIcons.shieldLock),
                    title: Text(l10n.onboarding_yourSetupHardening),
                  ),
                if (engine.lnaBlocking ?? false)
                  ListTile(
                    leading: const Icon(MdiIcons.lanPending),
                    title: Text(l10n.onboarding_yourSetupLocalNetwork),
                  ),
                if (draft.installsUBlock)
                  ListTile(
                    leading: const Icon(MdiIcons.advertisementsOff),
                    title: Text(l10n.onboarding_yourSetupContentBlocker),
                  ),
                if (historyDays > 0)
                  ListTile(
                    leading: const Icon(Icons.history),
                    title: Text(
                      l10n.onboarding_yourSetupHistoryRetention(historyDays),
                    ),
                  ),
              ],
            ),
            SetupSection(
              title: l10n.onboarding_goalsTitle,
              children: [
                // A goal and its notice are one entry of the card, with no
                // divider between them.
                for (final goal in SetupGoal.values)
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SwitchListTile.adaptive(
                        secondary: Icon(switch (goal) {
                          SetupGoal.keepAccountsApart =>
                            VisibilitySwitch.containers.icon,
                          SetupGoal.lockBrowser => Icons.lock_outline,
                          SetupGoal.setUpConnections =>
                            VisibilitySwitch.connections.icon,
                          SetupGoal.useOnDeviceAi => VisibilitySwitch.ai.icon,
                          SetupGoal.syncDevices => Icons.sync,
                        }),
                        title: Text(switch (goal) {
                          SetupGoal.keepAccountsApart =>
                            l10n.onboarding_goalKeepAccountsApart,
                          SetupGoal.lockBrowser =>
                            l10n.onboarding_goalLockBrowser,
                          SetupGoal.setUpConnections =>
                            l10n.onboarding_goalSetUpConnections,
                          SetupGoal.useOnDeviceAi =>
                            l10n.onboarding_aiUseOnDeviceTitle,
                          SetupGoal.syncDevices =>
                            l10n.onboarding_goalSyncDevices,
                        }),
                        subtitle: Text(switch (goal) {
                          SetupGoal.keepAccountsApart =>
                            l10n.onboarding_goalKeepAccountsApartSubtitle,
                          SetupGoal.lockBrowser =>
                            l10n.onboarding_goalLockBrowserSubtitle,
                          SetupGoal.setUpConnections =>
                            l10n.onboarding_goalSetUpConnectionsSubtitle,
                          SetupGoal.useOnDeviceAi =>
                            l10n.onboarding_aiOnDeviceSubtitle,
                          SetupGoal.syncDevices =>
                            l10n.onboarding_goalSyncDevicesSubtitle,
                        }),
                        value: draft.goalSelected(goal, general),
                        onChanged: (selected) => ref
                            .read(setupDraftControllerProvider.notifier)
                            .setGoal(goal, selected: selected),
                      ),
                      // On-device AI downloads a model and reads tab titles: what
                      // to know opens under its switch, below the finger, not as
                      // a row above it.
                      if (goal == SetupGoal.useOnDeviceAi && localAiOn)
                        const LocalAiNotice(),
                    ],
                  ),
              ],
            ),
            if (hidden.isNotEmpty)
              SetupSection(
                title: l10n.onboarding_yourSetupHiddenForNowTitle,
                children: [
                  // A link, not a switch: Customize explains what each one
                  // shows, and is the one place they change besides the
                  // goals above.
                  for (final visibilitySwitch in hidden)
                    ListTile(
                      leading: Icon(visibilitySwitch.icon),
                      title: Text(visibilitySwitch.label(context)),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => pushInSetupDraftScope<void>(
                        context,
                        CustomizeSetupScreen(focus: visibilitySwitch),
                      ),
                    ),
                ],
              ),
            // Customize covers more than what is hidden (privacy, ad
            // blocking, layout), so it is an action of the whole page.
            SizedBox(
              width: double.infinity,
              child: FilledButton.tonalIcon(
                icon: const Icon(Icons.tune),
                label: Text(l10n.onboarding_customizeAction),
                onPressed: () => pushInSetupDraftScope<void>(
                  context,
                  const CustomizeSetupScreen(),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                l10n.onboarding_customizeCaption,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

/// The onboarding's Customize step, pushed from [YourSetupPage] inside the
/// same draft scope. Back returns to the summary with every change kept in
/// the draft.
class CustomizeSetupScreen extends StatelessWidget {
  const CustomizeSetupScreen({super.key, this.focus});

  /// See [CustomizeSetupView.focus].
  final VisibilitySwitch? focus;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.onboarding_customizeAction)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            CustomizeSetupView(
              mode: CustomizeSetupMode.onboarding,
              focus: focus,
            ),
          ],
        ),
      ),
    );
  }
}
