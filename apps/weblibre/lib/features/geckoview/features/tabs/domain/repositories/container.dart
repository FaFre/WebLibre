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
import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:nullability/nullability.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/core/uuid.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/models/container_data.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/models/site_assignment.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/providers.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/repositories/tab.dart';
import 'package:weblibre/features/geckoview/features/tabs/utils/color_palette.dart';
import 'package:weblibre/features/proxy/data/proxy_connection.dart';

part 'container.g.dart';

@Riverpod(keepAlive: true)
class ContainerRepository extends _$ContainerRepository {
  Future<void> addContainer(ContainerData container) async {
    if (container.metadata.assignedSites.isNotEmpty) {
      if (!await areSitesAvailable(
        container.metadata.assignedSites!,
        container.id,
      )) {
        throw Exception('Sites already assigned to another container');
      }
    }

    if (container.orderKey.isEmpty) {
      throw ArgumentError.value(
        container.orderKey,
        'container.orderKey',
        'Containers require an explicit order key',
      );
    }

    return ref.read(tabDatabaseProvider).containerDao.addContainer(container);
  }

  Future<List<ContainerDataWithCount>> getAllContainersWithCount() {
    return ref
        .read(tabDatabaseProvider)
        .definitionsDrift
        .containersWithCount()
        .get();
  }

  Future<void> replaceContainer(ContainerData container) async {
    if (container.metadata.assignedSites.isNotEmpty) {
      if (!await areSitesAvailable(
        container.metadata.assignedSites!,
        container.id,
      )) {
        throw Exception('Sites already assigned to another container');
      }
    }

    return ref
        .read(tabDatabaseProvider)
        .containerDao
        .replaceContainer(container);
  }

  Future<void> clearProxyConnectionAssignments(
    ProxyConnectionId proxyConnectionId,
  ) async {
    final containers = await getAllContainersWithCount();
    final affectedContainers = containers.where(
      (container) => container.metadata.proxyConnectionId == proxyConnectionId,
    );

    for (final container in affectedContainers) {
      await replaceContainer(
        ContainerData(
          id: container.id,
          name: container.name,
          color: container.color,
          orderKey: container.orderKey,
          isPinned: container.isPinned,
          metadata: container.metadata.copyWith.proxyConnectionId(null),
        ),
      );
    }
  }

  Future<void> assignContainerOrderKey(String id, {required String orderKey}) {
    return ref
        .read(tabDatabaseProvider)
        .containerDao
        .assignOrderKey(id, orderKey: orderKey);
  }

  Future<void> setContainerPinned(String id, {required bool isPinned}) async {
    final orderKey = await getTrailingContainerOrderKey(isPinned: isPinned);
    return ref
        .read(tabDatabaseProvider)
        .containerDao
        .assignPinned(id, isPinned: isPinned, orderKey: orderKey);
  }

  Future<ContainerData?> getContainerData(String id) {
    return ref
        .read(tabDatabaseProvider)
        .containerDao
        .getContainerData(id)
        .getSingleOrNull();
  }

  Future<ContainerData?> getContainerByContextualIdentity(String contextId) {
    return ref
        .read(tabDatabaseProvider)
        .containerDao
        .getContainerByContextualIdentity(contextId)
        .getSingleOrNull();
  }

  Future<List<String>> getContainerTabIds(String? id) {
    return ref
        .read(tabDatabaseProvider)
        .containerDao
        .getContainerTabIds(id)
        .get();
  }

  Future<void> deleteContainer(String id) async {
    await ref.read(tabDataRepositoryProvider.notifier).closeContainerTabs(id);

    return ref.read(tabDatabaseProvider).containerDao.deleteContainer(id);
  }

  Future<Set<Color>> getDistinctColors() {
    return ref
        .read(tabDatabaseProvider)
        .containerDao
        .getDistinctColors()
        .get()
        .then((colors) => colors.toSet());
  }

  Future<String> getLeadingOrderKey(String? containerId) {
    return ref
        .read(tabDatabaseProvider)
        .containerDao
        .generateLeadingOrderKey(containerId)
        .getSingle();
  }

  Future<String> getTrailingOrderKey(String? containerId) {
    return ref
        .read(tabDatabaseProvider)
        .containerDao
        .generateTrailingOrderKey(containerId)
        .getSingle();
  }

  Future<String> getLeadingContainerOrderKey({required bool isPinned}) {
    return ref
        .read(tabDatabaseProvider)
        .containerDao
        .generateLeadingContainerOrderKey(isPinned: isPinned)
        .getSingle();
  }

  Future<String> getTrailingContainerOrderKey({required bool isPinned}) {
    return ref
        .read(tabDatabaseProvider)
        .containerDao
        .generateTrailingContainerOrderKey(isPinned: isPinned)
        .getSingle();
  }

  Future<String?> getOrderKeyAfterContainer(
    String containerId, {
    required bool isPinned,
  }) {
    return ref
        .read(tabDatabaseProvider)
        .containerDao
        .generateOrderKeyAfterContainerId(containerId, isPinned: isPinned)
        .getSingleOrNull();
  }

