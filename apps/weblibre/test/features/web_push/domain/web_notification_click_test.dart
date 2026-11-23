// ignore_for_file: riverpod_lint/avoid_public_notifier_properties

import 'dart:async';

import 'package:flutter/material.dart' show Colors;
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/features/geckoview/domain/providers.dart';
import 'package:weblibre/features/geckoview/domain/repositories/tab.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/services/proxy_settings_replication.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/services/startup_browsing_data_cleanup.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/models/container_data.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/entities/container_freeze.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/providers/container_freeze.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/services/container_freeze.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/services/container_membership_gate.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/services/storage_owners.dart';
import 'package:weblibre/features/proxy/domain/services/container_routing_snapshot.dart';
import 'package:weblibre/features/web_push/domain/providers.dart';
import 'package:weblibre/features/web_push/domain/services/web_notification_click.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _FakePushService push;
  late _FakeTabRepository tabs;
  late _FakeFreezeService freeze;
  late _FakeCleanup cleanup;
  late _FakeGate gate;
  late _FakeStorageOwners owners;
  late _FakeReplication replication;
  late ContainerRoutingSnapshot? routing;
  late ProviderContainer container;
  late List<String> calls;

  setUp(() {
    calls = [];
    push = _FakePushService(calls);
    tabs = _FakeTabRepository(calls);
    freeze = _FakeFreezeService(calls);
    cleanup = _FakeCleanup(calls);
    gate = _FakeGate(calls);
    owners = _FakeStorageOwners();
    replication = _FakeReplication(calls, () => routing);
    routing = _routing({});
    container = ProviderContainer(
      overrides: [
        pushServiceProvider.overrideWithValue(push),
        engineReadyStateProvider.overrideWith(_EngineReady.new),
        tabRepositoryProvider.overrideWith(() => tabs),
        containerFreezeServiceProvider.overrideWith(() => freeze),
        startupBrowsingDataCleanupProvider.overrideWith(() => cleanup),
        containerMembershipGateProvider.overrideWith(() => gate),
        storageOwnersProvider.overrideWith(() => owners),
        containerRoutingSnapshotProvider.overrideWith((ref) => routing),
        proxySettingsReplicationProvider.overrideWith(() => replication),
      ],
    );
    addTearDown(container.dispose);
  });

  List<ContainerFreezeNotice> notices() =>
      container.read(containerFreezeNoticesProvider);

  /// Starts the service as main.dart does, with the engine not ready yet.
  void start() {
    container.listen(webNotificationClickServiceProvider, (_, _) {});
  }

  void engineReady() =>
      (container.read(engineReadyStateProvider.notifier) as _EngineReady)
          .ready();

  test('a tap waits for the engine', () async {
    push.waiting.add(_click('a', 'gvctx.work'));

    start();
    await pumpEventQueue();

    expect(push.taken, 0);
    expect(push.delivered, isEmpty);

    engineReady();
    await pumpEventQueue();

    expect(push.delivered, ['a']);
  });

  test(
    "the route of the tap's storage is checked before it is delivered",
    () async {
      push.waiting.add(_click('a', 'gvctx.work'));

      start();
      engineReady();
      await pumpEventQueue();

      expect(tabs.routingAsked, [
        ['gvctx.work'],
      ]);
      expect(push.delivered, ['a']);
    },
  );

  test('a tap of the default storage checks the general route', () async {
    push.waiting.add(_click('a', null));

    start();
    engineReady();
    await pumpEventQueue();

    expect(tabs.routingAsked, [
      [generalContextId],
    ]);
    expect(push.delivered, ['a']);
  });

  test(
    'a tap is not delivered while no route is ready for its storage',
    () async {
      tabs.routingReady = false;
      push.waiting.add(_click('a', 'gvctx.work'));

      start();
      engineReady();
      await pumpEventQueue();

      expect(tabs.routingAsked, isNotEmpty);
      expect(push.delivered, isEmpty);
    },
  );

  test('every waiting tap is delivered, oldest first', () async {
    push.waiting.addAll([_click('a', null), _click('b', 'gvctx.work')]);

    start();
    engineReady();
    await pumpEventQueue();

    expect(push.delivered, ['a', 'b']);
  });

  test(
    'a tap that lands while another is being delivered is not left',
    () async {
      final gate = Completer<bool>();
      tabs.routingGate = gate;
      push.waiting.add(_click('a', null));

      start();
      engineReady();
      await pumpEventQueue();
      expect(push.delivered, isEmpty);

      // Parked after the loop's last take would have found nothing.
      push.waiting.add(_click('b', null));
      unawaited(
        container
            .read(webNotificationClickServiceProvider.notifier)
            .deliverWaitingClicks(),
      );

      tabs.routingGate = null;
      gate.complete(true);
      await pumpEventQueue();

      expect(push.delivered, ['a', 'b']);
    },
  );

  test('a failing pick-up is survived and the next one works', () async {
    push.failNextTake = true;
    push.waiting.add(_click('a', null));

    start();
    engineReady();
    await pumpEventQueue();
    expect(push.delivered, isEmpty);

    await container
        .read(webNotificationClickServiceProvider.notifier)
        .deliverWaitingClicks();

    expect(push.delivered, ['a']);
  });

  test('a refusal by native does not stop the taps behind it', () async {
    push.outcomes['a'] = NotificationClickOutcome.contextRestricted;
    push.waiting.addAll([_click('a', null), _click('b', null)]);

    start();
    engineReady();
    await pumpEventQueue();

    expect(push.delivered, ['a', 'b']);
  });

  group('a tap that fails', () {
    test('in the hand-over is released, its notification kept, and the taps '
        'behind it are delivered', () async {
      push.failDeliver.add('a');
      push.waiting.addAll([_click('a', null), _click('b', null)]);

      start();
      engineReady();
      await pumpEventQueue();

      expect(push.delivered, ['a', 'b']);
      expect(push.released, [('a', false)]);
    });

    test('before the hand-over is released all the same', () async {
      freeze.fail = true;
      push.waiting.addAll([_click('a', 'gvctx.work'), _click('b', null)]);

      start();
      engineReady();
      await pumpEventQueue();

      expect(push.delivered, ['b']);
      expect(push.released, [('a', false)]);
    });

    test('and cannot be released does not stop the taps behind it', () async {
      push
        ..failDeliver.add('a')
        ..failRelease = true;
      push.waiting.addAll([_click('a', null), _click('b', null)]);

      start();
      engineReady();
      await pumpEventQueue();

      expect(push.delivered, ['a', 'b']);
    });
  });

  group('the startup cleanup of browsing data', () {
    test('is started and waited for before a tap is handed over', () async {
      final done = Completer<void>();
      cleanup.done = done;
      push.waiting.add(_click('a', null));

      start();
      engineReady();
      await pumpEventQueue();

      // A cold start's tap can come before the browser screen starts it.
      expect(calls, ['cleanup start', 'cleanup wait']);
      expect(push.delivered, isEmpty);

      done.complete();
      await pumpEventQueue();

      expect(push.delivered, ['a']);
    });

    test('is not waited for by a tap that is not delivered', () async {
      tabs.routingReady = false;
      push.waiting.add(_click('a', null));

      start();
      engineReady();
      await pumpEventQueue();

      expect(calls, isEmpty);
    });
  });

  test('a tap with no route tells the user', () async {
    tabs.routingReady = false;
    push.waiting.add(_click('a', null));

    start();
    engineReady();
    await pumpEventQueue();

    expect(notices(), [isA<NotificationWaitsForRouting>()]);
  });

  test('a tap native refuses for a frozen storage reads the registry again '
      'and tells the user', () async {
    push.outcomes['a'] = NotificationClickOutcome.contextRestricted;
    push.waiting.add(_click('a', 'gvctx.work'));

    start();
    engineReady();
    await pumpEventQueue();

    // So that the next tap asks to resume.
    expect(calls, contains('gate refresh'));
    expect(notices(), [isA<NotificationContainerFrozen>()]);
    expect(push.released, [('a', false)]);
  });

  test('a delivered tap tells the user nothing', () async {
    push.waiting.add(_click('a', 'gvctx.work'));

    start();
    engineReady();
    await pumpEventQueue();

    expect(notices(), isEmpty);
  });

  group('a storage a freeze restricts', () {
    test(
      'is asked about before the route is checked, and a yes delivers',
      () async {
        push.waiting.add(_click('a', 'gvctx.work'));

        start();
        engineReady();
        await pumpEventQueue();

        expect(calls, [
          'freeze gvctx.work',
          'cleanup start',
          'cleanup wait',
          'route installed',
          'deliver a',
        ]);
        expect(push.released, isEmpty);
      },
    );

    test('the default storage is never asked about', () async {
      push.waiting.add(_click('a', null));

      start();
      engineReady();
      await pumpEventQueue();

      expect(freeze.asked, isEmpty);
      expect(push.delivered, ['a']);
    });

    test('a no leaves the notification showing and checks no route', () async {
      freeze.opening = StorageOpening.declined;
      push.waiting.add(_click('a', 'gvctx.work'));

      start();
      engineReady();
      await pumpEventQueue();

      expect(push.delivered, isEmpty);
      expect(tabs.routingAsked, isEmpty);
      expect(push.released, [('a', false)]);
    });

    test('recovery leaves the notification showing', () async {
      freeze.opening = StorageOpening.waitsForRecovery;
      push.waiting.add(_click('a', 'gvctx.work'));

      start();
      engineReady();
      await pumpEventQueue();

      expect(push.delivered, isEmpty);
      expect(push.released, [('a', false)]);
    });

    test('data waiting to be deleted takes the notification with it', () async {
      freeze.opening = StorageOpening.dataBeingDeleted;
      push.waiting.add(_click('a', 'gvctx.work'));

      start();
      engineReady();
      await pumpEventQueue();

      expect(push.delivered, isEmpty);
      expect(tabs.routingAsked, isEmpty);
      expect(push.released, [('a', true)]);
    });

    test('a refusal does not stop the taps behind it', () async {
      freeze.opening = StorageOpening.declined;
      push.waiting.addAll([_click('a', 'gvctx.work'), _click('b', null)]);

      start();
      engineReady();
      await pumpEventQueue();

      expect(push.delivered, ['b']);
      expect(push.released, [('a', false)]);
    });
  });

  test('a tap with no route is released, its notification kept', () async {
    tabs.routingReady = false;
    push.waiting.add(_click('a', null));

    start();
    engineReady();
    await pumpEventQueue();

    expect(push.released, [('a', false)]);
  });

  test('a tap native refuses is released, its notification kept', () async {
    push.outcomes['a'] = NotificationClickOutcome.contextRestricted;
    push.waiting.add(_click('a', null));

    start();
    engineReady();
    await pumpEventQueue();

    expect(push.released, [('a', false)]);
  });

  test('a delivered tap is not released', () async {
    push.waiting.add(_click('a', null));

    start();
    engineReady();
    await pumpEventQueue();

    expect(push.released, isEmpty);
  });

  test('a private tap checks the private route', () async {
    push.waiting.add(_click('a', null, private: true));

    start();
    engineReady();
    await pumpEventQueue();

    expect(tabs.routingAsked, [
      [privateContextId],
    ]);
    expect(push.delivered, ['a']);
  });

  group('an isolation group with no tab left', () {
    const group = 'iso1_group';

    test(
      "is not delivered while it would take another route than its container's",
      () async {
        routing = _routing({
          generalContextId: ['tor'],
          'gvctx.work': ['proxy-1'],
        });
        owners.lastContainers = [_container('work', 'gvctx.work')];
        push.waiting.add(_click('a', group));

        start();
        engineReady();
        await pumpEventQueue();

        expect(push.delivered, isEmpty);
        expect(push.released, [('a', false)]);
        expect(notices(), [isA<NotificationGroupWithoutRoute>()]);
      },
    );

    test('is delivered when its container takes the general route', () async {
      routing = _routing({
        generalContextId: ['tor'],
      });
      owners.lastContainers = [_container('work', 'gvctx.work')];
      push.waiting.add(_click('a', group));

      start();
      engineReady();
      await pumpEventQueue();

      expect(push.delivered, ['a']);
    });

    test('is not delivered while its containers are not known', () async {
      routing = _routing({
        generalContextId: ['tor'],
      });
      push.waiting.add(_click('a', group));

      start();
      engineReady();
      await pumpEventQueue();

      expect(push.delivered, isEmpty);
      expect(push.released, [('a', false)]);
      expect(notices(), [isA<NotificationGroupWithoutRoute>()]);
    });

    test('is delivered when it belongs to no container', () async {
      routing = _routing({
        generalContextId: ['tor'],
      });
      owners.lastContainers = [null];
      push.waiting.add(_click('a', group));

      start();
      engineReady();
      await pumpEventQueue();

      expect(push.delivered, ['a']);
    });

    test('is not delivered while its last containers took different '
        'routes', () async {
      routing = _routing({
        generalContextId: ['tor'],
        'gvctx.work': ['proxy-1'],
      });
      owners.lastContainers = [
        _container('home', 'gvctx.home'),
        _container('work', 'gvctx.work'),
      ];
      push.waiting.add(_click('a', group));

      start();
      engineReady();
      await pumpEventQueue();

      expect(push.delivered, isEmpty);
      expect(notices(), [isA<NotificationGroupWithoutRoute>()]);
    });

    test('is not delivered while no routing is computed', () async {
      routing = null;
      owners.lastContainers = [_container('work', 'gvctx.work')];
      push.waiting.add(_click('a', group));

      start();
      engineReady();
      await pumpEventQueue();

      expect(push.delivered, isEmpty);
      expect(push.released, [('a', false)]);
    });
  });

  group('the route Gecko enforces', () {
    test(
      'is checked after the startup cleanup, right before delivery',
      () async {
        push.waiting.add(_click('a', 'gvctx.work'));

        start();
        engineReady();
        await pumpEventQueue();

        expect(calls, [
          'freeze gvctx.work',
          'cleanup start',
          'cleanup wait',
          'route installed',
          'deliver a',
        ]);
      },
    );

    test(
      'holds a tap back while it is older than the routing Dart computes',
      () async {
        // The group's route is computed, but Gecko still holds a snapshot in
        // which it inherits the direct general route.
        routing = _routing({
          generalContextId: [],
          'iso1_group': ['proxy-1'],
        });
        replication.installed = _routing({generalContextId: []});
        push.waiting.add(_click('a', 'iso1_group'));

        start();
        engineReady();
        await pumpEventQueue();

        expect(push.delivered, isEmpty);
        expect(push.released, [('a', false)]);
        expect(notices(), [isA<NotificationWaitsForRouting>()]);
      },
    );

    test('holds a tap back while native says its route cannot carry '
        'traffic', () async {
      push.outcomes['a'] = NotificationClickOutcome.routeUnavailable;
      push.waiting.add(_click('a', 'gvctx.work'));

      start();
      engineReady();
      await pumpEventQueue();

      expect(push.released, [('a', false)]);
      expect(notices(), [isA<NotificationWaitsForRouting>()]);
    });

    test('holds a tap back when the routing changed while it waited for '
        'Gecko', () async {
      // Direct when the tap started waiting; the user switched to a proxy
      // before Gecko acknowledged anything newer than the direct route.
      routing = _routing({generalContextId: []});
      replication
        ..installed = _routing({generalContextId: []})
        ..whileWaiting = () {
          routing = _routing({
            generalContextId: ['proxy-1'],
          });
          container.invalidate(containerRoutingSnapshotProvider);
        };
      push.waiting.add(_click('a', 'gvctx.work'));

      start();
      engineReady();
      await pumpEventQueue();

      expect(push.delivered, isEmpty);
      expect(push.released, [('a', false)]);
      expect(notices(), [isA<NotificationWaitsForRouting>()]);
    });

    test('delivers a tap once Gecko holds the routing that changed while it '
        'waited', () async {
      routing = _routing({generalContextId: []});
      replication.whileWaiting = () {
        routing = _routing({
          generalContextId: ['proxy-1'],
        });
        container.invalidate(containerRoutingSnapshotProvider);
        replication.installed = routing;
      };
      push.waiting.add(_click('a', 'gvctx.work'));

      start();
      engineReady();
      await pumpEventQueue();

      expect(push.delivered, ['a']);
    });

    test('a private tap waits for the private route', () async {
      routing = _routing({
        privateContextId: ['tor'],
      });
      replication.installed = _routing({});
      push.waiting.add(_click('a', null, private: true));

      start();
      engineReady();
      await pumpEventQueue();

      expect(push.delivered, isEmpty);
    });
  });

  test('a group with tabs takes the route routing derives from them', () async {
    routing = _routing({
      generalContextId: ['tor'],
      'gvctx.work': ['proxy-1'],
    });
    owners.tabs = true;
    push.waiting.add(_click('a', 'iso1_group'));

    start();
    engineReady();
    await pumpEventQueue();

    expect(push.delivered, ['a']);
  });

  test('a group with a route of its own is delivered', () async {
    routing = _routing({
      generalContextId: ['tor'],
      'iso1_group': ['proxy-1'],
    });
    owners.lastContainers = [_container('work', 'gvctx.work')];
    push.waiting.add(_click('a', 'iso1_group'));

    start();
    engineReady();
    await pumpEventQueue();

    expect(push.delivered, ['a']);
  });

  group('a deleted container whose site data was kept', () {
    test('takes its notification with it, and the user is told', () async {
      owners.deleted.add('gvctx.gone');
      routing = _routing({generalContextId: []});
      push.waiting.add(_click('a', 'gvctx.gone'));

      start();
      engineReady();
      await pumpEventQueue();

      // Routing has no route of its own for it, and the general one is not
      // the one its pages took.
      expect(push.delivered, isEmpty);
      expect(push.released, [('a', true)]);
      expect(notices(), [isA<NotificationContainerDeleted>()]);
    });

    test('while the tap waits takes its notification with it, though the '
        'general route it falls back to is installed', () async {
      routing = _routing({
        'gvctx.work': ['proxy-1'],
      });
      replication.whileWaiting = () {
        // Deleted, its data kept: routing has no entry for it any more.
        owners.deleted.add('gvctx.work');
        routing = _routing({generalContextId: []});
        container.invalidate(containerRoutingSnapshotProvider);
        replication.installed = routing;
      };
      push.waiting.add(_click('a', 'gvctx.work'));

      start();
      engineReady();
      await pumpEventQueue();

      expect(push.delivered, isEmpty);
      expect(push.released, [('a', true)]);
      expect(notices(), [isA<NotificationContainerDeleted>()]);
    });

    test('is not the default storage, which has no container', () async {
      owners.deleted.add(generalContextId);
      push.waiting.add(_click('a', null));

      start();
      engineReady();
      await pumpEventQueue();

      expect(push.delivered, ['a']);
    });
  });

  group('the routing generation', () {
    test('Gecko acknowledged the route in is handed to native', () async {
      replication.generation = 41;
      push.waiting.add(_click('a', 'gvctx.work'));

      start();
      engineReady();
      await pumpEventQueue();

      expect(push.generations, {'a': 41});
    });

    test(
      'moving on while ownership is read again holds the tap back',
      () async {
        var lookUps = 0;
        owners.onLookUp = () {
          // The second look-up is the one after the wait: a push lands then.
          if (++lookUps == 2) replication.generation++;
        };
        push.waiting.add(_click('a', 'gvctx.work'));

        start();
        engineReady();
        await pumpEventQueue();

        expect(push.delivered, isEmpty);
        expect(push.released, [('a', false)]);
        expect(notices(), [isA<NotificationWaitsForRouting>()]);
      },
    );

    test('native no longer holds keeps the notification', () async {
      push.outcomes['a'] = NotificationClickOutcome.routingChanged;
      push.waiting.add(_click('a', 'gvctx.work'));

      start();
      engineReady();
      await pumpEventQueue();

      expect(push.released, [('a', false)]);
      expect(notices(), [isA<NotificationWaitsForRouting>()]);
    });
  });

  test('a tap whose notification was replaced or closed is not released and '
      'tells the user nothing', () async {
    push.outcomes['a'] = NotificationClickOutcome.superseded;
    push.waiting.add(_click('a', 'gvctx.work'));

    start();
    engineReady();
    await pumpEventQueue();

    // Native ended it, and left the replacement showing.
    expect(push.released, isEmpty);
    expect(notices(), isEmpty);
  });
}

