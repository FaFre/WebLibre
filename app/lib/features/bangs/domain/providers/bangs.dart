import 'package:lensai/features/bangs/data/models/bang.dart';
import 'package:lensai/features/bangs/data/models/bang_data.dart';
import 'package:lensai/features/bangs/data/models/search_history_entry.dart';
import 'package:lensai/features/bangs/domain/repositories/data.dart';
import 'package:lensai/features/bangs/domain/repositories/sync.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'bangs.g.dart';

@Riverpod()
Stream<BangData?> bangData(Ref ref, String? trigger) {
  final repository = ref.watch(bangDataRepositoryProvider.notifier);
  return repository.watchBang(trigger);
}

@Riverpod(keepAlive: true)
Stream<BangData?> defaultSearchBangData(Ref ref) {
  final repository = ref.watch(bangDataRepositoryProvider.notifier);
  return repository.watchBang('lai');
}

@Riverpod()
Stream<Map<String, List<String>>> bangCategories(Ref ref) {
  final repository = ref.watch(bangDataRepositoryProvider.notifier);
  return repository.watchCategories();
}

@Riverpod()
Stream<List<BangData>> bangDataList(
  Ref ref, {
  ({
    Iterable<BangGroup>? groups,
    String? domain,
    ({String category, String? subCategory})? categoryFilter,
    bool? orderMostFrequentFirst,
  })?
  filter,
}) {
  final repository = ref.watch(bangDataRepositoryProvider.notifier);
  return repository.watchBangs(
    groups: filter?.groups,
    domain: filter?.domain,
    categoryFilter: filter?.categoryFilter,
    orderMostFrequentFirst: filter?.orderMostFrequentFirst,
  );
}

@Riverpod()
Stream<List<BangData>> frequentBangDataList(Ref ref) {
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
