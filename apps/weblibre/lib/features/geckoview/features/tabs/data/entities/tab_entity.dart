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
import 'package:fast_equatable/fast_equatable.dart';

sealed class TabEntity with FastEquatable {
  String get tabId;
  String get orderKey;
}

class DefaultTabEntity extends TabEntity {
  @override
  final String tabId;
  @override
  final String orderKey;
  final String? containerId;

  DefaultTabEntity({
    required this.tabId,
    required this.orderKey,
    required this.containerId,
  });

  @override
  List<Object?> get hashParameters => [tabId, orderKey, containerId];
}

class SearchResultTabEntity extends TabEntity {
  @override
  final String tabId;
  @override
  final String orderKey;
  final String? containerId;

  final String searchQuery;

  SearchResultTabEntity({
    required this.tabId,
    required this.orderKey,
    required this.searchQuery,
    required this.containerId,
  });

  @override
  List<Object?> get hashParameters => [
    tabId,
    orderKey,
    searchQuery,
    containerId,
  ];
}

/// Sealed type for items rendered in the grouped flat list/grid views.
///
/// Distinct from [TabEntity] which serves the original flat-only path. The
/// grouped variant carries enough information to render parent-with-children
/// blocks while keeping a single ordered top-level list.
sealed class TabListItemEntity with FastEquatable {
  String get tabId;
  String get orderKey;
  String? get containerId;
}

class TabListStandaloneItem extends TabListItemEntity {
  @override
  final String tabId;
  @override
  final String orderKey;
  @override
  final String? containerId;

  TabListStandaloneItem({
    required this.tabId,
    required this.orderKey,
    required this.containerId,
  });

  @override
  List<Object?> get hashParameters => [tabId, orderKey, containerId];
}

class TabListParentGroup extends TabListItemEntity {
  @override
  final String tabId;
  @override
  final String orderKey;
  @override
  final String? containerId;
  final int childCount;

  TabListParentGroup({
    required this.tabId,
    required this.orderKey,
    required this.containerId,
    required this.childCount,
  });

  @override
  List<Object?> get hashParameters => [
    tabId,
    orderKey,
    containerId,
    childCount,
  ];
}

class TabListChildItem extends TabListItemEntity {
  @override
  final String tabId;
  @override
  final String orderKey;
  @override
  final String? containerId;
  final String parentId;
  final String rootId;
  final int depth;
  final int childCount;

  TabListChildItem({
    required this.tabId,
    required this.orderKey,
    required this.containerId,
    required this.parentId,
    required this.rootId,
    required this.depth,
    this.childCount = 0,
  });

  @override
  List<Object?> get hashParameters => [
    tabId,
    orderKey,
    containerId,
    parentId,
    rootId,
    depth,
    childCount,
  ];
}

class TabTreeEntity extends TabEntity {
  @override
  final String tabId;
  @override
  final String orderKey;

  final String? containerId;

  final String rootId;

  final int totalTabs;

  TabTreeEntity({
    required this.tabId,
    required this.orderKey,
    required this.containerId,
    required this.rootId,
    required this.totalTabs,
  });

  @override
  List<Object?> get hashParameters => [
    tabId,
    orderKey,
    containerId,
    rootId,
    totalTabs,
  ];
}
