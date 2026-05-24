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
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/tab_view/tab_view_item.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/database/definitions.drift.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';

class TabViewReorderResult {
  final List<String> movingTabIds;
  final String? previousTabId;
  final String? nextTabId;

  const TabViewReorderResult({
    required this.movingTabIds,
    required this.previousTabId,
    required this.nextTabId,
  });
}

TabViewReorderResult? buildTabViewReorderResult({
  required List<TabViewItem> visibleItems,
  required List<TabsWithRootAndDepthResult> treeRows,
  required Set<String> collapsedGroups,
  required Set<String> pinnedTabIds,
  required int oldIndex,
  required int newIndex,
  required TabDirection tabListDirection,
  required bool hierarchical,
  required bool sortPinnedFirst,
}) {
  if (oldIndex < 0 || oldIndex >= visibleItems.length) {
    logger.t(
      'reorder refused: oldIndex $oldIndex out of range '
      '(visibleItems.length=${visibleItems.length})',
    );
    return null;
  }

  final reordered = visibleItems.toList();
  final movingItem = reordered.removeAt(oldIndex);

  final insertIndex = newIndex.clamp(0, reordered.length);
  reordered.insert(insertIndex, movingItem);

  if (!hierarchical) {
    final ordered = reordered.map((item) => item.tabId).toList();
    return _resultFromOrderedIds(
      movingTabIds: [movingItem.tabId],
      orderedTabIds: _orderedIdsForStorageAnchors(
        ordered,
        tabListDirection: tabListDirection,
        pinnedTabIds: pinnedTabIds,
        parentById: const {},
        movingPartitionRootId: movingItem.tabId,
        sortPinnedFirst: sortPinnedFirst,
      ),
    );
  }

  final rowsById = {for (final row in treeRows) row.id: row};
  final parentById = {for (final row in treeRows) row.id: row.parentId};
  // Build the parent → ordered-children index once and reuse for every
  // _subtreeIds call below. _subtreeIds is invoked for the moving item plus
  // every collapsed group encountered while flattening, so reusing this map
  // turns N tree walks into N cheap lookups.
  final childrenByParent = _buildChildrenByParent(rowsById, parentById);
  final moveBlock = _subtreeIds(movingItem.tabId, rowsById, childrenByParent);
  final moveBlockIds = moveBlock.toSet();

  final withoutMovingItem = visibleItems.toList()..removeAt(oldIndex);
  final targetBeforeId = insertIndex < withoutMovingItem.length
      ? withoutMovingItem[insertIndex].tabId
      : null;
  if (targetBeforeId != null && moveBlockIds.contains(targetBeforeId)) {
    logger.t('reorder refused: drop target is inside the moving subtree');
    return null;
  }

  final remaining = [
    for (final item in visibleItems)
      if (!moveBlockIds.contains(item.tabId)) item,
  ];
  final requestedInsertIndex = targetBeforeId == null
      ? remaining.length
      : remaining.indexWhere((item) => item.tabId == targetBeforeId);
  if (requestedInsertIndex < 0) {
    logger.t(
      'reorder refused: target $targetBeforeId not present in remaining list '
      '(defensive)',
    );
    return null;
  }

  final parentScope = _parentScope(movingItem);
  final resolvedInsertIndex = _resolveInsertIndexInParentScope(
    remaining,
    requestedInsertIndex,
    parentScope,
    parentById,
  );
  if (resolvedInsertIndex == null) {
    logger.t(
      'reorder snapped: no anchor for parent scope $parentScope — drop '
      'rejected so the moving tab stays in its original parent',
    );
    return null;
  }

  final reorderedBlocks = remaining.toList()
    ..insert(resolvedInsertIndex, movingItem);

  final displayBlocks = <List<String>>[];
  final emitted = <String>{};
  for (final item in reorderedBlocks) {
    if (emitted.contains(item.tabId)) {
      continue;
    }

    final hasChildren =
        item.parentGroup != null || (item.childItem?.childCount ?? 0) > 0;
    final block = item.tabId == movingItem.tabId
        ? moveBlock
        : hasChildren && collapsedGroups.contains(item.tabId)
        ? _subtreeIds(item.tabId, rowsById, childrenByParent)
        : [item.tabId];

    final visibleBlock = [
      for (final tabId in block)
        if (!emitted.contains(tabId)) tabId,
    ];
    if (visibleBlock.isEmpty) {
      continue;
    }

    displayBlocks.add(visibleBlock);
    emitted.addAll(visibleBlock);
  }

  // Partition blocks (not raw ids) by their root group, preserving block
  // atomicity. The first block in each group always contains the root, since
  // visibleItems is rendered parent-before-children. Subsequent blocks are
  // siblings/descendants in display order.
  final blocksByRoot = <String, List<List<String>>>{};
  final rootOrder = <String>[];
  for (final block in displayBlocks) {
    final rootId = _rootIdFor(block.first, parentById);
    blocksByRoot
        .putIfAbsent(rootId, () {
          rootOrder.add(rootId);
          return [];
        })
        .add(block);
  }

  // For newest-first display, the rendered child order within a group is the
  // reverse of storage (orderKey-ascending) order. Convert back to storage
  // order before picking anchors so genBetween receives prev.orderKey <
  // next.orderKey. Block contents (e.g. the moving subtree from _subtreeIds)
  // are already storage-ordered internally, so we reverse blocks as units.
  if (tabListDirection == TabDirection.newestFirst) {
    for (final blocks in blocksByRoot.values) {
      if (blocks.length > 1) {
        final reversedTail = blocks.sublist(1).reversed.toList();
        blocks
          ..removeRange(1, blocks.length)
          ..addAll(reversedTail);
      }
    }
  }

  final orderedRootIds = tabListDirection == TabDirection.newestFirst
      ? rootOrder.reversed
      : rootOrder;

  final orderedTabIds = [
    for (final rootId in orderedRootIds)
      for (final block in blocksByRoot[rootId]!) ...block,
  ];

  return _resultFromOrderedIds(
    movingTabIds: moveBlock,
    orderedTabIds: _orderedIdsForStorageAnchors(
      orderedTabIds,
      tabListDirection: tabListDirection,
      pinnedTabIds: pinnedTabIds,
      parentById: parentById,
      movingPartitionRootId: _rootIdFor(movingItem.tabId, parentById),
      sortPinnedFirst: sortPinnedFirst,
    ),
  );
}

