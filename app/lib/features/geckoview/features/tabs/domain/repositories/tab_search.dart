import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/models/tab_query_result.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/providers.dart';

part 'tab_search.g.dart';

enum TabSearchPartition { preview, search }

@Riverpod()
class TabSearchRepository extends _$TabSearchRepository {
  Future<void> addQuery(
    String input, {
    int snippetLength = 120,
    String matchPrefix = '***',
    String matchSuffix = '***',
    String ellipsis = '…',
  }) async {
    if (input.isNotEmpty) {
      state = await AsyncValue.guard(
        () =>
            ref
                .read(tabDatabaseProvider)
                .tabDao
                .queryTabs(
                  matchPrefix: matchPrefix,
                  matchSuffix: matchSuffix,
                  ellipsis: ellipsis,
                  snippetLength: snippetLength,
                  searchString: input,
                )
                .get(),
      );
    } else {
      state = const AsyncValue.data(null);
    }
  }

  @override
  Future<List<TabQueryResult>?> build(TabSearchPartition partition) {
    return Future.value();
  }
}
