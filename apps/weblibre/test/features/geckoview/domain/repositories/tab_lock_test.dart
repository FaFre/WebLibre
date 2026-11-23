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

import 'package:drift/drift.dart' show SingleSelectable, Value;
import 'package:drift/native.dart';
import 'package:fast_equatable/fast_equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod/experimental/persist.dart';
import 'package:weblibre/data/database/functions/lexo_rank_functions.dart';
import 'package:weblibre/data/database/functions/url_functions.dart';
import 'package:weblibre/features/geckoview/domain/entities/states/tab.dart';
import 'package:weblibre/features/geckoview/domain/entities/tab_close_result.dart';
import 'package:weblibre/features/geckoview/domain/entities/tab_lock.dart';
import 'package:weblibre/features/geckoview/domain/providers.dart';
import 'package:weblibre/features/geckoview/domain/providers/restore_complete.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_list.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_state.dart';
import 'package:weblibre/features/geckoview/domain/providers/unlock_incomplete_tabs.dart';
import 'package:weblibre/features/geckoview/domain/repositories/tab.dart';
import 'package:weblibre/features/geckoview/domain/repositories/tab/container_deletion.dart';
import 'package:weblibre/features/geckoview/domain/repositories/tab/isolation_context_cleanup.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/services/browser_data.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/database/daos/tab.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/database/database.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/entities/tab_mode.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/entities/tab_source.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/models/container_data.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/providers.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/entities/container_freeze.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/providers/container_freeze.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/providers/selected_container.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/repositories/container.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/services/container_membership_gate.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/services/storage_owners.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';
import 'package:weblibre/features/user/data/models/proxy_routing_settings.dart';
import 'package:weblibre/features/user/data/providers.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/features/user/domain/repositories/proxy_routing_settings.dart';

import '../../fake_tab_lifecycle_service.dart';

// Every API of gecko.g.dart shares one codec; this one is exported.
const _codec = GeckoTrackingProtectionApi.pigeonChannelCodec;
const _prefix = 'dev.flutter.pigeon.flutter_mozilla_components';

List<Object?> _ok([Object? value]) => <Object?>[value];
List<Object?> _error(String message) => <Object?>['error', message, null];

/// The native side of the tab locks and the tab store, answering the Pigeon
/// channels the close and lock paths use.
class _FakeNative {
  final open = <String>{};
  final private = <String>{};
  final locked = <String>{};
  String? selected;

  /// The session context each tab runs in, for the tabs that run in one.
  final contextOf = <String, String>{};

  /// The session context of each custom tab or web app window.
  final customTabContextOf = <String, String>{};

  /// Every id native was asked to remove, in order.
  final removalRequests = <String>[];

  /// Native refuses to remove these for some other reason than a lock.
  final refuseRemoval = <String>{};

  /// The tabs the pending undo close would reopen: those of the last removal,
  /// as `UndoMiddleware` keeps them.
  final undoHistory = <String>[];

  /// Called once, right after the next answer to `pendingUndoTabs`: a close
  /// that comes between an undo's check and the undo itself.
  void Function()? afterPendingUndoRead;

  /// Called with the ids of each removal request before it is carried out.
  void Function(List<String> ids)? onRemove;

  bool failLockWrites = false;
  bool throwOnUnlock = false;
  bool throwOnReconcile = false;
  bool throwOnLockRead = false;
  int reconcileCalls = 0;

  final _channels = <String>[];

  void _handle(String method, FutureOr<Object?> Function(List<Object?>) on) {
    final name = '$_prefix.$method';
    _channels.add(name);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockDecodedMessageHandler<Object?>(
          BasicMessageChannel<Object?>(name, _codec),
          (message) async => await on((message as List<Object?>?) ?? const []),
        );
  }

  TabRemovalResult _remove(List<String> ids) {
    onRemove?.call(ids);
    final present = [
      for (final id in ids)
        if (open.contains(id) || private.contains(id)) id,
    ];
    removalRequests.addAll(ids);
    final removed = [
      for (final id in present)
        if (!locked.contains(id) && !refuseRemoval.contains(id)) id,
    ];
    open.removeAll(removed);
    private.removeAll(removed);
    if (removed.isNotEmpty) {
      undoHistory
        ..clear()
        ..addAll(removed);
    }
    return TabRemovalResult(
      removedTabIds: removed,
      lockedTabIds: [
        for (final id in present)
          if (locked.contains(id)) id,
      ],
      missingTabIds: [
        for (final id in ids)
          if (!present.contains(id)) id,
      ],
    );
  }

  void install() {
    _handle('GeckoTabLockApi.setTabLocked', (args) {
      final tabId = args[0]! as String;
      final lock = args[1]! as bool;
      final previouslyLocked = locked.contains(tabId);
      if (!lock) {
        if (throwOnUnlock) return _error('unlock failed');
        locked.remove(tabId);
        return _ok(TabLockChange(previouslyLocked: previouslyLocked));
      }
      final TabLockRejection? rejection;
      if (private.contains(tabId)) {
        rejection = TabLockRejection.privateTab;
      } else if (!open.contains(tabId)) {
        rejection = TabLockRejection.unknownTab;
      } else if (failLockWrites) {
        rejection = TabLockRejection.notPersisted;
      } else {
        rejection = null;
        locked.add(tabId);
      }
      return _ok(
        TabLockChange(previouslyLocked: previouslyLocked, rejection: rejection),
      );
    });
    _handle('GeckoTabLockApi.lockedTabIdsAmong', (args) {
      if (throwOnLockRead) return _error('lock read failed');
      final ids = (args[0]! as List<Object?>).cast<String>();
      return _ok([
        for (final id in ids)
          if (locked.contains(id)) id,
      ]);
    });
    _handle('GeckoTabLockApi.reconcileLockedTabs', (args) {
      reconcileCalls++;
      if (throwOnReconcile) return _error('reconcile failed');
      final ids = (args[0]! as List<Object?>).cast<String>();
      final next = {
        for (final id in ids)
          if (open.contains(id)) id,
      };
      final pruned = locked.difference(next).toList();
      locked
        ..clear()
        ..addAll(next);
      return _ok(pruned);
    });
    _handle('GeckoTabsApi.getSelectedTabId', (_) => _ok(selected));
    _handle('GeckoTabsApi.getTabIdsInContext', (args) {
      final contextId = args[0]! as String;
      return _ok([
        for (final id in {...open, ...private})
          if (contextOf[id] == contextId) id,
      ]);
    });
    _handle('GeckoTabsApi.getCustomTabIdsInContexts', (args) {
      final contextIds = (args[0]! as List<Object?>).cast<String>();
      return _ok([
        for (final MapEntry(key: id, value: contextId)
            in customTabContextOf.entries)
          if (contextIds.contains(contextId)) id,
      ]);
    });
    _handle(
      'GeckoTabsApi.removeTab',
      (args) => _ok(_remove([args[0]! as String])),
    );
    _handle(
      'GeckoTabsApi.removeTabs',
      (args) => _ok(_remove((args[0]! as List<Object?>).cast<String>())),
    );
    _handle('GeckoRecentlyClosedTabsApi.keepOffRecentlyClosed', (_) => _ok());
    // Answers once the tabs are back in the store; the app hears of them
    // through its tab list.
    _handle('GeckoTabsApi.pendingUndoTabs', (_) {
      final answer = [
        for (final id in undoHistory)
          PendingUndoTab(tabId: id, contextId: contextOf[id]),
      ];
      final after = afterPendingUndoRead;
      afterPendingUndoRead = null;
      after?.call();
      return _ok(answer);
    });
    _handle('GeckoTabsApi.undo', (args) {
      final expected = (args[0]! as List<Object?>).cast<String>().toSet();
      final pending = undoHistory.toSet();
      if (expected.length != pending.length || !expected.containsAll(pending)) {
        return _ok(<String>[]);
      }
      final restored = [...undoHistory];
      open.addAll(undoHistory);
      undoHistory.clear();
      return _ok(restored);
    });
    _handle('GeckoTabsApi.getTabIds', (_) => _ok([...open, ...private]));
    _handle('GeckoTabsApi.discardUndoOf', (args) {
      final tabIds = (args[0]! as List<Object?>).cast<String>();
      final contextIds = (args[1]! as List<Object?>).cast<String>();
      final discards = undoHistory.any(
        (id) => tabIds.contains(id) || contextIds.contains(contextOf[id]),
      );
      if (discards) undoHistory.clear();
      return _ok(discards);
    });
  }

  void uninstall() {
    for (final name in _channels) {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockDecodedMessageHandler<Object?>(
            BasicMessageChannel<Object?>(name, _codec),
            null,
          );
    }
  }
}

/// The routes an isolation group's cleanup drops, without the settings
/// database.
class _ProxyRoutes extends ProxyRoutingSettingsRepository {
  final cleared = <String>[];

  @override
  Stream<ProxyRoutingSettings> build() =>
      Stream.value(ProxyRoutingSettings.withDefaults());

  @override
  Future<void> clearIsolationContextRoute(String isolationContextId) async {
    cleared.add(isolationContextId);
  }
}

