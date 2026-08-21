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
import 'package:weblibre/core/copy/profile_copy.dart';

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
}) {
  return showDialog<bool?>(
    context: context,
    builder: (BuildContext context) {
      final theme = Theme.of(context);

      return AlertDialog(
        icon: Icon(Icons.delete_forever, color: theme.colorScheme.error),
        title: Text('Delete "$profileName"?'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Its $profileDataDescription are removed. $cannotBeUndone'),
            SizedBox(height: 16),
            _RestartNote(
              '$restartsToWork The profile is closed before it is deleted.',
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
            const _RestartNote(
              '$restartsThenAsksPassword Nothing is replaced before that.',
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

/// The shared "this takes a restart" footnote used by both dialogs here.
class _RestartNote extends StatelessWidget {
  const _RestartNote(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
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
    );
  }
}
