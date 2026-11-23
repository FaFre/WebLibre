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
import 'dart:math';
import 'dart:ui';

import 'package:flutter_mozilla_components/flutter_mozilla_components.dart'
    show VisitInfo;
import 'package:nullability/nullability.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/core/uuid.dart';
import 'package:weblibre/features/geckoview/domain/entities/tab_lock.dart';
import 'package:weblibre/features/geckoview/domain/repositories/tab/container_deletion.dart';
import 'package:weblibre/features/geckoview/features/history/domain/repositories/container_history.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/models/container_data.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/models/site_assignment.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/providers.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/services/container_membership_gate.dart';
import 'package:weblibre/features/geckoview/features/tabs/utils/color_palette.dart';
import 'package:weblibre/features/proxy/data/proxy_connection.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';

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

    return await ref
        .read(tabDatabaseProvider)
        .containerDao
        .addContainer(container);
  }

  Future<List<ContainerDataWithCount>> getAllContainersWithCount() {
    return ref
        .read(tabDatabaseProvider)
        .definitionsDrift
        .containersWithCount()
        .get();
  }

  /// Replaces [container]'s row. Changing its storage identity (cookie
  /// isolation on or off) throws [ContainerFrozenException] while the
  /// container is frozen or being frozen or resumed (D19): its tabs would
  /// move to contexts the freeze does not cover.
  Future<void> replaceContainer(ContainerData container) async {
    if (container.metadata.assignedSites.isNotEmpty) {
      if (!await areSitesAvailable(
        container.metadata.assignedSites!,
        container.id,
      )) {
        throw Exception('Sites already assigned to another container');
      }
    }

    final dao = ref.read(tabDatabaseProvider).containerDao;
    final current = await dao.getContainerData(container.id).getSingleOrNull();
    final identityChanges =
        current != null &&
        current.metadata.contextualIdentity !=
            container.metadata.contextualIdentity;
    if (!identityChanges) return await dao.replaceContainer(container);

    return await ref
        .read(containerMembershipGateProvider.notifier)
        .whileChanging(
          [container.id],
          () => dao.replaceContainer(container),
          kind: ContainerChange.membership,
        );
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
    return await ref
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

  /// Closes the container's tabs and deletes it, unless one of its tabs is
  /// locked ([ContainerDeletion.delete]); with [deleteHistory],
  /// its visits in Mozilla Places too, and with [deleteSiteData] the site data
  /// of its own cookie storage (D29). The site data of a context native has a
  /// record of is always deleted, by native's release procedure: for its own
  /// storage (frozen, say) only with [deleteSiteData], otherwise nothing is
  /// deleted ([ContainerDeletionNeedsSiteData]) and the user is asked again.
  ///
  /// Nothing is destroyed before the container is gone: the visits are only
  /// read beforehand, while the relation rows that find them still exist (they
  /// cascade away with the container), and deleted afterwards together with
  /// the container's app-link override. Here rather than in the screen that
  /// asked, so the cleanup happens even when that screen is gone by then.
  Future<ContainerDeletionResult> deleteContainer(
    String id, {
    bool deleteHistory = false,
    bool deleteSiteData = false,
  }) async {
    final container = await getContainerData(id);
    final history = ref.read(containerHistoryRepositoryProvider.notifier);
    final visits = deleteHistory
        ? await history.placesVisitsForContainer(id)
        : const <VisitInfo>[];

    // The data of a context with a record goes with the container through
    // native's release procedure (D28, D29); the deletion asks again when
    // that would delete its own storage's data unasked, and clears that data
    // itself when asked and native does not (5.5).
    final result = await ref
        .read(containerDeletionProvider.notifier)
        .delete(id, deleteSiteData: deleteSiteData);
    if (result is! ContainerDeleted) return result;

    // So the override does not outlive the container.
    try {
      await removeAppLinkOverrides({container?.metadata.contextualIdentity});
    } catch (error, stackTrace) {
      logger.e(
        'Could not drop the app-link override of deleted container $id',
        error: error,
        stackTrace: stackTrace,
      );
    }

    try {
      await history.deletePlacesVisits(visits);
    } catch (error, stackTrace) {
      logger.e(
        'Could not delete the history of deleted container $id',
        error: error,
        stackTrace: stackTrace,
      );
      return ContainerDeleted(
        historyKept: true,
        siteDataCleanupPending: result.siteDataCleanupPending,
      );
    }
    return result;
  }

  /// Drops the per-container app-link overrides (§ container isolation)
  /// stored for [contextIds], so they do not linger after a container drops
  /// isolation or is deleted. Null ids are ignored; a no-op when none is
  /// stored.
  Future<void> removeAppLinkOverrides(Set<String?> contextIds) async {
    final ids = contextIds.nonNulls.toSet();
    if (ids.isEmpty) return;

    await ref.read(generalSettingsRepositoryProvider.notifier).updateSettings((
      current,
    ) {
      if (!ids.any(current.appLinkContextOverrides.containsKey)) {
        return current;
      }
      return current.copyWith.appLinkContextOverrides(
        {...current.appLinkContextOverrides}
          ..removeWhere((key, _) => ids.contains(key)),
      );
    });
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

    final targetIndex = newIndex.clamp(0, containers.length - 1);
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
      return await getLeadingContainerOrderKey(isPinned: isPinned);
    }

    if (targetIndex >= containers.length - 1) {
      return await getTrailingContainerOrderKey(isPinned: isPinned);
    }

    if (targetIndex < oldIndex) {
      return await getOrderKeyAfterContainer(
            containers[targetIndex - 1].id,
            isPinned: isPinned,
          ) ??
          await getLeadingContainerOrderKey(isPinned: isPinned);
    }

    return await getOrderKeyBeforeContainer(
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
    final usedColors = (await getDistinctColors()).toSet();
    final unused = containerSeedColors
        .where((color) => !usedColors.contains(color))
        .toList();
    final pool = unused.isNotEmpty ? unused : containerSeedColors;
    return pool[Random().nextInt(pool.length)];
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
