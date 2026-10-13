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

import 'package:fast_equatable/fast_equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';

/// What blocked trackers are grouped into for display, in display order.
///
/// The buckets are Fenix's trust-panel ones, so a tracker lands where Firefox
/// users would look for it; [redirectTrackers] only ever comes from the
/// statistics, because a page's tracker log has no category of its own for
/// them.
enum BlockedTrackerCategory {
  crossSiteCookies(Icons.cookie_outlined),
  socialMedia(MdiIcons.thumbDownOutline),
  fingerprinters(Icons.fingerprint),
  cryptominers(MdiIcons.pickaxe),
  trackingContent(Icons.code_off),
  redirectTrackers(Icons.alt_route);

  const BlockedTrackerCategory(this.icon);
  final IconData icon;
}

/// The trackers a page has had blocked so far, by category.
class PageTrackers with FastEquatable {
  /// Tracker hosts per category, sorted, for every category with at least one.
  final Map<BlockedTrackerCategory, List<String>> blocked;

  PageTrackers(this.blocked);

  /// How many tracker origins were blocked. Each is counted once, under its
  /// primary category.
  int get blockedCount =>
      blocked.values.fold(0, (sum, hosts) => sum + hosts.length);

  @override
  List<Object?> get hashParameters => [blocked];
}

/// Groups a page's tracker log the way Fenix's `TrackerBuckets` does: each
/// blocked origin goes into one primary category, chosen in this order, so a
/// fingerprinting script that also had its cookies blocked is not counted
/// twice. Origins that were only loaded are left out.
PageTrackers bucketTrackerLog(List<TrackerLogEntry> log) {
  final blocked = <BlockedTrackerCategory, Set<String>>{};

  for (final entry in log) {
    final category = _primaryBlockedCategory(entry);
    if (category == null) continue;

    blocked.putIfAbsent(category, () => {}).add(_hostOf(entry.url));
  }

  return PageTrackers({
    for (final category in BlockedTrackerCategory.values)
      if (blocked[category] case final hosts?) category: hosts.toList()..sort(),
  });
}

BlockedTrackerCategory? _primaryBlockedCategory(TrackerLogEntry entry) {
  final categories = entry.blockedCategories;

  if (categories.contains(TrackerLogCategory.fingerprinting)) {
    return BlockedTrackerCategory.fingerprinters;
  }
  if (categories.contains(TrackerLogCategory.cryptomining)) {
    return BlockedTrackerCategory.cryptominers;
  }
  if (categories.contains(TrackerLogCategory.mozillaSocial)) {
    return BlockedTrackerCategory.socialMedia;
  }
  if (categories.contains(TrackerLogCategory.scriptsAndSubResources) ||
      categories.contains(TrackerLogCategory.email)) {
    return BlockedTrackerCategory.trackingContent;
  }
  if (entry.cookiesBlocked) {
    return BlockedTrackerCategory.crossSiteCookies;
  }

  return null;
}

/// The log reports origins (`https://tracker.example`); the host is what
/// people recognize. Falls back to the raw string for anything unparsable.
String _hostOf(String origin) {
  final host = Uri.tryParse(origin)?.host;
  return (host == null || host.isEmpty) ? origin : host.toLowerCase();
}

/// What the tracker-statistics database holds, summed for display.
class TrackerStatisticsSummary with FastEquatable {
  /// The (UTC) day recording started, or null when nothing was recorded.
  final DateTime? since;

  /// Trackers blocked since [since].
  final int total;

  /// Trackers blocked in the last seven days, today included, per category.
  /// Every category is present, zero or not.
  final Map<BlockedTrackerCategory, int> lastSevenDays;

  TrackerStatisticsSummary({
    required this.since,
    required this.total,
    required this.lastSevenDays,
  });

  int get lastSevenDaysTotal =>
      lastSevenDays.values.fold(0, (sum, count) => sum + count);

  @override
  List<Object?> get hashParameters => [since, total, lastSevenDays];
}

/// Sums [statistics] the way Fenix's protections dashboard does, adding
/// cryptominers and redirect trackers, which WebLibre blocks too.
///
/// Cookies the cookie policy blocked without them being known trackers
/// ([TrackingStatisticsType.otherCookies]) are left out: they are not trackers,
/// and a total that counts them would not match the categories listed under it.
///
/// Gecko writes each record under its UTC day, so the seven-day window is
/// counted in UTC days as well.
TrackerStatisticsSummary summarizeTrackingStatistics(
  TrackingStatistics statistics, {
  required DateTime now,
}) {
  final today = _utcDay(now.toUtc());
  final windowStart = today.subtract(const Duration(days: 6));

  var total = 0;
  final lastSevenDays = {
    for (final category in BlockedTrackerCategory.values) category: 0,
  };

  for (final record in statistics.records) {
    final category = _statisticsCategory(record.type);
    if (category == null) continue;

    total += record.count;

    final day = record.date.mapDay();
    if (day != null && !day.isBefore(windowStart) && !day.isAfter(today)) {
      lastSevenDays[category] = lastSevenDays[category]! + record.count;
    }
  }

  final earliest = statistics.earliestRecordMillis;

  return TrackerStatisticsSummary(
    since: earliest == null
        ? null
        : _utcDay(DateTime.fromMillisecondsSinceEpoch(earliest, isUtc: true)),
    total: total,
    lastSevenDays: lastSevenDays,
  );
}

BlockedTrackerCategory? _statisticsCategory(TrackingStatisticsType type) {
  return switch (type) {
    TrackingStatisticsType.trackingCookies =>
      BlockedTrackerCategory.crossSiteCookies,
    TrackingStatisticsType.social => BlockedTrackerCategory.socialMedia,
    TrackingStatisticsType.fingerprinters ||
    TrackingStatisticsType.suspiciousFingerprinters =>
      BlockedTrackerCategory.fingerprinters,
    TrackingStatisticsType.cryptominers => BlockedTrackerCategory.cryptominers,
    TrackingStatisticsType.trackers => BlockedTrackerCategory.trackingContent,
    TrackingStatisticsType.bounceTrackers =>
      BlockedTrackerCategory.redirectTrackers,
    TrackingStatisticsType.otherCookies => null,
  };
}

DateTime _utcDay(DateTime utc) => DateTime.utc(utc.year, utc.month, utc.day);

extension on String? {
  /// A `YYYY-MM-DD` record date as a UTC day, or null when absent or invalid.
  DateTime? mapDay() {
    final value = this;
    if (value == null) return null;

    final parsed = DateTime.tryParse(value);
    return parsed == null
        ? null
        : DateTime.utc(parsed.year, parsed.month, parsed.day);
  }
}