List<String> _orderedIdsForStorageAnchors(
  List<String> orderedTabIds, {
  required TabDirection tabListDirection,
  required Set<String> pinnedTabIds,
  required Map<String, String?> parentById,
  required String movingPartitionRootId,
  required bool sortPinnedFirst,
}) {
  final storageOrderedIds = tabListDirection == TabDirection.newestFirst
      // Rendering flips root group order for newest-first; convert the
      // display order back to storage order before choosing anchors.
      ? orderedTabIds.reversed.toList()
      : orderedTabIds;

  if (!sortPinnedFirst || pinnedTabIds.isEmpty) {
    return storageOrderedIds;
  }

  // Pinned-first is a render-only partition, so choose DB anchors only from
  // the moving tab's own partition to avoid snapping across the boundary.
  final movingPinned = pinnedTabIds.contains(movingPartitionRootId);
  return storageOrderedIds.where((tabId) {
    final rootId = _rootIdFor(tabId, parentById);
    return pinnedTabIds.contains(rootId) == movingPinned;
  }).toList();
}

TabViewReorderResult? _resultFromOrderedIds({
  required List<String> movingTabIds,
  required List<String> orderedTabIds,
}) {
  if (movingTabIds.isEmpty) {
    return null;
  }

  final movingSet = movingTabIds.toSet();
  final firstIndex = orderedTabIds.indexWhere(movingSet.contains);
  if (firstIndex < 0) {
    return null;
  }

  var lastIndex = firstIndex;
  while (lastIndex + 1 < orderedTabIds.length &&
      movingSet.contains(orderedTabIds[lastIndex + 1])) {
    lastIndex++;
  }

  return TabViewReorderResult(
    movingTabIds: movingTabIds,
    previousTabId: firstIndex > 0 ? orderedTabIds[firstIndex - 1] : null,
    nextTabId: lastIndex + 1 < orderedTabIds.length
        ? orderedTabIds[lastIndex + 1]
        : null,
  );
}

String? _parentScope(TabViewItem item) => item.childItem?.parentId;

