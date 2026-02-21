import 'dart:async';

import 'package:collection/collection.dart';
import 'package:drift/drift.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/features/geckoview/domain/repositories/tab.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/repositories/container.dart';
import 'package:weblibre/features/sync/domain/entities/sync_repository_state.dart';
import 'package:weblibre/features/sync/domain/entities/synced_tab_item.dart';

part 'sync.g.dart';

@Riverpod(keepAlive: true)
bool syncIsAuthenticated(Ref ref) {
  return ref.watch(
    syncRepositoryProvider.select(
      (value) => value.value?.account.authenticated == true,
    ),
  );
}

enum TabsTrayScope { local, synced }

@Riverpod(keepAlive: true)
class TabsTrayScopeController extends _$TabsTrayScopeController {
  @override
  TabsTrayScope build() => TabsTrayScope.local;

  void showLocal() {
    state = TabsTrayScope.local;
  }

  void showSynced() {
    state = TabsTrayScope.synced;
  }
}

@Riverpod(keepAlive: true)
TabsTrayScope effectiveTabsTrayScope(Ref ref) {
  final scope = ref.watch(tabsTrayScopeControllerProvider);
  final isAuthenticated = ref.watch(syncIsAuthenticatedProvider);

  if (!isAuthenticated && scope == TabsTrayScope.synced) {
    return TabsTrayScope.local;
  }

  return scope;
}

@Riverpod(keepAlive: true)
class SelectedSyncedTabsDeviceId extends _$SelectedSyncedTabsDeviceId {
  @override
  String? build() => null;

  // ignore: use_setters_to_change_properties
  void selectDevice(String? value) {
    state = value;
  }
}

@riverpod
Future<int> syncedTabsTotalCount(Ref ref) {
  return ref.watch(
    syncRemoteTabsProvider.selectAsync(
      (devices) =>
          devices.fold<int>(0, (count, device) => count + device.tabs.length),
    ),
  );
}

@riverpod
Future<String?> effectiveSyncedTabsDeviceId(Ref ref) async {
  final devices = await ref.watch(
    syncRemoteTabsProvider.selectAsync((tabs) => tabs),
  );
  final selectedDeviceId = ref.watch(selectedSyncedTabsDeviceIdProvider);

  if (devices.isEmpty) {
    return null;
  }

  if (selectedDeviceId != null &&
      devices.any((device) => device.deviceId == selectedDeviceId)) {
    return selectedDeviceId;
  }

  return devices.first.deviceId;
}

@riverpod
Future<List<SyncedTabItem>> syncedTabsForSelectedDevice(Ref ref) async {
  final devices = await ref.watch(
    syncRemoteTabsProvider.selectAsync((tabs) => tabs),
  );

  final selectedDeviceId = ref.watch(selectedSyncedTabsDeviceIdProvider);

  final effectiveSelectedDeviceId =
      selectedDeviceId != null &&
          devices.any((device) => device.deviceId == selectedDeviceId)
      ? selectedDeviceId
      : devices.firstOrNull?.deviceId;

  if (effectiveSelectedDeviceId == null) {
    return const <SyncedTabItem>[];
  }

  final device = devices.firstWhereOrNull(
    (item) => item.deviceId == effectiveSelectedDeviceId,
  );

  if (device == null) {
    return const <SyncedTabItem>[];
  }

  final tabs = device.tabs
      .map(
        (tab) => SyncedTabItem(
          deviceId: device.deviceId,
          deviceName: device.deviceName,
          tab: tab,
        ),
      )
      .toList(growable: false);

  tabs.sort((a, b) => b.tab.lastUsed.compareTo(a.tab.lastUsed));
  return tabs;
}

@Riverpod(keepAlive: true)
class SyncRepository extends _$SyncRepository {
  final _service = GeckoSyncService();

  StreamSubscription<SyncAccountInfo>? _authStateSub;
  StreamSubscription<void>? _syncStartedSub;
  StreamSubscription<void>? _syncCompletedSub;
  StreamSubscription<String?>? _syncErrorSub;

  Future<void> _awaitInitialized() => future;

  void _update(SyncRepositoryState Function(SyncRepositoryState) updater) {
    final current = state.value;
    if (current != null) {
      state = AsyncData(updater(current));
    }
  }

  Future<void> _refreshAccount() async {
    await _awaitInitialized();

    final account = await _service.getAccountInfo();
    _update((s) => s.copyWith(account: account));
  }

  Future<void> _refreshTabs() async {
    await _awaitInitialized();

    try {
      final tabs = await _service.getSyncedTabs();
      _update((s) => s.copyWith(remoteTabs: tabs));
    } on Exception catch (e) {
      logger.e('Failed to refresh synced tabs', error: e);
      _update(
        (s) => s.copyWith(
          lastSyncEvent: SyncEvent.error,
          lastSyncError: e.toString(),
        ),
      );
    }
  }

  Future<void> _refreshDevices() async {
    await _awaitInitialized();

    try {
      final devices = await _service.getDevices();
      _update((s) => s.copyWith(devices: devices));
    } on Exception catch (e) {
      logger.e('Failed to refresh devices', error: e);
      _update(
        (s) => s.copyWith(
          lastSyncEvent: SyncEvent.error,
          lastSyncError: e.toString(),
        ),
      );
    }
  }

  Future<void> _refreshDeviceName() async {
    await _awaitInitialized();

    final deviceName = await _service.getDeviceName();
    _update((s) => s.copyWith(deviceName: deviceName));
  }

  Future<SyncAccountInfo> refresh() async {
    await _refreshAccount();
    return state.value!.account;
  }

  Future<void> signIn() async {
    await _service.beginAuthentication();
  }

