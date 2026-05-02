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
import 'package:weblibre/features/geckoview/features/tabs/data/entities/tab_entity.dart';

/// Render-time descriptor for one item in the local tabs list/grid.
///
/// Unifies the search/flat path and the grouped path so list and grid can
/// share reorder semantics.
sealed class TabViewItem {
  String get tabId;
  String? get sourceSearchQuery;
  TabListParentGroup? get parentGroup;
  TabListChildItem? get childItem;

  const TabViewItem._();

  const factory TabViewItem.search({
    required String tabId,
    required String? sourceSearchQuery,
  }) = SearchTabViewItem;

  const factory TabViewItem.standalone({required String tabId}) =
      StandaloneTabViewItem;

  const factory TabViewItem.parent({
    required String tabId,
    required TabListParentGroup parentGroup,
  }) = ParentTabViewItem;

  const factory TabViewItem.child({
    required String tabId,
    required TabListChildItem childItem,
  }) = ChildTabViewItem;
}

class SearchTabViewItem extends TabViewItem {
  @override
  final String tabId;
  @override
  final String? sourceSearchQuery;

  @override
  TabListParentGroup? get parentGroup => null;

  @override
  TabListChildItem? get childItem => null;

  const SearchTabViewItem({
    required this.tabId,
    required this.sourceSearchQuery,
  }) : super._();
}

class StandaloneTabViewItem extends TabViewItem {
  @override
  final String tabId;

  @override
  String? get sourceSearchQuery => null;

  @override
  TabListParentGroup? get parentGroup => null;

  @override
  TabListChildItem? get childItem => null;

  const StandaloneTabViewItem({required this.tabId}) : super._();
}

class ParentTabViewItem extends TabViewItem {
  @override
  final String tabId;
  @override
  final TabListParentGroup parentGroup;

  @override
  String? get sourceSearchQuery => null;

  @override
  TabListChildItem? get childItem => null;

  const ParentTabViewItem({required this.tabId, required this.parentGroup})
    : super._();
}

class ChildTabViewItem extends TabViewItem {
  @override
  final String tabId;
  @override
  final TabListChildItem childItem;

  @override
  String? get sourceSearchQuery => null;

  @override
  TabListParentGroup? get parentGroup => null;

  const ChildTabViewItem({required this.tabId, required this.childItem})
    : super._();
}
