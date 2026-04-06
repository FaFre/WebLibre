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
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:fast_equatable/fast_equatable.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:json_annotation/json_annotation.dart';

part 'bookmark_item.g.dart';

sealed class BookmarkItem {
  abstract final String guid;
  abstract final String? parentGuid;
  abstract final String title;
  abstract final int dateAdded;
  abstract final int? position;

  const BookmarkItem();

  static BookmarkItem? parseRecursive(BookmarkNode node) {
    return switch (node.type) {
      BookmarkNodeType.item => BookmarkEntry(
        guid: node.guid,
        parentGuid: node.parentGuid,
        url: Uri.parse(node.url!),
        title: node.title ?? node.url!,
        previewImageUrl: Uri.parse(node.url!),
        position: node.position,
        dateAdded: node.dateAdded,
      ),
      BookmarkNodeType.folder => BookmarkFolder(
        guid: node.guid,
        parentGuid: node.parentGuid,
        title: node.title ?? "Unnamed Folder",
        position: node.position,
        dateAdded: node.dateAdded,
        children: node.children?.map(parseRecursive).nonNulls.toList(),
      ),
      BookmarkNodeType.separator => null,
    };
  }

  factory BookmarkItem.fromJson(Map<String, dynamic> json) {
    return (json.containsKey('url'))
        ? BookmarkEntry.fromJson(json)
        : BookmarkFolder.fromJson(json);
  }

  Map<String, dynamic> toJson();

  BookmarkItem clone();
}

@CopyWith()
@JsonSerializable()
class BookmarkEntry extends BookmarkItem with FastEquatable {
  @override
  final String guid;
  @override
  final String? parentGuid;
  final Uri url;
  @override
  final String title;
  final Uri previewImageUrl;
  @override
  final int? position;
  @override
  final int dateAdded;

  BookmarkEntry({
    required this.guid,
    required this.parentGuid,
    required this.url,
    required this.title,
    required this.previewImageUrl,
    required this.position,
    required this.dateAdded,
  });

  factory BookmarkEntry.fromJson(Map<String, dynamic> json) =>
      _$BookmarkEntryFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$BookmarkEntryToJson(this);

  @override
  BookmarkItem clone() {
    return copyWith();
  }

  @override
  List<Object?> get hashParameters => [
    guid,
    parentGuid,
    url,
    title,
    previewImageUrl,
    position,
    dateAdded,
  ];
}

@CopyWith()
@JsonSerializable()
class BookmarkFolder extends BookmarkItem with FastEquatable {
  @override
  final String guid;
  @override
  final String? parentGuid;
  @override
  final String title;
  @override
  final int? position;
  @override
  final int dateAdded;

  final List<BookmarkItem>? children;

  BookmarkFolder({
    required this.guid,
    required this.parentGuid,
    required String title,
    required this.position,
    required this.dateAdded,
    required this.children,
  }) : title = bookmarkRootDisplayNames[guid] ?? title;

  factory BookmarkFolder.fromJson(Map<String, dynamic> json) =>
      _$BookmarkFolderFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$BookmarkFolderToJson(this);

  @override
  BookmarkItem clone() {
    return copyWith();
  }

  @override
  List<Object?> get hashParameters => [
    guid,
    parentGuid,
    title,
    position,
    dateAdded,
    children,
  ];
}
