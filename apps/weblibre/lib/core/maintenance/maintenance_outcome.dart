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
import 'package:secure_archive/secure_archive.dart';
import 'package:weblibre/core/copy/profile_copy.dart';
import 'package:weblibre/core/maintenance/backup_operation.dart';
import 'package:weblibre/core/maintenance/saf_archive_target.dart' as saf;
import 'package:weblibre/core/startup/models/startup_config.dart';
import 'package:weblibre/utils/number_format.dart';

/// The operation stopped before it changed anything, and cleaned up after
/// itself.
///
/// The distinction this draws is the one that decides whether the browser opens
/// again. A destructive operation that dies half-way leaves durable evidence and
/// must hold the process in maintenance until it is reconciled — that is what
/// `recoveryRequired` is for. But a *wrong archive password* fails at the unpack,
/// before the profile has been touched at all, and treating the two the same way
/// turned a typo into a browser that could never be opened: the failed task kept
/// the maintenance reservation alive, and the only control left on the screen
/// asked for the password again.
///
/// So an abort means, specifically: no user data was modified, the workspace and
/// journal have been removed, and the task may simply be marked failed. There is
/// nothing for recovery to own.
class MaintenanceAborted implements Exception {
  const MaintenanceAborted(this.failure, {this.cause});

  /// What went wrong, in a form the caller can branch on.
  final MaintenanceFailure failure;

  /// The original error, kept for the log.
  final Object? cause;

  /// Shown to the user, so it says what went wrong rather than where.
  String get reason => failure.message;

  @override
  String toString() => 'MaintenanceAborted($reason)';
}

/// Why a maintenance operation could not be completed.
///
/// Sealed, and carrying each case's own payload, because the alternative was
/// what this file used to do: flatten everything to a sentence and then match
/// that sentence with `String.contains`. That lost information twice over —
/// `InsufficientStorage` already knew how many bytes it needed and the message
/// could not say, and a wrong password was indistinguishable from a corrupt file
/// once both were prose.
///
/// The maintenance screen runs before any profile exists, so whatever [message]
/// returns is the whole explanation the user gets.
sealed class MaintenanceFailure {
  const MaintenanceFailure();

  MaintenanceFailureKind get kind;

  String get message;

  bool get blamesPassword => kind.blamesPassword;
}

/// The archive refused the password, and said so itself.
final class WrongArchivePassword extends MaintenanceFailure {
  const WrongArchivePassword();

  @override
  MaintenanceFailureKind get kind => MaintenanceFailureKind.wrongPassword;

  @override
  String get message =>
      'The password did not open this backup file. Check it and try again. '
      '$nothingChanged';
}

/// The archive would not open and the cause cannot be pinned down.
///
/// Archive decryption is streamed, and ChaCha20-Poly1305 only verifies its MAC
/// once the stream ends — so on builds before that race was fixed upstream the
/// gzip decoder chokes on keystream garbage first and the real answer never
/// arrives. Both causes are named, password first, because that is the half the
/// user can act on.
final class UnreadableArchive extends MaintenanceFailure {
  const UnreadableArchive();

  @override
  MaintenanceFailureKind get kind => MaintenanceFailureKind.unreadableArchive;

  @override
  String get message =>
      'The password did not open this backup file, or the file is damaged. '
      'Check the password and try again. $nothingChanged';
}

/// The archive authenticated and its contents still could not be read.
///
/// Past the MAC check, so the password was right — the message must not send the
/// user back to the field.
final class DamagedArchive extends MaintenanceFailure {
  const DamagedArchive({this.detail});

  final String? detail;

  @override
  MaintenanceFailureKind get kind => MaintenanceFailureKind.damagedArchive;

  @override
  String get message =>
      'This backup file is damaged and could not be read. $nothingChanged';
}

/// The archive was written in a format this build does not know.
///
/// Never a password problem: the version byte is plaintext header.
final class UnsupportedArchiveVersion extends MaintenanceFailure {
  const UnsupportedArchiveVersion({this.version});

  final int? version;

  @override
  MaintenanceFailureKind get kind =>
      MaintenanceFailureKind.unsupportedArchiveVersion;

  @override
  String get message =>
      'This backup file was created by a newer version of WebLibre and cannot be '
      'read here. $nothingChanged';
}

/// There is not enough room to do the work.
///
/// Carries the numbers because it always knew them — `InsufficientStorage` has
/// held `requiredBytes` and `availableBytes` since it was written, and the
/// string-matching describer walked straight past it and printed the class name.
final class NotEnoughStorage extends MaintenanceFailure {
  const NotEnoughStorage({this.requiredBytes, this.availableBytes});

  final int? requiredBytes;
  final int? availableBytes;

  @override
  MaintenanceFailureKind get kind => MaintenanceFailureKind.notEnoughStorage;

