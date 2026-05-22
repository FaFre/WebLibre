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

// `riverpod/riverpod.dart` is what carries the `.select` extension on
// providers; `riverpod_annotation` re-exports `Ref` but not the
// ProviderListenable extensions, so this import isn't redundant despite
// the unused-import lint's opinion.
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:synchronized/synchronized.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/providers.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';

part 'local_index_settings_sync.g.dart';

/// Setting keys in `local_index_setting`. Kept as constants here because
/// the SQL triggers in `definitions.drift` reference the same literal
/// strings (`'enabled'`, `'index_private'`) — a divergence between the
/// Dart writer and the SQL reader would silently disable the trigger
/// gate.
const _kEnabledKey = 'enabled';
const _kIndexPrivateKey = 'index_private';

/// Mirrors `enableLocalSearchIndex` / `indexPrivateTabs` from user.db
/// settings into tab.db's `local_index_setting` rows. The trigger reads
/// from `local_index_setting` exclusively, so this provider is the bridge
/// keeping both in sync.
///
/// Scheduled as a `keepAlive` provider that's read at app start
/// (`main.dart`) so the listener is wired before the first tab event
/// reaches the database.
@Riverpod(keepAlive: true)
class LocalIndexSettingsSync extends _$LocalIndexSettingsSync {
  /// Serializes the two-row upsert per settings change. Without this, two
  /// rapid setting flips could interleave their `enabled` / `index_private`
  /// writes such that the final state on disk doesn't match the user's
  /// last click. The lock is fine-grained per provider instance.
  final _writeLock = Lock();

  Future<void> _push({
    required bool enabled,
    required bool indexPrivate,
  }) => _writeLock.synchronized(() async {
    final dao = ref.read(tabDatabaseProvider).historyDao;
    await dao.upsertSetting(_kEnabledKey, enabled);
    await dao.upsertSetting(_kIndexPrivateKey, indexPrivate);
  });

  @override
  void build() {
    ref.listen(
      generalSettingsWithDefaultsProvider.select(
        (s) => (
          enabled: s.enableLocalSearchIndex,
          indexPrivate: s.indexPrivateTabs,
        ),
      ),
      (previous, next) {
        if (previous == next) return;
        // Fire-and-forget: `_writeLock` ensures the second flip queues
        // behind the first instead of racing it.
        unawaited(_push(enabled: next.enabled, indexPrivate: next.indexPrivate));
      },
      fireImmediately: true,
    );
  }
}
