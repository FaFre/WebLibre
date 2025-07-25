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

class HistoryItem with FastEquatable {
  final Uri url;
  final String title;

  HistoryItem({required this.url, required this.title});

  @override
  List<Object?> get hashParameters => [url, title];
}

class HistoryState with FastEquatable {
  final List<HistoryItem> items;
  final int currentIndex;

  final bool canGoBack;
  final bool canGoForward;

  HistoryState({
    required this.items,
    required this.currentIndex,
    required this.canGoBack,
    required this.canGoForward,
  });

  factory HistoryState.$default() => HistoryState(
    items: const [],
    currentIndex: 0,
    canGoBack: false,
    canGoForward: false,
  );

  @override
  List<Object?> get hashParameters => [
    items,
    currentIndex,
    canGoBack,
    canGoForward,
  ];
}
