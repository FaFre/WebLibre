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
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/features/bangs/data/models/bang_data.dart';
import 'package:weblibre/features/bangs/data/models/bang_group.dart';
import 'package:weblibre/features/bangs/data/models/search_history_entry.dart';
import 'package:weblibre/features/bangs/domain/repositories/data.dart';
import 'package:weblibre/features/bangs/domain/repositories/sync.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';

part 'bangs.g.dart';

@Riverpod(keepAlive: true)
Stream<BangData?> defaultSearchBangData(Ref ref) {
  final trigger = ref.watch(
    generalSettingsRepositoryProvider.select(
      (value) => value.defaultSearchProvider,
    ),
  );

  final repository = ref.watch(bangDataRepositoryProvider.notifier);
  return repository.watchBang(trigger);
}

@Riverpod()
Stream<BangData?> bangData(Ref ref, String trigger) {
  final repository = ref.watch(bangDataRepositoryProvider.notifier);
  return repository.watchBang(trigger);
}

@Riverpod()
Stream<Map<String, List<String>>> bangCategories(Ref ref) {
  final repository = ref.watch(bangDataRepositoryProvider.notifier);
  return repository.watchCategories();
}

@Riverpod()
Stream<List<BangData>> bangList(
  Ref ref, {
  List<String>? triggers,
  List<BangGroup>? groups,
  String? domain,
  ({String category, String? subCategory})? categoryFilter,
  bool? orderMostFrequentFirst,
}) {
  final repository = ref.watch(bangDataRepositoryProvider.notifier);
  return repository.watchBangs(
    triggers: triggers,
    groups: groups,
    domain: domain,
    categoryFilter: categoryFilter,
    orderMostFrequentFirst: orderMostFrequentFirst,
  );
}

@Riverpod()
Stream<List<BangData>> frequentBangList(Ref ref) {
  final repository = ref.watch(bangDataRepositoryProvider.notifier);
  return repository.watchFrequentBangs();
}

@Riverpod()
Stream<List<SearchHistoryEntry>> searchHistory(Ref ref) {
  final repository = ref.watch(bangDataRepositoryProvider.notifier);
  return repository.watchSearchHistory(limit: 3); //TODO: make count dynamic
}

@Riverpod()
Stream<DateTime?> lastSyncOfGroup(Ref ref, BangGroup group) {
  final repository = ref.watch(bangSyncRepositoryProvider.notifier);
  return repository.watchLastSyncOfGroup(group);
}

@Riverpod()
Stream<int> bangCountOfGroup(Ref ref, BangGroup group) {
  final repository = ref.watch(bangDataRepositoryProvider.notifier);
  return repository.watchBangCount(group);
}