/// The tab database, with reads that fail on demand.
class _TestTabDatabase extends TabDatabase {
  _TestTabDatabase(super.e);

  late final _faultyTabDao = _FaultyTabDao(this);

  @override
  _FaultyTabDao get tabDao => _faultyTabDao;
}

class _FaultyTabDao extends TabDao {
  _FaultyTabDao(super.db);

  /// [lockedTabIdsAmong] fails.
  bool failLockRead = false;

  /// [tabsInIsolationGroup] fails for these contexts.
  final failGroupCountOf = <String>{};

  @override
  Future<Set<String>> lockedTabIdsAmong(Iterable<String> tabIds) {
    if (failLockRead) return Future.error(StateError('lock read failed'));
    return super.lockedTabIdsAmong(tabIds);
  }

  @override
  SingleSelectable<int> tabsInIsolationGroup(String contextId) {
    if (failGroupCountOf.contains(contextId)) {
      throw StateError('group count failed');
    }
    return super.tabsInIsolationGroup(contextId);
  }
}

class _TestTabRepository extends TabRepository {
  @override
  void build() {}
}

class _NoTabList extends TabList {
  @override
  EquatableValue<List<String>> build() => EquatableValue(const []);
}

class _NoTabStates extends TabStates {
  @override
  Map<String, TabState> build() => const {};
}

class _TabStatesOf extends TabStates {
  _TabStatesOf(this.states);

  final Map<String, TabState> states;

  @override
  Map<String, TabState> build() => states;
}

/// Records which storages were cleared instead of asking the engine.
class _RecordingBrowserData extends BrowserDataService {
  _RecordingBrowserData(this.cleared, this.clearedContexts);

  final List<List<String>> cleared;

  /// The contexts [clearDataForContext] cleared, in order.
  final List<String> clearedContexts;

  @override
  Future<void> clearContainerData(List<String> contextIds) async =>
      cleared.add(contextIds);

  @override
  Future<void> clearDataForContext(String contextId) async =>
      clearedContexts.add(contextId);
}

/// Settings that take every update without a database.
class _Settings extends GeneralSettingsRepository {
  var _settings = GeneralSettings.withDefaults();

  @override
  Stream<GeneralSettings> build() => Stream.value(_settings);

  @override
  Future<GeneralSettings> fetchSettings() => Future.value(_settings);

  @override
  Future<void> updateSettings(UpdateGeneralSettingsFunc updateWithCurrent) {
    _settings = updateWithCurrent(_settings);
    return Future.value();
  }
}

class _SelectedContainerOf extends SelectedContainer {
  _SelectedContainerOf(this.id);

  final String? id;

  @override
  String? build() => id;
}

class _RestoreComplete extends BrowserRestoreComplete {
  _RestoreComplete(this.complete);

  final bool complete;

  @override
  bool build() => complete;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _TestTabDatabase db;
  late _FakeNative native;
  late ProviderContainer container;
  late Storage<String, String> storage;
  late FakeTabLifecycleService lifecycle;
  late List<List<String>> clearedStorages;
  late List<String> clearedContexts;

  ProviderContainer makeContainer({
    bool restoreComplete = true,
    Map<String, TabState>? states,
    String? selectedContainer,
  }) {
    final created = ProviderContainer(
      overrides: [
        if (selectedContainer != null)
          selectedContainerProvider.overrideWith(
            () => _SelectedContainerOf(selectedContainer),
          ),
        tabDatabaseProvider.overrideWith((ref) => db),
        tabRepositoryProvider.overrideWith(_TestTabRepository.new),
        tabStatesProvider.overrideWith(
          states == null ? _NoTabStates.new : () => _TabStatesOf(states),
        ),
        tabListProvider.overrideWith(_NoTabList.new),
        browserRestoreCompleteProvider.overrideWith(
          () => _RestoreComplete(restoreComplete),
        ),
        generalSettingsWithDefaultsProvider.overrideWith(
          (ref) => GeneralSettings.withDefaults(),
        ),
        geckoTabLifecycleServiceProvider.overrideWithValue(lifecycle),
        proxyRoutingSettingsRepositoryProvider.overrideWith(_ProxyRoutes.new),
        browserDataServiceProvider.overrideWith(
          () => _RecordingBrowserData(clearedStorages, clearedContexts),
        ),
        generalSettingsRepositoryProvider.overrideWith(_Settings.new),
        riverpodDatabaseStorageProvider.overrideWith((ref) => storage),
      ],
    );
    addTearDown(created.dispose);
    return created;
  }

  setUp(() {
    storage = Storage.inMemory();
    clearedStorages = [];
    clearedContexts = [];
    db = _TestTabDatabase(
      NativeDatabase.memory(
        setup: (database) {
          registerLexorankFunctions(database);
          registerUrlFunctions(database);
        },
      ),
    );
    addTearDown(db.close);
    native = _FakeNative()..install();
    addTearDown(native.uninstall);
    lifecycle = FakeTabLifecycleService();
    container = makeContainer();
  });

  TabRepository repository() => container.read(tabRepositoryProvider.notifier);

  ContainerDeletion deletion() =>
      container.read(containerDeletionProvider.notifier);

  IsolationContextCleanup isolationCleanup() =>
      container.read(isolationContextCleanupProvider.notifier);

  /// A tab open natively with a row.
  Future<void> addTab(String id, {String? containerId, TabMode? mode}) async {
    await db.tabDao.insertTab(
      id,
      source: TabSource.manual,
      parentId: const Value(null),
      containerId: Value(containerId),
      tabMode: mode == null ? const Value.absent() : Value(mode),
    );
    if (mode is PrivateTabMode) {
      native.private.add(id);
    } else {
      native.open.add(id);
    }
  }

  Future<void> addContainer(String id, {String? contextId}) =>
      db.containerDao.addContainer(
        ContainerData(
          id: id,
          name: id,
          color: Colors.blue,
          orderKey: 'a',
          metadata: ContainerMetadata.withDefaults(
            contextualIdentity: contextId,
          ),
        ),
      );

  Future<Set<String>> dbLocked() async =>
      (await db.tabDao.getLockedTabIds().get()).toSet();

  Set<String> unlockIncomplete() =>
      container.read(unlockIncompleteTabsProvider).value;

  group('locking', () {
    test('goes native first, then the database', () async {
      await addTab('a');

      expect(
        await repository().setTabLocked('a', locked: true),
        TabLockOutcome.applied,
      );
      expect(native.locked, {'a'});
      expect(await dbLocked(), {'a'});
    });

    test('a private tab is refused before native is asked', () async {
      await addTab('p', mode: TabMode.private);

      expect(
        await repository().setTabLocked('p', locked: true),
        TabLockOutcome.privateTab,
      );
      expect(native.locked, isEmpty);
      expect(await dbLocked(), isEmpty);
    });

    test('a lock native could not persist changes nothing, and is '
        'reconciled in case native kept it', () async {
      await addTab('a');
      native
        ..failLockWrites = true
        // Native kept it: taking it back failed as well.
        ..locked.add('a');

      expect(
        await repository().setTabLocked('a', locked: true),
        TabLockOutcome.notPersisted,
      );
      expect(await dbLocked(), isEmpty);
      expect(native.reconcileCalls, 1);
      expect(native.locked, isEmpty);
    });

    test(
      'a lock the database refuses (no row) is taken back natively',
      () async {
        // Open natively, but its row is not written yet.
        native.open.add('new');

        expect(
          await repository().setTabLocked('new', locked: true),
          TabLockOutcome.unavailable,
        );
        expect(native.locked, isEmpty);
      },
    );
  });

  group('unlocking', () {
    test('goes to the database first, then native', () async {
      await addTab('a');
      await repository().setTabLocked('a', locked: true);

      expect(
        await repository().setTabLocked('a', locked: false),
        TabLockOutcome.applied,
      );
      expect(native.locked, isEmpty);
      expect(await dbLocked(), isEmpty);
    });

    test('when native refuses, a reconciliation finishes it', () async {
      await addTab('a');
      await repository().setTabLocked('a', locked: true);
      native.throwOnUnlock = true;

      expect(
        await repository().setTabLocked('a', locked: false),
        TabLockOutcome.applied,
      );
      expect(native.reconcileCalls, 1);
      expect(native.locked, isEmpty);
      expect(unlockIncomplete(), isEmpty);
    });

    test('when native and the reconciliation both fail, the tab stays '
        'effectively locked and refuses to close', () async {
      await addTab('a');
      await addTab('b');
      native.selected = 'b';
      await repository().setTabLocked('a', locked: true);
      native
        ..throwOnUnlock = true
        ..throwOnReconcile = true;

      expect(
        await repository().setTabLocked('a', locked: false),
        TabLockOutcome.unlockIncomplete,
      );
      expect(await dbLocked(), isEmpty);
      expect(native.locked, {'a'});
      expect(unlockIncomplete(), {'a'});
      expect(await repository().isTabLocked('a'), isTrue);

      // The close preflight sees native's lock: nothing is removed.
      final result = await repository().closeTab('a');
      expect(result.removedTabIds, isEmpty);
      expect(result.skippedLockedTabIds, ['a']);
      expect(native.removalRequests, isEmpty);

      // Once native accepts again, the retry finishes the unlock.
      native.throwOnReconcile = false;
      expect(await repository().retryLockReconciliation(), isTrue);
      expect(native.locked, isEmpty);
      expect(unlockIncomplete(), isEmpty);
    });
  });

