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

class KagiFeedEntry with FastEquatable {
  final Uri url;
  final String? title;
  final String? author;
  final String? summary;
  final DateTime? publishedAt;
  final List<String> categories;

  KagiFeedEntry({
    required this.url,
    this.title,
    this.author,
    this.summary,
    this.publishedAt,
    this.categories = const [],
  });

  @override
  List<Object?> get hashParameters => [
    url,
    title,
    author,
    summary,
    publishedAt,
    categories,
  ];
}
