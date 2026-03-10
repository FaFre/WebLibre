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
import 'package:weblibre/features/geckoview/features/top_sites/domain/entities/top_site_source.dart';

class TopSiteItem with FastEquatable {
  final String? id;
  final String title;
  final Uri url;
  final TopSiteSource source;
  final String? orderKey;
  final DateTime? createdAt;
  final String? previewImageUrl;
  final double? historyScore;
  final int? historyPlaceId;

  TopSiteItem({
    this.id,
    required this.title,
    required this.url,
    required this.source,
    this.orderKey,
    this.createdAt,
    this.previewImageUrl,
    this.historyScore,
    this.historyPlaceId,
  });

  bool get isPinned => source == TopSiteSource.pinned;

  bool get isDefault => source == TopSiteSource.defaultSite;

  bool get isHistory => source == TopSiteSource.history;

  bool get isPersisted => isPinned || isDefault;

  bool get isReorderable => isPersisted;

  bool get isEditable => isPersisted;

  bool get isRemovable => isPersisted;

  @override
  List<Object?> get hashParameters => [
    id,
    title,
    url,
    source,
    orderKey,
    createdAt,
    previewImageUrl,
    historyScore,
    historyPlaceId,
  ];
}
