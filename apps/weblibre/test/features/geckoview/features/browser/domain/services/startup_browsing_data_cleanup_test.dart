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

import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/repositories/pending_quit_deletion.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/services/browser_data.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/services/startup_browsing_data_cleanup.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/utils/exit_app.dart';

class _FakeGeneralSettingsRepository extends GeneralSettingsRepository {
  _FakeGeneralSettingsRepository(this.settings);

  // A test fake: tests change the selection between runs.
  // ignore: riverpod_lint/avoid_public_notifier_properties
  GeneralSettings settings;

  @override
  Stream<GeneralSettings> build() => Stream.value(settings);

  @override
  Future<GeneralSettings> fetchSettings() => Future.value(settings);
}

/// The record, in memory, behind the real serialization.
class _FakePendingQuitDeletionRepository extends PendingQuitDeletionRepository {
  _FakePendingQuitDeletionRepository(this.requests);

  // A test fake: tests seed and read back the record.
  // ignore: riverpod_lint/avoid_public_notifier_properties
  PendingDeletions requests;

  /// While set, writes wait for it: a stalled database.
  // ignore: riverpod_lint/avoid_public_notifier_properties
  Completer<void>? stallWrites;

  Set<DeleteBrowsingDataType> get types => requests.keys.toSet();

  @override
  Future<PendingDeletions> readStored() => Future.value(requests);

  @override
  Future<void> writeStored(PendingDeletions requests) async {
    await stallWrites?.future;
    this.requests = requests;
  }
}

/// Requests as an earlier Quit leaves them; a tab request names [quitTabIds].
PendingDeletions _requests(Set<DeleteBrowsingDataType> types) => {
  for (final type in types)
    type: (
      requestId: 'earlier-${type.name}',
      tabIds: type == DeleteBrowsingDataType.tabs ? _quitTabIds : null,
    ),
};

const _quitTabIds = {'quit-1', 'quit-2'};

typedef _Deletion = ({
  DeleteBrowsingDataType type,
  bool previousSessionTabsOnly,
});

class _FakeBrowserDataService extends BrowserDataService {
  _FakeBrowserDataService(this.deletions)
    : super(service: GeckoDeleteBrowserDataService());

  final List<_Deletion> deletions;

  /// Types whose next deletion throws, once each.
  final failOnce = <DeleteBrowsingDataType>{};

  /// Types whose next deletion waits for this to complete, once each.
  final holds = <DeleteBrowsingDataType, Completer<void>>{};

  /// The tab ids each tab deletion was limited to; null for none.
  final tabScopes = <Set<String>?>[];

  @override
  Future<Set<String>> sessionTabIds() async => {'open-1'};

  @override
  Future<void> deleteDataType(
    DeleteBrowsingDataType type, {
    bool previousSessionTabsOnly = false,
    Set<String>? onlyTabIds,
  }) async {
    deletions.add((
      type: type,
      previousSessionTabsOnly: previousSessionTabsOnly,
    ));
    if (type == DeleteBrowsingDataType.tabs) tabScopes.add(onlyTabIds);
    await holds.remove(type)?.future;
    if (failOnce.remove(type)) {
      throw Exception('simulated native failure');
    }
  }
}

typedef _Harness = ({
  ProviderContainer container,
  StartupBrowsingDataCleanup cleanup,
  List<_Deletion> deletions,
  _FakeBrowserDataService browserData,
  _FakeGeneralSettingsRepository settings,
  _FakePendingQuitDeletionRepository pendingQuit,
});

_Harness _harness({
  Set<DeleteBrowsingDataType>? autoDelete = const {DeleteBrowsingDataType.tabs},
  bool onStart = true,
  Set<DeleteBrowsingDataType> pendingQuit = const {},
  Duration waitTimeout = const Duration(seconds: 30),
}) {
  final deletions = <_Deletion>[];
  final browserData = _FakeBrowserDataService(deletions);
  final settings = _FakeGeneralSettingsRepository(
    GeneralSettings.withDefaults(
      autoDeleteBrowsingData: autoDelete,
      autoDeleteBrowsingDataOnStart: onStart,
    ),
  );
  final pending = _FakePendingQuitDeletionRepository(_requests(pendingQuit));

  final container = ProviderContainer(
    overrides: [
      generalSettingsRepositoryProvider.overrideWith(() => settings),
      browserDataServiceProvider.overrideWith(() => browserData),
      pendingQuitDeletionRepositoryProvider.overrideWith(() => pending),
      startupBrowsingDataCleanupProvider.overrideWith(
        () => StartupBrowsingDataCleanup(waitTimeout: waitTimeout),
      ),
    ],
  );
  addTearDown(container.dispose);

  return (
    container: container,
    cleanup: container.read(startupBrowsingDataCleanupProvider.notifier),
    deletions: deletions,
    browserData: browserData,
    settings: settings,
    pendingQuit: pending,
  );
}