  group('closing', () {
    test('a locked tab is skipped before any side effect', () async {
      await addTab('locked');
      await addTab('other');
      native.selected = 'other';
      await repository().setTabLocked('locked', locked: true);

      final result = await repository().closeTab('locked');

      expect(result, CloseResult(skippedLockedTabIds: ['locked']));
      expect(result.closedAny, isFalse);
      expect(native.removalRequests, isEmpty);
      // No tombstone either, which would close it again after a restore.
      final restoredClosed = await db.tabDao.getStartupRestoredClosedTabIds([
        'locked',
      ], sessionStartedAt: DateTime.now().add(const Duration(minutes: 1)));
      expect(restoredClosed, isEmpty);
    });

    test('a bulk close removes the rest and reports exact counts', () async {
      for (final id in ['a', 'b', 'c']) {
        await addTab(id);
      }
      native.selected = 'c';
      await repository().setTabLocked('b', locked: true);

      final result = await repository().closeTabs(['a', 'b', 'gone']);

      expect(result.removedTabIds, ['a']);
      expect(result.skippedLockedTabIds, ['b']);
      expect(result.missingTabIds, ['gone']);
      expect(native.removalRequests, ['a', 'gone']);
    });

    test(
      'a lock only native holds is honoured, and reconciled after',
      () async {
        await addTab('a');
        await addTab('b');
        native
          ..selected = 'b'
          ..locked.add('a');

        final result = await repository().closeTab('a');

        expect(result.skippedLockedTabIds, ['a']);
        // The database never acknowledged it: the reconciliation drops it.
        expect(native.reconcileCalls, 1);
        expect(native.locked, isEmpty);
      },
    );

    test("a close does nothing while native's locks cannot be read", () async {
      await addTab('a');
      await addTab('b');
      native
        ..selected = 'a'
        ..throwOnLockRead = true;

      // Said, not thrown: a close from the UI or from the tab list sync
      // goes on without it.
      expect(
        await repository().closeTab('a'),
        CloseResult(locksUnavailable: true),
      );
      expect(native.removalRequests, isEmpty);
      final restoredClosed = await db.tabDao.getStartupRestoredClosedTabIds([
        'a',
      ], sessionStartedAt: DateTime.now().add(const Duration(minutes: 1)));
      expect(restoredClosed, isEmpty, reason: 'no tombstone was written');
    });

    test('a replacement whose close could not read the locks opens nothing, '
        'and says that rather than that the tab is locked', () async {
      await addTab('a');
      await addTab('b');
      native
        ..selected = 'a'
        ..throwOnLockRead = true;
      var opened = false;

      final result = await repository().replaceTabClosingFirst('a', () async {
        opened = true;
        return 'new';
      });

      expect(result, OriginalKept(locksUnavailable: true));
      expect(opened, isFalse);
    });

    test("a close does nothing while the database's locks cannot be read, "
        'and still reconciles', () async {
      await addTab('a');
      await addTab('b');
      native.selected = 'a';
      db.tabDao.failLockRead = true;

      expect(
        await repository().closeTab('a'),
        CloseResult(locksUnavailable: true),
      );
      expect(native.removalRequests, isEmpty);
      expect(native.reconcileCalls, 1);
    });

    test("private tabs close while native's locks cannot be read: they "
        'cannot be locked', () async {
      container = makeContainer(
        states: {
          'p': TabState.$default('p').copyWith(tabMode: TabMode.private),
        },
      );
      await addTab('p', mode: TabMode.private);
      await addTab('a');
      native
        ..selected = 'a'
        ..throwOnLockRead = true;

      expect(
        await repository().closeTab('p'),
        CloseResult(removedTabIds: ['p']),
      );
      expect(native.private, isEmpty);
    });

    test(
      'no reconciliation runs before the session restore is complete',
      () async {
        container = makeContainer(restoreComplete: false);
        await addTab('a');
        await addTab('b');
        native
          ..selected = 'b'
          ..locked.add('a');

        await repository().closeTab('a');

        expect(native.reconcileCalls, 0);
        expect(native.locked, {'a'});
      },
    );
  });

  group('replacing a tab, closing first', () {
    test('opens and records nothing when the original is locked', () async {
      await addTab('a');
      await addTab('b');
      native.selected = 'b';
      await repository().setTabLocked('a', locked: true);
      var opened = false;

      final result = await repository().replaceTabClosingFirst('a', () async {
        opened = true;
        return 'a2';
      });

      expect(result, OriginalKept());
      expect(result.replacementTabId, isNull);
      expect(opened, isFalse);
    });

    test('replaces an unlocked original', () async {
      await addTab('a');
      await addTab('b');
      native.selected = 'b';

      final result = await repository().replaceTabClosingFirst(
        'a',
        () async => 'a2',
      );

      expect(result, TabReplaced('a2'));
    });
  });

