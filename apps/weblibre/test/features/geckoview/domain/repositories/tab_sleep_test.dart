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

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/data/database/functions/lexo_rank_functions.dart';
import 'package:weblibre/data/database/functions/url_functions.dart';
import 'package:weblibre/features/geckoview/domain/entities/states/tab.dart';
import 'package:weblibre/features/geckoview/domain/entities/tab_wake.dart';
import 'package:weblibre/features/geckoview/domain/providers/desktop_mode.dart';
import 'package:weblibre/features/geckoview/domain/providers/restore_complete.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_detail_state.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_session.dart';
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
import 'package:weblibre/features/geckoview/features/tabs/domain/repositories/tab.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/services/tab_sleep_policy_replication.dart';
import 'package:weblibre/features/proxy/data/proxy_connection.dart';
import 'package:weblibre/features/proxy/domain/repositories/container_proxy.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';

// Every API of gecko.g.dart shares one codec; this one is exported.
const _codec = GeckoTrackingProtectionApi.pigeonChannelCodec;
const _prefix = 'dev.flutter.pigeon.flutter_mozilla_components';

List<Object?> _ok([Object? value]) => <Object?>[value];

/// Native's tab lifecycle and session commands, recording what reached it
/// and in which order.
class _FakeNative {
  final calls = <String>[];
  final policies = <TabSleepPolicy>[];
  final _channels = <String>[];

  /// The tab native has selected.
  String? selected;

  /// Each tab's lifecycle as native has it, ahead of the events to Dart.
  final lifecycle = <String, TabLifecycleState>{};

  /// Tabs whose context the installed routing does not cover (a proxy
  /// without an endpoint): native refuses to wake them.
  final uncovered = <String>{};

  void _handle(String method, FutureOr<Object?> Function(List<Object?>) on) {
    final name = '$_prefix.$method';
    _channels.add(name);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockDecodedMessageHandler<Object?>(
          BasicMessageChannel<Object?>(name, _codec),
          (message) async => await on((message as List<Object?>?) ?? const []),
        );
  }

