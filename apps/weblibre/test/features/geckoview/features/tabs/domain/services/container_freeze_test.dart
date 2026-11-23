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

import 'package:clock/clock.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod/experimental/persist.dart';
import 'package:weblibre/data/database/functions/lexo_rank_functions.dart';
import 'package:weblibre/data/database/functions/url_functions.dart';
import 'package:weblibre/domain/feature_policy/feature_policy.dart';
import 'package:weblibre/features/geckoview/domain/entities/states/tab.dart';
import 'package:weblibre/features/geckoview/domain/entities/tab_container_selection.dart';
import 'package:weblibre/features/geckoview/domain/entities/tab_lock.dart';
import 'package:weblibre/features/geckoview/domain/providers.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_state.dart';
import 'package:weblibre/features/geckoview/domain/repositories/tab.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/database/database.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/entities/tab_mode.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/entities/tab_source.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/models/container_data.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/providers.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/entities/container_freeze.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/providers.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/providers/container_freeze.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/providers/selected_container.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/repositories/tab.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/services/container_freeze.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/services/container_membership_gate.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/services/storage_owners.dart';
import 'package:weblibre/features/proxy/data/proxy_connection.dart';
import 'package:weblibre/features/proxy/domain/repositories/container_proxy.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';
import 'package:weblibre/features/user/data/models/proxy_routing_settings.dart';
import 'package:weblibre/features/user/data/providers.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/features/user/domain/repositories/proxy_routing_settings.dart';

import '../../../../fake_tab_lifecycle_service.dart';

class _TestTabRepository extends TabRepository {
  @override
  void build() {}
}

/// Records what [addTab] is asked to open, and opens nothing.
class _RecordingTabRepository extends TabRepository {
  /// What [addTab] was asked to open, in order.
  final added =
      <
        ({
          Uri? url,
          TabMode tabMode,
          TabContainerSelection selection,
          bool selectTab,
        })
      >[];

  @override
  void build() {}

  @override
  Future<String> addTab({
    required TabMode tabMode,
    Uri? url,
    required bool selectTab,
    bool startLoading = true,
    String? parentId,
    LoadUrlFlags flags = LoadUrlFlags.NONE,
    Source source = Internal.newTab,
    HistoryMetadataKey? historyMetadata,
    Map<String, String>? additionalHeaders,
    TabContainerSelection containerSelection =
        const TabContainerSelection.useSelected(),
    bool launchedFromIntent = false,
    TabBackBehavior? onBackBehavior,
    void Function(String tabId)? onCreated,
    bool parentIsReferrer = true,
  }) async {
    added.add((
      url: url,
      tabMode: tabMode,
      selection: containerSelection,
      selectTab: selectTab,
    ));
    return 'opened';
  }
}

class _TabStates extends TabStates {
  _TabStates(this.states);

  final Map<String, TabState> states;

  @override
  Map<String, TabState> build() => states;
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

class _EngineReadyState extends EngineReadyState {
  @override
  bool build() => false;
}

/// Routing that is installed when [_ready] says so, and covers the contexts
/// asked about when [_covers] does and none is in [_uncovered]; tells
/// [_onWait] of each wait, and [_onAsk] of the contexts each check asks
/// about.
class _Routing extends ContainerProxyRepository {
  _Routing(
    this._ready,
    this._onWait,
    this._covers,
    this._uncovered,
    this._onAsk,
  );

  final bool _ready;
  final void Function() _onWait;
  final bool _covers;
  final Set<String> _uncovered;
  final void Function(List<String> contextIds) _onAsk;

  @override
  void build() {}

  @override
  Future<bool> waitUntilRoutingReady({
    Duration timeout = const Duration(seconds: 1),
  }) async {
    _onWait();
    return _ready;
  }

