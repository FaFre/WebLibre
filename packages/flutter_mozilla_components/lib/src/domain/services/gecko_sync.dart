import 'package:flutter/services.dart';
import 'package:flutter_mozilla_components/src/extensions/subject.dart';
import 'package:flutter_mozilla_components/src/pigeons/gecko.g.dart';
import 'package:rxdart/rxdart.dart';

final _apiInstance = GeckoSyncApi();

class GeckoSyncService {
  final GeckoSyncApi _api;

  GeckoSyncService({GeckoSyncApi? api}) : _api = api ?? _apiInstance;

  Future<SyncAccountInfo> getAccountInfo() {
    return _api.getAccountInfo();
  }

  Future<void> beginAuthentication() {
    return _api.beginAuthentication();
  }

  Future<void> beginPairingAuthentication(String pairingUrl) {
    return _api.beginPairingAuthentication(pairingUrl);
  }

  Future<void> logout() {
    return _api.logout();
  }

  Future<void> syncNow() {
    return _api.syncNow();
  }

  Future<void> setEngineEnabled(SyncEngineValue engine, bool enabled) {
    return _api.setEngineEnabled(engine, enabled);
  }

  Future<List<SyncDeviceTabs>> getSyncedTabs() {
    return _api.getSyncedTabs();
  }

  Future<List<SyncDevice>> getDevices() {
    return _api.getDevices();
  }

  Future<bool> sendTabToDevice(String deviceId, String title, String url) {
    return _api.sendTabToDevice(deviceId, title, url);
  }

  Future<void> refreshDevices() {
    return _api.refreshDevices();
  }

  Future<void> pollDeviceCommands() {
    return _api.pollDeviceCommands();
  }

  Future<List<SyncIncomingTab>> drainIncomingTabs() {
    return _api.drainIncomingTabs();
  }

  Future<String?> getDeviceName() {
    return _api.getDeviceName();
  }

  Future<bool> setDeviceName(String newName) {
    return _api.setDeviceName(newName);
  }
}

class GeckoSyncStateService extends GeckoSyncStateEvents {
  final _authStateSubject = BehaviorSubject<SyncAccountInfo>();
  final _syncStartedSubject = PublishSubject<void>();
  final _syncCompletedSubject = PublishSubject<void>();
  final _syncErrorSubject = PublishSubject<String?>();

  ValueStream<SyncAccountInfo> get authStateEvents => _authStateSubject.stream;
  Stream<void> get syncStartedEvents => _syncStartedSubject.stream;
  Stream<void> get syncCompletedEvents => _syncCompletedSubject.stream;
  Stream<String?> get syncErrorEvents => _syncErrorSubject.stream;

  @override
  void onAuthStateChanged(int sequence, SyncAccountInfo accountInfo) {
    _authStateSubject.addWhenMoreRecent(sequence, null, accountInfo);
  }

  @override
  void onSyncStarted(int sequence) {
    _syncStartedSubject.addWhenMoreRecent(sequence, null, null);
  }

  @override
  void onSyncCompleted(int sequence) {
    _syncCompletedSubject.addWhenMoreRecent(sequence, null, null);
  }

  @override
  void onSyncError(int sequence, String? errorMessage) {
    _syncErrorSubject.addWhenMoreRecent(sequence, null, errorMessage);
  }

  GeckoSyncStateService.setUp({
    BinaryMessenger? binaryMessenger,
    String messageChannelSuffix = '',
  }) {
    GeckoSyncStateEvents.setUp(
      this,
      binaryMessenger: binaryMessenger,
      messageChannelSuffix: messageChannelSuffix,
    );
  }

  Future<void> dispose() async {
    await Future.wait([
      _authStateSubject.close(),
      _syncStartedSubject.close(),
      _syncCompletedSubject.close(),
      _syncErrorSubject.close(),
    ]);
  }
}
