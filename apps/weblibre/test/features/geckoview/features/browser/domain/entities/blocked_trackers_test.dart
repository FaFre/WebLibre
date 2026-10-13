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
import 'package:flutter_test/flutter_test.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/entities/blocked_trackers.dart';

TrackerLogEntry _entry(
  String url, {
  List<TrackerLogCategory> blocked = const [],
  List<TrackerLogCategory> loaded = const [],
  bool cookiesBlocked = false,
}) => TrackerLogEntry(
  url: url,
  blockedCategories: blocked,
  loadedCategories: loaded,
  cookiesBlocked: cookiesBlocked,
  unblockedBySmartBlock: false,
);

TrackingStatisticsRecord _record(
  TrackingStatisticsType type,
  int count,
  String? date,
) => TrackingStatisticsRecord(type: type, count: count, date: date);

void main() {
  group('bucketTrackerLog', () {
    test('puts each origin under one primary category, by host', () {
      final trackers = bucketTrackerLog([
        // Fingerprinting wins over the cookie block on the same origin.
        _entry(
          'https://fp.example',
          blocked: [TrackerLogCategory.fingerprinting],
          cookiesBlocked: true,
        ),
        _entry(
          'https://miner.example',
          blocked: [TrackerLogCategory.cryptomining],
        ),
        _entry(
          'https://social.example',
          blocked: [TrackerLogCategory.mozillaSocial],
        ),
        _entry(
          'https://ads.example',
          blocked: [TrackerLogCategory.scriptsAndSubResources],
        ),
        _entry('https://mail.example', blocked: [TrackerLogCategory.email]),
        _entry('https://Cookie.Example', cookiesBlocked: true),
      ]);

      expect(trackers.blocked, {
        BlockedTrackerCategory.crossSiteCookies: ['cookie.example'],
        BlockedTrackerCategory.socialMedia: ['social.example'],
        BlockedTrackerCategory.fingerprinters: ['fp.example'],
        BlockedTrackerCategory.cryptominers: ['miner.example'],
        BlockedTrackerCategory.trackingContent: ['ads.example', 'mail.example'],
      });
      expect(trackers.blockedCount, 6);
    });

    test('leaves out origins that were only loaded', () {
      final trackers = bucketTrackerLog([
        _entry(
          'https://allowed.example',
          loaded: [TrackerLogCategory.scriptsAndSubResources],
        ),
      ]);

      expect(trackers.blocked, isEmpty);
      expect(trackers.blockedCount, 0);
    });

    test('lists categories in display order with hosts sorted', () {
      final trackers = bucketTrackerLog([
        _entry('https://z.example', cookiesBlocked: true),
        _entry(
          'https://b.example',
          blocked: [TrackerLogCategory.fingerprinting],
        ),
        _entry('https://a.example', cookiesBlocked: true),
      ]);

      expect(trackers.blocked.keys, [
        BlockedTrackerCategory.crossSiteCookies,
        BlockedTrackerCategory.fingerprinters,
      ]);
      expect(trackers.blocked[BlockedTrackerCategory.crossSiteCookies], [
        'a.example',
        'z.example',
      ]);
    });

    test('counts an origin logged twice once', () {
      final trackers = bucketTrackerLog([
        _entry('https://dup.example', cookiesBlocked: true),
        _entry('https://dup.example:443', cookiesBlocked: true),
      ]);

      expect(trackers.blockedCount, 1);
    });
  });

  group('summarizeTrackingStatistics', () {
    final now = DateTime.utc(2026, 10, 12, 15);

    test('sums all trackers and the last seven UTC days by category', () {
      final summary = summarizeTrackingStatistics(
        TrackingStatistics(
          earliestRecordMillis: DateTime.utc(2026, 9, 1).millisecondsSinceEpoch,
          records: [
            _record(TrackingStatisticsType.trackers, 10, '2026-09-01'),
            // Seven days: 2026-10-06 through today.
            _record(TrackingStatisticsType.trackers, 4, '2026-10-06'),
            _record(TrackingStatisticsType.trackingCookies, 3, '2026-10-12'),
            _record(TrackingStatisticsType.fingerprinters, 2, '2026-10-10'),
            _record(
              TrackingStatisticsType.suspiciousFingerprinters,
              1,
              '2026-10-10',
            ),
            _record(TrackingStatisticsType.bounceTrackers, 5, '2026-10-11'),
            // Just outside the window.
            _record(TrackingStatisticsType.social, 7, '2026-10-05'),
          ],
        ),
        now: now,
      );

      expect(summary.since, DateTime.utc(2026, 9, 1));
      expect(summary.total, 32);
      expect(summary.lastSevenDays, {
        BlockedTrackerCategory.crossSiteCookies: 3,
        BlockedTrackerCategory.socialMedia: 0,
        BlockedTrackerCategory.fingerprinters: 3,
        BlockedTrackerCategory.cryptominers: 0,
        BlockedTrackerCategory.trackingContent: 4,
        BlockedTrackerCategory.redirectTrackers: 5,
      });
      expect(summary.lastSevenDaysTotal, 15);
    });

    test('does not count cookies that are not trackers', () {
      final summary = summarizeTrackingStatistics(
        TrackingStatistics(
          earliestRecordMillis: DateTime.utc(
            2026,
            10,
            12,
          ).millisecondsSinceEpoch,
          records: [
            _record(TrackingStatisticsType.otherCookies, 50, '2026-10-12'),
            _record(TrackingStatisticsType.cryptominers, 1, '2026-10-12'),
          ],
        ),
        now: now,
      );

      expect(summary.total, 1);
      expect(summary.lastSevenDaysTotal, 1);
    });

    test('counts an undated record in the total only', () {
      final summary = summarizeTrackingStatistics(
        TrackingStatistics(
          earliestRecordMillis: DateTime.utc(
            2026,
            10,
            1,
          ).millisecondsSinceEpoch,
          records: [_record(TrackingStatisticsType.trackers, 2, null)],
        ),
        now: now,
      );

      expect(summary.total, 2);
      expect(summary.lastSevenDaysTotal, 0);
    });

    test('reports nothing recorded without an earliest record', () {
      final summary = summarizeTrackingStatistics(
        TrackingStatistics(earliestRecordMillis: null, records: []),
        now: now,
      );

      expect(summary.since, isNull);
      expect(summary.total, 0);
      expect(summary.lastSevenDaysTotal, 0);
    });

    test('uses the UTC day even when the local time is already tomorrow', () {
      // 23:30 UTC is the next day east of UTC; Gecko still files today's
      // blocks under the UTC date.
      final summary = summarizeTrackingStatistics(
        TrackingStatistics(
          earliestRecordMillis: DateTime.utc(
            2026,
            10,
            1,
          ).millisecondsSinceEpoch,
          records: [_record(TrackingStatisticsType.trackers, 1, '2026-10-06')],
        ),
        now: DateTime.utc(2026, 10, 12, 23, 30).toLocal(),
      );

      expect(summary.lastSevenDaysTotal, 1);
    });
  });
}
