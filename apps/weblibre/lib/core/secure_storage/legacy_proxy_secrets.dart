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
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart';
import 'package:weblibre/core/logger.dart';

/// What a profile's `user.db` says it owns, for records whose key cannot say.
///
/// `migrateUnqualifiedSecureRecords` claims legacy `singbox_proxy.secret.<id>`
/// records by looking up the proxy-profile row that uses them — but it only ever
/// runs for the profile this process *activated*. A profile backed up or deleted
/// before it has been opened once on this build has therefore never claimed its
/// own secrets, so enumerating by the `@p:<uuid>` suffix finds nothing and its
/// credentials are left out of the archive, or orphaned on the device forever.
///
/// The maintenance process is the one place that can close that gap: it is the
/// only context entitled to read a profile it has not bound, and for a delete it
/// is also the last moment the evidence exists at all.
class ProfileProxyOwnership {
  const ProfileProxyOwnership({
    required this.proxyProfileIds,
    required this.readable,
  });

  /// Empty and unreadable are different answers.
  ///
  /// "This profile configured no proxies" is a complete result; "the database
  /// could not be opened" is not, and a caller that deletes on the strength of
  /// the second would be acting on an absence it never established.
  static const unreadable = ProfileProxyOwnership(
    proxyProfileIds: <String>{},
    readable: false,
  );

  final Set<String> proxyProfileIds;
  final bool readable;
}

/// Reads the proxy-profile ids out of [profileDir]'s `user.db`.
///
/// Raw SQL rather than the drift database on purpose: the maintenance process is
/// deliberately provider-free, and opening the generated database would pull in
/// the whole profile-bound stack this context exists to stay out of. One
/// read-only query against one table needs none of it.
///
/// Read-only, so it cannot run a migration or leave a `-wal` behind in a tree
/// that is about to be archived or deleted.
Future<ProfileProxyOwnership> readProxyProfileIds(Directory profileDir) async {
  final file = File(p.join(profileDir.path, 'databases', 'user.db'));
  if (!file.existsSync()) {
    // A profile that never opened its database is a legitimate empty, not a
    // failure to look: there can be no proxy rows if there is no file.
    return const ProfileProxyOwnership(
      proxyProfileIds: <String>{},
      readable: true,
    );
  }

  Database? db;
  try {
    db = sqlite3.open(file.path, mode: OpenMode.readOnly, uri: false);
    final rows = db.select('SELECT id FROM proxy_profile');
    return ProfileProxyOwnership(
      proxyProfileIds: {
        for (final row in rows)
          if (row['id'] case final String id) id,
      },
      readable: true,
    );
  } catch (error, stackTrace) {
    // Includes the table simply not existing, which is what an older schema
    // looks like. Reported as unreadable rather than empty so the caller can
    // tell "nothing was there" from "we could not look".
    logger.w(
      'Could not read proxy ownership from ${file.path}',
      error: error,
      stackTrace: stackTrace,
    );
    return ProfileProxyOwnership.unreadable;
  } finally {
    db?.close();
  }
}
