import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartPackageName: 'flutter_singbox_proxy',
    dartOut: 'lib/src/singbox_proxy_api.g.dart',
    dartOptions: DartOptions(),
    kotlinOut:
        'android/src/main/kotlin/eu/weblibre/flutter_singbox_proxy/generated/SingboxProxyApi.g.kt',
    kotlinOptions: KotlinOptions(
      package: 'eu.weblibre.flutter_singbox_proxy.generated',
    ),
  ),
)
enum SingboxProxyProfileType {
  socks,
  http,
  shadowsocks,
  vmess,
  vless,
  trojan,
  naive,
  hysteria,
  hysteria2,
  tuic,
  ssh,
  wireguard,
  shadowTls,
  anyTls,
  customOutbound,
}

enum SingboxProxyRuntimeStatus { stopped, starting, running, stopping, error }

class SingboxProxyProfile {
  SingboxProxyProfile({
    required this.id,
    required this.name,
    required this.type,
    required this.configJson,
    this.secretJson,
  });

  final String id;
  final String name;
  final SingboxProxyProfileType type;

  /// Public profile configuration as JSON. The schema is intentionally owned by
  /// the profile type so the Pigeon API stays stable while sing-box evolves.
  final String configJson;

  /// Resolved secret values as JSON. Flutter stores secrets independently and
  /// only passes them to native code when building or starting a runtime config.
  final String? secretJson;
}

class SingboxProxyRuntimeOptions {
  SingboxProxyRuntimeOptions({
    this.preferredBasePort,
    this.blockUnmatchedTraffic = true,
    this.dnsConfig,
    this.bootstrapDohUrl,
  });

  /// Optional preferred start port for generated local SOCKS inbounds.
  final int? preferredBasePort;

  /// If true, traffic entering sing-box without a matching inbound rule is
  /// rejected instead of falling through to direct.
  final bool blockUnmatchedTraffic;

  /// Optional DNS block emitted into sing-box config. When null, sing-box
  /// uses its built-in default (system resolver), which can leak DNS outside
  /// the proxy — callers should always provide an explicit configuration.
  final SingboxProxyDnsConfig? dnsConfig;

  /// DoH endpoint used by the native LocalDNSTransport bridge to bootstrap
  /// hostname-only DNS server addresses (and any other hostname appearing in
  /// the sing-box config). When null, the bridge refuses to resolve and
  /// sing-box's stock `/etc/resolv.conf`/127.0.0.1:53 path runs — which is
  /// broken on Android. Callers should always pass the browser DoH URL.
  final String? bootstrapDohUrl;
}

class SingboxProxyDnsServerConfig {
  SingboxProxyDnsServerConfig({
    required this.tag,
    required this.address,
    this.detourTag,
    this.matchDomainSuffixes = const <String>[],
    this.matchGeosites = const <String>[],
    this.matchOutbounds = const <String>[],
    this.matchInbounds = const <String>[],
  });

  /// sing-box server tag, used to reference the server from `dns.rules`.
  final String tag;

  /// Server address. `https://...`, `tls://...`, `quic://...`, or plain IP.
  /// Hostnames are resolved on demand via the platform LocalDNSTransport
  /// bridge (sing-box `type: "local"` with our DoH-backed implementation).
  final String address;

  /// Outbound tag to dial the resolver through, or `direct` for direct, or
  /// null when sing-box should pick automatically.
  final String? detourTag;

  /// If non-empty, attaches a `dns.rules` entry routing matching domains to
  /// this server.
  final List<String> matchDomainSuffixes;

  /// Advanced sing-box geosite selectors (e.g. `geosite:cn`).
  final List<String> matchGeosites;

  /// If non-empty, attaches a `dns.rules` entry routing queries that *the
  /// listed outbounds* originate to this server. Note: sing-box treats an
  /// outbound's own bootstrap lookups (e.g. WireGuard peer hostname
  /// resolution) as queries from that outbound, so using this for per-profile
  /// scoping creates a chicken-and-egg loop at startup. Prefer
  /// [matchInbounds] for "queries from tabs routed through this profile".
  final List<String> matchOutbounds;

  /// If non-empty, attaches a `dns.rules` entry matching the listed inbound
  /// tags. Queries entering via that inbound (e.g. a tab whose container is
  /// bound to this profile's local SOCKS inbound) resolve through this
  /// server. Endpoint-bootstrap lookups don't come from any inbound, so this
  /// scope safely excludes them.
  final List<String> matchInbounds;
}

class SingboxProxyDnsConfig {
  SingboxProxyDnsConfig({
    required this.servers,
    this.finalServerTag,
    required this.domainStrategy,
  });

  final List<SingboxProxyDnsServerConfig> servers;

  /// Server tag used as `dns.final`. When null, sing-box uses the first
  /// server in the list as the fallback.
  final String? finalServerTag;

  /// sing-box `dns.strategy` string. e.g. `prefer_ipv4`, `ipv4_only`.
  final String domainStrategy;
}

class SingboxProxyRuntimeEndpoint {
  SingboxProxyRuntimeEndpoint({
    required this.profileId,
    required this.host,
    required this.port,
    required this.username,
    required this.password,
  });

  final String profileId;
  final String host;
  final int port;
  final String username;
  final String password;
}

class SingboxProxyRuntimeState {
  SingboxProxyRuntimeState({
    required this.status,
    required this.endpoints,
    this.message,
  });

  final SingboxProxyRuntimeStatus status;
  final List<SingboxProxyRuntimeEndpoint> endpoints;
  final String? message;
}

class SingboxProxyConfigResult {
  SingboxProxyConfigResult({required this.configJson, required this.endpoints});

  final String configJson;
  final List<SingboxProxyRuntimeEndpoint> endpoints;
}

class SingboxProxyLogMessage {
  SingboxProxyLogMessage({
    required this.level,
    required this.message,
    required this.timestamp,
    this.profileId,
  });

  final String level;
  final String message;
  final int timestamp;
  final String? profileId;
}

@HostApi()
abstract class SingboxProxyApi {
  @async
  String? validateProfile(SingboxProxyProfile profile);

  @async
  SingboxProxyConfigResult buildConfig(
    List<SingboxProxyProfile> profiles,
    SingboxProxyRuntimeOptions options,
  );

  @async
  SingboxProxyRuntimeState start(
    List<SingboxProxyProfile> profiles,
    SingboxProxyRuntimeOptions options,
  );

  @async
  void stop(List<String> profileIds);

  @async
  void stopAll();

  SingboxProxyRuntimeState getState();
}

@FlutterApi()
abstract class SingboxProxyEventsApi {
  void onStateChanged(SingboxProxyRuntimeState state);
  void onLogMessage(SingboxProxyLogMessage message);
}
