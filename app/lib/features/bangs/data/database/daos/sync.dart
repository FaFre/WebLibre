/*
 * Copyright (c) 2024-2025 Fabian Freund.
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
import 'package:drift/drift.dart';
import 'package:weblibre/features/bangs/data/database/daos/sync.drift.dart';
import 'package:weblibre/features/bangs/data/database/database.dart';
import 'package:weblibre/features/bangs/data/database/definitions.drift.dart';
import 'package:weblibre/features/bangs/data/models/bang.dart';
import 'package:weblibre/features/bangs/data/models/bang_group.dart';

@DriftAccessor()
class SyncDao extends DatabaseAccessor<BangDatabase> with $SyncDaoMixin {
  SyncDao(super.db);

  SingleOrNullSelectable<DateTime?> getLastSyncOfGroup(BangGroup group) {
    final query = selectOnly(db.bangSync)
      ..addColumns([db.bangSync.lastSync])
      ..where(db.bangSync.group.equalsValue(group));

    return query.map((row) => row.read(db.bangSync.lastSync));
  }

  Future<void> upsertLastSyncOfGroup(BangGroup group, DateTime lastSync) {
    return db.bangSync.insertOne(
      BangSyncCompanion.insert(group: Value(group), lastSync: lastSync),
      onConflict: DoUpdate(
        (old) => BangSyncCompanion(lastSync: Value(lastSync)),
      ),
    );
  }

  Future<void> insertBangs(Iterable<Bang> bangs) {
    return db.bang.insertAll(bangs);
  }

  Future<void> replaceBangs(Iterable<Bang> bangs) {
    return batch((batch) {
      batch.replaceAll(db.bang, bangs);
    });
  }

  Future<int> deleteBangs(BangGroup group, Iterable<String> triggers) {
    final statement = delete(db.bang)
      ..where((t) => t.group.equalsValue(group) & t.trigger.isIn(triggers));
    return statement.go();
  }

  Future<void> syncBangs({
    required BangGroup group,
    required Iterable<Bang> remoteBangs,
    required DateTime syncTime,
  }) async {
    final remoteBangMap = Map.fromEntries(
      remoteBangs.map((e) => MapEntry(e.trigger, e)),
    );
    final localBangMap = await db.bangDao
        .getBangList(groups: [group])
        .get()
        .then(
          (bangs) => Map.fromEntries(bangs.map((e) => MapEntry(e.trigger, e))),
        );

    final remoteBangTriggers = remoteBangMap.keys.toSet();
    final localBangTriggers = localBangMap.keys.toSet();

    final removedBangs = localBangTriggers.difference(remoteBangTriggers);
    final addedBangs = remoteBangTriggers
        .difference(localBangTriggers)
        .map((e) => remoteBangMap[e]!);

    final changedBangs = remoteBangTriggers
        .intersection(localBangTriggers)
        .where((e) => remoteBangMap[e] != localBangMap[e])
        .map((e) => remoteBangMap[e]!);

    await db.transaction(() async {
      await deleteBangs(group, removedBangs);
      await insertBangs(addedBangs);
      await replaceBangs(changedBangs);
      await upsertLastSyncOfGroup(group, syncTime);
    });
  }
}
