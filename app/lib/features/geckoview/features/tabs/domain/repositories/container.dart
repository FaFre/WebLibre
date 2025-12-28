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
import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:nullability/nullability.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/models/container_data.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/providers.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/repositories/tab.dart';
import 'package:weblibre/features/geckoview/features/tabs/utils/color_palette.dart';

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

  Future<ContainerData?> getContainerData(String id) {
    return ref
        .read(tabDatabaseProvider)
        .containerDao
        .getContainerData(id)
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
    final allColors = colorTypes.flattened.toList();
    final usedColors = await getDistinctColors();

    Color randomColor;
    do {
      randomColor = randomColorShade(allColors);
    } while (usedColors.contains(randomColor));

    return randomColor;
  }

  Future<bool> isSiteAssignedToContainer(Uri uri) {
    return ref
        .read(tabDatabaseProvider)
        .containerDao
        .isSiteAssignedToContainer(uri)
        .getSingle();
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

  Future<String?> siteAssignedContainerId(Uri uri) {
    return ref
        .read(tabDatabaseProvider)
        .containerDao
        .siteAssignedContainerId(uri)
        .getSingle();
  }

  @override
  void build() {}
}
