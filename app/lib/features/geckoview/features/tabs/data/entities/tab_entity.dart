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

sealed class TabEntity with FastEquatable {
  String get tabId;
}

class DefaultTabEntity extends TabEntity {
  @override
  final String tabId;

  DefaultTabEntity({required this.tabId});

  @override
  List<Object?> get hashParameters => [tabId];
}

class SearchResultTabEntity extends TabEntity {
  @override
  final String tabId;

  final String searchQuery;

  SearchResultTabEntity({required this.tabId, required this.searchQuery});

  @override
  List<Object?> get hashParameters => [tabId, searchQuery];
}

class TabTreeEntity extends TabEntity {
  @override
  final String tabId;

  final String rootId;

  final int totalTabs;

  TabTreeEntity({
    required this.tabId,
    required this.rootId,
    required this.totalTabs,
  });

  @override
  List<Object?> get hashParameters => [tabId, rootId, totalTabs];
}
