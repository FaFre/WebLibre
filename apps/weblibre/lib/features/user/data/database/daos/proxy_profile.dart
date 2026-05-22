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
import 'package:drift/drift.dart';
import 'package:weblibre/features/user/data/database/daos/proxy_profile.drift.dart';
import 'package:weblibre/features/user/data/database/database.dart';
import 'package:weblibre/features/user/data/database/definitions.drift.dart';

@DriftAccessor()
class ProxyProfileDao extends DatabaseAccessor<UserDatabase>
    with $ProxyProfileDaoMixin {
  ProxyProfileDao(super.attachedDatabase);

  Selectable<ProxyProfile> watch() {
    return db.proxyProfile.select()
      ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]);
  }

  Future<List<ProxyProfile>> fetchAll() => watch().get();

  Future<ProxyProfile?> findById(String id) {
    return (db.proxyProfile.select()
          ..where((t) => t.id.equals(id))
          ..limit(1))
        .getSingleOrNull();
  }

  Future<void> upsert(ProxyProfile profile) {
    return db.proxyProfile.insertOne(
      profile,
      onConflict: DoUpdate(
        (_) => ProxyProfileCompanion(
          name: Value(profile.name),
          type: Value(profile.type),
          configJson: Value(profile.configJson),
          dnsOverrideJson: Value(profile.dnsOverrideJson),
          updatedAt: Value(profile.updatedAt),
        ),
        target: [db.proxyProfile.id],
      ),
    );
  }

  Future<void> deleteById(String id) {
    return (db.proxyProfile.delete()..where((t) => t.id.equals(id))).go();
  }
}
