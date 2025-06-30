import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/features/bangs/data/models/bang_data.dart';
import 'package:weblibre/features/bangs/data/providers.dart';
import 'package:weblibre/features/bangs/domain/providers/bangs.dart';
import 'package:weblibre/features/bangs/domain/repositories/data.dart';

part 'search.g.dart';

@Riverpod()
class BangSearch extends _$BangSearch {
  late StreamController<List<BangData>> _streamController;

  Future<Uri> triggerBangSearch(BangData bang, String searchQuery) async {
    final bangDataNotifier = ref.read(bangDataRepositoryProvider.notifier);

    await bangDataNotifier.increaseFrequency(bang.trigger);
    await bangDataNotifier.addSearchEntry(
      bang.trigger,
      searchQuery,
      maxEntryCount: 3,
    ); //TODO: make count dynamic

    return bang.getTemplateUrl(searchQuery);
  }

  Future<void> search(String input) async {
    if (input.isNotEmpty) {
      await ref.read(bangDatabaseProvider).bangDao.queryBangs(input).get().then(
        (value) {
          if (!_streamController.isClosed) {
            _streamController.add(value);
          }
        },
      );
    }
  }

  @override
  Stream<List<BangData>> build() {
    _streamController = StreamController();

    ref.onDispose(() async {
      await _streamController.close();
    });

    return _streamController.stream;
  }
}

@Riverpod()
class SeamlessBang extends _$SeamlessBang {
  bool _hasSearch = false;

  void search(String input) {
    if (input.isNotEmpty) {
      if (!_hasSearch) {
        _hasSearch = true;
        ref.invalidateSelf();
      }

      //Don't block
      unawaited(ref.read(bangSearchProvider.notifier).search(input));
    } else if (_hasSearch) {
      _hasSearch = false;
      ref.invalidateSelf();
    }
  }

  @override
  AsyncValue<List<BangData>> build() {
    return _hasSearch
        ? ref.watch(bangSearchProvider)
        : ref.watch(frequentBangListProvider);
  }
}
