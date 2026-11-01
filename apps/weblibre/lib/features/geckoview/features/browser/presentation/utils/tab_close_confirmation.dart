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
import 'package:weblibre/domain/entities/remembered_prompt.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_state.dart';
import 'package:weblibre/features/geckoview/domain/repositories/tab.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/utils/ui_helper.dart' as ui_helper;

int countIsolatedGroupsRemovedByClosingTabs(
  WidgetRef ref,
  Iterable<String> tabIds,
) {
  final idsToClose = tabIds.toSet();
  if (idsToClose.isEmpty) return 0;

  final allStates = ref.read(tabStatesProvider);
  final isolatedCloseCounts = <String, int>{};

  for (final tabId in idsToClose) {
    final contextId = allStates[tabId]?.isolationContextId;
    if (contextId != null) {
      isolatedCloseCounts.update(
        contextId,
        (count) => count + 1,
        ifAbsent: () => 1,
      );
    }
  }

  return isolatedCloseCounts.entries.where((entry) {
    final totalInGroup = allStates.values
        .where((state) => state.isolationContextId == entry.key)
        .length;
    return totalInGroup == entry.value;
  }).length;
}

/// Asks before closing [tabIds] when that deletes the data of isolation
/// groups, or otherwise asks [otherwise], the question the caller has of its
/// own. Returns whether to go ahead.
///
/// One question at most, never one after the other: the groups' question
/// warns of more than any other, so it is the one asked while it would be. Once
/// it is answered with "Don't ask again" ([RememberedPrompt.closeIsolatedTabs])
/// it is not asked, and [otherwise] is.
Future<bool> confirmBulkTabCloseIfNeeded(
  BuildContext context,
  WidgetRef ref,
  Iterable<String> tabIds, {
  Future<bool> Function()? otherwise,
}) async {
  final groupsToDelete = countIsolatedGroupsRemovedByClosingTabs(ref, tabIds);
  final asksAboutGroups =
      groupsToDelete > 0 &&
      ref
              .read(generalSettingsWithDefaultsProvider)
              .rememberedAnswer<PromptConfirmation>(
                RememberedPrompt.closeIsolatedTabs,
              ) ==
          null;

  if (!asksAboutGroups) return await otherwise?.call() ?? true;
  if (!context.mounted) return false;

  return await ui_helper.confirmIsolatedTabClose(
    context,
    groupCount: groupsToDelete,
  );
}

Future<bool> closeTabsWithConfirmation(
  BuildContext context,
  WidgetRef ref,
  Iterable<String> tabIds,
) async {
  final idsToClose = tabIds.toSet().toList();
  if (idsToClose.isEmpty) return false;

  final tabRepository = ref.read(tabRepositoryProvider.notifier);

  if (!await confirmBulkTabCloseIfNeeded(context, ref, idsToClose)) {
    return false;
  }
  if (!context.mounted) {
    return false;
  }

  await tabRepository.closeTabs(idsToClose);
  return true;
}
