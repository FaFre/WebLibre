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
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'unlock_incomplete_tabs.g.dart';

/// Tabs whose unlock did not finish: the database says unlocked, but the
/// engine still keeps them from closing until a reconciliation succeeds.
///
/// Until then such a tab counts as locked everywhere the user looks: it keeps
/// its lock badge (with a warning), its close controls stay disabled, and its
/// menu offers to retry. The database alone saying "unlocked" never changes
/// what the user sees. Written only by `TabRepository`.
@Riverpod(keepAlive: true)
class UnlockIncompleteTabs extends _$UnlockIncompleteTabs {
  @override
  EquatableValue<Set<String>> build() => EquatableValue(const {});

  void add(String tabId) {
    if (state.value.contains(tabId)) return;
    state = EquatableValue({...state.value, tabId});
  }

  void remove(String tabId) {
    if (!state.value.contains(tabId)) return;
    state = EquatableValue({...state.value}..remove(tabId));
  }

  void clear() {
    if (state.value.isEmpty) return;
    state = EquatableValue(const {});
  }
}
