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
import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/features/bangs/data/models/bang_data.dart';
import 'package:weblibre/features/bangs/data/providers.dart';
import 'package:weblibre/features/bangs/domain/providers/bangs.dart';
import 'package:weblibre/features/bangs/domain/repositories/data.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';

part 'search.g.dart';

@Riverpod()
class BangSearch extends _$BangSearch {
  late StreamController<List<BangData>> _streamController;

  Future<Uri> triggerBangSearch(BangData bang, String searchQuery) async {
    final bangDataNotifier = ref.read(bangDataRepositoryProvider.notifier);
    final settings = ref.read(generalSettingsWithDefaultsProvider);

    await bangDataNotifier.increaseFrequency(bang.toKey());
    await bangDataNotifier.addSearchEntry(
      bang.group,
      bang.trigger,
      searchQuery,
      maxEntryCount: settings.maxSearchHistoryEntries,
    );

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
