import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'tab_delete_cache.g.dart';

@Riverpod(keepAlive: true)
class TabDeleteCache extends _$TabDeleteCache {
  void delete(String tabId) {
    state = {...state, tabId};

    Timer(const Duration(seconds: 3), () {
      if (ref.mounted) {
        state = {...state}..remove(tabId);
      }
    });
  }

  @override
  Set<String> build() {
    return {};
  }
}
