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
 */
import 'package:convert/convert.dart';

const backupArchiveExtension = '.weblibre';

/// The archive name's timestamp format.
///
/// Local time, not UTC: the name is read by a person looking for the backup they
/// took at four o'clock.
///
/// `isUtc: false` matters. `encode` reads the `DateTime`'s fields directly and
/// never converts, so names have always carried local digits — but the default
/// `decode` labels them UTC, and anything that then localises them shifts the
/// displayed time by the zone offset. Decoding local keeps the round trip honest
/// without changing how any existing file is named or matched.
final backupArchiveDateFormatter = FixedDateTimeFormatter(
  'YYYY-MM-DD_hhmmss',
  isUtc: false,
);

/// `backup_<profile>_YYYY-MM-DD_hhmmss.weblibre`.
///
/// The name is the only metadata the backup *list* has — the archive is
/// encrypted, so nothing inside it can be read without the password. Producer
/// and parser therefore live together here; when they drifted apart, every
/// backup in the list lost its profile name and date.
///
/// The profile part is non-greedy in [backupArchiveNamePattern] and the timestamp
/// is strictly anchored, so a profile name containing `_` still parses.
final backupArchiveNamePattern = RegExp(
  r'^backup_(?<profile>.+?)_(?<timestamp>\d{4}-\d{2}-\d{2}_\d{6})'
  r'\.weblibre$',
);

String backupArchiveName({required String profileName, required DateTime at}) =>
    'backup_${profileName}_${backupArchiveDateFormatter.encode(at)}'
    '$backupArchiveExtension';

/// What a backup's file name says about it, or null if it does not parse.
class BackupArchiveName {
  const BackupArchiveName({required this.profileName, required this.createdAt});

  final String profileName;
  final DateTime createdAt;

  static BackupArchiveName? tryParse(String fileName) {
    final match = backupArchiveNamePattern.firstMatch(fileName);
    if (match == null) return null;

    try {
      return BackupArchiveName(
        profileName: match.namedGroup('profile')!,
        createdAt: backupArchiveDateFormatter.decode(
          match.namedGroup('timestamp')!,
        ),
      );
    } catch (_) {
      // A name that matches the shape but holds an impossible date is not a
      // backup this build can describe; the file is still listed by its raw name.
      return null;
    }
  }
}
