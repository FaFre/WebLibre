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

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:weblibre/core/filesystem.dart';
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/features/onboarding/domain/providers.dart';
import 'package:weblibre/features/onboarding/domain/providers/setup_draft.dart';
import 'package:weblibre/features/onboarding/domain/providers/setup_follow_ups.dart';
import 'package:weblibre/features/onboarding/domain/services/setup_commit.dart';
import 'package:weblibre/features/onboarding/presentation/pages/abstract/i_form_page.dart';
import 'package:weblibre/features/onboarding/presentation/pages/ai_configuration.dart';
import 'package:weblibre/features/onboarding/presentation/pages/basics.dart';
import 'package:weblibre/features/onboarding/presentation/pages/permissions.dart';
import 'package:weblibre/features/onboarding/presentation/pages/preset.dart';
import 'package:weblibre/features/onboarding/presentation/pages/ublock_opt_in.dart';
import 'package:weblibre/features/onboarding/presentation/pages/welcome.dart';
import 'package:weblibre/features/onboarding/presentation/pages/your_setup.dart';
import 'package:weblibre/features/onboarding/presentation/widgets/setup_draft_scope.dart';
import 'package:weblibre/features/user/domain/presentation/screens/profile_backup_list.dart';
import 'package:weblibre/features/user/domain/presentation/screens/profile_restore.dart';
import 'package:weblibre/features/user/domain/repositories/onboarding.dart';
import 'package:weblibre/features/user/domain/repositories/profile.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';
import 'package:weblibre/presentation/widgets/button_spinner.dart';
import 'package:weblibre/utils/ui_helper.dart';

class OnboardingScreen extends HookConsumerWidget {
  final int currentRevision;
  final int targetRevision;

