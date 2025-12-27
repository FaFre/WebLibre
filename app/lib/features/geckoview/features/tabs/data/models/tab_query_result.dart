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
import 'package:fast_equatable/fast_equatable.dart';

class TabQueryResult with FastEquatable {
  final String id;
  final String? containerId;

  final String? title;
  final Uri? cleanUrl;

  final String? url;
  final String? extractedContent;
  final String? fullContent;

  final double weightedRank;

  TabQueryResult({
    required this.id,
    required this.containerId,
    required this.title,
    required this.url,
    required this.cleanUrl,
    this.extractedContent,
    this.fullContent,
    required this.weightedRank,
  });

  @override
  List<Object?> get hashParameters => [
    id,
    containerId,
    title,
    cleanUrl,
    url,
    extractedContent,
    fullContent,
    weightedRank,
  ];
}
