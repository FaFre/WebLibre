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
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/models/container_data.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/providers.dart';

part 'history_exclusion_replication.g.dart';

/// The Gecko contextIds that must be hard-excluded from history: containers with
/// `excludeFromHistory` enabled that actually have a contextId (contextId-less
/// containers can't be distinguished at the delegate, so they can't be
/// excluded — the invariant on [ContainerMetadata] keeps the flag off for them).
List<String> excludedHistoryContextIds(Iterable<ContainerData> containers) {
  return containers
      .where((container) => container.metadata.excludeFromHistory)
      .map((container) => container.metadata.contextualIdentity)
      .whereType<String>()
      .toList(growable: false);
}

/// Keeps the native history delegate's hard exclude-from-history set in sync
/// with WebLibre's containers, re-pushing whenever the container set changes.
/// Activated eagerly at startup (and once more before engine init) so an
/// excluded container never leaks a restored-tab visit to Places.
@Riverpod(keepAlive: true)
Future<void> historyExclusionReplication(Ref ref) async {
  final containers = await ref.watch(watchContainersWithCountProvider.future);

  await GeckoEngineSettingsService().setExcludedHistoryContextIds(
    excludedHistoryContextIds(containers),
  );
}