  @override
  Future<bool> routingCovers(List<String> contextIds) async {
    _onAsk(contextIds);
    return _covers && !contextIds.any(_uncovered.contains);
  }
}

/// Every API of gecko.g.dart shares one codec; this one is exported.
const _codec = GeckoTrackingProtectionApi.pigeonChannelCodec;
const _customTabsChannel =
    'dev.flutter.pigeon.flutter_mozilla_components.GeckoTabsApi.getCustomTabIdsInContexts';

/// Native's web app and custom tab windows, by id, with the context each
/// runs in.
void _answerWindows(Map<String, String> windows) {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockDecodedMessageHandler<Object?>(
        const BasicMessageChannel<Object?>(_customTabsChannel, _codec),
        (message) async {
          final contextIds = ((message! as List<Object?>)[0]! as List<Object?>)
              .cast<String>();
          return <Object?>[
            [
              for (final MapEntry(key: id, value: contextId) in windows.entries)
                if (contextIds.contains(contextId)) id,
            ],
          ];
        },
      );
  addTearDown(
    () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockDecodedMessageHandler<Object?>(
          const BasicMessageChannel<Object?>(_customTabsChannel, _codec),
          null,
        ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late TabDatabase db;
  late FakeTabLifecycleService native;
  late GeckoEventService events;
  late int routingWaits;
  late List<List<String>> routingAsked;
  late ProviderContainer container;
  late Storage<String, String> storage;

  ProviderContainer makeContainer({
    Map<String, TabState> states = const {},
    bool routingReady = true,
    bool routingCovers = true,
    Set<String> uncoveredContexts = const {},
    Map<String, ProxyConnectionId?> isolationRoutes = const {},
    GeneralSettings? settings,
    bool recordOpenedTabs = false,
    void Function()? onRoutingAsked,
  }) {
    routingWaits = 0;
    routingAsked = [];
    final created = ProviderContainer(
      overrides: [
        tabDatabaseProvider.overrideWith((ref) => db),
        tabRepositoryProvider.overrideWith(
          recordOpenedTabs
              ? _RecordingTabRepository.new
              : _TestTabRepository.new,
        ),
        tabStatesProvider.overrideWith(() => _TabStates(states)),
        geckoTabLifecycleServiceProvider.overrideWithValue(native),
        eventServiceProvider.overrideWithValue(events),
        generalSettingsWithDefaultsProvider.overrideWithValue(
          settings ?? GeneralSettings.withDefaults(),
        ),
        engineReadyStateProvider.overrideWith(_EngineReadyState.new),
        containerProxyRepositoryProvider.overrideWith(
          () => _Routing(
            routingReady,
            () => routingWaits++,
            routingCovers,
            uncoveredContexts,
            (contextIds) {
              routingAsked.add(contextIds);
              onRoutingAsked?.call();
            },
          ),
        ),
        proxyRoutingSettingsRepositoryProvider.overrideWith(_ProxyRoutes.new),
        proxyRoutingSettingsWithDefaultsProvider.overrideWithValue(
          ProxyRoutingSettings.withDefaults(
            isolationContextRoutes: isolationRoutes,
          ),
        ),
        riverpodDatabaseStorageProvider.overrideWith((ref) => storage),
      ],
    );
    addTearDown(created.dispose);
    return created;
  }

  setUp(() {
    storage = Storage.inMemory();
    db = TabDatabase(
      NativeDatabase.memory(
        setup: (database) {
          registerLexorankFunctions(database);
          registerUrlFunctions(database);
        },
      ),
    );
    addTearDown(db.close);
    native = FakeTabLifecycleService();
    events = GeckoEventService.setUp();
    addTearDown(events.dispose);
    _answerWindows(const {});
    container = makeContainer();
  });

  ContainerMembershipGate gate() =>
      container.read(containerMembershipGateProvider.notifier);
  ContainerFreezeService service() =>
      container.read(containerFreezeServiceProvider.notifier);

  Future<void> addContainer(
    String id, {
    String? contextId,
    ProxyConnectionId? proxy,
    int? autoFreezeAfterMinutes,
  }) => db.containerDao.addContainer(
    ContainerData(
      id: id,
      name: id,
      color: Colors.blue,
      orderKey: 'a',
      metadata: ContainerMetadata.withDefaults(
        contextualIdentity: contextId,
        proxyConnectionId: proxy,
        autoFreezeAfterMinutes: autoFreezeAfterMinutes,
      ),
    ),
  );

  Future<void> addTab(String id, {String? containerId, TabMode? mode}) =>
      db.tabDao.insertTab(
        id,
        source: TabSource.manual,
        parentId: const Value(null),
        containerId: Value(containerId),
        tabMode: mode == null ? const Value.absent() : Value(mode),
      );

  Future<String> move() => gate().whileChanging(
    ['work'],
    () async => 'moved',
    kind: ContainerChange.membership,
  );

  group('membership gate', () {
    test('a frozen container refuses moves and isolated tabs, but takes '
        'regular tabs', () async {
      native.restrict('work', ['ctx-work']);

      await expectLater(move(), throwsA(isA<ContainerFrozenException>()));
      expect(
        await gate().whileChanging(['work'], () async => 'added'),
        'added',
      );
    });

    test('an unrestricted container takes moves', () async {
      expect(await move(), 'moved');
    });

    test('a move goes by the container the tab is in once it holds the '
        'reservations', () async {
      await addContainer('home', contextId: 'ctx-home');
      await addContainer('work', contextId: 'ctx-work');
      await addContainer('other', contextId: 'ctx-other');
      await addTab(
        'iso',
        containerId: 'home',
        mode: TabMode.isolated('iso1_x'),
      );
      container = makeContainer(
        states: {
          'iso': TabState.$default(
            'iso',
          ).copyWith(tabMode: TabMode.isolated('iso1_x')),
        },
      );
      final work = (await db.containerDao
          .getContainerData('work')
          .getSingleOrNull())!;
      native.snapshotGate = Completer();

      final moving = container
          .read(tabDataRepositoryProvider.notifier)
          .assignContainer('iso', work);
      await pumpEventQueue();
      // Moved meanwhile into a container that is frozen now.
      await db.tabDao.assignContainer('iso', containerId: 'other');
      native.restrict('other', ['ctx-other']);
      native.snapshotGate!.complete();

      expect(await moving, ContainerMoveResult.containerFrozen);
      expect(
        await db.tabDao.getTabContainerId('iso').getSingleOrNull(),
        'other',
      );
    });

    test('an isolation group whose release did not finish does not make '
        'its container frozen', () async {
      native.restrict('work', [
        'iso1_gone',
      ], phase: ContextFreezePhase.releasing);
      await gate().seed();

      expect(gate().isRestricted('work'), isFalse);
      expect(gate().isFrozen('work'), isFalse);
      expect(await move(), 'moved');

      // Frozen as well: the frozen record decides.
      native.restrict('work', ['ctx-work']);
      await gate().refresh();
      expect(gate().isFrozen('work'), isTrue);
      expect(gate().contextsHolding('work'), ['ctx-work']);
    });

    test('every container is restricted in recovery mode', () async {
      native.recovery = true;

      await expectLater(move(), throwsA(isA<ContainerFrozenException>()));
      expect(gate().isFrozen('anything'), isTrue);
    });

    test(
      'an unreadable registry refuses moves, and is read again next time',
      () async {
        native.snapshotFails = true;

        await expectLater(move(), throwsA(isA<ContainerFrozenException>()));
        // A guess never loosens anything else either.
        expect(gate().isFrozen('work'), isFalse);

        native.snapshotFails = false;
        expect(await move(), 'moved');
      },
    );

    test('a running freeze holds the container: moves and deletion are '
        'refused, a second freeze is ignored, a Resume gets through', () async {
      final held = Completer<void>();
      final freezing = gate().whileOperating('work', () => held.future);
      await pumpEventQueue();

      await expectLater(move(), throwsA(isA<ContainerFrozenException>()));
      expect(await gate().whileDeleting('work', () async => 'deleted'), isNull);
      expect(await gate().whileOperating('work', () async => 'again'), isNull);
      expect(
        await gate().whileOperating(
          'work',
          () async => 'resumed',
          concurrentWithOthers: true,
        ),
        'resumed',
      );

      held.complete();
      await freezing;
      expect(await move(), 'moved');
    });

    test(
      'after an operation the gate takes native state, not the reply',
      () async {
        await gate().whileOperating('work', () async {
          native.restrict('work', ['ctx-work']);
          // Whatever this operation says, the snapshot decides.
          return 'unrestricted';
        });

        await expectLater(move(), throwsA(isA<ContainerFrozenException>()));
      },
    );

    test('when the read after an operation fails, every container stays '
        'restricted until a read succeeds', () async {
      await gate().seed();
      await gate().whileOperating('work', () async {
        native
          ..restrict('work', ['ctx-work'])
          ..snapshotFails = true;
      });

      // The last snapshot read says unrestricted; it is not trusted now.
      await expectLater(move(), throwsA(isA<ContainerFrozenException>()));
      expect(gate().isFrozen('work'), isFalse);

      native.snapshotFails = false;
      await expectLater(move(), throwsA(isA<ContainerFrozenException>()));
      expect(gate().isFrozen('work'), isTrue);
    });

    test('takes the snapshots native reports for changes of its own, newest '
        'only', () async {
      native.restrict('work', ['ctx-work']);
      await gate().seed();
      final frozen = native.currentSnapshot;
      // A Resume's background retry removed the records.
      await native.releaseContexts(['ctx-work']);

      await events.onContextFreezeChange(1, native.currentSnapshot);
      await pumpEventQueue();
      expect(await move(), 'moved');

      // Delivered late: older than the one the gate has.
      await events.onContextFreezeChange(2, frozen);
      await pumpEventQueue();
      expect(await move(), 'moved');
    });

    test('a slow startup reconciliation holds up no decision', () async {
      native.recovery = true;
      await gate().seed();
      final reconciling = Completer<LifecycleSnapshot>();
      final adopting = reconciling.future.then(gate().adoptStartupSnapshot);

      // Decided by the snapshot held meanwhile: recovery.
      expect(
        await gate().whileChanging(['work'], () async => 'added'),
        'added',
      );
      await expectLater(move(), throwsA(isA<ContainerFrozenException>()));

      native.recovery = false;
      native.restrict('other', ['ctx-other']);
      reconciling.complete(native.currentSnapshot);
      await adopting;
      expect(await move(), 'moved');
    });

    test('an older snapshot never replaces a newer one', () async {
      native.restrict('work', ['ctx-work']);
      await gate().seed();
      final stale = LifecycleSnapshot(
        mode: LifecycleRegistryMode.normal,
        revision: 0,
        contexts: const [],
        owners: const [],
      );

      gate().adoptStartupSnapshot(stale);

      expect(gate().isFrozen('work'), isTrue);
    });

    test(
      'a membership change in flight keeps a freeze from starting',
      () async {
        final held = Completer<void>();
        final moving = gate().whileChanging(
          ['work'],
          () => held.future,
          kind: ContainerChange.membership,
        );
        await pumpEventQueue();

        expect(
          await gate().whileOperating('work', () async => 'frozen'),
          isNull,
        );

        held.complete();
        await moving;
      },
    );
  });

  group('adding tabs', () {
    TabRepository tabs() => container.read(tabRepositoryProvider.notifier);

    test('a request with extra headers into a frozen container is refused, '
        'also before the registry was read', () async {
      await addContainer('work', contextId: 'ctx-work');
      native.restrict('work', ['ctx-work']);
      final work = (await db.containerDao
          .getContainerData('work')
          .getSingleOrNull())!;

      expect(gate().hasRegistrySnapshot(), isFalse);
      await expectLater(
        tabs().addTab(
          tabMode: TabMode.regular,
          selectTab: false,
          additionalHeaders: {'Referer': 'https://a.example'},
          containerSelection: TabContainerSelection.specific(work),
        ),
        throwsA(isA<ContainerFrozenException>()),
      );
      expect(gate().hasRegistrySnapshot(), isTrue);
    });

    test('isolated tabs may come back into storage the freeze holds for the '
        'container, and no other while it is frozen', () async {
      await addContainer('work', contextId: 'ctx-work');
      await addContainer('home', contextId: 'ctx-home');
      native.restrict('work', ['ctx-work', 'iso1_kept']);

      expect(await tabs().mayAddIsolatedTabs('work', ['iso1_kept']), isTrue);
      expect(
        await tabs().mayAddIsolatedTabs('work', ['iso1_kept', 'iso1_new']),
        isFalse,
      );
      expect(await tabs().mayAddIsolatedTabs('home', ['iso1_new']), isTrue);
    });
  });

  group('freeze', () {
    test("restricts the container context and its isolated tabs' contexts, "
        'with every member', () async {
      await addContainer('work', contextId: 'ctx-work');
      await addTab('a', containerId: 'work');
      await addTab(
        'iso',
        containerId: 'work',
        mode: TabMode.isolated('iso1_x'),
      );

      final outcome = await service().freeze('work');

      expect(outcome, isA<FreezeAttempted>());
      expect((outcome as FreezeAttempted).frozen, isTrue);
      expect(native.lastFreezeContexts, ['ctx-work', 'iso1_x']);
      expect(native.lastFreezeMembers, unorderedEquals(['a', 'iso']));
      expect(gate().isFrozen('work'), isTrue);
    });

    test('a container deleted before the reservation is missing, and '
        'nothing is frozen', () async {
      await addContainer('work', contextId: 'ctx-work');
      native.snapshotGate = Completer();

      final freezing = service().freeze('work');
      await pumpEventQueue();
      // Deleted while the freeze waited for the registry: no deletion is
      // left for the gate to refuse.
      await db.tabDao.deleteContainerIfOnlyClosedTabs(
        'work',
        closedTabIds: const {},
      );
      native.snapshotGate!.complete();

      expect(await freezing, FreezeUnavailable(FreezeUnavailability.missing));
      expect(native.calls, isEmpty);
      expect(gate().isFrozen('work'), isFalse);
    });

    test('a retry also covers an isolation group kept restricted after an '
        'incomplete freeze', () async {
      await addContainer('work', contextId: 'ctx-work');
      native.restrict('work', [
        'ctx-work',
        'iso1_gone',
      ], phase: ContextFreezePhase.failed);

      final outcome = await service().freeze('work');

      expect((outcome as FreezeAttempted).frozen, isTrue);
      expect(native.lastFreezeContexts, ['ctx-work', 'iso1_gone']);
    });

    test('leaves out an isolation group only waiting for its data to be '
        'deleted', () async {
      await addContainer('work', contextId: 'ctx-work');
      native.restrict('work', [
        'iso1_gone',
      ], phase: ContextFreezePhase.releasing);

      final outcome = await service().freeze('work');

      expect((outcome as FreezeAttempted).frozen, isTrue);
      expect(native.lastFreezeContexts, ['ctx-work']);
    });

    test('counts an open tab of its context that has no row yet', () async {
      container = makeContainer(
        states: {
          'popup': TabState.$default('popup').copyWith(contextId: 'ctx-work'),
        },
      );
      await addContainer('work', contextId: 'ctx-work');
      await addTab('a', containerId: 'work');

      await service().freeze('work');

      expect(native.lastFreezeMembers, unorderedEquals(['a', 'popup']));
    });

    test('is unavailable for a container without its own storage', () async {
      await addContainer('shared');

      expect(
        await service().freeze('shared'),
        FreezeUnavailable(FreezeUnavailability.needsOwnStorage),
      );
      expect(native.calls, isEmpty);
    });

    test('is unavailable when an isolated tab shares storage with a tab '
        'outside the container', () async {
      await addContainer('work', contextId: 'ctx-work');
      await addTab(
        'iso',
        containerId: 'work',
        mode: TabMode.isolated('iso1_x'),
      );
      await addTab('outside', mode: TabMode.isolated('iso1_x'));

      expect(
        await service().freeze('work'),
        FreezeUnavailable(FreezeUnavailability.sharedStorage),
      );
      expect(native.calls, isEmpty);
    });

    test('is refused until the containers are reconstructed', () async {
      native.recovery = true;
      await addContainer('work', contextId: 'ctx-work');

      expect(
        await service().freeze('work'),
        FreezeUnavailable(FreezeUnavailability.recoveryPending),
      );
    });

    test('a second request while one runs is ignored', () async {
      await addContainer('work', contextId: 'ctx-work');
      native.freezeGate = Completer<void>();
      final first = service().freeze('work');
      await pumpEventQueue();

      expect(await service().freeze('work'), const FreezeBusy());

      native.freezeGate!.complete();
      expect(await first, isA<FreezeAttempted>());
    });
  });

  group('automatic freeze', () {
    var sequence = 0;
    var now = DateTime(2026, 11, 17, 12);

    /// The service, listening in a zone whose clock is [now].
    ContainerFreezeService listening() => withClock(Clock(() => now), service);

    Future<void> due(String containerId) async {
      await events.onContainerFreezeDue(++sequence, containerId);
      await pumpEventQueue();
    }

    setUp(() => now = DateTime(2026, 11, 17, 12));

    test('a due container goes through the gated preflight, with '
        'automatic', () async {
      await addContainer(
        'work',
        contextId: 'ctx-work',
        autoFreezeAfterMinutes: 30,
      );
      await addTab('a', containerId: 'work');
      listening();

      await due('work');

      expect(native.calls, ['freeze work [ctx-work]']);
      expect(native.lastFreezeAutomatic, isTrue);
      expect(native.lastFreezeMembers, ['a']);
      expect(gate().isFrozen('work'), isTrue);
    });

    test('the menu freeze is never automatic', () async {
      await addContainer('work', contextId: 'ctx-work');

      await service().freeze('work');

      expect(native.lastFreezeAutomatic, isFalse);
    });

    test('a container without a schedule is left alone', () async {
      await addContainer('work', contextId: 'ctx-work');

      expect(
        await service().freezeAutomatically('work'),
        FreezeUnavailable(FreezeUnavailability.notScheduled),
      );
      expect(native.calls, isEmpty);
    });

    test('nothing freezes automatically while container freeze is '
        'hidden', () async {
      container = makeContainer(
        settings: GeneralSettings.withDefaults().withVisibilitySwitch(
          VisibilitySwitch.containers,
          enabled: false,
        ),
      );
      await addContainer(
        'work',
        contextId: 'ctx-work',
        autoFreezeAfterMinutes: 30,
      );

      expect(
        await service().freezeAutomatically('work'),
        FreezeUnavailable(FreezeUnavailability.notScheduled),
      );
      expect(native.calls, isEmpty);
    });

    test('a refusal lets due events go for a while, doubling each '
        'time', () async {
      await addContainer(
        'work',
        contextId: 'ctx-work',
        autoFreezeAfterMinutes: 30,
      );
      native.freezeAnswer = (owner) =>
          native.result(owner, failure: LifecycleFailure.protectedActivity);
      listening();

      await due('work');
      await due('work');
      expect(native.calls, hasLength(1));

      now = now.add(const Duration(minutes: 5));
      await due('work');
      expect(native.calls, hasLength(2));

      now = now.add(const Duration(minutes: 9));
      await due('work');
      expect(native.calls, hasLength(2));
      now = now.add(const Duration(minutes: 1));
      await due('work');
      expect(native.calls, hasLength(3));
    });

    test('a container used again is tried at its next due event', () async {
      await addContainer(
        'work',
        contextId: 'ctx-work',
        autoFreezeAfterMinutes: 30,
      );
      native.freezeAnswer = (owner) =>
          native.result(owner, failure: LifecycleFailure.noLongerEligible);
      listening();

      await due('work');
      await due('work');

      expect(native.calls, hasLength(2));
    });

    test('a due event while the container is busy is dropped', () async {
      await addContainer(
        'work',
        contextId: 'ctx-work',
        autoFreezeAfterMinutes: 30,
      );
      native.freezeGate = Completer<void>();
      listening();
      final manual = service().freeze('work');
      await pumpEventQueue();

      await due('work');
      native.freezeGate!.complete();
      await manual;
      await pumpEventQueue();

      expect(native.calls, ['freeze work [ctx-work]']);
      expect(native.lastFreezeAutomatic, isFalse);
    });

    test('a due event during a membership change is dropped, and the next '
        'one counts the tab that moved in', () async {
      await addContainer(
        'work',
        contextId: 'ctx-work',
        autoFreezeAfterMinutes: 30,
      );
      await addTab('a', containerId: 'work');
      await addTab('moved');
      listening();
      final moving = Completer<void>();
      final move = gate().whileChanging(['work'], () async {
        await moving.future;
        await db.tabDao.assignContainer('moved', containerId: 'work');
        return 'moved';
      }, kind: ContainerChange.membership);
      await pumpEventQueue();

      await due('work');
      moving.complete();
      await move;
      await pumpEventQueue();
      expect(native.calls, isEmpty);

      await due('work');
      expect(native.calls, ['freeze work [ctx-work]']);
      expect(native.lastFreezeMembers, unorderedEquals(['a', 'moved']));
    });
  });

  group('selected container', () {
    test("follows a frozen proxied container's tab while routing is not "
        'ready, so its placeholder and Resume show', () async {
      container = makeContainer(routingReady: false);
      await addContainer(
        'work',
        contextId: 'ctx-work',
        proxy: const TorProxyConnectionId(),
      );
      await addContainer(
        'home',
        contextId: 'ctx-home',
        proxy: const TorProxyConnectionId(),
      );
      native.restrict('work', ['ctx-work']);
      await gate().seed();
      final selected = container.read(selectedContainerProvider.notifier);

      expect(await selected.followTab('work'), SetContainerResult.success);
      expect(container.read(selectedContainerProvider), 'work');
      // One that is not frozen still waits for its routing.
      expect(await selected.followTab('home'), SetContainerResult.failed);
      expect(container.read(selectedContainerProvider), 'work');
    });
  });

  group('resume', () {
    test('lifts and wakes the tab, once routing is ready', () async {
      container = makeContainer();
      await addContainer(
        'work',
        contextId: 'ctx-work',
        proxy: const TorProxyConnectionId(),
      );
      native.restrict('work', ['ctx-work']);

      final outcome = await service().resume('work', wakeTabId: 'a');

      expect((outcome as ResumeAttempted).resumed, isTrue);
      expect(native.calls, ['resume work a']);
      expect(routingWaits, 1);
      expect(gate().isFrozen('work'), isFalse);
    });

    test('reaches nothing native while routing is not ready', () async {
      container = makeContainer(routingReady: false);
      await addContainer(
        'work',
        contextId: 'ctx-work',
        proxy: const TorProxyConnectionId(),
      );
      native.restrict('work', ['ctx-work']);

      expect(await service().resume('work'), const ResumeRoutingNotReady());
      expect(native.calls, isEmpty);
      expect(gate().isFrozen('work'), isTrue);
    });

    test('checks the routing an isolated tab has of its own', () async {
      container = makeContainer(
        routingReady: false,
        isolationRoutes: {'iso1_x': const TorProxyConnectionId()},
      );
      await addContainer('work', contextId: 'ctx-work');
      await addTab(
        'iso',
        containerId: 'work',
        mode: TabMode.isolated('iso1_x'),
      );
      native.restrict('work', ['ctx-work', 'iso1_x']);

      expect(await service().resume('work'), const ResumeRoutingNotReady());
      expect(native.calls, isEmpty);
    });

    test('is refused while a frozen container shares its storage, and goes '
        'ahead once that one is resumed', () async {
      // After a damaged registry, an isolation group of two containers is
      // restored under one of them.
      await addContainer('work', contextId: 'ctx-work');
      await addContainer('home', contextId: 'ctx-home');
      await addTab('w', containerId: 'work', mode: TabMode.isolated('iso1_s'));
      await addTab('h', containerId: 'home', mode: TabMode.isolated('iso1_s'));
      native
        ..restrict('work', ['ctx-work', 'iso1_s'])
        ..restrict('home', ['ctx-home']);

      expect(await service().resume('work'), const ResumeSharedWithFrozen());
      expect(native.calls, isEmpty);

      expect(
        (await service().resume('home') as ResumeAttempted).resumed,
        isTrue,
      );
      expect(
        (await service().resume('work') as ResumeAttempted).resumed,
        isTrue,
      );
      expect(native.calls, ['resume home -', 'resume work -']);
    });

    test('releases an isolation group left without a tab while frozen '
        'before it lifts anything', () async {
      await addContainer('work', contextId: 'ctx-work');
      await addTab(
        'iso',
        containerId: 'work',
        mode: TabMode.isolated('iso1_kept'),
      );
      native.restrict('work', ['ctx-work', 'iso1_gone', 'iso1_kept']);

      final outcome = await service().resume('work');

      expect((outcome as ResumeAttempted).resumed, isTrue);
      // Through the release procedure while its record still restricts it;
      // the group with a tab is resumed with the container.
      expect(native.calls, ['release [iso1_gone]', 'resume work -']);
    });

    test('releases no isolation group while an undo close runs, which '
        'could bring its last tab back: busy instead', () async {
      final undo = Completer<void>();
      var undoStarted = false;
      // Started while the Resume holds its container, during its routing
      // check: a Resume does not start beside one that runs already.
      container = makeContainer(
        onRoutingAsked: () {
          if (undoStarted) return;
          undoStarted = true;
          unawaited(gate().whileChangingAnywhere(() => undo.future));
        },
      );
      await addContainer('work', contextId: 'ctx-work');
      native.restrict('work', ['ctx-work', 'iso1_gone']);

      expect(await service().resume('work'), const ResumeBusy());
      expect(native.calls, isEmpty);
      expect(gate().isFrozen('work'), isTrue);

      undo.complete();
      await pumpEventQueue();
      expect(
        (await service().resume('work') as ResumeAttempted).resumed,
        isTrue,
      );
      expect(native.calls, ['release [iso1_gone]', 'resume work -']);
    });

    test('keeps a proxied container frozen while its proxy has no route '
        'out, though routing is installed', () async {
      container = makeContainer(routingCovers: false);
      await addContainer(
        'work',
        contextId: 'ctx-work',
        proxy: const TorProxyConnectionId(),
      );
      native.restrict('work', ['ctx-work']);

      expect(await service().resume('work'), const ResumeRoutingNotReady());
      expect(native.calls, isEmpty);
      expect(gate().isFrozen('work'), isTrue);
    });

    test("stops before lifting anything when an empty isolation group's "
        'release could not start', () async {
      await addContainer('work', contextId: 'ctx-work');
      native
        ..restrict('work', ['ctx-work', 'iso1_gone'])
        // Native could not write `releasing`: the group is still frozen.
        ..releaseFails = true;

      expect(
        await service().resume('work'),
        const ResumeIsolationCleanupFailed(),
      );
      expect(native.calls, ['release [iso1_gone]']);
      expect(gate().isFrozen('work'), isTrue);
      expect(
        gate().contextRecord('iso1_gone')?.phase,
        ContextFreezePhase.frozen,
      );
    });

    test('lifts an isolation group without a tab that a web app still uses '
        'with the container, its data kept', () async {
      await addContainer('work', contextId: 'ctx-work');
      native.restrict('work', ['ctx-work', 'iso1_app']);
      _answerWindows({'pwa': 'iso1_app'});

      final outcome = await service().resume('work');

      expect((outcome as ResumeAttempted).resumed, isTrue);
      expect(native.calls, ['resume work -']);
    });

    test('remembers the container of an isolation group it lifts without a '
        'tab, whose record named it until then', () async {
      await addContainer('work', contextId: 'ctx-work');
      await addTab(
        'iso',
        containerId: 'work',
        mode: TabMode.isolated('iso1_x'),
      );
      native.restrict('work', ['ctx-work', 'iso1_app', 'iso1_x']);
      _answerWindows({'pwa': 'iso1_app'});

      await service().resume('work');

      expect(gate().contextRecord('iso1_app'), isNull);
      final owners = container.read(storageOwnersProvider.notifier);
      expect((await owners.containerOwning('iso1_app'))?.id, 'work');
      // A group with a tab is found by its tab.
      expect((await owners.containerOwning('iso1_x'))?.id, 'work');
    });

    test('checks a container without a proxy of its own too, which can '
        'take the global one', () async {
      container = makeContainer(routingReady: false);
      await addContainer('work', contextId: 'ctx-work');
      native.restrict('work', ['ctx-work']);

      expect(await service().resume('work'), const ResumeRoutingNotReady());
      expect(native.calls, isEmpty);
      expect(gate().isFrozen('work'), isTrue);
    });

    test('checks every context native lifts, also an isolation group '
        'without a tab', () async {
      container = makeContainer(uncoveredContexts: {'iso1_held'});
      await addContainer('work', contextId: 'ctx-work');
      // A group a running Resume left behind: no tab, not released first.
      native
        ..restrict('work', ['ctx-work'])
        ..restrict('work', ['iso1_held'], phase: ContextFreezePhase.resuming);

      expect(await service().resume('work'), const ResumeRoutingNotReady());
      expect(routingAsked.single, unorderedEquals(['ctx-work', 'iso1_held']));
      expect(native.calls, isEmpty);
    });

    test('a retry after a Resume that lifted some contexts waits only for '
        'the routes of the ones still frozen', () async {
      // The container's proxy is down; the isolated tab's group has a route
      // of its own.
      container = makeContainer(uncoveredContexts: {'ctx-work'});
      await addContainer(
        'work',
        contextId: 'ctx-work',
        proxy: const TorProxyConnectionId(),
      );
      await addTab(
        'iso',
        containerId: 'work',
        mode: TabMode.isolated('iso1_x'),
      );
      // The first Resume lifted the container's own storage, not the group.
      native.restrict('work', ['iso1_x'], phase: ContextFreezePhase.resuming);

      final outcome = await service().resume('work');

      expect((outcome as ResumeAttempted).resumed, isTrue);
      expect(routingAsked, [
        ['iso1_x'],
      ]);
    });

    test('lifts nothing while the registry could not be read, which says '
        'nothing of what native holds or whose routes to check', () async {
      await addContainer('work', contextId: 'ctx-work');
      // An isolation group without a tab, which a web app still uses: only
      // native's registry knows the Resume would lift it.
      native
        ..restrict('work', ['ctx-work', 'iso1_app'])
        ..snapshotFails = true;
      _answerWindows({'pwa': 'iso1_app'});

      expect(await service().resume('work'), const ResumeFreezeStateUnknown());
      expect(routingAsked, isEmpty);
      expect(native.calls, isEmpty);
    });

    test('checks the route of an isolation group a web app still uses '
        'before lifting it, not that of one it releases', () async {
      container = makeContainer(uncoveredContexts: {'iso1_app'});
      await addContainer('work', contextId: 'ctx-work');
      native.restrict('work', ['ctx-work', 'iso1_gone', 'iso1_app']);
      _answerWindows({'pwa': 'iso1_app'});

      expect(await service().resume('work'), const ResumeRoutingNotReady());
      expect(routingAsked, [
        ['ctx-work'],
        ['iso1_app'],
      ]);
      // The empty group was released, which runs nothing; nothing was
      // lifted.
      expect(native.calls, ['release [iso1_gone]']);
      expect(gate().isFrozen('work'), isTrue);
    });

    test('is refused in recovery mode', () async {
      native.recovery = true;

      expect(await service().resume('work'), const ResumeRecoveryPending());
      expect(native.calls, isEmpty);
    });

    test('stops a running freeze ("Stop freezing and resume")', () async {
      await addContainer('work', contextId: 'ctx-work');
      native.freezeGate = Completer<void>();
      final freezing = service().freeze('work');
      await pumpEventQueue();

      final resumed = await service().resume('work');

      expect(resumed, isA<ResumeAttempted>());
      native.freezeGate!.complete();
      await freezing;
      expect(native.calls.first, startsWith('freeze work'));
      expect(native.calls[1], 'resume work -');
    });
  });

  group('page of a frozen web app window', () {
    setUp(() => container = makeContainer(recordOpenedTabs: true));

    _RecordingTabRepository tabs() =>
        container.read(tabRepositoryProvider.notifier)
            as _RecordingTabRepository;

    String? containerOf(TabContainerSelection selection) => switch (selection) {
      SpecificContainerTabSelection(:final container) => container.id,
      _ => null,
    };

    test('opens held in its isolation group, under the container whose '
        'freeze holds it, rather than as a link', () async {
      await addContainer('work', contextId: 'ctx-work');
      native
        ..restrict('work', ['ctx-work', 'iso1_app'])
        ..frozenWindowHandoff = FrozenWindowHandoff(
          contextId: 'iso1_app',
          url: 'https://app.example/inbox',
          private: false,
        );

      await service().openFrozenWindowHandoff();

      final opened = tabs().added.single;
      expect(opened.url, Uri.parse('https://app.example/inbox'));
      expect(opened.tabMode, TabMode.isolated('iso1_app'));
      expect(containerOf(opened.selection), 'work');
      expect(opened.selectTab, isTrue);
      // Nothing resumed: the tab's placeholder does that, routing first.
      expect(native.calls, isEmpty);
    });

    test("opens in a frozen container's own storage as a regular tab of "
        'it', () async {
      await addContainer('work', contextId: 'ctx-work');
      native
        ..restrict('work', ['ctx-work'])
        ..frozenWindowHandoff = FrozenWindowHandoff(
          contextId: 'ctx-work',
          url: 'https://app.example',
          private: false,
        );

      await service().openFrozenWindowHandoff();

      final opened = tabs().added.single;
      expect(opened.tabMode, TabMode.regular);
      expect(containerOf(opened.selection), 'work');
    });

    test('goes by the tabs of its isolation group once nothing holds '
        'it', () async {
      await addContainer('home', contextId: 'ctx-home');
      await addTab('h', containerId: 'home', mode: TabMode.isolated('iso1_g'));
      native.frozenWindowHandoff = FrozenWindowHandoff(
        contextId: 'iso1_g',
        url: 'https://app.example',
        private: false,
      );

      await service().openFrozenWindowHandoff();

      final opened = tabs().added.single;
      expect(opened.tabMode, TabMode.isolated('iso1_g'));
      expect(containerOf(opened.selection), 'home');
    });

    test("opens a private window's page in a private tab of the container, "
        'kept out of the session and the history', () async {
      await addContainer('work', contextId: 'ctx-work');
      native
        ..restrict('work', ['ctx-work'])
        ..frozenWindowHandoff = FrozenWindowHandoff(
          contextId: 'ctx-work',
          url: 'https://shared.example/article',
          private: true,
        );

      await service().openFrozenWindowHandoff();

      final opened = tabs().added.single;
      expect(opened.url, Uri.parse('https://shared.example/article'));
      expect(opened.tabMode, TabMode.private);
      expect(containerOf(opened.selection), 'work');
      expect(opened.selectTab, isTrue);
    });

    test('is opened once, and nothing is opened without one', () async {
      await addContainer('work', contextId: 'ctx-work');
      native.frozenWindowHandoff = FrozenWindowHandoff(
        contextId: 'ctx-work',
        url: 'https://app.example',
        private: false,
      );

      await service().openFrozenWindowHandoff();
      await service().openFrozenWindowHandoff();

      expect(tabs().added, hasLength(1));
    });

    test('opens nothing for a window that had no page', () async {
      await addContainer('work', contextId: 'ctx-work');
      native.frozenWindowHandoff = FrozenWindowHandoff(
        contextId: 'ctx-work',
        private: false,
      );

      await service().openFrozenWindowHandoff();

      expect(tabs().added, isEmpty);
    });
  });

  group('placeholder', () {
    test('a Resume that did not finish is told to the browser', () async {
      container = makeContainer(routingReady: false);
      await addContainer(
        'work',
        contextId: 'ctx-work',
        proxy: const TorProxyConnectionId(),
      );
      await addTab('a', containerId: 'work');
      native.restrict('work', ['ctx-work']);
      service();

      await events.onResumeRequested(1, 'a');
      await pumpEventQueue();

      expect(native.calls, isEmpty);
      expect(container.read(containerFreezeNoticesProvider), [
        ResumeNotFinished('work', const ResumeRoutingNotReady()),
      ]);
    });

    test('a tab whose isolation group was restored under another container '
        'resumes its own container first, then that one, and wakes with '
        'it', () async {
      container = makeContainer(
        states: {'h': TabState.$default('h').copyWith(contextId: 'iso1_s')},
      );
      await addContainer('work', contextId: 'ctx-work');
      await addContainer('home', contextId: 'ctx-home');
      await addTab('w', containerId: 'work', mode: TabMode.isolated('iso1_s'));
      await addTab('h', containerId: 'home', mode: TabMode.isolated('iso1_s'));
      native
        ..restrict('work', ['ctx-work', 'iso1_s'])
        ..restrict('home', ['ctx-home']);
      service();

      await events.onResumeRequested(1, 'h');
      await pumpEventQueue();

      expect(native.calls, ['resume home -', 'resume work h']);
      expect(container.read(containerFreezeNoticesProvider), isEmpty);
    });

    test('a tab of a container that is not frozen resumes only the '
        'container its storage was restored under', () async {
      container = makeContainer(
        states: {'h': TabState.$default('h').copyWith(contextId: 'iso1_s')},
      );
      await addContainer('work', contextId: 'ctx-work');
      await addContainer('shared');
      await addTab('w', containerId: 'work', mode: TabMode.isolated('iso1_s'));
      await addTab(
        'h',
        containerId: 'shared',
        mode: TabMode.isolated('iso1_s'),
      );
      native.restrict('work', ['ctx-work', 'iso1_s']);
      service();

      await events.onResumeRequested(1, 'h');
      await pumpEventQueue();

      expect(native.calls, ['resume work h']);
    });
  });

  group('resume and open', () {
    test('a navigation in a frozen tab waits for the answer and may run once '
        'the container resumed', () async {
      await addContainer('work', contextId: 'ctx-work');
      await addTab('t1', containerId: 'work');
      final requests = <ResumeAndOpenRequest>[];
      addTearDown(service().answerResumeAndOpenWith(requests.add));

      final mayRun = service().resumeForNavigation('t1');
      await pumpEventQueue();
      expect(requests.single.containerId, 'work');
      expect(requests.single.tabId, 't1');

      requests.single.complete(resumed: true);
      expect(await mayRun, isTrue);
    });

    test("names the container that holds the tab's storage, and Resume "
        "resumes the tab's own container first", () async {
      container = makeContainer(
        states: {'h': TabState.$default('h').copyWith(contextId: 'iso1_s')},
      );
      await addContainer('work', contextId: 'ctx-work');
      await addContainer('home', contextId: 'ctx-home');
      await addTab('w', containerId: 'work', mode: TabMode.isolated('iso1_s'));
      await addTab('h', containerId: 'home', mode: TabMode.isolated('iso1_s'));
      native
        ..restrict('work', ['ctx-work', 'iso1_s'])
        ..restrict('home', ['ctx-home']);
      final requests = <ResumeAndOpenRequest>[];
      addTearDown(service().answerResumeAndOpenWith(requests.add));

      final mayRun = service().resumeForNavigation('h');
      await pumpEventQueue();
      final request = requests.single;
      expect(request.containerId, 'work');

      final outcome = await service().resumeRequested(request);
      request.complete(resumed: (outcome as ResumeAttempted).resumed);

      expect(await mayRun, isTrue);
      expect(native.calls, ['resume home -', 'resume work h']);
    });

    test('a cancelled request leaves the navigation dropped', () async {
      await addContainer('work', contextId: 'ctx-work');
      await addTab('t1', containerId: 'work');
      addTearDown(
        service().answerResumeAndOpenWith(
          (request) => request.complete(resumed: false),
        ),
      );

      expect(await service().resumeForNavigation('t1'), isFalse);
    });

    test('only the newest screen is asked', () async {
      await addContainer('work', contextId: 'ctx-work');
      await addTab('t1', containerId: 'work');
      final older = <ResumeAndOpenRequest>[];
      final newer = <ResumeAndOpenRequest>[];
      addTearDown(service().answerResumeAndOpenWith(older.add));
      addTearDown(service().answerResumeAndOpenWith(newer.add));

      final mayRun = service().resumeForNavigation('t1');
      await pumpEventQueue();

      expect(older, isEmpty);
      newer.single.complete(resumed: false);
      expect(await mayRun, isFalse);
    });

    test('a screen that goes away before answering drops its request, so '
        'nothing waits for it', () async {
      await addContainer('work', contextId: 'ctx-work');
      await addTab('t1', containerId: 'work');
      final stopAnswering = service().answerResumeAndOpenWith((_) {});

      final mayRun = service().resumeForNavigation('t1');
      await pumpEventQueue();
      stopAnswering();

      expect(await mayRun, isFalse);
      expect(native.calls, isEmpty);
    });

    test('with no screen to ask on, the navigation is dropped', () async {
      await addContainer('work', contextId: 'ctx-work');
      await addTab('t1', containerId: 'work');

      expect(await service().resumeForNavigation('t1'), isFalse);
      expect(native.calls, isEmpty);
    });

    test(
      'a tab restricted while the frozen containers are restored, with '
      'no container to resume, says why its navigation did not run',
      () async {
        native.recovery = true;
        await addTab('loose', mode: TabMode.isolated('iso1_loose'));
        final requests = <ResumeAndOpenRequest>[];
        addTearDown(service().answerResumeAndOpenWith(requests.add));

        expect(await service().resumeForNavigation('loose'), isFalse);
        expect(requests, isEmpty);
        expect(container.read(containerFreezeNoticesProvider), [
          isA<NavigationWaitsForRecovery>(),
        ]);
      },
    );
  });

  group('a tapped web notification', () {
    test('wakes a storage nothing restricts without asking', () async {
      await addContainer('work', contextId: 'ctx-work');
      final requests = <ResumeAndOpenRequest>[];
      addTearDown(service().answerResumeAndOpenWith(requests.add));

      expect(
        await service().resumeStorageToOpen('ctx-work'),
        StorageOpening.open,
      );
      expect(requests, isEmpty);
      expect(container.read(containerFreezeNoticesProvider), isEmpty);
    });

    test('asks to resume the container whose freeze holds the storage, and a '
        'yes opens', () async {
      await addContainer('work', contextId: 'ctx-work');
      native.restrict('work', ['ctx-work']);
      final requests = <ResumeAndOpenRequest>[];
      addTearDown(service().answerResumeAndOpenWith(requests.add));

      final opening = service().resumeStorageToOpen('ctx-work');
      await pumpEventQueue();
      expect(requests.single.containerId, 'work');
      // A page that opens in a new tab, so no tab to wake.
      expect(requests.single.tabId, isNull);

      requests.single.complete(resumed: true);
      expect(await opening, StorageOpening.open);
    });

    test('an isolation group is asked about as its owner container', () async {
      await addContainer('work', contextId: 'ctx-work');
      await addTab(
        'iso',
        containerId: 'work',
        mode: TabMode.isolated('iso1_s'),
      );
      native.restrict('work', ['ctx-work', 'iso1_s']);
      final requests = <ResumeAndOpenRequest>[];
      addTearDown(service().answerResumeAndOpenWith(requests.add));

      final opening = service().resumeStorageToOpen('iso1_s');
      await pumpEventQueue();

      expect(requests.single.containerId, 'work');
      requests.single.complete(resumed: false);
      expect(await opening, StorageOpening.declined);
    });

    test('an isolation group left without a tab while frozen is not asked '
        'about: the Resume deletes its data', () async {
      await addContainer('work', contextId: 'ctx-work');
      native.restrict('work', ['ctx-work', 'iso1_gone']);
      final requests = <ResumeAndOpenRequest>[];
      addTearDown(service().answerResumeAndOpenWith(requests.add));

      expect(
        await service().resumeStorageToOpen('iso1_gone'),
        StorageOpening.dataBeingDeleted,
      );
      expect(requests, isEmpty);
      expect(native.calls, isEmpty);
      expect(container.read(containerFreezeNoticesProvider), [
        isA<NotificationSiteDataBeingDeleted>(),
      ]);
    });

    test('an isolation group a web app keeps is asked about', () async {
      await addContainer('work', contextId: 'ctx-work');
      native.restrict('work', ['ctx-work', 'iso1_app']);
      _answerWindows({'pwa': 'iso1_app'});
      final requests = <ResumeAndOpenRequest>[];
      addTearDown(service().answerResumeAndOpenWith(requests.add));

      final opening = service().resumeStorageToOpen('iso1_app');
      await pumpEventQueue();

      requests.single.complete(resumed: true);
      expect(await opening, StorageOpening.open);
    });

    test('an isolation group whose web app closed while the user was asked '
        'is gone after a yes', () async {
      await addContainer('work', contextId: 'ctx-work');
      native.restrict('work', ['ctx-work', 'iso1_app']);
      _answerWindows({'pwa': 'iso1_app'});
      final requests = <ResumeAndOpenRequest>[];
      addTearDown(service().answerResumeAndOpenWith(requests.add));

      final opening = service().resumeStorageToOpen('iso1_app');
      await pumpEventQueue();
      // The Resume found it unused, and released it.
      _answerWindows({});

      requests.single.complete(resumed: true);
      expect(await opening, StorageOpening.dataBeingDeleted);
      expect(container.read(containerFreezeNoticesProvider), [
        isA<NotificationSiteDataBeingDeleted>(),
      ]);
    });

    test('a cancel leaves it frozen and declined', () async {
      await addContainer('work', contextId: 'ctx-work');
      native.restrict('work', ['ctx-work']);
      addTearDown(
        service().answerResumeAndOpenWith(
          (request) => request.complete(resumed: false),
        ),
      );

      expect(
        await service().resumeStorageToOpen('ctx-work'),
        StorageOpening.declined,
      );
      expect(native.calls, isEmpty);
    });

    test('waits for a screen that is not up yet, as at a cold start', () async {
      await addContainer('work', contextId: 'ctx-work');
      native.restrict('work', ['ctx-work']);
      final opening = service().resumeStorageToOpen('ctx-work');
      await pumpEventQueue();

      final requests = <ResumeAndOpenRequest>[];
      addTearDown(service().answerResumeAndOpenWith(requests.add));
      await pumpEventQueue();

      requests.single.complete(resumed: true);
      expect(await opening, StorageOpening.open);
    });

    test('gives up on a screen that never comes, stays frozen, and tells the '
        'user once a screen is up', () async {
      await addContainer('work', contextId: 'ctx-work');
      native.restrict('work', ['ctx-work']);

      expect(
        await service().resumeStorageToOpen(
          'ctx-work',
          waitForScreen: const Duration(milliseconds: 20),
        ),
        StorageOpening.declined,
      );
      expect(native.calls, isEmpty);
      // Kept until the browser screen takes it: the notification stays, and
      // the next tap asks.
      expect(container.read(containerFreezeNoticesProvider), [
        isA<NotificationContainerFrozen>(),
      ]);
    });

    test('a cancel tells the user nothing', () async {
      await addContainer('work', contextId: 'ctx-work');
      native.restrict('work', ['ctx-work']);
      addTearDown(
        service().answerResumeAndOpenWith(
          (request) => request.complete(resumed: false),
        ),
      );

      await service().resumeStorageToOpen('ctx-work');

      expect(container.read(containerFreezeNoticesProvider), isEmpty);
    });

    test('storage that only waits for its data to be deleted has no container '
        'to resume: the user is told', () async {
      native.restrict('gone', [
        'ctx-gone',
      ], phase: ContextFreezePhase.releasing);
      final requests = <ResumeAndOpenRequest>[];
      addTearDown(service().answerResumeAndOpenWith(requests.add));

      expect(
        await service().resumeStorageToOpen('ctx-gone'),
        StorageOpening.dataBeingDeleted,
      );
      expect(requests, isEmpty);
      expect(container.read(containerFreezeNoticesProvider), [
        isA<NotificationSiteDataBeingDeleted>(),
      ]);
    });

    test('storage that only waits for its data to be deleted is not asked '
        'about while another storage of its container is frozen', () async {
      await addContainer('work', contextId: 'ctx-work');
      native
        ..restrict('work', ['ctx-work'])
        ..restrict('work', ['iso1_gone'], phase: ContextFreezePhase.releasing);
      final requests = <ResumeAndOpenRequest>[];
      addTearDown(service().answerResumeAndOpenWith(requests.add));

      expect(
        await service().resumeStorageToOpen('iso1_gone'),
        StorageOpening.dataBeingDeleted,
      );
      expect(requests, isEmpty);
    });

    test('an orphaned storage is the same', () async {
      native.restrict(null, ['ctx-orphan'], phase: ContextFreezePhase.orphaned);

      expect(
        await service().resumeStorageToOpen('ctx-orphan'),
        StorageOpening.dataBeingDeleted,
      );
    });

    test('while the frozen containers are restored, every storage waits and '
        'the user is told', () async {
      native.recovery = true;
      final requests = <ResumeAndOpenRequest>[];
      addTearDown(service().answerResumeAndOpenWith(requests.add));

      expect(
        await service().resumeStorageToOpen('ctx-work'),
        StorageOpening.waitsForRecovery,
      );
      expect(requests, isEmpty);
      expect(container.read(containerFreezeNoticesProvider), [
        isA<NavigationWaitsForRecovery>(),
      ]);
    });
  });

  group('storage owners', () {
    StorageOwners owners() => container.read(storageOwnersProvider.notifier);

    Future<void> closeAllTabs() async => owners().rememberDeletedTabs(
      (await db.tabDao.syncTabs(retainTabIds: [])).deletedIsolationContainers,
    );

    test('remember the container of an isolation group whose last tab '
        'closed', () async {
      await addContainer('work', contextId: 'ctx-work');
      await addTab(
        'iso',
        containerId: 'work',
        mode: TabMode.isolated('iso1_x'),
      );

      await closeAllTabs();

      expect((await owners().containerOwning('iso1_x'))?.id, 'work');
    });

    test('remember every container of a group whose last tabs closed '
        'together', () async {
      await addContainer('work', contextId: 'ctx-work');
      await addContainer('home', contextId: 'ctx-home');
      await addTab('a', containerId: 'work', mode: TabMode.isolated('iso1_x'));
      await addTab('b', containerId: 'home', mode: TabMode.isolated('iso1_x'));

      await closeAllTabs();

      expect(
        (await owners().lastContainersOf('iso1_x'))?.map((c) => c?.id),
        unorderedEquals(['work', 'home']),
      );
    });

    test('know a group whose last tabs were in no container', () async {
      await addTab('iso', mode: TabMode.isolated('iso1_x'));
      expect(await owners().hasTabs('iso1_x'), isTrue);

      await closeAllTabs();

      expect(await owners().hasTabs('iso1_x'), isFalse);
      expect(await owners().containerOwning('iso1_x'), isNull);
      expect(await owners().lastContainersOf('iso1_x'), [null]);
    });

    test('go by the tabs a group has, also when none of them is in a '
        'container', () async {
      await addContainer('work', contextId: 'ctx-work');
      await addTab('a', containerId: 'work', mode: TabMode.isolated('iso1_x'));
      await addTab('b', mode: TabMode.isolated('iso1_x'));

      owners().rememberDeletedTabs(
        (await db.tabDao.syncTabs(
          retainTabIds: ['b'],
        )).deletedIsolationContainers,
      );

      expect(await owners().containerOwning('iso1_x'), isNull);
    });

    test('forget a group once its data is deleted', () async {
      await addContainer('work', contextId: 'ctx-work');
      await addTab(
        'iso',
        containerId: 'work',
        mode: TabMode.isolated('iso1_x'),
      );
      await closeAllTabs();

      owners().forget('iso1_x');

      expect(await owners().containerOwning('iso1_x'), isNull);
      expect(await owners().lastContainersOf('iso1_x'), isNull);
    });

    test('do not know a group whose tabs closed before they were '
        'watched', () async {
      expect(await owners().containerOwning('iso1_x'), isNull);
      expect(await owners().lastContainersOf('iso1_x'), isNull);
    });

    test('do not know the last containers once one of them is '
        'deleted', () async {
      await addContainer('work', contextId: 'ctx-work');
      await addTab(
        'iso',
        containerId: 'work',
        mode: TabMode.isolated('iso1_x'),
      );
      await closeAllTabs();

      await (db.delete(db.container)..where((c) => c.id.equals('work'))).go();

      expect(await owners().lastContainersOf('iso1_x'), isNull);
    });
  });

  group('messages', () {
    test('a Resume that did not finish says what the engine still '
        'enforces', () async {
      await addContainer('work', contextId: 'ctx-work');
      native
        ..restrict('work', ['ctx-work'], phase: ContextFreezePhase.resuming)
        ..enforcement = EngineEnforcement.lifted
        ..resumeAnswer = (owner) =>
            native.result(owner, failure: LifecycleFailure.notPersisted);

      final outcome = await service().resume('work');

      expect(outcome, isA<ResumeAttempted>());
      outcome as ResumeAttempted;
      expect(outcome.resumed, isFalse);
      expect(outcome.enforcement, EngineEnforcement.lifted);
    });

    test('a Resume that finished carries no enforcement', () async {
      await addContainer('work', contextId: 'ctx-work');
      native.restrict('work', ['ctx-work']);

      final outcome = await service().resume('work') as ResumeAttempted;

      expect(outcome.resumed, isTrue);
      expect(outcome.enforcement, isNull);
    });
  });

  group('site data waiting to be deleted', () {
    test("lists a deleted container's releasing contexts together and each "
        'orphaned context alone', () async {
      native
        ..restrict('gone', ['a', 'b'], phase: ContextFreezePhase.releasing)
        ..restrict(null, ['o1', 'o2'], phase: ContextFreezePhase.orphaned)
        ..restrict('work', ['ctx-work']);
      // Listened, as the screens do: an unlistened stream provider pauses.
      container.listen(contextFreezeSnapshotProvider, (_, _) {});
      await container.read(contextFreezeSnapshotProvider.future);

      final pending = container.read(pendingSiteDataProvider).value;

      expect(pending, [
        PendingSiteData(
          ownerId: 'gone',
          contextIds: ['a', 'b'],
          orphaned: false,
        ),
        PendingSiteData(ownerId: null, contextIds: ['o1'], orphaned: true),
        PendingSiteData(ownerId: null, contextIds: ['o2'], orphaned: true),
      ]);
    });

    test('lists the closed isolated tabs of a container that still exists '
        'as its own', () async {
      await addContainer('work', contextId: 'ctx-work');
      native.restrict('work', [
        'iso1_gone',
      ], phase: ContextFreezePhase.releasing);
      container.listen(contextFreezeSnapshotProvider, (_, _) {});
      container.listen(watchContainersWithCountProvider, (_, _) {});
      await container.read(contextFreezeSnapshotProvider.future);
      await container.read(watchContainersWithCountProvider.future);

      expect(container.read(pendingSiteDataProvider).value, [
        PendingSiteData(
          ownerId: 'work',
          contextIds: ['iso1_gone'],
          orphaned: false,
          ownerExists: true,
          ownerName: 'work',
        ),
      ]);
      // Not frozen for it: nothing to show as frozen or to resume.
      expect(container.read(frozenContainersProvider).value, isEmpty);
    });

    test('Delete data releases the contexts and says whether all '
        'went', () async {
      native.restrict('gone', ['a'], phase: ContextFreezePhase.releasing);

      expect(await service().releasePendingSiteData(['a']), isTrue);
      expect(native.calls, ['release [a]']);

      native
        ..restrict('gone', ['b'], phase: ContextFreezePhase.releasing)
        ..releaseFails = true;
      expect(await service().releasePendingSiteData(['b']), isFalse);
    });
  });

  group('startup', () {
    test('reconciles the records with the containers that exist', () async {
      await addContainer('a', contextId: 'ctx-a');
      await addContainer('b');

      await service().reconcileAtStartup();
      await service().reconcileAtStartup();

      expect(native.calls, ['reconcile [a, b]']);
    });

    test('in recovery mode reconstructs every container with its own '
        'context, and releases the isolation contexts no such container '
        'owns', () async {
      native.recovery = true;
      await addContainer('work', contextId: 'ctx-work');
      await addContainer('shared');
      await addTab(
        'iso',
        containerId: 'work',
        mode: TabMode.isolated('iso1_w'),
      );
      await addTab('loose', mode: TabMode.isolated('iso1_loose'));
      await addTab(
        'inShared',
        containerId: 'shared',
        mode: TabMode.isolated('iso1_s'),
      );

      await service().reconcileAtStartup();

      expect(native.calls, [
        'reconstruct [work=[ctx-work, iso1_w]] unfreezable=[iso1_loose, iso1_s]',
      ]);
      expect(gate().isInRecovery(), isFalse);
      expect(gate().isFrozen('work'), isTrue);
      expect(gate().isFrozen('shared'), isFalse);
    });

    test('in recovery mode gives an isolation group two containers share to '
        'one of them only', () async {
      native.recovery = true;
      await addContainer('work', contextId: 'ctx-work');
      await addContainer('home', contextId: 'ctx-home');
      await addTab('w', containerId: 'work', mode: TabMode.isolated('iso1_s'));
      await addTab('h', containerId: 'home', mode: TabMode.isolated('iso1_s'));

      await service().reconcileAtStartup();

      expect(native.calls, hasLength(1));
      expect('iso1_s'.allMatches(native.calls.single), hasLength(1));
      expect(gate().isFrozen('work'), isTrue);
      expect(gate().isFrozen('home'), isTrue);
    });

    test('after the reconstruction the user hears how many containers were '
        'frozen to be safe', () async {
      native.recovery = true;
      await addContainer('work', contextId: 'ctx-work');
      await addContainer('home', contextId: 'ctx-home');

      await service().reconcileAtStartup();

      expect(container.read(containerFreezeNoticesProvider), [
        ContainersFrozenToBeSafe(2),
      ]);
      expect(
        container.read(freezeRecoveryProgressProvider),
        FreezeRecoveryStatus.none,
      );
      // Shown once.
      expect(container.read(containerFreezeNoticesProvider.notifier).take(), [
        ContainersFrozenToBeSafe(2),
      ]);
      expect(container.read(containerFreezeNoticesProvider), isEmpty);
    });

    test('a reconstruction that did not finish says so, and Retry runs it '
        'again', () async {
      native
        ..recovery = true
        ..reconstructionKeepsRecovery = true;
      await addContainer('work', contextId: 'ctx-work');

      await service().reconcileAtStartup();

      expect(container.read(containerFreezeNoticesProvider), [
        isA<FreezeRecoveryFailed>(),
      ]);
      expect(
        container.read(freezeRecoveryProgressProvider),
        FreezeRecoveryStatus.failed,
      );

      native.reconstructionKeepsRecovery = false;
      await service().retryRecovery();

      expect(
        native.calls.where((call) => call.startsWith('reconstruct')),
        hasLength(2),
      );
      expect(
        container.read(freezeRecoveryProgressProvider),
        FreezeRecoveryStatus.none,
      );
      expect(gate().isInRecovery(), isFalse);
    });

    test('a registry that could not be read decides nothing, and Retry '
        'reconstructs once it reads as in recovery', () async {
      native
        ..recovery = true
        ..snapshotFails = true;
      await addContainer('work', contextId: 'ctx-work');

      await service().reconcileAtStartup();

      expect(native.calls, isEmpty);
      expect(
        container.read(freezeRecoveryProgressProvider),
        FreezeRecoveryStatus.failed,
      );

      native.snapshotFails = false;
      await service().retryRecovery();

      expect(native.calls, ['reconstruct [work=[ctx-work]] unfreezable=[]']);
      expect(gate().isInRecovery(), isFalse);
    });

    test('a deletion interrupted while its container still exists is '
        'reported; one whose container is gone is not', () async {
      await addContainer('work', contextId: 'ctx-work');
      native
        ..restrict('work', [
          'ctx-work',
        ], phase: ContextFreezePhase.deletionPending)
        ..restrict('gone', [
          'ctx-gone',
        ], phase: ContextFreezePhase.deletionPending);

      await service().reconcileAtStartup();

      expect(container.read(containerFreezeNoticesProvider), [
        ContainerDeletionNotFinished(['work']),
      ]);
    });
  });
}
