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
import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';
import 'package:weblibre/features/user/data/providers.dart';

part 'pending_quit_deletion.g.dart';

/// One requested deletion of one data type.
///
/// [requestId] tells requests of the same type apart: only the request that is
/// still recorded may be completed, so finishing an older one never clears a
/// newer one. [tabIds], set for [DeleteBrowsingDataType.tabs] only, names the
/// tabs to delete, so the request can never reach a tab opened later.
typedef PendingDeletion = ({String requestId, Set<String>? tabIds});

typedef PendingDeletions = Map<DeleteBrowsingDataType, PendingDeletion>;

/// What explicit Quits set out to delete and has not been deleted yet: a
/// request per type, recorded before a Quit starts deleting and completed as
/// soon as that type is deleted, by the Quit or by a later start.
///
/// A Quit whose deletion failed, or whose process died half way, leaves
/// requests behind, and the next start finishes the job
/// (`StartupBrowsingDataCleanup`). Without it, a Quit-only automatic deletion
/// would silently keep whatever an interrupted Quit did not get to, and data
/// picked in the confirmation for that Quit only would never be deleted at all.
///
/// Requests are never replaced by a snapshot of the record. Every read and
/// change is serialized, and each change touches only its own requests: a Quit
/// adds without dropping what is outstanding, and the startup cleanup, which
/// may still be running during a Quit, completes only the requests it read.
///
/// Stored in the settings table but not a setting: it is never shown or
/// edited.
@Riverpod(keepAlive: true)
class PendingQuitDeletionRepository extends _$PendingQuitDeletionRepository {
  static const _key = 'pendingQuitDeletion';
  static const _partitionKey = 'browsing_data';

  Future<void> _queue = Future.value();

  @override
  void build() {}

  /// The requests not completed yet; empty when none.
  Future<PendingDeletions> read() => _serialized(readStored);

  /// Records a new request for each of [types], replacing an older request of
  /// the same type, and returns them. Outstanding requests of other types stay.
  ///
  /// A tab request needs [tabIds]: without them, [DeleteBrowsingDataType.tabs]
  /// is left out. A new tab request also keeps the tabs of the one it replaces,
  /// which are still meant to go.
  Future<PendingDeletions> request(
    Set<DeleteBrowsingDataType> types, {
    Set<String>? tabIds,
  }) => _serialized(() async {
    final current = {...await readStored()};
    final requested = <DeleteBrowsingDataType, PendingDeletion>{};

    for (final type in types) {
      final isTabs = type == DeleteBrowsingDataType.tabs;
      if (isTabs && tabIds == null) continue;

      requested[type] = (
        requestId: const Uuid().v7(),
        tabIds: isTabs ? {...?current[type]?.tabIds, ...tabIds!} : null,
      );
    }

    if (requested.isNotEmpty) await writeStored({...current, ...requested});
    return requested;
  });

  /// Completes the request [requestId] for [type], if it is still the one
  /// recorded; a newer request of the type stays.
  Future<void> complete(DeleteBrowsingDataType type, String requestId) =>
      _serialized(() async {
        final current = await readStored();
        if (current[type]?.requestId != requestId) return;

        await writeStored({...current}..remove(type));
      });

  /// Runs [operation] after every earlier one finished, failed or not.
  Future<T> _serialized<T>(Future<T> Function() operation) {
    final result = _queue.then((_) => operation());
    _queue = result.then<void>((_) {}, onError: (Object _) {});
    return result;
  }

  /// The stored record. Overridden by tests; everything else goes through the
  /// serialized operations above.
  ///
  /// A tab request without tab ids, or a record that is not readable at all,
  /// is dropped: deleting tabs nobody named could reach a newer session's.
  @visibleForOverriding
  Future<PendingDeletions> readStored() async {
    final db = ref.read(userDatabaseProvider);
    final value = await db.settingDao.getSettingValue(_key);
    final json = value?.readAs<String>(DriftSqlType.string, db.typeMapping);
    if (json == null) return const {};

    final decoded = jsonDecode(json);
    if (decoded is! Map<String, dynamic>) return const {};

    final requests = <DeleteBrowsingDataType, PendingDeletion>{};
    for (final MapEntry(:key, :value) in decoded.entries) {
      final type = DeleteBrowsingDataType.values.firstWhereOrNull(
        (type) => type.name == key,
      );
      if (type == null || value is! Map<String, dynamic>) continue;
      if (value['requestId'] is! String) continue;

      final tabIds = switch (value['tabIds']) {
        final List<dynamic> ids => ids.whereType<String>().toSet(),
        _ => null,
      };
      if (type == DeleteBrowsingDataType.tabs && tabIds == null) continue;

      requests[type] = (
        requestId: value['requestId'] as String,
        tabIds: tabIds,
      );
    }
    return requests;
  }

  /// Stores [requests] as the record; empty clears it.
  @visibleForOverriding
  Future<void> writeStored(PendingDeletions requests) async {
    await ref
        .read(userDatabaseProvider)
        .settingDao
        .updateSetting(
          _key,
          _partitionKey,
          requests.isEmpty
              ? null
              : {
                  for (final MapEntry(key: type, value: request)
                      in requests.entries)
                    type.name: {
                      'requestId': request.requestId,
                      if (request.tabIds case final tabIds?)
                        'tabIds': tabIds.toList(),
                    },
                },
        );
  }
}