  void install() {
    _handle('GeckoTabLifecycleApi.wakeTab', (args) {
      if (uncovered.contains(args[0])) return _ok(false);
      // A frozen container's tab keeps its hold.
      if (lifecycle[args[0]]?.contextFrozen ?? false) return _ok(false);
      calls.add('wake ${args[0]}');
      return _ok(true);
    });
    _handle(
      'GeckoTabLifecycleApi.getTabLifecycleState',
      (args) => _ok(lifecycle[args[0]]),
    );
    _handle('GeckoTabLifecycleApi.setSleepPolicy', (args) {
      policies.add(args[0]! as TabSleepPolicy);
      return _ok();
    });
    _handle('GeckoTabsApi.getSelectedTabId', (_) => _ok(selected));
    for (final method in ['loadUrl', 'reload', 'goBack', 'goForward']) {
      _handle('GeckoSessionApi.$method', (args) {
        calls.add('$method ${args[0]}');
        return _ok();
      });
    }
    _handle('GeckoSessionApi.requestDesktopSite', (args) {
      calls.add('desktop ${args[0]} ${args[1]}');
      return _ok();
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

class _TestTabRepository extends TabRepository {
  @override
  void build() {}
}

/// No tab states until a test puts one.
class _TabStates extends TabStates {
  @override
  Map<String, TabState> build() => const {};

  void put(TabState tab) => state = {...state, tab.id: tab};
}

class _RestoreComplete extends BrowserRestoreComplete {
  @override
  bool build() => true;
}

/// Whether [_Routing] is installed; each test starts with it installed.
var _routingInstalled = true;

/// Routing that is installed unless [_routingInstalled] says otherwise;
/// whether it covers a tab is native's answer ([_FakeNative.uncovered]).
class _Routing extends ContainerProxyRepository {
  @override
  void build() {}

  @override
  Future<bool> waitUntilRoutingReady({
    Duration timeout = const Duration(seconds: 1),
  }) async => _routingInstalled;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late TabDatabase db;
  late _FakeNative native;
  late ProviderContainer container;

  setUp(() {
    _routingInstalled = true;
    db = TabDatabase(
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
    container = ProviderContainer(
      overrides: [
        tabDatabaseProvider.overrideWith((ref) => db),
        tabRepositoryProvider.overrideWith(_TestTabRepository.new),
        tabStatesProvider.overrideWith(_TabStates.new),
        browserRestoreCompleteProvider.overrideWith(_RestoreComplete.new),
        containerProxyRepositoryProvider.overrideWith(_Routing.new),
        generalSettingsWithDefaultsProvider.overrideWith(
          (ref) => GeneralSettings.withDefaults(
            autoSleepTabs: true,
            autoSleepIdleMinutes: 10,
            residentTabLimit: 6,
            desktopModeSites: ['ruled.example'],
          ),
        ),
      ],
    );
    addTearDown(container.dispose);
  });

  Future<void> addTab(String id, {String? containerId}) => db.tabDao.insertTab(
    id,
    source: TabSource.manual,
    parentId: const Value(null),
    containerId: Value(containerId),
  );

  TabLifecycleState lifecycleOf(String tabId, TabSleepHold hold) =>
      TabLifecycleState(
        tabId: tabId,
        residency: hold == TabSleepHold.none
            ? TabResidency.resident
            : TabResidency.unloaded,
        sleepHold: hold,
        operation: LifecycleOperationState.idle,
        contextFrozen: false,
      );

  /// [tabId] holds [hold] in native, and its event reached Dart.
  void reportLifecycle(String tabId, TabSleepHold hold) {
    native.lifecycle[tabId] = lifecycleOf(tabId, hold);
    container
        .read(tabLifecycleStatesProvider.notifier)
        .update(lifecycleOf(tabId, hold));
  }

  TabRepository repository() => container.read(tabRepositoryProvider.notifier);

  test(
    'a navigation into a sleeping tab wakes it first, then runs once',
    () async {
      await addTab('a');
      reportLifecycle('a', TabSleepHold.manual);

      await container
          .read(tabSessionProvider(tabId: 'a').notifier)
          .loadUrl(url: Uri.parse('https://example.com'));

      expect(native.calls, ['wake a', 'loadUrl a']);
    },
  );

  test('a navigation in the selected tab wakes and loads the tab native has '
      'selected, which Dart may not have heard of yet', () async {
    await addTab('b');
    reportLifecycle('b', TabSleepHold.manual);
    native.selected = 'b';

    await container
        .read(tabSessionProvider(tabId: null).notifier)
        .loadUrl(url: Uri.parse('https://example.com'));

    expect(native.calls, ['wake b', 'loadUrl b']);
  });

  test('a navigation into a sleeping tab whose routing is not ready runs '
      'nothing, and says why', () async {
    _routingInstalled = false;
    await addTab('a');
    reportLifecycle('a', TabSleepHold.manual);

    await container
        .read(tabSessionProvider(tabId: 'a').notifier)
        .loadUrl(url: Uri.parse('https://example.com'));

    expect(native.calls, isEmpty);
    expect(container.read(containerFreezeNoticesProvider), [
      isA<NavigationWaitsForRouting>(),
    ]);
  });

  test('a navigation into an awake tab does not wake anything', () async {
    await addTab('a');
    reportLifecycle('a', TabSleepHold.none);

    await container.read(tabSessionProvider(tabId: 'a').notifier).reload();

    expect(native.calls, ['reload a']);
  });

  test('a navigation goes by the hold native placed, before its event '
      'reaches Dart', () async {
    await addTab('a');
    reportLifecycle('a', TabSleepHold.none);
    native.lifecycle['a'] = lifecycleOf('a', TabSleepHold.manual);

    await container
        .read(tabSessionProvider(tabId: 'a').notifier)
        .loadUrl(url: Uri.parse('https://example.com'));

    expect(native.calls, ['wake a', 'loadUrl a']);
  });

  test('back and forward wake a sleeping tab too', () async {
    await addTab('a');
    reportLifecycle('a', TabSleepHold.manual);

    await container.read(tabSessionProvider(tabId: 'a').notifier).goBack();

    expect(native.calls, ['wake a', 'goBack a']);
  });

  test('a sleeping tab whose routing is not ready stays asleep, and the '
      'navigation does not run', () async {
    await db.containerDao.addContainer(
      ContainerData(
        id: 'proxied',
        name: 'proxied',
        color: Colors.blue,
        orderKey: 'a',
        metadata: ContainerMetadata.withDefaults(
          proxyConnectionId: const TorProxyConnectionId(),
        ),
      ),
    );
    await addTab('a', containerId: 'proxied');
    reportLifecycle('a', TabSleepHold.manual);
    native.uncovered.add('a');

    await container
        .read(tabSessionProvider(tabId: 'a').notifier)
        .loadUrl(url: Uri.parse('https://example.com'));

    expect(native.calls, isEmpty);
  });

  group('Desktop Site', () {
    test('a toggle the user made wakes a sleeping tab and applies, as a '
        'navigation does', () async {
      await addTab('a');
      reportLifecycle('a', TabSleepHold.manual);
      final desktop = desktopModeProvider('a');
      container.listen(desktop, (_, _) {});

      await container.read(desktop.notifier).toggle();

      expect(native.calls, ['wake a', 'desktop a true']);
      expect(container.read(desktop), isTrue);
    });

    test('a toggle in a tab that stays asleep changes nothing, the mode '
        'shown included', () async {
      await addTab('a');
      reportLifecycle('a', TabSleepHold.manual);
      native.uncovered.add('a');
      final desktop = desktopModeProvider('a');
      container.listen(desktop, (_, _) {});

      await container.read(desktop.notifier).enabled(true);

      expect(native.calls, isEmpty);
      expect(container.read(desktop), isFalse);
    });

    test('the per-site rule applies on its own, never waking a tab', () async {
      await addTab('a');
      reportLifecycle('a', TabSleepHold.manual);
      final states = container.read(tabStatesProvider.notifier) as _TabStates;
      states.put(
        TabState.$default(
          'a',
        ).copyWith(url: Uri.parse('https://other.example')),
      );
      final desktop = desktopModeProvider('a');
      container.listen(desktop, (_, _) {});

      states.put(
        TabState.$default(
          'a',
        ).copyWith(url: Uri.parse('https://ruled.example')),
      );
      await pumpEventQueue();

      expect(native.calls, ['desktop a true']);
      expect(container.read(desktop), isTrue);
    });
  });

  test('Wake on the placeholder wakes once routing is ready', () async {
    await addTab('a');

    expect(await repository().wakeTab('a'), TabWakeOutcome.woken);
    expect(native.calls, ['wake a']);
  });

  test('Wake leaves a tab asleep while routing is not installed, whatever its '
      'container', () async {
    _routingInstalled = false;
    await addTab('a');

    expect(await repository().wakeTab('a'), TabWakeOutcome.routingNotReady);
    expect(native.calls, isEmpty);
  });

  test('Wake leaves a tab asleep that its own routing does not cover, as a '
      'pane does', () async {
    // An isolated tab with a route of its own, in a container without one:
    // only native knows the tab's verdict.
    await addTab('a');
    native.uncovered.add('a');

    expect(await repository().wakeTab('a'), TabWakeOutcome.routingNotReady);
    expect(native.calls, isEmpty);
  });

  test("Wake leaves a frozen container's tab asleep, and says so", () async {
    await addTab('a');
    native.lifecycle['a'] = TabLifecycleState(
      tabId: 'a',
      residency: TabResidency.unloaded,
      sleepHold: TabSleepHold.manual,
      operation: LifecycleOperationState.idle,
      contextFrozen: true,
    );

    expect(await repository().wakeTab('a'), TabWakeOutcome.containerFrozen);
    expect(native.calls, isEmpty);
  });

  group('automatic sleep', () {
    test('"Keep awake" is stored per tab and read back', () async {
      await addTab('a');
      await addTab('b');
      final tabs = container.read(tabDataRepositoryProvider.notifier);

      await tabs.setSleepExempt('a', exempt: true);
      expect(await db.tabDao.getSleepExemptTabIds().get(), ['a']);

      await tabs.setSleepExempt('a', exempt: false);
      expect(await db.tabDao.getSleepExemptTabIds().get(), isEmpty);
    });

    test('native gets the policy from the settings and the kept-awake tabs, '
        'again when they change', () async {
      await addTab('b');
      await addTab('a');
      final tabs = container.read(tabDataRepositoryProvider.notifier);
      await tabs.setSleepExempt('b', exempt: true);
      await tabs.setSleepExempt('a', exempt: true);

      final subscription = container.listen(
        tabSleepPolicyReplicationProvider,
        (_, _) {},
      );
      addTearDown(subscription.close);
      await container.read(watchSleepExemptTabIdsProvider.future);
      // Sent once the containers are known too.
      await pumpEventQueue();

      final policy = native.policies.last;
      expect(policy.enabled, isTrue);
      expect(policy.idleMinutes, 10);
      expect(policy.residentLimit, 6);
      expect(policy.exemptTabIds, ['a', 'b']);

      await tabs.setSleepExempt('a', exempt: false);
      await pumpEventQueue();
      expect(native.policies.last.exemptTabIds, ['b']);
    });

    test('native gets the containers that freeze automatically, with the '
        "contexts of their isolated tabs, again when they change", () async {
      Future<void> addContainer(String id, {int? autoFreezeAfterMinutes}) =>
          db.containerDao.addContainer(
            ContainerData(
              id: id,
              color: Colors.blue,
              orderKey: id,
              metadata: ContainerMetadata.withDefaults(
                contextualIdentity: 'ctx-$id',
                autoFreezeAfterMinutes: autoFreezeAfterMinutes,
              ),
            ),
          );
      await addContainer('work', autoFreezeAfterMinutes: 30);
      await addContainer('plain');
      await db.tabDao.insertTab(
        'iso',
        source: TabSource.manual,
        parentId: const Value(null),
        containerId: const Value('work'),
        tabMode: Value(TabMode.isolated('iso1_x')),
      );

      final subscription = container.listen(
        tabSleepPolicyReplicationProvider,
        (_, _) {},
      );
      addTearDown(subscription.close);
      await container.read(watchSleepExemptTabIdsProvider.future);
      await pumpEventQueue();

      expect(native.policies.last.containers, [
        ContainerAutoFreeze(
          ownerId: 'work',
          contextIds: ['ctx-work', 'iso1_x'],
          afterMinutes: 30,
        ),
      ]);

      await db.containerDao.replaceContainer(
        (await db.containerDao.getContainerData('work').getSingleOrNull())!
            .copyWith(
              metadata: ContainerMetadata.withDefaults(
                contextualIdentity: 'ctx-work',
              ),
            ),
      );
      await pumpEventQueue();
      expect(native.policies.last.containers, isEmpty);
    });
  });

  test('isTabAsleep needs both a hold and an unloaded page', () {
    reportLifecycle('a', TabSleepHold.manual);
    expect(container.read(isTabAsleepProvider('a')), isTrue);

    container
        .read(tabLifecycleStatesProvider.notifier)
        .update(
          TabLifecycleState(
            tabId: 'a',
            residency: TabResidency.resident,
            sleepHold: TabSleepHold.manual,
            operation: LifecycleOperationState.sleeping,
            contextFrozen: false,
          ),
        );
    // Still being put to sleep: its page is there.
    expect(container.read(isTabAsleepProvider('a')), isFalse);
  });
}