NotificationClickHandoff _click(
  String id,
  String? contextId, {
  bool private = false,
}) => NotificationClickHandoff(
  clickId: id,
  contextId: contextId,
  private: private,
);

/// Every proxy [relations] name is starting.
ContainerRoutingSnapshot _routing(Map<String, List<String>> relations) =>
    ContainerRoutingSnapshot(
      proxies: const [],
      relations: relations,
      directScopes: const {},
      siteAssignments: const {},
      strictContexts: const {},
      awaitingProxyIds: {
        for (final route in relations.values) ...route,
      }.toList(),
    );

ContainerData _container(String id, String contextId) => ContainerData(
  id: id,
  name: id,
  color: Colors.blue,
  orderKey: id,
  metadata: ContainerMetadata.withDefaults(contextualIdentity: contextId),
);

class _FakeStorageOwners extends StorageOwners {
  bool tabs = false;
  List<ContainerData?>? lastContainers;
  final asked = <String>[];

  /// Storages whose container was deleted; every other has one.
  final deleted = <String>{};

  /// Runs on every look-up of an owner, before it answers.
  void Function()? onLookUp;

  @override
  void build() {}

  @override
  Future<ContainerData?> containerOwning(String contextId) async {
    onLookUp?.call();
    return deleted.contains(contextId) ? null : _container('owner', contextId);
  }