  Future<void> signInWithPairing(String pairingUrl) async {
    await _service.beginPairingAuthentication(pairingUrl);
  }

  Future<void> signOut() async {
    await _service.logout();
  }

  Future<void> syncNow() async {
    await _service.syncNow();
    await Future.wait([_refreshAccount(), _refreshTabs(), _refreshDevices()]);
  }

  Future<void> setEngineEnabled(SyncEngineValue engine, bool enabled) async {
    await _service.setEngineEnabled(engine, enabled);
    await Future.wait([_refreshAccount(), _refreshTabs(), _refreshDevices()]);
  }

  Future<bool> sendTabToDevice({
    required String deviceId,
    required String title,
    required String url,
  }) {
    return _service.sendTabToDevice(deviceId, title, url);
  }

  Future<bool> setDeviceName(String newName) async {
    final result = await _service.setDeviceName(newName);

    if (result) {
      await Future.wait([_refreshDevices(), _refreshDeviceName()]);
    }

    return result;
  }

  Future<void> refreshDevices() async {
    await _service.refreshDevices();
    await _refreshDevices();
  }

  Future<int> pollIncomingTabsAndOpen() async {
    await _service.pollDeviceCommands();
    final incomingTabs = await _service.drainIncomingTabs();

    for (final tab in incomingTabs) {
      await _openUrlInAssignedContainer(tab.url);
    }

    await _refreshTabs();
    return incomingTabs.length;
  }

  Future<void> openSyncedTab(SyncRemoteTab tab) async {
    await _openUrlInAssignedContainer(tab.url);
  }

  Future<void> _openUrlInAssignedContainer(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) {
      return;
    }

    final containerRepository = ref.read(containerRepositoryProvider.notifier);

    final containerId = await containerRepository.siteAssignedContainerId(uri);

    final assignedContainer = containerId == null
        ? null
        : await containerRepository.getContainerData(containerId);

    await ref
        .read(tabRepositoryProvider.notifier)
        .addTab(
          url: uri,
          selectTab: true,
          private: false,
          container: Value(assignedContainer),
        );
  }

  @override
  Future<SyncRepositoryState> build() async {
    final syncStateService = ref.read(geckoSyncStateServiceProvider);

    _syncStartedSub = syncStateService.syncStartedEvents.listen((_) {
      _update(
        (s) => s.copyWith(
          lastSyncEvent: SyncEvent.started,
          // ignore: avoid_redundant_argument_values
          lastSyncError: null,
        ),
      );
    });

    _syncCompletedSub = syncStateService.syncCompletedEvents.listen((_) {
      _update(
        (s) => s.copyWith(
          lastSyncEvent: SyncEvent.completed,
          // ignore: avoid_redundant_argument_values
          lastSyncError: null,
        ),
      );
      unawaited(Future.wait([_refreshTabs(), _refreshDevices()]));
    });

    _syncErrorSub = syncStateService.syncErrorEvents.listen((error) {
      logger.e('Sync failed', error: error ?? 'Unknown synchronization error');
      _update(
        (s) => s.copyWith(lastSyncEvent: SyncEvent.error, lastSyncError: error),
      );
      unawaited(Future.wait([_refreshTabs(), _refreshDevices()]));
    });

    _authStateSub = syncStateService.authStateEvents.listen((info) {
      final previous = state.value;

      if (previous == null) {
        state = AsyncData(SyncRepositoryState(account: info));
        return;
      }

      final unauthenticated = !info.authenticated;
      state = AsyncData(
        unauthenticated
            ? SyncRepositoryState(account: info)
            : previous.copyWith(account: info),
      );

      final authStateChanged =
          previous.account.authenticated != info.authenticated ||
          previous.account.needsReauth != info.needsReauth;

      if (authStateChanged && info.authenticated) {
        unawaited(
          Future.wait([
            _refreshAccount(),
            _refreshTabs(),
            _refreshDevices(),
            _refreshDeviceName(),
          ]),
        );
      }
    });

    ref.onDispose(() {
      unawaited(_authStateSub?.cancel());
      unawaited(_syncStartedSub?.cancel());
      unawaited(_syncCompletedSub?.cancel());
      unawaited(_syncErrorSub?.cancel());
    });

    final (account, tabs, devices, deviceName) = await (
      _service.getAccountInfo(),
      _service.getSyncedTabs(),
      _service.getDevices(),
      _service.getDeviceName(),
    ).wait;

    return SyncRepositoryState(
      account: account,
      remoteTabs: tabs,
      devices: devices,
      deviceName: deviceName,
    );
  }
}

@Riverpod(keepAlive: true)
GeckoSyncStateService geckoSyncStateService(Ref ref) {
  final service = GeckoSyncStateService.setUp();
  ref.onDispose(() => service.dispose());
  return service;
}

@riverpod
Future<String?> syncDeviceName(Ref ref) {
  return ref.watch(
    syncRepositoryProvider.selectAsync((value) => value.deviceName),
  );
}

@riverpod
Future<List<SyncDeviceTabs>> syncRemoteTabs(Ref ref) {
  return ref.watch(
    syncRepositoryProvider.selectAsync((value) => value.remoteTabs),
  );
}

@riverpod
Future<List<SyncDevice>> syncDevices(Ref ref) {
  return ref.watch(
    syncRepositoryProvider.selectAsync((value) => value.devices),
  );
}

@riverpod
Future<(SyncEvent?, String?)> syncEvent(Ref ref) {
  return ref.watch(
    syncRepositoryProvider.selectAsync(
      (s) => (s.lastSyncEvent, s.lastSyncError),
    ),
  );
}
