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
import 'package:clock/clock.dart';
import 'package:weblibre/features/app_update/data/github/allowlisted_fetcher.dart';
import 'package:weblibre/features/app_update/data/metadata/catalogue_reader.dart';
import 'package:weblibre/features/app_update/data/metadata/freshness_guard.dart';
import 'package:weblibre/features/app_update/data/store/accepted_catalogue_store.dart';
import 'package:weblibre/features/app_update/domain/entities/release_metadata.dart';
import 'package:weblibre/features/app_update/domain/entities/update_failure.dart';
import 'package:weblibre/features/app_update/domain/repositories/release_metadata_repository.dart';
import 'package:weblibre/features/app_update/domain/services/update_backend.dart';

/// The signed catalogue on the static host (plan 5.6, 7.1): fetch through the
/// routed client, verify, apply the one freshness rule set, store.
class StaticReleaseMetadataRepository implements ReleaseMetadataRepository {
  StaticReleaseMetadataRepository({
    required this.packageId,
    required this.fetcher,
    required this.reader,
    required this.store,
    required this.guard,
  });

  final String packageId;
  final AllowlistedFetcher fetcher;
  final CatalogueReader reader;
  final AcceptedCatalogueStore store;
  final FreshnessGuard guard;

  @override
  Future<void> open() async {
    if (store.current == null) await store.open();
  }

  @override
  bool get recoveryRequired => store.recoveryRequired;

  @override
  AcceptedCatalogue? get accepted => store.accepted;

  /// Returned only after acceptance has committed (7.1 step 6), so the same
  /// target can be derived again from signed bytes after a restart.
  @override
  Future<AcceptedCatalogue> fetchAndAccept({CancelToken? cancel}) async {
    await open();
    if (store.recoveryRequired) {
      throw UpdateFailure(UpdateFailureKind.stateCorrupt);
    }

    final bytes = await fetcher.fetchCatalogue(packageId, cancel: cancel);
    final candidate = await reader.read(bytes);
    final failure = guard.check(
      candidate: candidate,
      accepted: store.accepted,
      deviceNow: clock.now().toUtc(),
    );
    if (failure != null) throw failure;

    await store.accept(candidate);
    return candidate;
  }

  /// The accepted catalogue when it may be relied on right now: verified on
  /// read, and fresh under the full guard (5.3). There is no reduced
  /// "expiry only" path.
  @override
  ReleaseCatalogue? usable() {
    final current = store.accepted;
    if (current == null) return null;
    final failure = guard.check(
      candidate: current,
      accepted: current,
      deviceNow: clock.now().toUtc(),
    );
    return failure == null ? current.catalogue : null;
  }

  @override
  Future<void> reset() => store.reset();
}