  @override
  String get message {
    if (requiredBytes case final required?) {
      final free = availableBytes;
      return 'There is not enough free space: this needs about '
          '${formatBytes(required)}'
          '${free == null ? '' : ', and ${formatBytes(free)} is free'}. '
          '$nothingChanged';
    }
    return 'There is not enough free space to do this. $nothingChanged';
  }
}

/// The folder the backup was going to no longer accepts writes.
final class BackupFolderUnavailableFailure extends MaintenanceFailure {
  const BackupFolderUnavailableFailure();

  @override
  MaintenanceFailureKind get kind =>
      MaintenanceFailureKind.backupTargetUnavailable;

  @override
  String get message =>
      'The backup could not be written to the folder. Choose the folder again '
      'and retry. $nothingChanged';
}

/// The staged archive is not what it has to be to be installed.
///
/// Its [reason] is written where the check is, because only that code knows what
/// it was looking for.
final class ArchiveRejected extends MaintenanceFailure {
  const ArchiveRejected(this.reason);

  final String reason;

  @override
  MaintenanceFailureKind get kind => MaintenanceFailureKind.archiveRejected;

  @override
  String get message => reason;
}

/// A failure this build has no case for.
///
/// The raw text is kept and shown deliberately: the maintenance screen has no
/// logs behind it, so a failure the user can read out to a bug report is worth
/// more to them than a generic apology.
final class UnknownMaintenanceFailure extends MaintenanceFailure {
  const UnknownMaintenanceFailure(this.detail);

  final String detail;

  @override
  MaintenanceFailureKind get kind => MaintenanceFailureKind.unknown;

  @override
  String get message => detail;
}

/// The target directory named by a destructive task is not on disk.
///
/// Shared so that a delete, a replace and a backup all say it the same way: it
/// is one situation — a task naming a profile that is not there — and which
/// operation happened to notice it is not something the user has to care about.
const profileNoLongerExists = UnknownMaintenanceFailure(
  'That profile no longer exists.',
);

/// A restore was asked to start over a record of an earlier attempt.
///
/// Its own sentence rather than a generic failure because the recovery it points
/// at is the only thing that can clear it, and telling the user to "try again"
/// here would be telling them to do the one thing that destroys the copy of their
/// profile the interrupted attempt set aside.
const restoreEvidenceUnresolved = UnknownMaintenanceFailure(
  'An earlier attempt at this restore left a record that has not been '
  'resolved yet.',
);

/// Classifies a raw error into the one shape the rest of the app handles.
///
/// The only place a maintenance failure is inspected. Types are preferred wherever
/// one exists; the text matching below is a bridge for `secure_archive` builds
/// that still throw bare `Exception`s, and it deletes cleanly once the pinned ref
/// carries `SecureArchiveException` — at which point this becomes a `switch` over
/// that sealed type and nothing else in the app changes.
MaintenanceFailure classifyMaintenanceFailure(Object error) {
  if (error is MaintenanceAborted) return error.failure;
  if (error is InsufficientStorage) {
    return NotEnoughStorage(
      requiredBytes: error.requiredBytes,
      availableBytes: error.availableBytes,
    );
  }
  if (error is saf.BackupTargetUnavailable ||
      error is saf.BackupPublicationFailure) {
    return const BackupFolderUnavailableFailure();
  }
  if (error is SecureArchiveException) {
    return switch (error) {
      ArchiveWrongPassword() => const WrongArchivePassword(),
      ArchiveDamaged(:final detail) => DamagedArchive(detail: detail),
      ArchiveUnsupportedVersion(:final version) => UnsupportedArchiveVersion(
        version: version,
      ),
      ArchivePartMissing() => DamagedArchive(detail: error.toString()),
      ArchiveIntegrityCheckFailed(:final detail) => DamagedArchive(
        detail: detail,
      ),
    };
  }

  // `Exception('…')` stringifies with an `Exception: ` prefix, and the messages
  // this app throws are already written for a person to read. The prefix is the
  // only part of them that is not.
  final text = error.toString().replaceFirst(RegExp('^Exception: '), '');

  if (text.contains('Decryption failed') || text.contains('wrong password')) {
    return const WrongArchivePassword();
  }

  // See [UnreadableArchive]: on the pre-fix upstream this arrives as
  // `RemoteError: FormatException: Filter error, bad data`, which is not even an
  // `Exception` and cannot be told apart from genuine corruption.
  if (text.contains('Filter error')) {
    return const UnreadableArchive();
  }

  if (text.contains('Failed to extract part') ||
      text.contains('Corrupt output') ||
      text.contains('Could not validate backup integrity') ||
      text.contains('not found') && text.contains('Archive part')) {
    return DamagedArchive(detail: text);
  }

  if (text.contains('Unsupported version')) {
    return const UnsupportedArchiveVersion();
  }

  if (text.contains('No space left') || text.contains('ENOSPC')) {
    return const NotEnoughStorage();
  }

  return UnknownMaintenanceFailure(text);
}

/// Turns a maintenance failure into something worth showing a user.
String describeMaintenanceFailure(Object error) =>
    classifyMaintenanceFailure(error).message;
