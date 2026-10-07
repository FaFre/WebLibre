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
import 'package:weblibre/core/design/display_features.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';
import 'package:weblibre/features/user/presentation/utils/delete_browsing_data_type_l10n.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';

/// Shows a confirmation dialog for quitting the browser.
///
/// For the settings prompts that need a restart to apply a change. An explicit
/// Quit asks with [showQuitConfirmationDialog] instead.
///
/// Returns true if the user confirms, false if cancelled, null if dismissed.
Future<bool?> showQuitBrowserDialog(BuildContext context) {
  return showDialog<bool?>(
    context: context,
    anchorPoint: preferredAnchorPoint(MediaQuery.of(context)),
    builder: (BuildContext context) {
      final l10n = AppLocalizations.of(context);

      return AlertDialog(
        icon: const Icon(Icons.warning),
        title: Text(l10n.user_quitBrowserTitle),
        content: Text(l10n.user_quitBrowserContent),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.pop(context, false);
            },
            child: Text(l10n.common_cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context, true);
            },
            child: Text(l10n.user_actionQuit),
          ),
        ],
      );
    },
  );
}

/// The answer to [showQuitConfirmationDialog]: whether to stop asking, and
/// everything this Quit deletes — the automatic deletion plus whatever was
/// picked here.
typedef QuitConfirmation = ({
  bool dontAskAgain,
  Set<DeleteBrowsingDataType> deletes,
});

/// Asks before an explicit Quit, with a "Don't ask again" option and a
/// collapsed section for deleting browsing data on this Quit only — or on
/// every Quit, when "Don't ask again" is ticked as well.
///
/// [alwaysDeleted] is the automatic deletion from the settings: shown ticked
/// and locked, since it happens either way. [deletesOnStart] is whether it
/// also runs on every start; data picked here joins it when "Don't ask again"
/// is ticked too.
///
/// Returns null unless the user confirms.
Future<QuitConfirmation?> showQuitConfirmationDialog(
  BuildContext context, {
  required Set<DeleteBrowsingDataType> alwaysDeleted,
  required bool deletesOnStart,
}) {
  return showDialog<QuitConfirmation>(
    context: context,
    anchorPoint: preferredAnchorPoint(MediaQuery.of(context)),
    builder: (context) => _QuitConfirmationDialog(
      alwaysDeleted: alwaysDeleted,
      deletesOnStart: deletesOnStart,
    ),
  );
}

class _QuitConfirmationDialog extends HookWidget {
  final Set<DeleteBrowsingDataType> alwaysDeleted;
  final bool deletesOnStart;

  const _QuitConfirmationDialog({
    required this.alwaysDeleted,
    required this.deletesOnStart,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final dontAskAgain = useState(false);
    final oneTime = useState(<DeleteBrowsingDataType>{});
    final deletes = {...alwaysDeleted, ...oneTime.value};
    // What was picked is then saved, not dropped: the hint says where it goes.
    final savesPicked = dontAskAgain.value && oneTime.value.isNotEmpty;

    return AlertDialog(
      icon: const Icon(Icons.warning),
      title: Text(l10n.user_quitBrowserTitle),
      scrollable: true,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.user_quitBrowserContent),
          const SizedBox(height: 8),
          ExpansionTile(
            tilePadding: EdgeInsets.zero,
            childrenPadding: EdgeInsets.zero,
            shape: const Border(),
            collapsedShape: const Border(),
            leading: const Icon(Icons.delete_outline),
            title: Text(l10n.user_quitBrowserDeleteDataTitle),
            subtitle: Text(
              l10n.user_quitBrowserDeleteDataSummary(deletes.length),
            ),
            children: [
              // In enum order, the order the settings list them in.
              for (final type in DeleteBrowsingDataType.values)
                CheckboxListTile.adaptive(
                  value: deletes.contains(type),
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  title: Text(type.label(context)),
                  subtitle: alwaysDeleted.contains(type)
                      ? Text(l10n.user_quitBrowserDeletedAutomatically)
                      : null,
                  onChanged: alwaysDeleted.contains(type)
                      ? null
                      : (value) => oneTime.value = value == true
                            ? {...oneTime.value, type}
                            : ({...oneTime.value}..remove(type)),
                ),
            ],
          ),
          CheckboxListTile.adaptive(
            value: dontAskAgain.value,
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            title: Text(l10n.user_quitBrowserDontAskAgain),
            subtitle: Text(switch (savesPicked) {
              false => l10n.user_quitBrowserDontAskAgainHint,
              true when deletesOnStart =>
                l10n.user_quitBrowserDontAskAgainSavesQuitAndStart,
              true => l10n.user_quitBrowserDontAskAgainSavesQuit,
            }),
            onChanged: (value) => dontAskAgain.value = value ?? false,
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text(l10n.common_cancel),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop<QuitConfirmation>(context, (
              dontAskAgain: dontAskAgain.value,
              deletes: deletes,
            ));
          },
          child: Text(l10n.user_actionQuit),
        ),
      ],
    );
  }
}
