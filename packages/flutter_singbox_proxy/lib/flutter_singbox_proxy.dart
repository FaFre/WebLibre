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

  Future<SingboxProxyConfigResult> buildConfig(
    List<SingboxProxyProfile> profiles, {
    SingboxProxyRuntimeOptions? options,
  }) {
    return _api.buildConfig(profiles, options ?? SingboxProxyRuntimeOptions());
  }

  Future<SingboxProxyRuntimeState> start(
    List<SingboxProxyProfile> profiles, {
    SingboxProxyRuntimeOptions? options,
  }) {
    return _api.start(profiles, options ?? SingboxProxyRuntimeOptions());
  }

  Future<void> stop(List<String> profileIds) => _api.stop(profileIds);

  Future<void> stopAll() => _api.stopAll();

  Future<SingboxProxyRuntimeState> getState() => _api.getState();
}
