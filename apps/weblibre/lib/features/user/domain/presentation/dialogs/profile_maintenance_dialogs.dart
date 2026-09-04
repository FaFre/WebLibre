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
import 'package:weblibre/core/copy/profile_copy.dart';
import 'package:weblibre/features/user/domain/entities/restart_cost.dart';

/// Confirms deleting [profileName], including the restart it needs.
///
/// The restart is not a detail to leave out. Deletion is journaled and runs in a
/// process that has never opened the profile, so confirming here closes WebLibre
/// on the spot — and a browser that vanishes the instant you tap "Delete" reads
/// as a crash, not as the thing you asked for.
///
/// Returns true if the user confirms, false if cancelled, null if dismissed.
Future<bool?> showDeleteProfileDialog(
  BuildContext context, {
  required String profileName,

  /// What closing this process costs the profile in front of the user, which is
  /// never the one being deleted — deletion is not offered for the active one.
  required RestartCost restartCost,
}) {
  return showDialog<bool?>(
    context: context,
    builder: (BuildContext context) {
      final theme = Theme.of(context);

      return AlertDialog(
        icon: Icon(Icons.delete_forever, color: theme.colorScheme.error),
        title: Text('Delete "$profileName"?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Its $profileDataDescription are removed. $cannotBeUndone',
            ),
            const SizedBox(height: 16),
            _RestartNote(
              '$restartsToWork $restartClosesCurrentProfile The profile '
              'being deleted is closed first.',
              cost: restartCost,
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.pop(context, false);
            },
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
              foregroundColor: theme.colorScheme.onError,
            ),
            onPressed: () {
              Navigator.pop(context, true);
            },
            child: const Text('Delete and restart'),
          ),
        ],
      );
    },
  );
}

/// Confirms replacing everything in [profileName] with a backup.
///
/// A separate confirmation from the delete one because it is a separate loss:
/// the profile survives, but everything in it since the backup was taken does
/// not. It is also the only irreversible action here that used to run straight
/// off a button press with nothing in between.
Future<bool?> showReplaceProfileDialog(
  BuildContext context, {
  required String profileName,

  /// What closing this process costs the session in front of the user, which is
  /// a separate loss from the one this dialog is about even when the profile
  /// being replaced is the active one.
  required RestartCost restartCost,

  /// Set when the backup came from a different user, so the confirmation says
  /// whose data is arriving rather than leaving the user to infer it.
  String? sourceProfileName,

  /// Set when the user will be renamed to the archive's name, so the sentence
  /// about keeping its own name is not printed when it is not true.
  String? adoptedName,

  /// Set when the target is a user the caller created moments ago rather than
  /// one with a history behind it. It changes what the loss actually is, and a
  /// warning that overstates it is a warning people learn to tap past.
  bool replacesPlaceholder = false,
}) {
  return showDialog<bool?>(
    context: context,
    builder: (BuildContext context) {
      final theme = Theme.of(context);

      return AlertDialog(
        icon: Icon(
          Icons.settings_backup_restore,
          color: theme.colorScheme.error,
        ),
        title: Text('Replace "$profileName" with this backup?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              replacesPlaceholder
                  ? 'The backup replaces the profile you are setting up. '
                        'Anything already in it is lost. $cannotBeUndone'
                  : 'The backup replaces everything in "$profileName" — its '
                        '$profileDataDescription. Anything added after the '
                        'backup is lost. $cannotBeUndone',
            ),
            const SizedBox(height: 12),
            // Stated on the way in, because it is the half of the archive people
            // do not picture: replacing a user installs what makes it signed in.
            Text(
              "$signedInFromBackup It restores the backup file's "
              '$profileSecretDataDescription. $olderBackupKeepsCredentials',
              style: theme.textTheme.bodySmall,
            ),
            if (adoptedName != null) ...[
              const SizedBox(height: 12),
              Text(
                'The profile is renamed to "$adoptedName" and keeps its lock. '
                '$shortcutsNeedPinningAgain',
                style: theme.textTheme.bodySmall,
              ),
            ] else if (sourceProfileName != null) ...[
              const SizedBox(height: 12),
              Text(
                'The backup came from "$sourceProfileName". "$profileName" '
                'keeps its name and lock. '
                '$shortcutsNeedPinningAgain',
                style: theme.textTheme.bodySmall,
              ),
            ],
            const SizedBox(height: 16),
            _RestartNote(
              '$restartsThenAsksPassword Nothing is replaced before that. '
              '$restartClosesCurrentProfile',
              cost: restartCost,
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
              foregroundColor: theme.colorScheme.onError,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Replace and restart'),
          ),
        ],
      );
    },
  );
}

/// Confirms backing up [profileName], including what the restart costs.
///
/// Backup is the odd one out among these three: it destroys nothing it names,
/// so it used to run straight off a button press with the restart mentioned only
/// in a subtitle about passwords. But it leaves through the same `exitApp` as
/// delete and replace, and that ends the private session of whatever profile is
/// open — so the harmless-sounding action was the one taking a session down
/// without asking, and for a profile the user may not even have been backing up.
///
/// Returns true if the user confirms, false if cancelled, null if dismissed.
Future<bool?> showBackupProfileDialog(
  BuildContext context, {
  required String profileName,
  required RestartCost restartCost,
}) {
  return showDialog<bool?>(
    context: context,
    builder: (BuildContext context) {
      // Not error-coloured, unlike the two below it. Nothing in the named
      // profile is lost, and dressing a backup as a destructive action is how
      // the colour stops meaning anything on the screens where it does.
      return AlertDialog(
        icon: const Icon(MdiIcons.safe),
        title: Text('Back up "$profileName"?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'The backup is taken with the profile closed, so nothing in it '
              'changes.',
            ),
            const SizedBox(height: 16),
            _RestartNote(
              '$restartsToWork $restartClosesCurrentProfile',
              cost: restartCost,
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Back up and restart'),
          ),
        ],
      );
    },
  );
}

/// The shared "this takes a restart" footnote used by the dialogs here.
///
/// [cost] is what leaving actually discards. It is listed only when there is
/// something in it: most restarts cost nothing, and a warning that prints every
/// time is one people learn to tap past.
class _RestartNote extends StatelessWidget {
  const _RestartNote(this.text, {required this.cost});

  final String text;
  final RestartCost cost;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final losses = [
      if (cost.privateTabs > 0) privateTabsClosedByRestart(cost.privateTabs),
      if (cost.containersClearedOnExit > 0)
        containersClearedByRestart(cost.containersClearedOnExit),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.restart_alt,
              size: 18,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                text,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
        if (losses.isNotEmpty)
          // Indented under the footnote and coloured apart from it: these are
          // the only sentences here describing something that does not come
          // back, and on the backup dialog they are the only warning at all.
          Padding(
            padding: const EdgeInsets.only(left: 26, top: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final loss in losses)
                  Text(
                    loss,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                const SizedBox(height: 4),
                // The floor under the list. Without it, "your tabs close" is
                // what people read, and they stop taking backups.
                Text(
                  restartKeepsOtherTabs,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