  Future<String> getOrderKeyBeforeContainer(
    String containerId, {
    required bool isPinned,
  }) {
    return ref
        .read(tabDatabaseProvider)
        .containerDao
        .generateOrderKeyBeforeContainerId(containerId, isPinned: isPinned)
        .getSingle();
  }

  Future<void> reorderContainer(
    List<ContainerData> containers,
    int oldIndex,
    int newIndex,
  ) async {
    if (containers.isEmpty || oldIndex == newIndex) return;

    var targetIndex = newIndex;
    if (targetIndex > oldIndex) {
      targetIndex -= 1;
    }
    targetIndex = targetIndex.clamp(0, containers.length - 1);
    if (targetIndex == oldIndex) return;

    final movingContainer = containers[oldIndex];
    final scopedContainers = containers
        .where((container) => container.isPinned == movingContainer.isPinned)
        .toList();
    final scopedOldIndex = scopedContainers.indexWhere(
      (container) => container.id == movingContainer.id,
    );
    if (scopedOldIndex < 0) return;

    final containersWithoutMoving = containers.toList()..removeAt(oldIndex);
    final scopedTargetIndex = containersWithoutMoving
        .take(targetIndex)
        .where((container) => container.isPinned == movingContainer.isPinned)
        .length
        .clamp(0, scopedContainers.length - 1);
    if (scopedTargetIndex == scopedOldIndex) return;

    // Generate a new order key and assign it in the same transaction so a
    // crash between the two cannot leave the moving container with a stale
    // key that no longer matches the surrounding rows.
    final db = ref.read(tabDatabaseProvider);
    await db.transaction(() async {
      final orderKey = await _orderKeyForReorder(
        scopedContainers,
        scopedOldIndex,
        scopedTargetIndex,
        movingContainer.isPinned,
      );
      await db.containerDao.assignOrderKey(
        movingContainer.id,
        orderKey: orderKey,
      );
    });
  }

  Future<String> _orderKeyForReorder(
    List<ContainerData> containers,
    int oldIndex,
    int targetIndex,
    bool isPinned,
  ) async {
    if (targetIndex <= 0) {
      return getLeadingContainerOrderKey(isPinned: isPinned);
    }

    if (targetIndex >= containers.length - 1) {
      return getTrailingContainerOrderKey(isPinned: isPinned);
    }

    if (targetIndex < oldIndex) {
      return await getOrderKeyAfterContainer(
            containers[targetIndex - 1].id,
            isPinned: isPinned,
          ) ??
          await getLeadingContainerOrderKey(isPinned: isPinned);
    }

    return getOrderKeyBeforeContainer(
      containers[targetIndex + 1].id,
      isPinned: isPinned,
    );
  }

  Future<String?> getOrderKeyAfterTab(String tabId, String? containerId) {
    return ref
        .read(tabDatabaseProvider)
        .containerDao
        .generateOrderKeyAfterTabId(containerId, tabId)
        .getSingleOrNull();
  }

  Future<String> getOrderKeyBeforeTab(String tabId, String? containerId) {
    return ref
        .read(tabDatabaseProvider)
        .containerDao
        .generateOrderKeyBeforeTabId(containerId, tabId)
        .getSingle();
  }

  Future<Color> unusedRandomContainerColor() async {
    final usedColors = await getDistinctColors();
    final unusedColorTypes = colorTypes.where((colors) {
      return !shadingTypes(
        colors,
      ).any((shade) => usedColors.contains(shade.keys.first));
    }).toList();
    final availableColors =
        (unusedColorTypes.isNotEmpty ? unusedColorTypes : colorTypes).flattened
            .toList();

    Color randomColor;
    do {
      randomColor = randomColorShade(availableColors);
    } while (usedColors.contains(randomColor));

    return randomColor;
  }

  Future<ContainerData> createNewContainer() async {
    final initialColor = await unusedRandomContainerColor();
    final orderKey = await getTrailingContainerOrderKey(isPinned: false);

    return ContainerData(
      id: uuid.v7(),
      color: initialColor,
      orderKey: orderKey,
    );
  }

  Future<bool> isSiteAssignedToContainer(Uri uri) async {
    return (await siteAssignedContainerId(uri)) != null;
  }

  Future<bool> areSitesAvailable(
    Iterable<Uri> origins,
    String ignoreContainerId,
  ) {
    return ref
        .read(tabDatabaseProvider)
        .containerDao
        .areSitesAvailable(origins, ignoreContainerId)
        .getSingle();
  }

  Future<String?> siteAssignedContainerId(Uri uri) async {
    final all = await ref
        .read(tabDatabaseProvider)
        .containerDao
        .allAssignedSites()
        .get();

    String? wildcardMatch;
    for (final a in all) {
      if (siteAssignmentMatches(a.assignedSite, uri)) {
        if (!isWildcardSite(a.assignedSite)) return a.id;
        wildcardMatch ??= a.id;
      }
    }
    return wildcardMatch;
  }

  Future<List<String>> getContainersToClearOnExit() async {
    final contextIds = await ref
        .read(tabDatabaseProvider)
        .containerDao
        .containersToClearOnExit()
        .get();
    return contextIds.whereType<String>().toList();
  }

  @override
  void build() {}
}
