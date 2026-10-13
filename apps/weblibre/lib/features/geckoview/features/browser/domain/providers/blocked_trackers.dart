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

import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_state.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/entities/blocked_trackers.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/repositories/tracking_protection.dart';

part 'blocked_trackers.g.dart';

/// The trackers blocked on the page in [tabId] so far.
///
/// There is no event per blocked tracker to follow, so the log is read again
/// whenever the page changes or starts or finishes loading — the points where
/// it can have grown.
@Riverpod()
Future<PageTrackers> pageTrackers(Ref ref, String tabId) async {
  ref.watch(
    tabStateProvider(tabId).select((tab) => (tab?.url, tab?.isLoading)),
  );

  final log = await ref
      .read(trackingProtectionRepositoryProvider.notifier)
      .fetchTrackerLog(tabId);

  return bucketTrackerLog(log);
}

/// The tracker-statistics database, summed for display. Read once per watcher,
/// so it is current whenever a screen showing it opens.
@Riverpod()
Future<TrackerStatisticsSummary> trackerStatistics(Ref ref) async {
  final statistics = await ref
      .read(trackingProtectionRepositoryProvider.notifier)
      .fetchTrackingStatistics();

  return summarizeTrackingStatistics(statistics, now: DateTime.now());
}
