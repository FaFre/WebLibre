import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_singbox_proxy/src/singbox_proxy_api.g.dart';

export 'src/singbox_proxy_api.g.dart'
    show
        SingboxProxyConfigResult,
        SingboxProxyDnsConfig,
        SingboxProxyDnsServerConfig,
        SingboxProxyLogLevel,
        SingboxProxyLogMessage,
        SingboxProxyProfile,
        SingboxProxyProfileType,
        SingboxProxyRuntimeEndpoint,
        SingboxProxyRuntimeOptions,
        SingboxProxyRuntimeState,
        SingboxProxyRuntimeStatus,
        SingboxProxyTunnelState;

/// sing-box could not start: [reason] is its own explanation (English,
/// technical), and [profileId] / [profileName] the profile it failed on, when
/// it says.
class SingboxStartException implements Exception {
  /// The [PlatformException.code] native reports a failed start with.
  static const code = 'start_failed';

  final String reason;
  final String? profileId;
  final String? profileName;

  const SingboxStartException({
    required this.reason,
    this.profileId,
    this.profileName,
  });

  /// The start failure [error] reports, or null when it is something else.
  static SingboxStartException? fromPlatformException(PlatformException error) {
    if (error.code != code) return null;

    final details = error.details;
    return SingboxStartException(
      reason: error.message ?? '',
      profileId: details is Map ? details['profileId'] as String? : null,
      profileName: details is Map ? details['profileName'] as String? : null,
    );
  }

  @override
  String toString() => profileName == null
      ? 'SingboxStartException: $reason'
      : 'SingboxStartException ($profileName): $reason';
}

class FlutterSingboxProxy {
  FlutterSingboxProxy({SingboxProxyApi? api}) : _api = api ?? SingboxProxyApi();

  final SingboxProxyApi _api;

  // Every call to a generated stream function opens an event channel of its
  // own, and native keeps only the newest listener on a channel. Each stream is
  // therefore created once, and every subscriber shares it.
  late final Stream<SingboxProxyRuntimeState> _states = streamState();
  late final Stream<SingboxProxyLogMessage> _logs = streamLogs();
  late final Stream<SingboxProxyTunnelState> _tunnels = streamTunnels();

  Stream<SingboxProxyRuntimeState> get stateStream => _states;
  Stream<SingboxProxyLogMessage> get logStream => _logs;

  /// The latest tunnel state while anyone listens, for the next subscriber.
  SingboxProxyTunnelState? _latestTunnels;

  /// The one subscription to the native channel, held while anyone listens.
  ///
  /// Cancelled when the last subscriber of [tunnelStream] cancels, which the
  /// lint cannot follow into the stream's onCancel.
  // ignore: cancel_subscriptions
  StreamSubscription<SingboxProxyTunnelState>? _tunnelSource;

  final _tunnelConsumers = <MultiStreamController<SingboxProxyTunnelState>>{};

  /// The WireGuard profiles whose peer does not answer, whenever that changes
  /// and once as a listener subscribes. See [SingboxProxyTunnelState].
  ///
  /// Native hands its latest state to the channel's listener as it attaches,
  /// but the channel is listened to once for all subscribers, so a subscriber
  /// that joins a running stream would hear nothing until the state changed.
  /// It gets the latest state from here instead. Once nobody listens it is
  /// dropped: it may change unheard, and the next native listen replays it.
  ///
  /// Every subscriber is fed from one subscription that is never paused, so
  /// the latest state stays current while a subscriber is paused; a paused
  /// subscriber's events wait in its own controller.
  late final Stream<SingboxProxyTunnelState> tunnelStream =
      Stream<SingboxProxyTunnelState>.multi((controller) {
        if (_latestTunnels case final latest?) controller.add(latest);
        _tunnelConsumers.add(controller);
        _tunnelSource ??= _tunnels.listen(
          (state) {
            _latestTunnels = state;
            for (final consumer in [..._tunnelConsumers]) {
              consumer.add(state);
            }
          },
          onError: (Object error, StackTrace stackTrace) {
            for (final consumer in [..._tunnelConsumers]) {
              consumer.addError(error, stackTrace);
            }
          },
          onDone: () {
            final consumers = [..._tunnelConsumers];
            _tunnelConsumers.clear();
            _tunnelSource = null;
            _latestTunnels = null;
            for (final consumer in consumers) {
              unawaited(consumer.close());
            }
          },
        );

        controller.onCancel = () {
          _tunnelConsumers.remove(controller);
          if (_tunnelConsumers.isNotEmpty) return null;

          final source = _tunnelSource;
          _tunnelSource = null;
          _latestTunnels = null;
          return source?.cancel();
        };
      });

  Future<String?> validateProfile(SingboxProxyProfile profile) {
    return _api.validateProfile(profile);
  }

  Future<String?> probeProfile(SingboxProxyProfile profile) {
    return _api.probeProfile(profile);
  }

  Future<SingboxProxyConfigResult> buildConfig(
    List<SingboxProxyProfile> profiles, {
    SingboxProxyRuntimeOptions? options,
  }) {
    return _api.buildConfig(profiles, options ?? SingboxProxyRuntimeOptions());
  }

  /// Throws [SingboxStartException] when sing-box could not start.
  Future<SingboxProxyRuntimeState> start(
    List<SingboxProxyProfile> profiles, {
    SingboxProxyRuntimeOptions? options,
  }) async {
    try {
      return await _api.start(
        profiles,
        options ?? SingboxProxyRuntimeOptions(),
      );
    } on PlatformException catch (error) {
      throw SingboxStartException.fromPlatformException(error) ?? error;
    }
  }

  Future<void> stop(List<String> profileIds) => _api.stop(profileIds);

  Future<void> stopAll() => _api.stopAll();

  Future<SingboxProxyRuntimeState> getState() => _api.getState();

  /// The bundled sing-box core's version, or null when it is unknown.
  Future<String?> getVersion() => _api.getVersion();
}
