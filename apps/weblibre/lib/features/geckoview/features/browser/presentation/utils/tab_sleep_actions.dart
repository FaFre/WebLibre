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
import 'package:weblibre/core/providers/provider_read.dart';
import 'package:weblibre/domain/entities/remembered_prompt.dart';
import 'package:weblibre/features/geckoview/domain/entities/protected_activity.dart';
import 'package:weblibre/features/geckoview/domain/entities/tab_wake.dart';
import 'package:weblibre/features/geckoview/domain/repositories/tab.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/dialogs/cut_off_activity_dialog.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/utils/tab_sleep_result_l10n.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';
import 'package:weblibre/presentation/widgets/remembered_prompt.dart';
import 'package:weblibre/utils/ui_helper.dart' as ui_helper;

/// The name of the sleep action for a tab: Put to sleep, or Wake tab for a
/// tab [held] asleep.
String sleepTabActionLabel(AppLocalizations l10n, {required bool held}) =>
    held ? l10n.browser_wakeTab : l10n.browser_sleepTab;

/// The icon of the sleep action named by [sleepTabActionLabel].
IconData sleepTabActionIcon({required bool held}) =>
    held ? MdiIcons.weatherSunny : MdiIcons.sleep;

/// Puts [tabIds] to sleep, the way the user asked for it (D13):
///
/// - the first time, says what sleeping keeps and loses ("Don't ask again");
/// - asks before stopping playing media, unloading a POST result or dropping
///   form input;
/// - says what kept a tab awake, naming the reason for a single tab.
///
/// Success shows in the tabs themselves (the sleep badge, the placeholder).
Future<void> sleepTabsWithConfirmation(
  BuildContext context,
  ProviderRead read,
  List<String> tabIds,
) async {
  if (tabIds.isEmpty) return;
  final l10n = AppLocalizations.of(context);

  final explained = await confirmUnlessRemembered(
    context,
    read,
    RememberedPrompt.sleepTabs,
    title: l10n.browser_sleepTabsConfirmTitle(tabIds.length),
    content: l10n.browser_sleepTabDescription,
    confirmLabel: l10n.browser_sleepTab,
    icon: const Icon(MdiIcons.sleep),
  );
  if (!explained || !context.mounted) return;

  final repository = read(tabRepositoryProvider.notifier);
  final results = {
    for (final result in await repository.sleepTabs(tabIds))
      result.tabId: result,
  };
  if (!context.mounted) return;

  final asking = results.values
      .where((result) => refusedOnlyToAsk(result.failure, result.blockers))
      .toList();
  if (asking.isNotEmpty) {
    final blockers = [
      for (final result in asking)
        for (final activity in result.blockers) (result.tabId, activity),
    ];
    final (:mediaTabs, :postResultTabs, :formDataTabs) = countCutOffTabs(
      blockers,
    );

    final confirmed = await askToCutOffActivity(
      context,
      icon: const Icon(MdiIcons.sleep),
      title: l10n.browser_sleepAskTitle,
      lines: [
        if (mediaTabs > 0) l10n.browser_sleepAskMedia(mediaTabs),
        if (postResultTabs > 0) l10n.browser_sleepAskPostResult(postResultTabs),
        if (formDataTabs > 0) l10n.browser_sleepAskFormData(formDataTabs),
      ],
      confirmLabel: l10n.browser_sleepTab,
    );
    if (!context.mounted) return;

    if (confirmed) {
      // Form input only of the tabs the user was told about: input found in
      // another one on the retry still keeps it awake.
      final consent = CutOffConsent()..agreeTo(blockers);
      final retried = await repository.sleepTabs(
        [for (final result in asking) result.tabId],
        stopMedia: consent.stopMedia,
        discardPostResult: consent.discardPostResult,
        discardFormDataTabIds: consent.formDataTabIds.toList(),
      );
      if (!context.mounted) return;
      for (final result in retried) {
        results[result.tabId] = result;
      }
    } else {
      // Kept awake by the user's own answer: nothing to report for them.
      for (final result in asking) {
        results.remove(result.tabId);
      }
    }
  }

  if (results.values.toList().describe(l10n) case (
    :final text,
    :final failed,
  )) {
    ui_helper.showOutcomeMessage(context, text, failed: failed);
  }
}

/// Wakes [tabId]: once its routing is ready, its page loads again (D34). A
/// frozen container's tab stays asleep until the container is resumed.
Future<void> wakeTabFromMenu(
  BuildContext context,
  ProviderRead read,
  String tabId,
) async {
  final outcome = await read(tabRepositoryProvider.notifier).wakeTab(tabId);
  if (!context.mounted) return;
  final l10n = AppLocalizations.of(context);
  switch (outcome) {
    case TabWakeOutcome.woken:
      break;
    case TabWakeOutcome.routingNotReady:
      ui_helper.showInfoMessage(context, l10n.browser_wakeTabRoutingNotReady);
    case TabWakeOutcome.containerFrozen:
      ui_helper.showInfoMessage(context, l10n.browser_containerFrozen);
  }
}
