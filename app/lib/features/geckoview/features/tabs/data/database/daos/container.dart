import 'dart:ui';

import 'package:drift/drift.dart';
import 'package:lensai/features/geckoview/features/tabs/data/database/database.dart';
import 'package:lensai/features/geckoview/features/tabs/data/models/container_data.dart';

part 'container.g.dart';

@DriftAccessor()
class ContainerDao extends DatabaseAccessor<TabDatabase>
    with _$ContainerDaoMixin {
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
    final query =
        db.selectOnly(db.container, distinct: true)
          ..addColumns([db.container.color])
          ..where(db.container.color.isNotNull());

    return query.map(
      (row) => row.readWithConverter<Color?, int>(db.container.color)!,
    );
  }

  Selectable<String> getContainerTabIds(String? containerId) {
    final query =
        selectOnly(db.tab)
          ..addColumns([db.tab.id])
          ..where(
            (containerId != null)
                ? db.tab.containerId.equals(containerId)
                : db.tab.containerId.isNull(),
          )
          ..orderBy([OrderingTerm.asc(db.tab.orderKey)]);

    return query.map((row) => row.read(db.tab.id)!);
  }

  SingleSelectable<String> generateLeadingOrderKey(
    String? containerId, {
    int bucket = 0,
  }) {
    return db.leadingOrderKey(bucket: bucket, containerId: containerId);
  }

  SingleSelectable<String> generateTrailingOrderKey(
    String? containerId, {
    int bucket = 0,
  }) {
    return db.trailingOrderKey(bucket: bucket, containerId: containerId);
  }

  SingleSelectable<String> generateOrderKeyAfterTabId(
    String? containerId,
    String tabId,
  ) {
    return db.orderKeyAfterTab(containerId: containerId, tabId: tabId);
  }
}