  @override
  Future<bool> hasTabs(String contextId) async {
    asked.add(contextId);
    return tabs;
  }

  @override
  Future<List<ContainerData?>?> lastContainersOf(String contextId) async =>
      lastContainers;
}

/// Gecko holds [installed], or by default the snapshot Dart computes.
class _FakeReplication extends ProxySettingsReplication {
  _FakeReplication(this.calls, this.computed);

  final List<String> calls;
  final ContainerRoutingSnapshot? Function() computed;
  ContainerRoutingSnapshot? installed;

  /// Runs while a tap waits for its route, before Gecko acknowledges.
  void Function()? whileWaiting;

  @override
  void build() {}

  @override
  Future<bool> waitUntilInstalled(
    bool Function(ContainerRoutingSnapshot installed) test, {
    required Duration timeout,
  }) async {
    calls.add('route installed');
    whileWaiting?.call();
    return installedSatisfies(test);
  }

  @override
  bool installedSatisfies(
    bool Function(ContainerRoutingSnapshot snapshot) test,
  ) {
    final snapshot = installed ?? computed();
    return snapshot != null && test(snapshot);
  }

  /// The generation of what Gecko holds.
  int generation = 7;

  @override
  int? installedGenerationIf(
    bool Function(ContainerRoutingSnapshot snapshot) test,
  ) => installedSatisfies(test) ? generation : null;
}

