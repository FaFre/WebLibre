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
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:weblibre/core/providers/provider_read.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/domain/entities/remembered_prompt.dart';
import 'package:weblibre/features/geckoview/domain/entities/protected_activity.dart';
import 'package:weblibre/features/geckoview/domain/repositories/tab.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/dialogs/cut_off_activity_dialog.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/dialogs/freeze_blockers_dialog.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/dialogs/resume_and_open_dialog.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/models/container_data.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/entities/container_freeze.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/repositories/container.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/services/container_freeze.dart';
import 'package:weblibre/features/geckoview/features/tabs/presentation/utils/container_data_l10n.dart';
import 'package:weblibre/features/geckoview/features/tabs/presentation/utils/container_freeze_l10n.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';
import 'package:weblibre/presentation/widgets/remembered_prompt.dart';
import 'package:weblibre/utils/ui_helper.dart' as ui_helper;

/// Freezes [container] the way the user asked for it (5.3, 7.2 of
/// `plans/TAB_LOCK_AND_FREEZE_IMPLEMENTATION_PLAN.md`):
///
/// - the first time, says what freezing keeps and stops ("Don't ask again");
/// - asks before stopping playing media, unloading a POST result or dropping
///   form input;
/// - lists what keeps it from freezing, each with Show tab or View downloads;
/// - says why it is unavailable or how far it got.
Future<void> freezeContainerWithConfirmation(
  BuildContext context,
  ProviderRead read,
  ContainerData container,
) async {
  final l10n = AppLocalizations.of(context);
  final explained = await confirmUnlessRemembered(
    context,
    read,
    RememberedPrompt.freezeContainer,
    title: l10n.browser_freezeContainerTitle(container.displayName(l10n)),
    content: l10n.browser_freezeContainerDescription,
    confirmLabel: l10n.browser_freezeContainer,
    icon: const Icon(MdiIcons.pause),
  );
  if (!explained || !context.mounted) return;

  final service = read(containerFreezeServiceProvider.notifier);
  var outcome = await service.freeze(container.id);
  if (!context.mounted) return;

  // A retry can meet activity the answer did not cover (media started, a
  // form check that gave no answer counting as form input): it is asked
  // about in turn, a few times at most, rather than reported as nothing.
  final consent = CutOffConsent();
  for (var asked = 0; asked < _maxCutOffQuestions; asked++) {
    final unanswered = switch (outcome) {
      FreezeAttempted(:final result)
          when refusedOnlyToAsk(result.failure, [
            for (final blocker in result.blockers) blocker.activity,
          ]) =>
        consent.uncovered([
          for (final blocker in result.blockers)
            (blocker.tabId, blocker.activity),
        ]),
      _ => const <(String?, ProtectedActivity)>[],
    };
    if (unanswered.isEmpty) break;

    final (:mediaTabs, :postResultTabs, :formDataTabs) = countCutOffTabs(
      unanswered,
    );
    final confirmed = await askToCutOffActivity(
      context,
      icon: const Icon(MdiIcons.pause),
      title: l10n.browser_freezeAskTitle,
      lines: [
        if (mediaTabs > 0) l10n.browser_freezeAskMedia(mediaTabs),
        if (postResultTabs > 0)
          l10n.browser_freezeAskPostResult(postResultTabs),
        if (formDataTabs > 0) l10n.browser_freezeAskFormData(formDataTabs),
      ],
      confirmLabel: l10n.browser_freezeContainer,
    );
    if (!context.mounted) return;
    if (!confirmed) {
      // Kept by the user's own answer: nothing to report, unless a freeze
      // already got as far as restricting the container before it was
      // refused (a teardown that met new activity). That stays until
      // Resume, so it is said.
      if (outcome case FreezeAttempted(
        :final result,
      ) when result.phase == ContextFreezePhase.failed) {
        ui_helper.showErrorMessage(context, l10n.browser_freezeFailedGeneric);
      }
      return;
    }
    // Form input only of the tabs the user was told about: input found in
    // another one on the retry still keeps the container from freezing.
    consent.agreeTo(unanswered);
    outcome = await service.freeze(
      container.id,
      stopMedia: consent.stopMedia,
      discardPostResult: consent.discardPostResult,
      discardFormDataTabIds: consent.formDataTabIds.toList(),
    );
    if (!context.mounted) return;
  }

  await _reportFreeze(context, read, container, outcome);
}