  group('deleting a container', () {
    Future<ContainerDeletionResult> deleteWithSiteData(String id) => container
        .read(containerRepositoryProvider.notifier)
        .deleteContainer(id, deleteSiteData: true);

    test('with its site data has native delete its own storage when only an '
        'isolation group of it has a record', () async {
      await addContainer('work', contextId: 'ctx-work');
      lifecycle
        ..restrict('work', ['iso1_gone'], phase: ContextFreezePhase.releasing)
        // Its release fails again: that is no reason to keep the rest.
        ..completeDeletionFails = true;

      expect(
        await deleteWithSiteData('work'),
        ContainerDeleted(siteDataCleanupPending: true),
      );
      // By the release procedure, which removes its push subscriptions too
      // and retries at every start, not by a clear nobody confirms.
      expect(lifecycle.calls, contains('beginDeletion work [ctx-work]'));
      expect(clearedStorages, isEmpty);
      expect(
        (await lifecycle.lifecycleSnapshot()).contexts.map(
          (context) => (context.contextId, context.phase),
        ),
        contains(('ctx-work', ContextFreezePhase.releasing)),
      );
    });

    test('with its site data has native delete the storage of a container '
        'that was never frozen, written down before its row goes', () async {
      await addContainer('work', contextId: 'ctx-work');
      // Before anything is closed or deleted: a process that ends after the
      // row delete still has it.
      Map<String, String>? writtenDown;
      lifecycle.onBeginDeletion = () =>
          writtenDown = {...lifecycle.dataDeletions};

      expect(await deleteWithSiteData('work'), ContainerDeleted());
      expect(writtenDown, {'ctx-work': 'work'});
      expect(lifecycle.calls, [
        'beginDeletion work [ctx-work]',
        'completeDeletion work',
      ]);
      expect(lifecycle.dataDeletions, isEmpty);
      expect(clearedStorages, isEmpty);
    });

    test('keeps a container never frozen when the site data to delete with '
        'it could not be written down', () async {
      await addContainer('work', contextId: 'ctx-work');
      await addTab('a', containerId: 'work');
      await addTab('outside');
      native.selected = 'outside';
      lifecycle.beginDeletionFails = true;

      expect(
        await deleteWithSiteData('work'),
        const ContainerDeletionNotPersisted(),
      );
      // Deleted without it, nothing would be left to retry the cleanup.
      expect(native.removalRequests, isEmpty);
      expect(
        await db.containerDao.getContainerData('work').getSingleOrNull(),
        isNotNull,
      );
      expect(lifecycle.calls, [
        'beginDeletion work [ctx-work]',
        // An earlier write of it may still be in native's memory.
        'cancelDeletion work',
      ]);
    });

    test("leaves a frozen container's own storage to native's release, "
        'which deletes its data', () async {
      await addContainer('work', contextId: 'ctx-work');
      lifecycle.restrict('work', ['ctx-work']);

      expect(await deleteWithSiteData('work'), isA<ContainerDeleted>());
      expect(clearedStorages, isEmpty);
      expect(lifecycle.calls, contains('completeDeletion work'));
    });

    test('of a container frozen since the user kept its site data closes '
        'nothing and asks again: native would delete that data', () async {
      await addContainer('work', contextId: 'ctx-work');
      await addTab('a', containerId: 'work');
      await addTab('outside');
      native.selected = 'outside';
      // Frozen after the dialog read it as not frozen, or before its
      // snapshot had loaded.
      lifecycle.restrict('work', ['ctx-work']);

      expect(
        await container
            .read(containerRepositoryProvider.notifier)
            .deleteContainer('work'),
        const ContainerDeletionNeedsSiteData(),
      );
      expect(native.removalRequests, isEmpty);
      expect(lifecycle.calls, isEmpty);
      expect(
        await db.containerDao.getContainerData('work').getSingleOrNull(),
        isNotNull,
      );

      expect(await deleteWithSiteData('work'), isA<ContainerDeleted>());
      expect(lifecycle.calls, contains('completeDeletion work'));
    });

    test(
      'is refused, closing nothing, while one of its tabs is locked',
      () async {
        await addContainer('work');
        await addTab('locked', containerId: 'work');
        await addTab('other', containerId: 'work');
        await addTab('outside');
        native.selected = 'outside';
        await repository().setTabLocked('locked', locked: true);

        final result = await deletion().delete('work');

        expect(result, ContainerDeletionBlockedByLockedTabs(['locked']));
        expect(native.removalRequests, isEmpty);
        expect(
          await db.containerDao.getContainerData('work').getSingleOrNull(),
          isNotNull,
        );
      },
    );

    test(
      'is refused for a lock only native holds after a failed unlock',
      () async {
        await addContainer('work');
        await addTab('a', containerId: 'work');
        await addTab('outside');
        native.selected = 'outside';
        await repository().setTabLocked('a', locked: true);
        native
          ..throwOnUnlock = true
          ..throwOnReconcile = true;
        await repository().setTabLocked('a', locked: false);

        final result = await deletion().delete('work');

        expect(result, isA<ContainerDeletionBlockedByLockedTabs>());
        expect(native.removalRequests, isEmpty);
      },
    );

    test(
      'is refused, closing nothing, while a web app runs in its storage',
      () async {
        await addContainer('work', contextId: 'ctx-work');
        await addTab('a', containerId: 'work');
        await addTab('outside');
        native
          ..selected = 'outside'
          ..contextOf['a'] = 'ctx-work'
          ..customTabContextOf['pwa'] = 'ctx-work'
          ..customTabContextOf['elsewhere'] = 'ctx-other';

        final result = await deletion().delete('work');

        expect(result, const ContainerDeletionBlockedByWebApps());
        expect(native.removalRequests, isEmpty);
        expect(
          await db.containerDao.getContainerData('work').getSingleOrNull(),
          isNotNull,
        );

        // Closed, the deletion goes ahead.
        native.customTabContextOf.remove('pwa');
        expect(await deletion().delete('work'), isA<ContainerDeleted>());
      },
    );

    test('keeps the row when a tab survives its close', () async {
      await addContainer('work');
      await addTab('stuck', containerId: 'work');
      await addTab('outside');
      native
        ..selected = 'outside'
        ..refuseRemoval.add('stuck');

      final result = await deletion().delete('work');

      expect(result, ContainerDeletionIncomplete(['stuck']));
      expect(
        await db.containerDao.getContainerData('work').getSingleOrNull(),
        isNotNull,
      );
      expect(await db.tabDao.getExistingTabIds(['stuck']).get(), ['stuck']);
    });

    test('closes its tabs and deletes it otherwise', () async {
      await addContainer('work');
      await addTab('a', containerId: 'work');
      await addTab('outside');
      native.selected = 'outside';

      final result = await deletion().delete('work');

      expect(result, ContainerDeleted());
      expect(native.removalRequests, ['a']);
      expect(
        await db.containerDao.getContainerData('work').getSingleOrNull(),
        isNull,
      );
    });

    test('of a frozen container is recorded before anything is closed, and '
        'its contexts are released after the row went', () async {
      await addContainer('work', contextId: 'ctx-work');
      await addTab('a', containerId: 'work');
      await addTab('outside');
      native.selected = 'outside';
      lifecycle.restrict('work', ['ctx-work']);

      final result = await deletion().delete('work', deleteSiteData: true);

      expect(result, ContainerDeleted());
      expect(lifecycle.calls, ['beginDeletion work', 'completeDeletion work']);
      expect(native.removalRequests, ['a']);
      expect(
        await db.containerDao.getContainerData('work').getSingleOrNull(),
        isNull,
      );
    });

    test('of a frozen container is refused while a web app runs in storage '
        'it keeps for an isolation group without tabs', () async {
      await addContainer('work', contextId: 'ctx-work');
      await addTab('a', containerId: 'work');
      await addTab('outside');
      native
        ..selected = 'outside'
        ..customTabContextOf['pwa'] = 'iso1_gone';
      lifecycle.restrict('work', ['ctx-work', 'iso1_gone']);

      expect(
        await deletion().delete('work', deleteSiteData: true),
        const ContainerDeletionBlockedByWebApps(),
      );
      expect(native.removalRequests, isEmpty);
      expect(lifecycle.calls, isEmpty);
    });

    test('an isolation group of a frozen container keeps its restriction '
        'when its last tab closes', () async {
      await addContainer('work', contextId: 'ctx-work');
      await addTab(
        'iso',
        containerId: 'work',
        mode: TabMode.isolated('iso1_g'),
      );
      await addTab('outside');
      native.selected = 'outside';
      lifecycle.restrict('work', ['ctx-work', 'iso1_g']);

      await repository().closeTab('iso');
      await repository().handleTabListChange(null, EquatableValue(['outside']));

      // An undo close would bring the tab back into it: it stays held.
      expect(lifecycle.calls, isNot(contains('release [iso1_g]')));
      expect(
        (await lifecycle.lifecycleSnapshot()).contexts.map((c) => c.contextId),
        contains('iso1_g'),
      );
    });

    test('of a frozen container closes nothing when its deletion cannot be '
        'recorded', () async {
      await addContainer('work', contextId: 'ctx-work');
      await addTab('a', containerId: 'work');
      await addTab('outside');
      native.selected = 'outside';
      lifecycle
        ..restrict('work', ['ctx-work'])
        ..beginDeletionFails = true;

      final result = await deletion().delete('work', deleteSiteData: true);

      expect(result, const ContainerDeletionNotPersisted());
      expect(native.removalRequests, isEmpty);
      expect(
        await db.containerDao.getContainerData('work').getSingleOrNull(),
        isNotNull,
      );
    });

    test(
      'of a frozen container that keeps its row puts its phase back',
      () async {
        await addContainer('work', contextId: 'ctx-work');
        await addTab('stuck', containerId: 'work');
        await addTab('outside');
        native
          ..selected = 'outside'
          ..refuseRemoval.add('stuck');
        lifecycle.restrict('work', ['ctx-work']);

        final result = await deletion().delete('work', deleteSiteData: true);

        expect(result, ContainerDeletionIncomplete(['stuck']));
        expect(lifecycle.calls, ['beginDeletion work', 'cancelDeletion work']);
        expect(
          (await lifecycle.lifecycleSnapshot()).contexts.single.phase,
          ContextFreezePhase.frozen,
        );
      },
    );

    test(
      'of a frozen container whose close throws puts its phase back',
      () async {
        await addContainer('work', contextId: 'ctx-work');
        await addTab('a', containerId: 'work');
        await addTab('outside');
        native.selected = 'outside';
        lifecycle
          ..restrict('work', ['ctx-work'])
          // Native's locks become unreadable once the deletion is recorded.
          ..onBeginDeletion = () => native.throwOnLockRead = true;

        final result = await deletion().delete('work', deleteSiteData: true);

        expect(result, ContainerDeletionIncomplete(const []));
        expect(lifecycle.calls, ['beginDeletion work', 'cancelDeletion work']);
        expect(
          (await lifecycle.lifecycleSnapshot()).contexts.single.phase,
          ContextFreezePhase.frozen,
        );
      },
    );

    test('is refused while the frozen containers are being restored', () async {
      await addContainer('work', contextId: 'ctx-work');
      await addTab('a', containerId: 'work');
      await addTab('outside');
      native.selected = 'outside';
      lifecycle.recovery = true;

      expect(
        await deletion().delete('work'),
        const ContainerDeletionRecoveryPending(),
      );
      expect(native.removalRequests, isEmpty);
      expect(lifecycle.calls, isEmpty);
    });

    test('of a frozen container is refused while it holds an isolation group '
        'a tab of another container uses, and goes through once '
        'resumed', () async {
      // After a damaged registry, the group of two containers is restored
      // under one of them.
      await addContainer('work', contextId: 'ctx-work');
      await addContainer('home', contextId: 'ctx-home');
      await addTab('w', containerId: 'work', mode: TabMode.isolated('iso1_s'));
      await addTab('h', containerId: 'home', mode: TabMode.isolated('iso1_s'));
      await addTab('outside');
      native.selected = 'outside';
      lifecycle.restrict('work', ['ctx-work', 'iso1_s']);

      // Native would delete the group's data under home's tab.
      expect(
        await deletion().delete('work', deleteSiteData: true),
        const ContainerDeletionSharedStorage(),
      );
      expect(native.removalRequests, isEmpty);
      expect(lifecycle.calls, isEmpty);

      // Resumed, it holds nothing, and the group stays home's.
      await lifecycle.resumeContexts('work');
      await container.read(containerMembershipGateProvider.notifier).refresh();

      expect(await deletion().delete('work'), ContainerDeleted());
      expect(native.removalRequests, ['w']);
      expect(native.open, containsAll(['h', 'outside']));
    });

    test('is refused while the freeze registry cannot be read', () async {
      await addContainer('work', contextId: 'ctx-work');
      await addTab('a', containerId: 'work');
      await addTab('outside');
      native
        ..selected = 'outside'
        ..customTabContextOf['pwa'] = 'iso1_gone';
      lifecycle
        ..restrict('work', ['ctx-work', 'iso1_gone'])
        ..snapshotFails = true;

      // Which contexts it holds is not known: the web app in one of them
      // would be missed.
      expect(
        await deletion().delete('work'),
        const ContainerDeletionFreezeStateUnknown(),
      );
      expect(native.removalRequests, isEmpty);
      expect(lifecycle.calls, isEmpty);
    });

    test('finishes an unlock left unfinished, as every close does', () async {
      await addContainer('work');
      await addTab('a', containerId: 'work');
      await addTab('x');
      native.selected = 'x';
      await repository().setTabLocked('x', locked: true);
      native
        ..throwOnUnlock = true
        ..throwOnReconcile = true;
      await repository().setTabLocked('x', locked: false);
      expect(unlockIncomplete(), {'x'});
      native
        ..throwOnUnlock = false
        ..throwOnReconcile = false;

      expect(await deletion().delete('work'), ContainerDeleted());
      expect(native.locked, isEmpty);
      expect(unlockIncomplete(), isEmpty);
    });

    test('an isolation group of a frozen container being deleted is left to '
        'the deletion', () async {
      await addContainer('work', contextId: 'ctx-work');
      await addTab(
        'iso',
        containerId: 'work',
        mode: TabMode.isolated('iso1_g'),
      );
      await addTab('outside');
      native.selected = 'outside';
      lifecycle.restrict('work', [
        'ctx-work',
        'iso1_g',
      ], phase: ContextFreezePhase.deletionPending);
      final routes =
          container.read(proxyRoutingSettingsRepositoryProvider.notifier)
              as _ProxyRoutes;

      await repository().closeTab('iso');
      await repository().handleTabListChange(null, EquatableValue(['outside']));
      expect(lifecycle.calls, isNot(contains('release [iso1_g]')));
      expect(routes.cleared, isEmpty);

      // The deletion stopped: the group stays held with the container, its
      // data kept.
      await lifecycle.cancelContextDeletion('work');
      await container.read(containerMembershipGateProvider.notifier).refresh();
      await isolationCleanup().drain();

      expect(lifecycle.calls, isNot(contains('release [iso1_g]')));
      expect(routes.cleared, isEmpty);
      expect(
        (await lifecycle.lifecycleSnapshot()).contexts.map((c) => c.contextId),
        contains('iso1_g'),
      );
    });

    test('an isolation group a web app window still uses keeps its data, '
        'and is cleaned up once the window is gone', () async {
      await addTab('iso', mode: TabMode.isolated('iso1_g'));
      await addTab('outside');
      native
        ..selected = 'outside'
        ..customTabContextOf['pwa'] = 'iso1_g';
      final routes =
          container.read(proxyRoutingSettingsRepositoryProvider.notifier)
              as _ProxyRoutes;

      await repository().closeTab('iso');
      await repository().handleTabListChange(null, EquatableValue(['outside']));
      expect(routes.cleared, isEmpty);

      native.customTabContextOf.remove('pwa');
      await isolationCleanup().drain();

      expect(routes.cleared, ['iso1_g']);
    });

    test('the last containers of an isolation group are forgotten once its '
        'data is deleted', () async {
      await addTab('iso', mode: TabMode.isolated('iso1_g'));
      await addTab('outside');
      native
        ..selected = 'outside'
        ..customTabContextOf['pwa'] = 'iso1_g';
      final owners = container.read(storageOwnersProvider.notifier);

      await repository().closeTab('iso');
      await repository().handleTabListChange(null, EquatableValue(['outside']));
      // Kept for a page its web app window opens.
      expect(await owners.lastContainersOf('iso1_g'), [null]);

      native.customTabContextOf.remove('pwa');
      await isolationCleanup().drain();

      expect(await owners.lastContainersOf('iso1_g'), isNull);
    });

    test('an isolation group native released with its record is not '
        'cleared again, and one without a record is', () async {
      await addTab('kept', mode: TabMode.isolated('iso1_g'));
      await addTab('plain', mode: TabMode.isolated('iso2_g'));
      await addTab('outside');
      native.selected = 'outside';
      // A release left over from an earlier Resume: native deletes its data
      // with an acknowledgment, and lifts it. Cleared again afterwards, a
      // web app opened in it meanwhile would lose its session.
      lifecycle.restrict(null, ['iso1_g'], phase: ContextFreezePhase.releasing);

      await repository().closeTabs(['kept', 'plain']);
      await repository().handleTabListChange(null, EquatableValue(['outside']));

      expect(lifecycle.calls, contains('release [iso1_g]'));
      expect(clearedContexts, ['iso2_g']);
    });

    test('an isolation group a web app window kept from its cleanup is '
        'cleaned up after a restart too', () async {
      await addTab('iso', mode: TabMode.isolated('iso1_g'));
      await addTab('outside');
      native
        ..selected = 'outside'
        ..customTabContextOf['pwa'] = 'iso1_g';
      await repository().closeTab('iso');
      await repository().handleTabListChange(null, EquatableValue(['outside']));
      await pumpEventQueue();

      // The next process: the group has no tab row left, and nothing of the
      // last one's memory.
      container = makeContainer();
      native.customTabContextOf.remove('pwa');
      await isolationCleanup().drain();

      final routes =
          container.read(proxyRoutingSettingsRepositoryProvider.notifier)
              as _ProxyRoutes;
      expect(routes.cleared, ['iso1_g']);
      expect(isolationCleanup().state, isEmpty);
    });

    test('an isolation group whose cleanup fails holds up no other, and is '
        'tried again', () async {
      await addTab('iso1', mode: TabMode.isolated('iso1_g'));
      await addTab('iso2', mode: TabMode.isolated('iso2_g'));
      await addTab('outside');
      native.selected = 'outside';
      db.tabDao.failGroupCountOf.add('iso1_g');
      final routes =
          container.read(proxyRoutingSettingsRepositoryProvider.notifier)
              as _ProxyRoutes;

      await repository().closeTabs(['iso1', 'iso2']);
      await repository().handleTabListChange(null, EquatableValue(['outside']));
      expect(routes.cleared, ['iso2_g']);

      db.tabDao.failGroupCountOf.clear();
      await isolationCleanup().drain();

      expect(routes.cleared, ['iso2_g', 'iso1_g']);
    });

    test('an isolation group emptied before the frozen containers are '
        'restored is cleaned up once they are', () async {
      await addTab('iso', mode: TabMode.isolated('iso1_g'));
      await addTab('outside');
      native.selected = 'outside';
      lifecycle.recovery = true;
      final routes =
          container.read(proxyRoutingSettingsRepositoryProvider.notifier)
              as _ProxyRoutes;

      await repository().closeTab('iso');
      await repository().handleTabListChange(null, EquatableValue(['outside']));
      expect(routes.cleared, isEmpty);

      lifecycle.recovery = false;
      await container.read(containerMembershipGateProvider.notifier).refresh();
      await isolationCleanup().drain();

      expect(routes.cleared, ['iso1_g']);
    });

    test('of a frozen container whose data could not be deleted yet says the '
        'cleanup is pending', () async {
      await addContainer('work', contextId: 'ctx-work');
      await addTab('outside');
      native.selected = 'outside';
      lifecycle
        ..restrict('work', ['ctx-work'])
        ..completeDeletionFails = true;

      final result = await deletion().delete('work', deleteSiteData: true);

      expect(result, ContainerDeleted(siteDataCleanupPending: true));
      expect(
        await db.containerDao.getContainerData('work').getSingleOrNull(),
        isNull,
      );
    });

    test('closes the tabs the engine runs in its cookie store, an empty '
        "container's too", () async {
      await addContainer('work', contextId: 'ctx-work');
      await addTab('outside');
      // Opened natively a moment ago: no row, no event yet.
      native
        ..selected = 'outside'
        ..open.add('popup')
        ..contextOf['popup'] = 'ctx-work';

      final result = await deletion().delete('work');

      expect(result, ContainerDeleted());
      expect(native.removalRequests, ['popup']);
      expect(native.open, {'outside'});
    });

    test('is refused while a tab is being added to it', () async {
      await addContainer('work');
      await addTab('outside');
      native.selected = 'outside';
      final gate = container.read(containerMembershipGateProvider.notifier);

      // An addition in flight: past its decision, its row not written yet.
      final adding = Completer<void>();
      final addition = gate.whileChanging(['work'], () => adding.future);
      await Future<void>.delayed(Duration.zero);

      expect(
        await deletion().delete('work'),
        const ContainerDeletionWaitForOperation(),
      );
      expect(
        await db.containerDao.getContainerData('work').getSingleOrNull(),
        isNotNull,
      );

      adding.complete();
      await addition;
      expect(await deletion().delete('work'), ContainerDeleted());
    });

    test('takes no new tab, and no undo, while it runs', () async {
      await addContainer('work');
      await addTab('outside');
      native.selected = 'outside';
      final gate = container.read(containerMembershipGateProvider.notifier);

      final release = Completer<void>();
      final deleting = gate.whileDeleting('work', () => release.future);
      await Future<void>.delayed(Duration.zero);

      expect(gate.isBeingDeleted('work'), isTrue);
      await expectLater(
        gate.whileChanging(['work'], () async {}),
        throwsA(isA<ContainerBeingDeletedException>()),
      );
      // Changes to other containers, and to no container, go on.
      await gate.whileChanging(['other', null], () async {});
      expect(
        await deletion().delete('work'),
        const ContainerDeletionWaitForOperation(),
      );
      expect(await repository().undoClose(), UndoCloseOutcome.refused);

      release.complete();
      await deleting;
      expect(gate.isBeingDeleted('work'), isFalse);
      await gate.whileChanging(['work'], () async {});
    });

    test('a tab aimed at a container deleted after it was looked up is '
        'refused, and the engine is not asked', () async {
      await addContainer('work');
      await addTab('source');
      final looked = await db.containerDao
          .getContainerData('work')
          .getSingleOrNull();
      // The deletion finished between the lookup and the reservation, so the
      // gate has nothing in flight to refuse it with.
      await db.tabDao.deleteContainerIfOnlyClosedTabs('work', closedTabIds: {});

      await expectLater(
        repository().duplicateTab(
          selectTabId: 'source',
          containerData: looked,
          selectTab: false,
        ),
        throwsA(isA<ContainerBeingDeletedException>()),
      );
    });

    test(
      'a change nested in another passes and hands everything back',
      () async {
        final gate = container.read(containerMembershipGateProvider.notifier);

        final result = await gate.whileChanging([
          'work',
        ], () => gate.whileChanging(['work'], () async => 'reopened'));

        expect(result, 'reopened');
        expect(await gate.whileDeleting('work', () async => true), isTrue);
      },
    );
  });

