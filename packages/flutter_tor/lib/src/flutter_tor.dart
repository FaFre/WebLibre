import 'dart:async';

import 'package:flutter_tor/src/tor_api.g.dart';

/// Flutter Tor implementation
/// Provides a clean Dart API over the Pigeon-generated code
class FlutterTor {
  FlutterTor() {
    _torLogApi = _TorLogApiImpl(
      onLog: _logController.add,
      onStatus: _statusController.add,
      onBootstrap: _bootstrapController.add,
    );

    // Register the Flutter API handler so native can call us
    TorLogApi.setUp(_torLogApi);
  }

  final _torApi = TorApi();
  late final _TorLogApiImpl _torLogApi;

  final _logController = StreamController<TorLogMessage>.broadcast();
  final _statusController = StreamController<TorStatus>.broadcast();
  final _bootstrapController = StreamController<int>.broadcast();

  /// Stream of log messages from Tor
  Stream<TorLogMessage> get logStream => _logController.stream;

  /// Stream of status changes
  Stream<TorStatus> get statusStream => _statusController.stream;

  /// Stream of bootstrap progress updates (0-100)
  Stream<int> get bootstrapProgressStream => _bootstrapController.stream;

  /// Start Tor with the given configuration
  Future<int> start(TorConfiguration config) async {
    return await _torApi.startTor(config);
  }

  /// Stop Tor
  Future<void> stop() async {
    await _torApi.stopTor();
  }

  /// Get current Tor status
  Future<TorStatus> getStatus() async {
    return await _torApi.getStatus();
  }

  /// Request a new Tor identity (new circuit)
  Future<void> requestNewIdentity() async {
    await _torApi.requestNewIdentity();
  }

  /// Dispose resources
  void dispose() {
    // Unregister the Flutter API handler
    TorLogApi.setUp(null);

    unawaited(_logController.close());
    unawaited(_statusController.close());
    unawaited(_bootstrapController.close());
  }
}

/// Implementation of TorLogApi for receiving callbacks from native
class _TorLogApiImpl extends TorLogApi {
  _TorLogApiImpl({
    required this.onLog,
    required this.onStatus,
    required this.onBootstrap,
  });

  final void Function(TorLogMessage) onLog;
  final void Function(TorStatus) onStatus;
  final void Function(int) onBootstrap;

  @override
  void onLogMessage(TorLogMessage log) {
    onLog(log);
  }

  @override
  void onStatusChanged(TorStatus status) {
    onStatus(status);
  }
}