class _EngineReady extends EngineReadyState {
  @override
  bool build() => false;

  void ready() => state = true;
}

class _FakeTabRepository extends TabRepository {
  _FakeTabRepository(this.calls);

  final List<String> calls;
  final routingAsked = <List<String>>[];
  bool routingReady = true;
  Completer<bool>? routingGate;

  @override
  void build() {}

  @override
  Future<bool> ensureRoutingReadyForContexts(Iterable<String> contextIds) {
    routingAsked.add(contextIds.toList());
    final gate = routingGate;
    return gate?.future ?? Future.value(routingReady);
  }
}

class _FakeCleanup extends StartupBrowsingDataCleanup {
  _FakeCleanup(this.calls);

  final List<String> calls;
  Completer<void>? done;

  @override
  void build() {}

  @override
  Future<void> start() async => calls.add('cleanup start');

  @override
  Future<void> waitUntilDone() async {
    calls.add('cleanup wait');
    await done?.future;
  }
}

class _FakeGate extends ContainerMembershipGate {
  _FakeGate(this.calls);

  final List<String> calls;

  @override
  void build() {}

  @override
  Future<void> refresh() async => calls.add('gate refresh');
}

class _FakeFreezeService extends ContainerFreezeService {
  _FakeFreezeService(this.calls);