  group('windows opened while a container is deleted', () {
    test(
      "are closed with it, for a container sharing the default cookie store",
      () async {
        await addContainer('work');
        await addTab('a', containerId: 'work');
        await addTab('outside');
        native.selected = 'outside';
        // 'a' opens a window just as it is closed; its event arrives while
        // the deletion runs. Native has no context to find it by.
        Future<void>? added;
        native.onRemove = (ids) {
          if (ids.contains('a') && added == null) {
            native.open.add('popup');
            added = repository().handleTabAdded('popup', openerId: 'a');
          }
        };

        final result = await deletion().delete('work');

        expect(result, ContainerDeleted());
        expect(native.open, {'outside'});
        await added;
        expect(native.open, {'outside'});
      },
    );

    test('are closed with it in the contexts of its isolated tabs, and no '
        'tab outside it is', () async {
      await addContainer('work', contextId: 'ctx-work');
      await addTab(
        'iso',
        containerId: 'work',
        mode: const IsolatedTabMode('iso1_a'),
      );
      await addTab(
        'shared',
        containerId: 'work',
        mode: const IsolatedTabMode('iso1_b'),
      );
      // Moved out of the container, it kept its isolation context.
      await addTab('elsewhere', mode: const IsolatedTabMode('iso1_b'));
      await addTab('outside');
      native
        ..selected = 'outside'
        ..contextOf.addAll({
          'iso': 'iso1_a',
          'shared': 'iso1_b',
          'elsewhere': 'iso1_b',
        })
        // Opened by 'iso' a moment ago: no row, no event yet.
        ..open.add('popup')
        ..contextOf['popup'] = 'iso1_a';

      final result = await deletion().delete('work');

      expect(result, ContainerDeleted());
      expect(native.open, {'outside', 'elsewhere'});
    });

    test('are closed once it is over when it went through', () async {
      await addContainer('work');
      await addTab('a', containerId: 'work');
      await addTab('outside');
      native.selected = 'outside';
      final gate = container.read(containerMembershipGateProvider.notifier);
      final release = Completer<void>();
      final deleting = gate.whileDeleting('work', () => release.future);
      await pumpEventQueue();

      // Its event arrives after the deletion's last look at the tabs.
      native.open.add('popup');
      final added = repository().handleTabAdded('popup', openerId: 'a');
      await pumpEventQueue();

      expect(gate.tabsOpenedDuringDeletion('work'), {'popup'});
      expect(await db.tabDao.getExistingTabIds(['popup']).get(), ['popup']);
      expect(
        await db.tabDao.getTabContainerId('popup').getSingleOrNull(),
        isNull,
      );
      expect(native.open, contains('popup'));

      await db.tabDao.deleteContainerIfOnlyClosedTabs(
        'work',
        closedTabIds: {'a'},
      );
      release.complete();
      await deleting;
      await added;

      expect(native.open, isNot(contains('popup')));
    });

    test('a window such a window opens is closed with it too', () async {
      await addContainer('work');
      await addTab('a', containerId: 'work');
      await addTab('outside');
      native.selected = 'outside';
      // The refused window's row names no container, so the window it opens
      // can only be told apart by what the deletion remembers.
      Future<void>? added;
      native.onRemove = (ids) {
        if (ids.contains('a') && added == null) {
          native.open.add('popup');
          added = repository().handleTabAdded('popup', openerId: 'a').then((_) {
            native.open.add('grandchild');
            return repository().handleTabAdded('grandchild', openerId: 'popup');
          });
        }
      };

      final result = await deletion().delete('work');

      expect(result, ContainerDeleted());
      await added;
      expect(native.open, {'outside'});
    });

    test('a window reported after its opener went with the container is '
        'closed', () async {
      await addContainer('work');
      await addTab('a', containerId: 'work');
      await addTab('outside');
      native.selected = 'outside';
      expect(await deletion().delete('work'), ContainerDeleted());
      // The cascade took the opener's row.
      expect(await db.tabDao.getExistingTabIds(['a']).get(), isEmpty);

      native.open.add('late');
      await repository().handleTabAdded('late', openerId: 'a');

      expect(native.open, {'outside'});
      // Undone, it would come back into the deleted container's storage,
      // with no container left to route it.
      expect(native.undoHistory, isEmpty);
    });

    test('are filed into it when its deletion did not go through', () async {
      await addContainer('work');
      await addTab('a', containerId: 'work');
      await addTab('outside');
      native.selected = 'outside';
      final gate = container.read(containerMembershipGateProvider.notifier);
      final release = Completer<void>();
      final deleting = gate.whileDeleting('work', () => release.future);
      await pumpEventQueue();

      native.open.add('popup');
      final added = repository().handleTabAdded('popup', openerId: 'a');
      await pumpEventQueue();
      release.complete();
      await deleting;
      await added;

      expect(native.open, contains('popup'));
      expect(
        await db.tabDao.getTabContainerId('popup').getSingleOrNull(),
        'work',
      );
    });
  });

