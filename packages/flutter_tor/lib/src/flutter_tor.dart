import 'package:flutter_tor/src/tor_api.g.dart';

/// Flutter Tor implementation
/// Provides a clean Dart API over the Pigeon-generated code
class FlutterTor {
  final _torApi = TorApi();

  // Every call to a generated stream function opens an event channel of its
  // own, and native keeps only the newest listener on a channel. Each stream is
  // therefore created once, and every subscriber shares it.
  late final Stream<TorLogMessage> _logs = streamLogs();
  late final Stream<TorStatus> _status = streamStatus();

  /// Stream of log messages from Tor
  Stream<TorLogMessage> get logStream => _logs;

  /// Stream of status changes
  Stream<TorStatus> get statusStream => _status;

  /// Stream of bootstrap progress updates (0-100)
  Stream<int> get bootstrapProgressStream =>
      _status.map((status) => status.bootstrapProgress).distinct();

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
}
