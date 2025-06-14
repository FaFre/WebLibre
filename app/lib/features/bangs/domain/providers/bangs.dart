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
