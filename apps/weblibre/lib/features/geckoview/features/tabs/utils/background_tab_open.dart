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
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/features/geckoview/domain/repositories/tab.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/utils/ui_helper.dart';

/// Follow-up for an action that just created a tab with `selectTab: false`.
///
/// Depending on [BackgroundTabOpenAction] this either shows the "New tab
/// opened" snackbar with its `Switch` action, or selects [tabId] straight away
/// — the equivalent of the user tapping `Switch` immediately.
///
/// Call this *before* popping the route the action was triggered from: the tab
/// repository is resolved eagerly here, so the snackbar action keeps working
/// after `ref` is disposed by the pop.
void handleBackgroundTabOpened(
  BuildContext context,
  WidgetRef ref,
  String tabId, {
  String? tabName,
}) {
  final repository = ref.read(tabRepositoryProvider.notifier);
  final action = ref
      .read(generalSettingsWithDefaultsProvider)
      .backgroundTabOpenAction;

  switch (action) {
    case BackgroundTabOpenAction.switchImmediately:
      // Drop any pending switch prompt first — mirrors what
      // `showTabSwitchMessage` does — so a snackbar left over from an earlier
      // background open can no longer switch back to that older tab.
      ScaffoldMessenger.of(context).clearSnackBars();
      unawaited(repository.selectTab(tabId));
    case BackgroundTabOpenAction.prompt:
      showTabSwitchMessage(
        context,
        tabName: tabName,
        onSwitch: () => repository.selectTab(tabId),
      );
  }
}