  group('windows whose opener has no row', () {
    test('go into the container the opener closed in', () async {
      await addContainer('work');
      await addTab('a', containerId: 'work');
      await addTab('outside');
      native.selected = 'outside';
      await repository().closeTab('a');
      await db.tabDao.syncTabs(retainTabIds: ['outside']);

      native.open.add('late');
      await repository().handleTabAdded('late', openerId: 'a');

      expect(native.open, contains('late'));
      expect(
        await db.tabDao.getTabContainerId('late').getSingleOrNull(),
        'work',
      );
    });

    test('of an unassigned opener stay unassigned', () async {
      await addContainer('work');
      await addTab('u');
      native.open.add('child');

      await repository().handleTabAdded('child', openerId: 'u');

      expect(
        await db.tabDao.getTabContainerId('child').getSingleOrNull(),
        isNull,
      );
    });
  });

  group('tabs an extension opens', () {
    test('go into the selected container, unless it is frozen: its freeze '
        'would not stop them', () async {
      await addContainer('work', contextId: 'ctx-work');
      container = makeContainer(selectedContainer: 'work');
      native.open.add('ext1');

      await repository().handleTabAdded('ext1');
      expect(
        await db.tabDao.getTabContainerId('ext1').getSingleOrNull(),
        'work',
      );

      lifecycle.restrict('work', ['ctx-work']);
      await container.read(containerMembershipGateProvider.notifier).refresh();
      native.open.add('ext2');

      await repository().handleTabAdded('ext2');
      expect(
        await db.tabDao.getTabContainerId('ext2').getSingleOrNull(),
        isNull,
      );
    });
  });

