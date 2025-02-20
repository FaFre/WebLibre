import 'package:lensai/features/bangs/data/models/bang_data.dart';
import 'package:lensai/features/bangs/domain/repositories/data.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'search.g.dart';

@Riverpod()
class BangSearch extends _$BangSearch {
  Future<Uri> triggerBangSearch(BangData bang, String searchQuery) async {
    final bangDataNotifier = ref.read(bangDataRepositoryProvider.notifier);

    await bangDataNotifier.increaseFrequency(bang.trigger);
    await bangDataNotifier.addSearchEntry(
      bang.trigger,
      searchQuery,
      maxEntryCount: 3,
    ); //TODO: make count dynamic

    return bang.getUrl(searchQuery);
  }

  @override
  void build() {}
}