/// Resumes [container] from its menu or "Stop freezing and resume" (5.5),
/// and says how it went.
Future<void> resumeContainerWithFeedback(
  BuildContext context,
  ProviderRead read,
  ContainerData container,
) async {
  final outcome = await read(
    containerFreezeServiceProvider.notifier,
  ).resume(container.id);
  if (!context.mounted) return;

  if (outcome case ResumeAttempted(resumed: true)) {
    final l10n = AppLocalizations.of(context);
    ui_helper.showInfoMessage(
      context,
      l10n.browser_containerResumedDone(container.displayName(l10n)),
    );
  } else {
    showResumeOutcome(context, outcome);
  }
}

/// Says why a Resume did not finish: an error when it ran and failed, a
/// hint when it could not start yet. Nothing when it resumed.
void showResumeOutcome(BuildContext context, ContainerResumeOutcome outcome) {
  if (outcome.describe(AppLocalizations.of(context)) case (
    :final text,
    :final failed,
  )) {
    ui_helper.showOutcomeMessage(context, text, failed: failed);
  }
}

/// Answers a navigation into a frozen container's tab (5.2.1, D31): "Resume
/// {container} and open?" with Resume and open, which resumes it and wakes
/// the tab (routing first, D34), or Cancel, which says nothing was opened.
/// The navigation runs once the request is answered with a Resume.
Future<void> answerResumeAndOpen(
  BuildContext context,
  ProviderRead read,
  ResumeAndOpenRequest request,
) async {
  var resumed = false;
  try {
    final container = await read(
      containerRepositoryProvider.notifier,
    ).getContainerData(request.containerId);
    if (container == null || !context.mounted) return;

    final confirmed = await showResumeAndOpenDialog(
      context,
      containerName: container.displayName(AppLocalizations.of(context)),
    );
    if (!context.mounted) return;
    final l10n = AppLocalizations.of(context);
    if (!confirmed) {
      ui_helper.showInfoMessage(context, l10n.browser_resumeAndOpenCancelled);
      return;
    }

    final outcome = await read(
      containerFreezeServiceProvider.notifier,
    ).resumeRequested(request);
    resumed = outcome is ResumeAttempted && outcome.resumed;
    if (!resumed && context.mounted) showResumeOutcome(context, outcome);
  } finally {
    request.complete(resumed: resumed);
  }
}

Future<void> _reportFreeze(
  BuildContext context,
  ProviderRead read,
  ContainerData container,
  ContainerFreezeOutcome outcome,
) async {
  if (outcome case FreezeAttempted(
    frozen: false,
    :final result,
  ) when result.failure == LifecycleFailure.protectedActivity) {
    // Refused after it already restricted the container (a teardown that met
    // new activity): that stays until Resume, so it is said along with what
    // refused, never only as a Resume button.
    final stoppedPartWay = result.phase == ContextFreezePhase.failed;
    if (stoppedPartWay) {
      ui_helper.showErrorMessage(
        context,
        AppLocalizations.of(context).browser_freezeFailedGeneric,
      );
    }
    await _showBlockers(
      context,
      read,
      result.blockers,
      failureShown: stoppedPartWay,
    );
    return;
  }
  final l10n = AppLocalizations.of(context);
  final described = outcome.describe(
    l10n,
    containerName: container.displayName(l10n),
  );
  if (described case (:final text, :final failed)) {
    ui_helper.showOutcomeMessage(context, text, failed: failed);
  }
}

/// How many times one freeze asks before cutting activity off.
const _maxCutOffQuestions = 3;

/// Lists what kept the container from freezing (7.2), and goes where the
/// user picks. Only the refusing ones: those asked about come up once these
/// are gone. With none left (a freeze still refused after its questions),
/// says it did not finish, so the container's state never goes unexplained;
/// [failureShown] when the caller said so already.
Future<void> _showBlockers(
  BuildContext context,
  ProviderRead read,
  List<FreezeBlocker> blockers, {
  required bool failureShown,
}) async {
  final refusing = blockers.where((b) => !b.activity.asksBeforeCutOff).toList();
  if (refusing.isEmpty) {
    if (failureShown) return;
    ui_helper.showErrorMessage(
      context,
      AppLocalizations.of(context).browser_freezeFailedGeneric,
    );
    return;
  }

  final chosen = await showFreezeBlockersDialog(context, read, refusing);
  if (chosen == null || !context.mounted) return;

  switch (chosen) {
    case (FreezeBlockerAction.showTab, final String tabId):
      final selected = await read(
        tabRepositoryProvider.notifier,
      ).selectTab(tabId);
      if (selected && context.mounted) const BrowserRoute().go(context);
    case (FreezeBlockerAction.viewDownloads, _):
      await const HistoryDownloadsRoute().push(context);
    case (FreezeBlockerAction.showTab, null):
      break;
  }
}
