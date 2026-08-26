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
import 'package:weblibre/features/bangs/domain/services/bang_query.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';

part 'search.g.dart';

/// A bang the user wrote inline (`!g cats`) together with the query left after
/// the bang token was lifted out.
class InlineBangMatch {
  final BangData bang;
  final String query;

  const InlineBangMatch({required this.bang, required this.query});
}

/// Tracks the bang written into the address bar as the user types.
///
/// Kept as a notifier rather than a `.family` on the text so that a keystroke
/// updates one provider instead of creating and disposing one per input value.
@Riverpod()
class InlineBang extends _$InlineBang {
  /// Guards against a slow lookup for stale text overwriting a newer one.
  String? _pendingInput;

  @override
  InlineBangMatch? build() => null;

  /// Resolves the bang in [input], publishes it as this provider's state and
  /// returns it. Submit paths use the return value directly so they never race
  /// the state write.
  Future<InlineBangMatch?> resolve(String input) async {
    final parsed = parseBangInput(input);
    _pendingInput = input;

    if (!parsed.hasBang) {
      state = null;
      return null;
    }

    // Read the repository before the await: an autoDispose notifier that is
    // disposed mid-flight loses its ref.
    final repository = ref.read(bangDataRepositoryProvider.notifier);
    final bang = await repository.resolveTrigger(parsed.trigger!);

    final match = bang == null
        ? null
        : InlineBangMatch(bang: bang, query: parsed.query);

    // A newer keystroke has already been handled, or the provider is gone.
    if (_pendingInput != input || !ref.mounted) {
      return match;
    }

    state = match;
    return match;
  }
}

@Riverpod()
class BangSearch extends _$BangSearch {
  late StreamController<List<BangData>> _streamController;
  String _pendingInput = '';

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

  Future<void> removeSearchEntry(String searchQuery) {
    return ref
        .read(bangDataRepositoryProvider.notifier)
        .removeSearchEntry(searchQuery);
  }

  Future<void> search(String input) async {
    _pendingInput = input;

    if (!_streamController.isClosed) {
      _streamController.add([]);
    }

    if (input.isEmpty) {
      return;
    }

    final results = await ref
        .read(bangDatabaseProvider)
        .bangDao
        .queryBangs(input)
        .get();

    if (ref.mounted && _pendingInput == input && !_streamController.isClosed) {
      _streamController.add(results);
    }
  }

  @override
  Stream<List<BangData>> build() {
    _streamController = StreamController();

    // Emit initial empty list so UI doesn't show loading state
    _streamController.add([]);

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
    // Both are watched unconditionally, and only the presentation switches.
    // `search()` pushes into `bangSearchProvider` before the rebuild that
    // starts watching it lands; watching it only once `_hasSearch` flipped
    // left that provider without a listener in between, so autoDispose tore it
    // down — closing the stream controller and dropping the first query.
    final searchResults = ref.watch(bangSearchProvider);
    final frequentBangs = ref.watch(frequentBangListProvider);

    return _hasSearch ? searchResults : frequentBangs;
  }
}