  group("tabs with no opener that run in a container's storage", () {
    // The page a notification's service worker opens, in the storage of the
    // container whose site it came from, whichever container is on screen.
    test('belong to that container, not the selected one', () async {
      await addContainer('work', contextId: 'ctx-work');
      await addContainer('play', contextId: 'ctx-play');
      container = makeContainer(selectedContainer: 'play');
      native.open.add('notified');

      await repository().handleTabAdded('notified', contextId: 'ctx-work');

      expect(
        await db.tabDao.getTabContainerId('notified').getSingleOrNull(),
        'work',
      );
    });

    test('of an isolation group belong to the container of its tabs', () async {
      await addContainer('work', contextId: 'ctx-work');
      await addContainer('play', contextId: 'ctx-play');
      await addTab(
        'iso',
        containerId: 'work',
        mode: TabMode.isolated('iso1_g'),
      );
      container = makeContainer(selectedContainer: 'play');
      native.open.add('notified');

      await repository().handleTabAdded('notified', contextId: 'iso1_g');

      expect(
        await db.tabDao.getTabContainerId('notified').getSingleOrNull(),
        'work',
      );
    });

    test(
      'in the default storage still go into the selected container',
      () async {
        await addContainer('work', contextId: 'ctx-work');
        container = makeContainer(selectedContainer: 'work');
        native.open.add('notified');

        await repository().handleTabAdded('notified', contextId: null);

        expect(
          await db.tabDao.getTabContainerId('notified').getSingleOrNull(),
          'work',
        );
      },
    );

    test(
      'of a context no container uses fall back to the selected one',
      () async {
        await addContainer('work', contextId: 'ctx-work');
        container = makeContainer(selectedContainer: 'work');
        native.open.add('notified');

        await repository().handleTabAdded('notified', contextId: 'ctx-gone');

        expect(
          await db.tabDao.getTabContainerId('notified').getSingleOrNull(),
          'work',
        );
      },
    );

    test('of an isolation group go by the tabs it has, also when none of '
        'them is in a container', () async {
      await addContainer('work', contextId: 'ctx-work');
      await addContainer('play', contextId: 'ctx-play');
      container = makeContainer(selectedContainer: 'play');
      await addTab('a', containerId: 'work', mode: TabMode.isolated('iso1_g'));
      await addTab('b', mode: TabMode.isolated('iso1_g'));
      // 'a' closes; 'b', moved out of the container, stays in the group.
      container
          .read(storageOwnersProvider.notifier)
          .rememberDeletedTabs(
            (await db.tabDao.syncTabs(
              retainTabIds: ['b'],
            )).deletedIsolationContainers,
          );
      native.open.add('notified');

      await repository().handleTabAdded(
        'notified',
        contextId: 'iso1_g',
        openedByServiceWorker: true,
      );

      // Filed under 'work', it would give the whole group that route.
      expect(
        await db.tabDao.getTabContainerId('notified').getSingleOrNull(),
        isNull,
      );
    });

    test('are closed with their container when it is being deleted', () async {
      await addContainer('work', contextId: 'ctx-work');
      await addContainer('play', contextId: 'ctx-play');
      container = makeContainer(selectedContainer: 'play');
      await addTab('a', containerId: 'work');
      await addTab('outside');
      native.selected = 'outside';
      final gate = container.read(containerMembershipGateProvider.notifier);
      final release = Completer<void>();
      final deleting = gate.whileDeleting('work', () => release.future);
      await pumpEventQueue();

      native.open.add('notified');
      final added = repository().handleTabAdded(
        'notified',
        contextId: 'ctx-work',
        openedByServiceWorker: true,
      );
      await pumpEventQueue();

      // Told to the deletion, as a window of one of its pages is.
      expect(gate.tabsOpenedDuringDeletion('work'), {'notified'});

      await db.tabDao.deleteContainerIfOnlyClosedTabs(
        'work',
        closedTabIds: {'a'},
      );
      release.complete();
      await deleting;
      await added;

      // Not left running in the deleted container's storage.
      expect(native.open, isNot(contains('notified')));
    });

    test('belong to that container when the tab list sync wrote their row '
        'first', () async {
      await addContainer('work', contextId: 'ctx-work');
      await addContainer('play', contextId: 'ctx-play');
      container = makeContainer(selectedContainer: 'play');
      await addTab('outside');
      native
        ..selected = 'outside'
        ..open.add('notified');

      // The tab list reaches Dart before the tab added event: a placeholder.
      await repository().handleTabListChange(
        null,
        EquatableValue(['outside', 'notified']),
      );
      expect(await db.tabDao.getTabSource('notified'), TabSource.syncEvent);

      await repository().handleTabAdded(
        'notified',
        contextId: 'ctx-work',
        openedByServiceWorker: true,
      );

      expect(
        await db.tabDao.getTabContainerId('notified').getSingleOrNull(),
        'work',
      );
    });

    test('are told to a deletion of their container when the tab list sync '
        'wrote their row first', () async {
      await addContainer('work', contextId: 'ctx-work');
      await addContainer('play', contextId: 'ctx-play');
      container = makeContainer(selectedContainer: 'play');
      await addTab('a', containerId: 'work');
      await addTab('outside');
      native
        ..selected = 'outside'
        ..open.add('notified');
      await repository().handleTabListChange(
        null,
        EquatableValue(['a', 'outside', 'notified']),
      );
      final gate = container.read(containerMembershipGateProvider.notifier);
      final release = Completer<void>();
      final deleting = gate.whileDeleting('work', () => release.future);
      await pumpEventQueue();

      final added = repository().handleTabAdded(
        'notified',
        contextId: 'ctx-work',
        openedByServiceWorker: true,
      );
      await pumpEventQueue();

      expect(gate.tabsOpenedDuringDeletion('work'), {'notified'});

      await db.tabDao.deleteContainerIfOnlyClosedTabs(
        'work',
        closedTabIds: {'a'},
      );
      release.complete();
      await deleting;
      await added;

      expect(native.open, isNot(contains('notified')));
    });

    test('a tab the app added keeps its row', () async {
      await addContainer('work', contextId: 'ctx-work');
      await addContainer('play', contextId: 'ctx-play');
      container = makeContainer(selectedContainer: 'play');
      await addTab('added', containerId: 'play');

      await repository().handleTabAdded('added', contextId: 'ctx-work');

      expect(
        await db.tabDao.getTabContainerId('added').getSingleOrNull(),
        'play',
      );
    });
  });

  group('the page a notification click opens', () {
    // The engine creates and selects it on its own, so nothing in Dart picks
    // it the way a tab the user chose lifts a "stay on home": the startup home
    // target latches it over a cold start's session before the click is
    // handed to the engine, and the home button sets it. Native says which
    // tab it is: the one its service worker delegate opened.
    setUp(() async {
      await addContainer('work', contextId: 'ctx-work');
      container = makeContainer(selectedContainer: 'work');
    });

    bool homeForced() => container.read(forceBrowserHomeProvider);

    void latchHome() =>
        container.read(forceBrowserHomeProvider.notifier).request();

    Future<void> openedByWorker(String tabId, {String? contextId}) =>
        repository().handleTabAdded(
          tabId,
          contextId: contextId,
          openedByServiceWorker: true,
        );

    test('lifts a latched home once it is filed', () async {
      native.open.add('notified');
      latchHome();

      await openedByWorker('notified', contextId: 'ctx-work');

      expect(homeForced(), isFalse);
    });

    test(
      'in the default storage belongs to no container, not the selected one',
      () async {
        native.open.add('notified');

        await openedByWorker('notified');

        expect(
          await db.tabDao.getTabContainerId('notified').getSingleOrNull(),
          isNull,
        );
      },
    );

    test('of a context no container uses belongs to no container', () async {
      native.open.add('notified');

      await openedByWorker('notified', contextId: 'ctx-gone');

      expect(
        await db.tabDao.getTabContainerId('notified').getSingleOrNull(),
        isNull,
      );
    });

    test("in a container's storage still belongs to that container", () async {
      await addContainer('play', contextId: 'ctx-play');
      native.open.add('notified');

      await openedByWorker('notified', contextId: 'ctx-play');

      expect(
        await db.tabDao.getTabContainerId('notified').getSingleOrNull(),
        'play',
      );
    });

    test('of an isolation group with no tab left belongs to the container '
        "whose freeze still holds the group's storage", () async {
      // Its last tab closed while the container was frozen: no row names
      // the group's container any more, native's registry does.
      await addContainer('play', contextId: 'ctx-play');
      lifecycle.restrict('work', ['ctx-work', 'iso1_g']);
      await container.read(containerMembershipGateProvider.notifier).refresh();
      native.open.add('notified');

      await openedByWorker('notified', contextId: 'iso1_g');

      expect(
        await db.tabDao.getTabContainerId('notified').getSingleOrNull(),
        'work',
      );
    });

    test(
      'in the storage of a deleted container belongs to no container',
      () async {
        // A record whose owner is gone only waits for its data to be deleted.
        lifecycle.restrict('deleted', ['ctx-deleted']);
        await container
            .read(containerMembershipGateProvider.notifier)
            .refresh();
        native.open.add('notified');

        await openedByWorker('notified', contextId: 'ctx-deleted');

        expect(
          await db.tabDao.getTabContainerId('notified').getSingleOrNull(),
          isNull,
        );
      },
    );

    test('does not lift it for a tab no service worker opened', () async {
      native.open.add('ext');
      latchHome();

      await repository().handleTabAdded('ext', contextId: 'ctx-work');

      expect(homeForced(), isTrue);
    });

    test(
      'lifts it for every such tab, however late and however many',
      () async {
        // Nothing is waited for or used up: a second tap's page, or a slow
        // worker's, is the click's page as much as the first.
        native.open.addAll(['first', 'second']);
        latchHome();

        await openedByWorker('first');
        expect(homeForced(), isFalse);

        latchHome();
        await openedByWorker('second');
        expect(homeForced(), isFalse);
      },
    );

    test('is not a tab a page opened, which has an opener', () async {
      await addTab('a');
      native.open.add('popup');
      latchHome();

      await repository().handleTabAdded('popup', openerId: 'a');

      expect(homeForced(), isTrue);
    });
  });

