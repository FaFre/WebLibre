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
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/repositories/pending_quit_deletion.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/services/browser_data.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';
import 'package:weblibre/utils/exit_app.dart';

/// Stores the record in memory and logs every write, behind the real
/// serialization.
class _FakePendingQuitDeletionRepository extends PendingQuitDeletionRepository {
  _FakePendingQuitDeletionRepository(this.log);

  final List<String> log;

  // A test fake: tests seed and read back the record.
  // ignore: riverpod_lint/avoid_public_notifier_properties
  PendingDeletions requests = const {};

  Set<DeleteBrowsingDataType> get types => requests.keys.toSet();

  @override
  Future<PendingDeletions> readStored() async => requests;

  @override
  Future<void> writeStored(PendingDeletions requests) async {
    log.add(
      requests.isEmpty
          ? 'clear'
          : 'record ${(requests.keys.map((t) => t.name).toList()..sort()).join(',')}',
    );
    this.requests = requests;
  }
}

class _FakeBrowserDataService extends BrowserDataService {
  _FakeBrowserDataService(this.log)
    : super(service: GeckoDeleteBrowserDataService());

  final List<String> log;

  /// Types whose deletion fails.
  final failing = <DeleteBrowsingDataType>{};

  /// What [sessionTabIds] returns; null makes it fail.
  Set<String>? openTabIds = {'open-1', 'open-2'};

  @override
  Future<Set<String>> sessionTabIds() async =>
      openTabIds ?? (throw Exception('simulated native failure'));

  @override
  Future<void> deleteDataType(
    DeleteBrowsingDataType type, {
    bool previousSessionTabsOnly = false,
    Set<String>? onlyTabIds,
  }) async {
    log.add('delete ${type.name}');
    if (failing.contains(type)) throw Exception('simulated native failure');
  }
}

typedef _Harness = ({
  ProviderContainer container,
  List<String> log,
  _FakePendingQuitDeletionRepository record,
  _FakeBrowserDataService browserData,
});

_Harness _harness() {
  final log = <String>[];
  final record = _FakePendingQuitDeletionRepository(log);
  final browserData = _FakeBrowserDataService(log);

  final container = ProviderContainer(
    overrides: [
      pendingQuitDeletionRepositoryProvider.overrideWith(() => record),
      browserDataServiceProvider.overrideWith(() => browserData),
    ],
  );
  addTearDown(container.dispose);

  return (
    container: container,
    log: log,
    record: record,
    browserData: browserData,
  );
}

void main() {
  group('deleteBrowsingDataOnQuit', () {
    test('records the deletion first, then completes each type', () async {
      final h = _harness();

      await deleteBrowsingDataOnQuit(h.container, {
        DeleteBrowsingDataType.history,
        DeleteBrowsingDataType.tabs,
      });

      expect(h.log, [
        'record history,tabs',
        'delete history',
        'record tabs',
        'delete tabs',
        'clear',
      ]);
    });

    test('the tab request names the tabs open at Quit', () async {
      final h = _harness();
      h.browserData.failing.add(DeleteBrowsingDataType.tabs);

      await deleteBrowsingDataOnQuit(h.container, {
        DeleteBrowsingDataType.tabs,
      });

      expect(h.record.requests[DeleteBrowsingDataType.tabs]?.tabIds, {
        'open-1',
        'open-2',
      });
    });

    test('keeps only what failed', () async {
      // Tabs that were deleted must not stay requested.
      final h = _harness();
      h.browserData.failing.add(DeleteBrowsingDataType.cookies);

      await deleteBrowsingDataOnQuit(h.container, {
        DeleteBrowsingDataType.tabs,
        DeleteBrowsingDataType.cookies,
      });

      expect(h.record.types, {DeleteBrowsingDataType.cookies});
    });

    test('keeps what an earlier deletion left outstanding', () async {
      final h = _harness();
      h.record.requests = {
        DeleteBrowsingDataType.cookies: (requestId: 'old', tabIds: null),
      };

      await deleteBrowsingDataOnQuit(h.container, {
        DeleteBrowsingDataType.history,
      });

      expect(h.log.first, 'record cookies,history');
      expect(h.record.requests, {
        DeleteBrowsingDataType.cookies: (requestId: 'old', tabIds: null),
      });
    });

    test('a type requested again is completed by this Quit', () async {
      final h = _harness();
      h.record.requests = {
        DeleteBrowsingDataType.cookies: (requestId: 'old', tabIds: null),
      };

      await deleteBrowsingDataOnQuit(h.container, {
        DeleteBrowsingDataType.cookies,
      });

      expect(h.record.requests, isEmpty);
    });

    test('a new tab request keeps the tabs of an older one', () async {
      final h = _harness();
      h.record.requests = {
        DeleteBrowsingDataType.tabs: (requestId: 'old', tabIds: {'old-1'}),
      };
      h.browserData.failing.add(DeleteBrowsingDataType.tabs);

      await deleteBrowsingDataOnQuit(h.container, {
        DeleteBrowsingDataType.tabs,
      });

      expect(h.record.requests[DeleteBrowsingDataType.tabs]?.tabIds, {
        'old-1',
        'open-1',
        'open-2',
      });
    });

    test('an older tab request stays when this Quit keeps tabs', () async {
      // It names its own tabs, so it cannot reach this session's.
      final h = _harness();
      h.record.requests = {
        DeleteBrowsingDataType.tabs: (requestId: 'old', tabIds: {'old-1'}),
      };

      await deleteBrowsingDataOnQuit(h.container, {
        DeleteBrowsingDataType.history,
      });

      final request = h.record.requests[DeleteBrowsingDataType.tabs];
      expect(h.record.types, {DeleteBrowsingDataType.tabs});
      expect(request?.requestId, 'old');
      expect(request?.tabIds, {'old-1'});
    });

    test('tabs still go when the open tabs cannot be read', () async {
      final h = _harness();
      h.browserData.openTabIds = null;

      await deleteBrowsingDataOnQuit(h.container, {
        DeleteBrowsingDataType.tabs,
        DeleteBrowsingDataType.history,
      });

      expect(h.log, [
        'record history',
        'delete tabs',
        'delete history',
        'clear',
      ]);
    });

    test('does nothing when nothing is selected', () async {
      final h = _harness();

      await deleteBrowsingDataOnQuit(h.container, const {});

      expect(h.log, isEmpty);
    });
  });
}