List<DeleteBrowsingDataType> _types(_Harness h) =>
    h.deletions.map((d) => d.type).toList();

/// Lets every pending microtask and zero-delay timer run.
Future<void> _settle() => Future<void>.delayed(Duration.zero);

void main() {
  group('StartupBrowsingDataCleanup', () {
    test('deletes nothing while automatic deletion is off', () async {
      final h = _harness(autoDelete: null);

      await h.cleanup.start();

      expect(h.deletions, isEmpty);
    });

    test('deletes the selected types, tabs last', () async {
      final h = _harness(
        autoDelete: {DeleteBrowsingDataType.tabs, DeleteBrowsingDataType.cache},
      );

      await h.cleanup.start();

      expect(_types(h), [
        DeleteBrowsingDataType.cache,
        DeleteBrowsingDataType.tabs,
      ]);
    });

    test("deletes only the previous session's tabs", () async {
      final h = _harness();

      await h.cleanup.start();

      expect(h.deletions.single.previousSessionTabsOnly, isTrue);
    });

    test(
      'a failed cookie deletion is not retried once browsing began',
      () async {
        final h = _harness(
          autoDelete: {
            DeleteBrowsingDataType.tabs,
            DeleteBrowsingDataType.cookies,
          },
        );
        h.browserData.failOnce.add(DeleteBrowsingDataType.cookies);

        await h.cleanup.start();
        expect(_types(h), [
          DeleteBrowsingDataType.cookies,
          DeleteBrowsingDataType.tabs,
        ]);

        // The user signs in somewhere, then the browser view mounts again: the
        // cookie deletion would take that login with it.
        h.deletions.clear();
        await h.cleanup.start();

        expect(h.deletions, isEmpty);
      },
    );

    test('a failed tab deletion is retried, still scoped', () async {
      final h = _harness(
        autoDelete: {
          DeleteBrowsingDataType.tabs,
          DeleteBrowsingDataType.cookies,
        },
      );
      h.browserData.failOnce.add(DeleteBrowsingDataType.tabs);

      await h.cleanup.start();
      h.deletions.clear();
      await h.cleanup.start();

      expect(h.deletions, [
        (type: DeleteBrowsingDataType.tabs, previousSessionTabsOnly: true),
      ]);
    });

    test('a retry keeps the selection taken on the first run', () async {
      final h = _harness();
      h.browserData.failOnce.add(DeleteBrowsingDataType.tabs);

      await h.cleanup.start();
      h.settings.settings = GeneralSettings.withDefaults(
        autoDeleteBrowsingData: {DeleteBrowsingDataType.history},
      );
      h.deletions.clear();
      await h.cleanup.start();

      expect(_types(h), [DeleteBrowsingDataType.tabs]);
    });

    test('nothing global starts after the wait timed out', () async {
      // History outlasts the wait, so new tabs are let in while it runs. The
      // cookie deletion queued after it must not start any more; the scoped
      // tab deletion still may.
      final h = _harness(
        autoDelete: {
          DeleteBrowsingDataType.tabs,
          DeleteBrowsingDataType.history,
          DeleteBrowsingDataType.cookies,
        },
        waitTimeout: const Duration(milliseconds: 20),
      );
      final hold = h.browserData.holds[DeleteBrowsingDataType.history] =
          Completer();

      final run = h.cleanup.start();
      await h.cleanup.waitUntilDone();
      hold.complete();
      await run;

      expect(_types(h), [
        DeleteBrowsingDataType.history,
        DeleteBrowsingDataType.tabs,
      ]);
    });

    test('runs once per process after a success', () async {
      final h = _harness();

      await h.cleanup.start();
      await h.cleanup.start();

      expect(h.deletions, hasLength(1));
    });

    test('a second start while running joins the first', () async {
      final h = _harness();
      final hold = h.browserData.holds[DeleteBrowsingDataType.tabs] =
          Completer();

      final first = h.cleanup.start();
      final second = h.cleanup.start();
      hold.complete();
      await Future.wait([first, second]);

      expect(h.deletions, hasLength(1));
    });

    test('new tabs wait until the first run has finished', () async {
      final h = _harness(autoDelete: {DeleteBrowsingDataType.cookies});
      final hold = h.browserData.holds[DeleteBrowsingDataType.cookies] =
          Completer();

      unawaited(h.cleanup.start());
      var released = false;
      unawaited(h.cleanup.waitUntilDone().then((_) => released = true));

      await _settle();
      expect(released, isFalse);

      hold.complete();
      await _settle();
      await _settle();

      expect(released, isTrue);
    });

    test(
      'a slow cleanup stops holding new tabs back after one timeout',
      () async {
        // Cache before tabs, the cache deletion outlasting the wait: new tabs
        // open while the cleanup goes on, and the tab deletion that follows is
        // the scoped one, which cannot reach them.
        final h = _harness(
          autoDelete: {
            DeleteBrowsingDataType.tabs,
            DeleteBrowsingDataType.cache,
          },
          waitTimeout: const Duration(milliseconds: 20),
        );
        final hold = h.browserData.holds[DeleteBrowsingDataType.cache] =
            Completer();

        final run = h.cleanup.start();
        await h.cleanup.waitUntilDone();

        // Released for good: a later tab does not wait out another timeout.
        final stopwatch = Stopwatch()..start();
        await h.cleanup.waitUntilDone();
        expect(stopwatch.elapsedMilliseconds, lessThan(20));

        hold.complete();
        await run;

        expect(_types(h), [
          DeleteBrowsingDataType.cache,
          DeleteBrowsingDataType.tabs,
        ]);
        expect(h.deletions.last.previousSessionTabsOnly, isTrue);
      },
    );

    test('new tabs do not wait when no cleanup was started', () async {
      final h = _harness();

      await h.cleanup.waitUntilDone();
    });
  });

  group('StartupBrowsingDataCleanup when deleting on Quit only', () {
    test('deletes nothing after a Quit that finished', () async {
      final h = _harness(
        autoDelete: {DeleteBrowsingDataType.tabs, DeleteBrowsingDataType.cache},
        onStart: false,
      );

      await h.cleanup.start();

      expect(h.deletions, isEmpty);
    });

    test('finishes what the last Quit left undeleted', () async {
      final h = _harness(
        autoDelete: {DeleteBrowsingDataType.tabs, DeleteBrowsingDataType.cache},
        onStart: false,
        pendingQuit: {DeleteBrowsingDataType.cache},
      );

      await h.cleanup.start();

      expect(_types(h), [DeleteBrowsingDataType.cache]);
      expect(h.pendingQuit.types, isEmpty);
    });

    test(
      "deletes only the tabs the Quit named, of the restored ones",
      () async {
        final h = _harness(
          onStart: false,
          pendingQuit: {DeleteBrowsingDataType.tabs},
        );

        await h.cleanup.start();

        expect(h.deletions, [
          (type: DeleteBrowsingDataType.tabs, previousSessionTabsOnly: true),
        ]);
        expect(h.browserData.tabScopes, [_quitTabIds]);
        expect(h.pendingQuit.types, isEmpty);
      },
    );

    test('takes deleted types off the record, keeping what failed', () async {
      final h = _harness(
        autoDelete: null,
        onStart: false,
        pendingQuit: {
          DeleteBrowsingDataType.tabs,
          DeleteBrowsingDataType.cookies,
        },
      );
      h.browserData.failOnce.add(DeleteBrowsingDataType.cookies);

      await h.cleanup.start();

      expect(h.pendingQuit.types, {DeleteBrowsingDataType.cookies});
    });

    test(
      'a failed tab deletion stays requested, still naming its tabs',
      () async {
        // Safe to hand on: a later start deletes only the tabs it names, never
        // ones opened in between.
        final h = _harness(
          autoDelete: null,
          onStart: false,
          pendingQuit: {DeleteBrowsingDataType.tabs},
        );
        h.browserData.failOnce.add(DeleteBrowsingDataType.tabs);

        await h.cleanup.start();
        expect(
          h.pendingQuit.requests[DeleteBrowsingDataType.tabs]?.tabIds,
          _quitTabIds,
        );

        // Retried in this process, with the same scope.
        await h.cleanup.start();
        expect(h.browserData.tabScopes, [_quitTabIds, _quitTabIds]);
        expect(h.pendingQuit.types, isEmpty);
      },
    );

    test('keeps the record for a type skipped once browsing began', () async {
      final h = _harness(
        autoDelete: null,
        onStart: false,
        pendingQuit: {
          DeleteBrowsingDataType.history,
          DeleteBrowsingDataType.cookies,
        },
        waitTimeout: const Duration(milliseconds: 20),
      );
      final hold = h.browserData.holds[DeleteBrowsingDataType.history] =
          Completer();

      final run = h.cleanup.start();
      await h.cleanup.waitUntilDone();
      hold.complete();
      await run;

      expect(_types(h), [DeleteBrowsingDataType.history]);
      expect(h.pendingQuit.types, {DeleteBrowsingDataType.cookies});
    });

    test('a stalled record write does not hold new tabs back', () async {
      final h = _harness(
        autoDelete: null,
        onStart: false,
        pendingQuit: {
          DeleteBrowsingDataType.cache,
          DeleteBrowsingDataType.tabs,
        },
        waitTimeout: const Duration(milliseconds: 20),
      );
      // The cache deletion succeeds; recording that never returns.
      h.pendingQuit.stallWrites = Completer();

      unawaited(h.cleanup.start());

      await h.cleanup.waitUntilDone().timeout(const Duration(seconds: 1));
    });
  });

  group('StartupBrowsingDataCleanup during a Quit', () {
    _Harness slowHistory() {
      final h = _harness(
        autoDelete: null,
        onStart: false,
        pendingQuit: {
          DeleteBrowsingDataType.history,
          DeleteBrowsingDataType.cookies,
        },
        waitTimeout: const Duration(milliseconds: 20),
      );
      h.browserData.holds[DeleteBrowsingDataType.history] = Completer();
      return h;
    }

    test(
      'keeps what the Quit recorded and completes its own deletion',
      () async {
        // The history deletion outlasts the wait; the user browses and quits,
        // and the Quit's download deletion fails.
        final h = slowHistory();
        final hold = h.browserData.holds[DeleteBrowsingDataType.history]!;

        final run = h.cleanup.start();
        await h.cleanup.waitUntilDone();
        h.browserData.failOnce.add(DeleteBrowsingDataType.downloads);
        await deleteBrowsingDataOnQuit(h.container, {
          DeleteBrowsingDataType.downloads,
        });

        hold.complete();
        await run;

        // History is done and comes off; cookies were skipped once browsing
        // began; downloads is the Quit's.
        expect(h.pendingQuit.types, {
          DeleteBrowsingDataType.cookies,
          DeleteBrowsingDataType.downloads,
        });
      },
    );

    test(
      'an older deletion finishing does not complete a newer request',
      () async {
        final h = slowHistory();
        final hold = h.browserData.holds[DeleteBrowsingDataType.history]!;

        final run = h.cleanup.start();
        await h.cleanup.waitUntilDone();
        // The Quit asks for history again, and its own deletion fails.
        h.browserData.failOnce.add(DeleteBrowsingDataType.history);
        await deleteBrowsingDataOnQuit(h.container, {
          DeleteBrowsingDataType.history,
        });

        hold.complete();
        await run;

        expect(h.pendingQuit.types, contains(DeleteBrowsingDataType.history));
        expect(
          h.pendingQuit.requests[DeleteBrowsingDataType.history]?.requestId,
          isNot('earlier-history'),
        );
      },
    );
  });

  group('StartupBrowsingDataCleanup when deleting on start too', () {
    test('also finishes what was picked for the last Quit only', () async {
      final h = _harness(
        autoDelete: {DeleteBrowsingDataType.tabs},
        pendingQuit: {DeleteBrowsingDataType.cookies},
      );

      await h.cleanup.start();

      expect(_types(h), [
        DeleteBrowsingDataType.cookies,
        DeleteBrowsingDataType.tabs,
      ]);
      expect(h.pendingQuit.types, isEmpty);
    });

    test('takes every restored tab, which completes a tab request', () async {
      final h = _harness(pendingQuit: {DeleteBrowsingDataType.tabs});

      await h.cleanup.start();

      expect(h.browserData.tabScopes, [null]);
      expect(h.pendingQuit.types, isEmpty);
    });
  });
}