  final List<String> calls;
  final List<String> asked = [];
  StorageOpening opening = StorageOpening.open;
  bool fail = false;

  @override
  void build() {}

  @override
  Future<StorageOpening> resumeStorageToOpen(
    String contextId, {
    Duration waitForScreen = Duration.zero,
  }) async {
    asked.add(contextId);
    calls.add('freeze $contextId');
    if (fail) throw StateError('registry unreadable');
    return opening;
  }
}

class _FakePushService extends GeckoPushService {
  _FakePushService(this.calls);

  final List<String> calls;
  final List<NotificationClickHandoff> waiting = [];
  final List<String> delivered = [];
  final List<(String, bool)> released = [];
  final Map<String, NotificationClickOutcome> outcomes = {};
  int taken = 0;
  bool failNextTake = false;
  final Set<String> failDeliver = {};
  bool failRelease = false;

  @override
  Future<NotificationClickHandoff?> takeNotificationClick() async {
    taken++;
    if (failNextTake) {
      failNextTake = false;
      throw StateError('channel not up');
    }
    return waiting.isEmpty ? null : waiting.removeAt(0);
  }

  @override
  Future<void> releaseNotificationClick(
    String clickId, {
    required bool dismissNotification,
  }) async {
    if (failRelease) throw StateError('channel not up');
    released.add((clickId, dismissNotification));
  }

  /// The routing generation each delivery named, by tap.
  final Map<String, int> generations = {};

  @override
  Future<NotificationClickOutcome> deliverNotificationClick(
    String clickId, {
    required int routingGeneration,
  }) async {
    generations[clickId] = routingGeneration;
    delivered.add(clickId);
    calls.add('deliver $clickId');
    if (failDeliver.contains(clickId)) throw StateError('channel not up');
    return outcomes[clickId] ?? NotificationClickOutcome.delivered;
  }
}
