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
import 'package:weblibre/features/geckoview/features/browser/domain/services/browser_data.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/services/startup_browsing_data_cleanup.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';

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

  /// Types whose deletion waits for this to complete.
  final holds = <DeleteBrowsingDataType, Completer<void>>{};

  @override
  Future<void> deleteDataType(
    DeleteBrowsingDataType type, {
    bool previousSessionTabsOnly = false,
  }) async {
    deletions.add((
      type: type,
      previousSessionTabsOnly: previousSessionTabsOnly,
    ));
    await holds[type]?.future;
    if (failOnce.remove(type)) {
      throw Exception('simulated native failure');
    }
  }
}

typedef _Harness = ({
  StartupBrowsingDataCleanup cleanup,
  List<_Deletion> deletions,
  _FakeBrowserDataService browserData,
  _FakeGeneralSettingsRepository settings,
});

_Harness _harness({
  Set<DeleteBrowsingDataType>? autoDelete = const {DeleteBrowsingDataType.tabs},
  Duration waitTimeout = const Duration(seconds: 30),
}) {
  final deletions = <_Deletion>[];
  final browserData = _FakeBrowserDataService(deletions);
  final settings = _FakeGeneralSettingsRepository(
    GeneralSettings.withDefaults(autoDeleteBrowsingData: autoDelete),
  );

  final container = ProviderContainer(
    overrides: [
      generalSettingsRepositoryProvider.overrideWith(() => settings),
      browserDataServiceProvider.overrideWith(() => browserData),
      startupBrowsingDataCleanupProvider.overrideWith(
        () => StartupBrowsingDataCleanup(waitTimeout: waitTimeout),
      ),
    ],
  );
  addTearDown(container.dispose);

  return (
    cleanup: container.read(startupBrowsingDataCleanupProvider.notifier),
    deletions: deletions,
    browserData: browserData,
    settings: settings,
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
}