  group('undo close and a frozen container', () {
    Future<void> closeIsolatedTab() async {
      await addContainer('work', contextId: 'ctx-work');
      await addTab(
        'iso',
        containerId: 'work',
        mode: TabMode.isolated('iso1_g'),
      );
      await addTab('outside');
      native
        ..selected = 'outside'
        ..contextOf['iso'] = 'iso1_g';
      await repository().closeTab('iso');
      // The last tab of its group: its row, and with it the group, left the
      // container.
      await repository().handleTabListChange(null, EquatableValue(['outside']));
    }

    test('does not bring an isolated tab back into a container frozen since, '
        'whose freeze does not hold its storage', () async {
      await closeIsolatedTab();
      lifecycle.restrict('work', ['ctx-work']);
      await container.read(containerMembershipGateProvider.notifier).refresh();

      expect(await repository().undoClose(), UndoCloseOutcome.refused);

      expect(native.open, {'outside'});
      expect(native.undoHistory, ['iso']);
      expect(container.read(containerFreezeNoticesProvider), [
        isA<PageNotOpened>().having(
          (notice) => notice.refusal,
          'refusal',
          isA<ContainerFrozenException>(),
        ),
      ]);
    });

    test('does not bring it back into storage whose release has begun, '
        'whose data is being deleted', () async {
      await closeIsolatedTab();
      lifecycle
        ..restrict('work', ['ctx-work'])
        ..restrict('work', ['iso1_g'], phase: ContextFreezePhase.releasing);
      await container.read(containerMembershipGateProvider.notifier).refresh();

      expect(await repository().undoClose(), UndoCloseOutcome.refused);

      expect(native.open, {'outside'});
      expect(native.undoHistory, ['iso']);
    });

    test('does not bring it back into storage whose release did not '
        'finish, though its container resumed since', () async {
      await closeIsolatedTab();
      // A Resume released the group first, which failed: it waits for its
      // data to be deleted, which the next start retries, while the
      // container itself runs again.
      lifecycle.restrict('work', [
        'iso1_g',
      ], phase: ContextFreezePhase.releasing);
      await container.read(containerMembershipGateProvider.notifier).refresh();

      expect(await repository().undoClose(), UndoCloseOutcome.refused);

      expect(native.open, {'outside'});
      expect(native.undoHistory, ['iso']);
      expect(container.read(containerFreezeNoticesProvider), [
        isA<UndoWaitsForSiteDataDeletion>(),
      ]);
    });

    test("does not run beside a Resume's release of isolation groups, "
        'which has not marked them yet', () async {
      await closeIsolatedTab();
      lifecycle.restrict('work', ['ctx-work', 'iso1_g']);
      final gate = container.read(containerMembershipGateProvider.notifier);
      await gate.refresh();
      final release = Completer<void>();
      unawaited(gate.whileReleasing(() => release.future));

      expect(await repository().undoClose(), UndoCloseOutcome.refused);
      expect(native.open, {'outside'});
      expect(native.undoHistory, ['iso']);

      release.complete();
      await pumpEventQueue();
      final undo = repository().undoClose();
      await pumpEventQueue();
      await repository().handleTabListChange(
        null,
        EquatableValue(['outside', 'iso']),
      );
      expect(await undo, UndoCloseOutcome.reopened);
    });

    test('brings it back when the freeze holds its storage: it stays '
        'frozen', () async {
      await closeIsolatedTab();
      lifecycle.restrict('work', ['ctx-work', 'iso1_g']);
      await container.read(containerMembershipGateProvider.notifier).refresh();

      final undo = repository().undoClose();
      await pumpEventQueue();
      await repository().handleTabListChange(
        null,
        EquatableValue(['outside', 'iso']),
      );

      expect(await undo, UndoCloseOutcome.reopened);
      expect(
        await db.tabDao.getTabContainerId('iso').getSingleOrNull(),
        'work',
      );
    });
  });

  group('undo close and the undo history', () {
    test('a close between the check and the undo has the new tabs checked '
        'and undone, rather than an older tab reopened', () async {
      await addTab('a');
      await addTab('b');
      await addTab('outside');
      native.selected = 'outside';
      await repository().closeTab('a');
      // 'b' closes right after the undo read what there is to undo.
      native.afterPendingUndoRead = () {
        native.open.remove('b');
        native.undoHistory
          ..clear()
          ..add('b');
      };

      final undo = repository().undoClose();
      await pumpEventQueue();
      await repository().handleTabListChange(
        null,
        EquatableValue(['outside', 'b']),
      );

      expect(await undo, UndoCloseOutcome.reopened);
      expect(native.open, containsAll(['outside', 'b']));
      expect(native.open, isNot(contains('a')));
    });
  });

  group('undo close and container deletion', () {
    test('a deletion waits for a pending undo to land', () async {
      await addContainer('work', contextId: 'ctx-work');
      await addTab('a', containerId: 'work');
      await addTab('outside');
      native
        ..selected = 'outside'
        ..contextOf['a'] = 'ctx-work';
      await repository().closeTab('a');
      // The close is synced: 'a' has no row until the undo's sync.
      await repository().handleTabListChange(null, EquatableValue(['outside']));

      // Native answers once 'a' is back; the app knows which container it is
      // back in once the tab list change has been synced into its row.
      final undo = repository().undoClose();
      await pumpEventQueue();
      expect(
        await deletion().delete('work'),
        const ContainerDeletionWaitForOperation(),
      );

      await repository().handleTabListChange(
        null,
        EquatableValue(['outside', 'a']),
      );
      expect(await undo, UndoCloseOutcome.reopened);

      expect(await deletion().delete('work'), ContainerDeleted());
      expect(native.open, {'outside'});
    });

    test('a second undo leaves the first one to land on its own', () async {
      await addContainer('work', contextId: 'ctx-work');
      await addTab('a', containerId: 'work');
      await addTab('b', containerId: 'work');
      await addTab('outside');
      native.selected = 'outside';
      await repository().closeTab('a');
      await repository().handleTabListChange(
        null,
        EquatableValue(['outside', 'b']),
      );
      final first = repository().undoClose();
      await pumpEventQueue();
      await repository().closeTab('b');
      final second = repository().undoClose();
      await pumpEventQueue();

      await repository().handleTabListChange(
        null,
        EquatableValue(['outside', 'a', 'b']),
      );

      // Not after the 30 s backstop: deletion is allowed again at once.
      expect(
        await first.timeout(const Duration(seconds: 5)),
        UndoCloseOutcome.reopened,
      );
      expect(
        await second.timeout(const Duration(seconds: 5)),
        UndoCloseOutcome.reopened,
      );
      expect(await deletion().delete('work'), ContainerDeleted());
    });

    test('a deletion leaves nothing for an undo to reopen', () async {
      await addContainer('work', contextId: 'ctx-work');
      await addTab('a', containerId: 'work');
      await addTab('outside');
      native
        ..selected = 'outside'
        ..contextOf['a'] = 'ctx-work';

      expect(await deletion().delete('work'), ContainerDeleted());

      expect(await repository().undoClose(), UndoCloseOutcome.nothingToUndo);
      expect(native.open, {'outside'});
    });

    test('a tab closed in it just before is not reopened into its cookie '
        'store', () async {
      await addContainer('work', contextId: 'ctx-work');
      await addTab('a', containerId: 'work');
      await addTab('outside');
      native
        ..selected = 'outside'
        ..contextOf['a'] = 'ctx-work';
      await repository().closeTab('a');
      // Its row synced away: the container is empty.
      await db.tabDao.syncTabs(retainTabIds: ['outside']);

      expect(await deletion().delete('work'), ContainerDeleted());

      expect(await repository().undoClose(), UndoCloseOutcome.nothingToUndo);
      expect(native.open, {'outside'});
    });

    test('a tab of a container sharing the default cookie store comes back '
        'under no container', () async {
      await addContainer('work');
      await addTab('a', containerId: 'work');
      await addTab('outside');
      native.selected = 'outside';
      await repository().closeTab('a');
      await db.tabDao.syncTabs(retainTabIds: ['outside']);
      expect(await deletion().delete('work'), ContainerDeleted());

      final undo = repository().undoClose();
      await pumpEventQueue();
      // The row kept for the undo pointed at the deleted container.
      await repository().handleTabListChange(
        null,
        EquatableValue(['outside', 'a']),
      );

      expect(await undo, UndoCloseOutcome.reopened);
      expect(await db.tabDao.getExistingTabIds(['a']).get(), ['a']);
      expect(await db.tabDao.getTabContainerId('a').getSingleOrNull(), isNull);
    });
  });
}