int? _resolveInsertIndexInParentScope(
  List<TabViewItem> items,
  int requestedInsertIndex,
  String? parentScope,
  Map<String, String?> parentById,
) {
  final target = requestedInsertIndex < items.length
      ? items[requestedInsertIndex]
      : null;

  if (target != null && _isDirectScopeAnchor(target, parentScope, parentById)) {
    return target.tabId == parentScope
        ? requestedInsertIndex + 1
        : requestedInsertIndex;
  }

  final previousAnchorIndex = _nearestPreviousScopeAnchorIndex(
    items,
    requestedInsertIndex - 1,
    parentScope,
    parentById,
  );
  if (previousAnchorIndex != null) {
    return _indexAfterVisibleSubtree(items, previousAnchorIndex, parentById);
  }

  return _nearestNextScopeAnchorIndex(
    items,
    requestedInsertIndex,
    parentScope,
    parentById,
  );
}

bool _isDirectScopeAnchor(
  TabViewItem item,
  String? parentScope,
  Map<String, String?> parentById,
) {
  return item.tabId == parentScope || parentById[item.tabId] == parentScope;
}

int? _nearestPreviousScopeAnchorIndex(
  List<TabViewItem> items,
  int startIndex,
  String? parentScope,
  Map<String, String?> parentById,
) {
  for (var i = startIndex; i >= 0; i--) {
    if (_isDirectScopeAnchor(items[i], parentScope, parentById)) {
      return i;
    }
  }
  return null;
}

int? _nearestNextScopeAnchorIndex(
  List<TabViewItem> items,
  int startIndex,
  String? parentScope,
  Map<String, String?> parentById,
) {
  for (var i = startIndex; i < items.length; i++) {
    if (_isDirectScopeAnchor(items[i], parentScope, parentById)) {
      return items[i].tabId == parentScope ? i + 1 : i;
    }
  }
  return null;
}

int _indexAfterVisibleSubtree(
  List<TabViewItem> items,
  int anchorIndex,
  Map<String, String?> parentById,
) {
  final anchorId = items[anchorIndex].tabId;
  var index = anchorIndex + 1;
  while (index < items.length &&
      _isDescendantOf(items[index].tabId, anchorId, parentById)) {
    index++;
  }
  return index;
}

bool _isDescendantOf(
  String tabId,
  String ancestorId,
  Map<String, String?> parentById,
) {
  var parentId = parentById[tabId];
  final seen = <String>{tabId};
  while (parentId != null) {
    if (parentId == ancestorId) {
      return true;
    }
    if (!seen.add(parentId)) {
      return false;
    }
    parentId = parentById[parentId];
  }
  return false;
}

Map<String, List<TabsWithRootAndDepthResult>> _buildChildrenByParent(
  Map<String, TabsWithRootAndDepthResult> rowsById,
  Map<String, String?> parentById,
) {
  final childrenByParent = <String, List<TabsWithRootAndDepthResult>>{};
  for (final row in rowsById.values) {
    final parentId = parentById[row.id];
    if (parentId == null) continue;
    childrenByParent.putIfAbsent(parentId, () => []).add(row);
  }
  for (final children in childrenByParent.values) {
    children.sort((a, b) => a.orderKey.compareTo(b.orderKey));
  }
  return childrenByParent;
}

List<String> _subtreeIds(
  String rootId,
  Map<String, TabsWithRootAndDepthResult> rowsById,
  Map<String, List<TabsWithRootAndDepthResult>> childrenByParent,
) {
  final root = rowsById[rootId];
  if (root == null) {
    return [rootId];
  }

  final result = <String>[];
  final visited = <String>{};

  void collect(String tabId) {
    if (!visited.add(tabId)) return;

    result.add(tabId);
    for (final child
        in childrenByParent[tabId] ?? const <TabsWithRootAndDepthResult>[]) {
      collect(child.id);
    }
  }

  collect(root.id);
  return result;
}

String _rootIdFor(String tabId, Map<String, String?> parentById) {
  var rootId = tabId;
  var parentId = parentById[rootId];
  final seen = <String>{rootId};

  while (parentId != null && parentById.containsKey(parentId)) {
    if (!seen.add(parentId)) {
      break;
    }
    rootId = parentId;
    parentId = parentById[rootId];
  }

  return rootId;
}
