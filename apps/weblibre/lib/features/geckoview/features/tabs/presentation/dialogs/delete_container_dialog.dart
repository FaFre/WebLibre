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
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:weblibre/core/design/display_features.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';

/// Result of the delete-container confirmation.
class DeleteContainerDecision {
  /// Whether the container's browsing history should also be deleted from
  /// Mozilla Places. When false, the visit→container relation dissolves and the
  /// visits are kept (shown as uncontained).
  final bool wipeHistory;

  /// Whether the site data of the container's own cookie storage should also
  /// be deleted (D29). Always true for a frozen container.
  final bool deleteSiteData;

  const DeleteContainerDecision({
    required this.wipeHistory,
    required this.deleteSiteData,
  });
}

/// Confirm container deletion. Returns the decision on confirm, or `null` if
/// cancelled/dismissed.
///
/// [hasOwnStorage] offers "Also delete site data": a container without its
/// own cookie storage has none of its own. For a [frozen] container it is
/// checked and cannot be unchecked, with the reason (D29).
Future<DeleteContainerDecision?> showDeleteContainerDialog(
  BuildContext context, {
  required bool hasOwnStorage,
  required bool frozen,
}) {
  return showDialog<DeleteContainerDecision?>(
    context: context,
    anchorPoint: preferredAnchorPoint(MediaQuery.of(context)),
    builder: (context) =>
        _DeleteContainerDialog(hasOwnStorage: hasOwnStorage, frozen: frozen),
  );
}

/// Shown instead of deleting a container that holds [count] locked tabs:
/// nothing is closed or deleted. Returns whether to show its tabs, where they
/// can be unlocked.
Future<bool> showContainerHasLockedTabsDialog(
  BuildContext context, {
  required int count,
}) async {
  final l10n = AppLocalizations.of(context);
  final showTabs = await showDialog<bool>(
    context: context,
    anchorPoint: preferredAnchorPoint(MediaQuery.of(context)),
    builder: (context) => AlertDialog(
      icon: const Icon(MdiIcons.lockOutline),
      title: Text(l10n.tabs_deleteContainerTitle),
      content: Text(l10n.tabs_deleteContainerLockedTabs(count)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(l10n.common_close),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(l10n.tabs_deleteContainerShowTabs),
        ),
      ],
    ),
  );
  return showTabs ?? false;
}

class _DeleteContainerDialog extends HookWidget {
  final bool hasOwnStorage;
  final bool frozen;

  const _DeleteContainerDialog({
    required this.hasOwnStorage,
    required this.frozen,
  });

  @override
  Widget build(BuildContext context) {
    final wipeHistory = useState(false);
    final deleteSiteData = useState(false);
    final l10n = AppLocalizations.of(context);

    return AlertDialog(
      icon: const Icon(Icons.warning),
      title: Text(l10n.tabs_deleteContainerTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.tabs_deleteContainerConfirm),
            const SizedBox(height: 8),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              value: wipeHistory.value,
              onChanged: (value) {
                wipeHistory.value = value ?? false;
              },
              title: Text(l10n.tabs_deleteContainerAlsoDeleteHistory),
              subtitle: Text(l10n.tabs_deleteContainerHistoryKeptNote),
            ),
            if (hasOwnStorage || frozen)
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                value: frozen || deleteSiteData.value,
                onChanged: frozen
                    ? null
                    : (value) {
                        deleteSiteData.value = value ?? false;
                      },
                title: Text(l10n.tabs_deleteContainerAlsoDeleteSiteData),
                subtitle: Text(
                  frozen
                      ? l10n.tabs_deleteContainerSiteDataFrozenNote
                      : l10n.tabs_deleteContainerSiteDataNote,
                ),
              ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.pop(context, null);
          },
          child: Text(l10n.common_cancel),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(
              context,
              DeleteContainerDecision(
                wipeHistory: wipeHistory.value,
                deleteSiteData: frozen || deleteSiteData.value,
              ),
            );
          },
          child: Text(l10n.common_delete),
        ),
      ],
    );
  }
}
