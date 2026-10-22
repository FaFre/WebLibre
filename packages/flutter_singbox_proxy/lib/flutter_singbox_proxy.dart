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
        SingboxProxyRuntimeStatus;

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

  Stream<SingboxProxyRuntimeState> get stateStream => _states;
  Stream<SingboxProxyLogMessage> get logStream => _logs;

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
}
