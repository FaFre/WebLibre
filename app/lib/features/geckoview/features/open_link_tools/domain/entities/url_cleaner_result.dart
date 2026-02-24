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

enum UrlCleanerMatchType { rawRule, queryRule, referralRule }

class RemovedParam with FastEquatable {
  final String provider;
  final String param;
  final String match;
  final UrlCleanerMatchType type;

  RemovedParam({
    required this.provider,
    required this.param,
    required this.match,
    required this.type,
  });

  @override
  List<Object?> get hashParameters => [provider, param, match, type];
}

class UrlCleanerResult with FastEquatable {
  final String cleanedUrl;
  final bool changed;
  final bool blocked;
  final List<RemovedParam> removedParams;
  final List<String> matchedProviders;
  final String? redirectedFrom;

  UrlCleanerResult({
    required this.cleanedUrl,
    required this.changed,
    required this.blocked,
    required this.removedParams,
    required this.matchedProviders,
    this.redirectedFrom,
  });

  @override
  List<Object?> get hashParameters => [
    cleanedUrl,
    changed,
    blocked,
    removedParams,
    matchedProviders,
    redirectedFrom,
  ];
}
