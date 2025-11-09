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
import 'dart:convert';
import 'dart:ui';

import 'package:drift/drift.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/database/daos/container.drift.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/database/database.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/database/definitions.drift.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/models/container_data.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/models/site_assignment.dart';

@DriftAccessor()
class ContainerDao extends DatabaseAccessor<TabDatabase>
    with $ContainerDaoMixin {
  ContainerDao(super.db);

  Future<void> addContainer(ContainerData container) {
    return db.container.insertOne(
      ContainerCompanion.insert(
        id: container.id,
        name: Value(container.name),
        color: container.color,
        metadata: Value(container.metadata),
      ),
    );
  }

  Future<void> replaceContainer(ContainerData container) {
    return db.container.replaceOne(
      ContainerCompanion(
        id: Value(container.id),
        name: Value(container.name),
        color: Value(container.color),
        metadata: Value(container.metadata),
      ),
    );
  }

  Future<void> deleteContainer(String id) {
    return db.container.deleteOne(ContainerCompanion(id: Value(id)));
  }

  SingleOrNullSelectable<ContainerData> getContainerData(String id) {
    return select(db.container)..where((t) => t.id.equals(id));
  }

  Selectable<Color> getDistinctColors() {
    final query = db.selectOnly(db.container, distinct: true)
      ..addColumns([db.container.color])
      ..where(db.container.color.isNotNull());

    return query.map(
      (row) => row.readWithConverter<Color?, int>(db.container.color)!,
    );
  }

  Selectable<String> getContainerTabIds(String? containerId) {
    final query = selectOnly(db.tab)
      ..addColumns([db.tab.id])
      ..where(
        (containerId != null)
            ? db.tab.containerId.equals(containerId)
            : db.tab.containerId.isNull(),
      )
      ..orderBy([OrderingTerm.asc(db.tab.orderKey)]);

    return query.map((row) => row.read(db.tab.id)!);
  }

  Selectable<TabData> getContainerTabsData(String? containerId) {
    final query = db.tab.select()
      ..where(
        (t) => (containerId != null)
            ? t.containerId.equals(containerId)
            : t.containerId.isNull(),
      )
      ..orderBy([(t) => OrderingTerm.asc(t.orderKey)]);

    return query;
  }

  SingleSelectable<String> generateLeadingOrderKey(
    String? containerId, {
    int bucket = 0,
  }) {
    return db.definitionsDrift.leadingOrderKey(
      bucket: bucket,
      containerId: containerId,
    );
  }

  SingleSelectable<String> generateTrailingOrderKey(
    String? containerId, {
    int bucket = 0,
  }) {
    return db.definitionsDrift.trailingOrderKey(
      bucket: bucket,
      containerId: containerId,
    );
  }

  SingleOrNullSelectable<String> generateOrderKeyAfterTabId(
    String? containerId,
    String tabId,
  ) {
    return db.definitionsDrift.orderKeyAfterTab(
      containerId: containerId,
      tabId: tabId,
    );
  }

  SingleSelectable<String> generateOrderKeyBeforeTabId(
    String? containerId,
    String tabId,
  ) {
    return db.definitionsDrift.orderKeyBeforeTab(
      containerId: containerId,
      tabId: tabId,
    );
  }

  SingleSelectable<bool> isSiteAssignedToContainer(Uri uri) {
    return db.definitionsDrift.isSiteAssignedToContainer(uri: uri.origin);
  }

  SingleSelectable<bool> areSitesAvailable(
    Iterable<Uri> origins,
    String ignoredContainerId,
  ) {
    return db.definitionsDrift.areSitesAvailable(
      ignoreContainerId: ignoredContainerId,
      uriList: jsonEncode(origins.map((value) => value.origin).toList()),
    );
  }

  SingleSelectable<String> siteAssignedContainerId(Uri uri) {
    return db.definitionsDrift.siteAssignedContainerId(uri: uri.origin);
  }

  Selectable<SiteAssignment> allAssignedSites() {
    return db.definitionsDrift.allAssignedSites();
  }
}
