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

class FindResultState with FastEquatable {
  final String? lastSearchText;

  final int activeMatchOrdinal;
  final int numberOfMatches;
  final bool isDoneCounting;

  bool get hasMatches => numberOfMatches > 0;

  FindResultState({
    required this.lastSearchText,
    required this.activeMatchOrdinal,
    required this.numberOfMatches,
    required this.isDoneCounting,
  });

  factory FindResultState.$default() => FindResultState(
    lastSearchText: null,
    activeMatchOrdinal: -1,
    numberOfMatches: 0,
    isDoneCounting: false,
  );

  @override
  List<Object?> get hashParameters => [
    lastSearchText,
    activeMatchOrdinal,
    numberOfMatches,
    isDoneCounting,
  ];
}
