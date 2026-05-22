import 'dart:async';

import 'src/singbox_proxy_api.g.dart';

export 'src/singbox_proxy_api.g.dart'
    show
        SingboxProxyConfigResult,
        SingboxProxyDnsConfig,
        SingboxProxyDnsServerConfig,
        SingboxProxyLogMessage,
        SingboxProxyProfile,
        SingboxProxyProfileType,
        SingboxProxyRuntimeEndpoint,
        SingboxProxyRuntimeOptions,
        SingboxProxyRuntimeState,
        SingboxProxyRuntimeStatus;

class FlutterSingboxProxy implements SingboxProxyEventsApi {
  FlutterSingboxProxy({SingboxProxyApi? api})
    : _api = api ?? SingboxProxyApi() {
    SingboxProxyEventsApi.setUp(this);
  }

  final SingboxProxyApi _api;
  final _stateController =
      StreamController<SingboxProxyRuntimeState>.broadcast();
  final _logController = StreamController<SingboxProxyLogMessage>.broadcast();

  Stream<SingboxProxyRuntimeState> get stateStream => _stateController.stream;
  Stream<SingboxProxyLogMessage> get logStream => _logController.stream;

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

  @override
  void onStateChanged(SingboxProxyRuntimeState state) {
    _stateController.add(state);
  }

  @override
  void onLogMessage(SingboxProxyLogMessage message) {
    _logController.add(message);
  }

  Future<void> dispose() async {
    SingboxProxyEventsApi.setUp(null);
    await _stateController.close();
    await _logController.close();
  }
}
