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
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/features/onboarding/domain/entities/setup_goal.dart';
import 'package:weblibre/features/onboarding/domain/providers/setup_follow_ups.dart';
import 'package:weblibre/features/onboarding/domain/services/setup_steps.dart';
import 'package:weblibre/features/user/domain/presentation/screens/profile_edit.dart';
import 'package:weblibre/features/user/domain/providers.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';
import 'package:weblibre/utils/ui_helper.dart';

/// What the onboarding leaves for the browser to do once it shows: open the
/// setups the goal switches asked for, and report external steps that failed.
///
/// Called from the browser screen's build, which is the first screen after
/// the commit and the one every later start lands on.
void useSetupFollowUps(BuildContext context, WidgetRef ref) {
  void reportFailures(Set<SetupStep> failed) {
    if (failed.isEmpty || !context.mounted) return;

    final l10n = AppLocalizations.of(context);
    // One message per failure the user can tell apart; the snack bars queue.
    // A failed install also fails its filter lists, so it covers both.
    final messages = [
      if (failed.contains(SetupStep.hardeningBaseline))
        l10n.onboarding_setupStepFailedHardening,
      if (failed.contains(SetupStep.installUBlock))
        l10n.onboarding_setupStepFailedUBlock
      else if (failed.contains(SetupStep.optimizedUBlockFilters))
        l10n.onboarding_setupStepFailedFilters,
    ];
    for (final message in messages) {
      showErrorMessage(context, message, duration: const Duration(seconds: 8));
    }
    ref.read(setupStepRunnerProvider.notifier).acknowledgeFailures();
  }

  ref.listen(setupStepRunnerProvider, (previous, failed) {
    reportFailures(failed);
  });

  // useEffect runs during the first build, where providers must not be
  // modified: taking the pending goals clears them, and acknowledging a
  // failure clears it, so wait for the frame.
  useEffect(() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;

      // A step that failed before this screen first built (a resumed run on
      // a later start) changed the state before the listener above existed.
      reportFailures(ref.read(setupStepRunnerProvider));

      final goals = ref.read(pendingGoalSetupsProvider.notifier).take();
      if (goals.isEmpty) return;
      unawaited(_openGoalSetups(context, ref, goals));
    });
    return null;
  }, const []);
}

Future<void> _openGoalSetups(
  BuildContext context,
  WidgetRef ref,
  List<SetupGoal> goals,
) async {
  for (final goal in goals) {
    if (!context.mounted) return;
    switch (goal) {
      case SetupGoal.lockBrowser:
        final profile = await ref.read(selectedProfileProvider.future);
        if (!context.mounted) return;
        // Straight to the lock: the profile screen holds more than that.
        await Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) =>
                ProfileEditScreen(profile: profile, focusLock: true),
          ),
        );
      case SetupGoal.syncDevices:
        await SyncSettingsRoute().push<void>(context);
      case SetupGoal.setUpConnections:
        // The connection list: Tor and the VPNs and proxies, set up and
        // started there. Opening it starts nothing.
        await const SingboxProxyProfilesRoute().push<void>(context);
      case SetupGoal.keepAccountsApart || SetupGoal.useOnDeviceAi:
        // Settings only; nothing to open.
        break;
    }
  }
}