  const OnboardingScreen({
    super.key,
    required this.currentRevision,
    required this.targetRevision,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final disableAnimations = MediaQuery.disableAnimationsOf(context);

    final pageController = usePageController();
    final eulaAccepted = ref.watch(eulaAcceptedProvider);
    final committing = useState(false);

    // A first run: Welcome, Preset, Basics, Your setup, Permissions. Anything
    // else is a review after an update, which never shows the Preset step and
    // changes only what the user edits. Revision 1 predates the on-device AI
    // features and is asked about those alone, as it always was.
    final isFreshOnboarding = currentRevision < 0;

    // What Done commits. Watched here, from the first page to the commit, so
    // the draft survives the pages that do not show it and the routes
    // Customize pushes over this one.
    final draft = ref.watch(setupDraftControllerProvider);

    // Every first run starts from a fresh draft. Nothing is written before
    // Done, so a draft left over from an abandoned run must not leak in.
    useEffect(() {
      if (isFreshOnboarding) {
        unawaited(
          Future.microtask(
            () => ref.read(setupDraftControllerProvider.notifier).discard(),
          ),
        );
      }
      return null;
    }, [isFreshOnboarding]);

    final pages = useMemoized<List<Widget>>(() {
      if (currentRevision == 1) return const [AiConfigurationPage()];
      if (!isFreshOnboarding) {
        return [
          const WelcomePage(isReturningUser: true),
          UBlockOptInPage(formKey: GlobalKey<FormState>()),
          PermissionsPage(formKey: GlobalKey<FormState>()),
        ];
      }
      return [
        WelcomePage(onRestore: () => _restoreIntoThisUser(context, ref)),
        const PresetPage(),
        const SetupDraftScope(step: SetupDraftStep.basics, child: BasicsPage()),
        const SetupDraftScope(
          step: SetupDraftStep.customize,
          child: YourSetupPage(),
        ),
        PermissionsPage(formKey: GlobalKey<FormState>()),
      ];
    }, [currentRevision, targetRevision]);

    final lastPage = useRef(pageController.initialPage);
    final currentPage = useState(pageController.initialPage);

    Future<void> goTo(int page) async {
      if (disableAnimations) {
        pageController.jumpToPage(page);
      } else {
        await pageController.animateToPage(
          page,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
        );
      }
    }

    Future<void> finish() async {
      if (pages[currentPage.value] case final IFormPage formPage) {
        formPage.formKey.currentState?.save();
      }

      if (!isFreshOnboarding) {
        await ref
            .read(onboardingRepositoryProvider.notifier)
            .pushRevision(targetRevision);
        if (context.mounted) const BrowserRoute().go(context);
        return;
      }

      committing.value = true;
      try {
        // Read before the commit writes it: the draft over the settings it
        // is committed onto, which decides which setups are still selected.
        final applied = ref.read(draftGeneralSettingsProvider);
        await ref
            .read(setupCommitServiceProvider.notifier)
            .commit(draft, targetRevision: targetRevision);

        // The setups a goal asked for open once the browser shows, outside
        // an onboarding that could still be cancelled.
        ref
            .read(pendingGoalSetupsProvider.notifier)
            .schedule(draft.setupsToOpen(applied));
        ref.read(setupDraftControllerProvider.notifier).discard();
        if (context.mounted) const BrowserRoute().go(context);
      } catch (error, stackTrace) {
        logger.e(
          'Committing the onboarding failed',
          error: error,
          stackTrace: stackTrace,
        );
        if (context.mounted) {
          showErrorMessage(context, l10n.onboarding_commitFailed);
        }
      } finally {
        if (context.mounted) committing.value = false;
      }
    }

    return PopScope(
      canPop: currentPage.value == 0,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        await goTo(currentPage.value - 1);
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: PageView(
                  controller: pageController,
                  physics: currentPage.value == 0 && !eulaAccepted
                      ? const NeverScrollableScrollPhysics()
                      : null,
                  children: pages,
                  onPageChanged: (value) {
                    if (value > lastPage.value) {
                      if (pages[lastPage.value] case final IFormPage formPage) {
                        formPage.formKey.currentState?.save();
                      }
                    }

                    lastPage.value = value;
                    currentPage.value = value;
                  },
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: Visibility(
                      visible: currentPage.value > 0,
                      child: TextButton.icon(
                        onPressed: committing.value
                            ? null
                            : () => goTo(currentPage.value - 1),
                        icon: const Icon(Icons.chevron_left),
                        label: Text(l10n.onboarding_actionPrevious),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: SmoothPageIndicator(
                        controller: pageController,
                        count: pages.length,
                        effect: WormEffect(
                          activeDotColor: theme.colorScheme.primary,
                          dotHeight: 10.0,
                          dotWidth: 10.0,
                        ),
                      ),
                    ),
                  ),
                  if (currentPage.value < pages.length - 1)
                    Expanded(
                      child: TextButton.icon(
                        onPressed: currentPage.value == 0 && !eulaAccepted
                            ? null
                            : () => goTo(currentPage.value + 1),
                        iconAlignment: IconAlignment.end,
                        icon: const Icon(Icons.chevron_right),
                        label: Text(l10n.onboarding_actionNext),
                      ),
                    )
                  else
                    // The step that commits everything: the one filled
                    // button of the flow.
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: committing.value ? null : finish,
                        iconAlignment: IconAlignment.end,
                        icon: committing.value
                            ? const ButtonSpinner()
                            : const Icon(Icons.done),
                        label: Text(l10n.common_done),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Restores a backup *into the user this process is already serving*.
///
/// It used to restore into a new one. That looked reasonable and was the wrong
/// shape in three ways at once: the profile the user had just created was left
/// behind empty and could not be deleted from itself, the lock they had just
/// configured on it did not travel (a clone is `Profile.create` with no auth
/// settings), and the onboarding revision was pushed onto the abandoned profile
/// rather than the one they ended up in.
///
/// Replacing instead has none of those problems and needs no new machinery:
/// `queueRestoreOver` journals the work and restarts into it, and
/// `bindStagingToTarget` re-addresses the archive onto this profile's id while
/// keeping its lock. The name is the one thing taken from the archive — at
/// first run the target is a placeholder (`Default`, or one made a minute ago),
/// so the backup's own name is the one the user meant.
///
/// The onboarding revision is deliberately *not* pushed here. The restored
/// `user.db` brings its own, and if the restore never runs — a wrong password,
/// a cancelled task — first run has to still be first run.
Future<void> _restoreIntoThisUser(BuildContext context, WidgetRef ref) async {
  final profiles = await ref.read(profileRepositoryProvider.future);
  final current = profiles.firstWhereOrNull(
    (profile) => profile.uuidValue == filesystem.selectedProfile,
  );

  if (!context.mounted) return;

  if (current == null) {
    // The process is serving a profile the repository cannot see, which means
    // its metadata is unreadable. Restoring over it would work, but naming the
    // target is the one thing the confirmation has to be able to do.
    showErrorMessage(
      context,
      AppLocalizations.of(context).onboarding_restoreTargetUnreadable,
    );
    return;
  }

  await Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => ProfileBackupListScreen(
        onBackupSelected: (context, uri) {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => ProfileRestoreScreen(
                backupFileUri: uri,
                forcedOverwriteTarget: current,
                adoptArchiveName: true,
              ),
            ),
          );
        },
      ),
    ),
  );
}
