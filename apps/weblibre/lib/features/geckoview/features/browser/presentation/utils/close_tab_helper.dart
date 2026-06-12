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
import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_state.dart';
import 'package:weblibre/features/geckoview/domain/repositories/tab.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/entities/tab_mode.dart';
import 'package:weblibre/utils/ui_helper.dart' as ui_helper;

/// Closes [tabId] with the shared UX contract: confirm before closing the
/// last tab of an isolation group, then offer undo via snackbar.
Future<void> closeTabWithConfirmationAndUndo(
  BuildContext context,
  WidgetRef ref,
  String tabId,
) async {
  // Confirm before closing the last tab in an isolation group
  final tabState = ref.read(tabStateProvider(tabId));
  if (tabState != null && tabState.tabMode is IsolatedTabMode) {
    final allStates = ref.read(tabStatesProvider);
    final groupCount = allStates.values
        .where((s) => s.isolationContextId == tabState.isolationContextId)
        .length;
    if (groupCount <= 1 && context.mounted) {
      final confirmed = await ui_helper.confirmIsolatedTabClose(context);
      if (!confirmed) return;
    }
  }

  await ref.read(tabRepositoryProvider.notifier).closeTab(tabId);

  if (context.mounted) {
    ui_helper.showTabUndoClose(
      context,
      ref.read(tabRepositoryProvider.notifier).undoClose,
    );
  }
}
