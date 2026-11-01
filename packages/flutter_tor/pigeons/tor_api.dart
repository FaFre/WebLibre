import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/tor_api.g.dart',
    dartOptions: DartOptions(),
    kotlinOut:
        'android/src/main/kotlin/eu/weblibre/flutter_tor/generated/TorApi.g.kt',
    kotlinOptions: KotlinOptions(package: 'eu.weblibre.flutter_tor.generated'),
  ),
)
/// Transport types for Tor connections
enum TransportType {
  /// Direct Tor connection (no bridges)
  none,

  /// obfs4 pluggable transport
  obfs4,

  /// Snowflake pluggable transport (default broker)
  snowflake,

  /// Snowflake via AMP cache
  snowflakeAmp,

  /// Meek pluggable transport
  meek,

  /// Meek via Azure CDN
  meekAzure,

  /// WebTunnel pluggable transport
  webtunnel,

  /// Custom bridge lines (passthrough)
  custom,
}

/// Configuration for starting Tor
class TorConfiguration {
  TorConfiguration({
    required this.transport,
    required this.bridgeLines,
    this.entryNodeCountries,
    this.exitNodeCountries,
    this.strictNodes,
  });

  /// Transport type to use
  final TransportType transport;

  /// Bridge lines for the transport (empty for direct connection)
  final List<String> bridgeLines;

  /// Entry node countries (ISO 3166-1 alpha-2, comma-separated, e.g., "de,fr,nl")
  final String? entryNodeCountries;

  /// Exit node countries (ISO 3166-1 alpha-2, comma-separated, e.g., "ch,is,se")
  final String? exitNodeCountries;

  /// If true, never use nodes outside specified countries
  final bool? strictNodes;
}

/// Current Tor status
class TorStatus {
  TorStatus({
    required this.isRunning,
    this.socksPort,
    required this.bootstrapProgress,
    this.currentCircuit,
    this.exitNodeCountry,
  });

  /// Whether Tor is running
  final bool isRunning;

  /// SOCKS proxy port (if running)
  final int? socksPort;

  /// Bootstrap progress (0-100)
  final int bootstrapProgress;

  /// Current circuit ID
  final String? currentCircuit;

  /// Exit node country code
  final String? exitNodeCountry;
}

/// Log message from Tor
class TorLogMessage {
  TorLogMessage({
    required this.severity,
    required this.message,
    required this.timestamp,
  });

  /// Log severity (NOTICE, WARN, ERR, DEBUG)
  final String severity;

  /// Log message
  final String message;

  /// Timestamp (milliseconds since epoch)
  final int timestamp;
}

/// Versions of the Tor components bundled with the app
class TorComponentVersions {
  TorComponentVersions({required this.tor, this.snowflake, this.lyrebird});

  /// The tor daemon (tor-android), e.g. "0.4.9.14"
  final String tor;

  /// The Snowflake pluggable transport, or null when it cannot be determined
  final String? snowflake;

  /// The Lyrebird pluggable transport (obfs4, meek, WebTunnel), or null when it
  /// cannot be determined
  final String? lyrebird;
}

/// Host API (Flutter -> Native)
@HostApi()
abstract class TorApi {
  /// Start Tor with the given configuration
  /// Returns a Future to avoid blocking the main thread
  @async
  int startTor(TorConfiguration config);

  /// Stop Tor
  @async
  void stopTor();

  /// Get current status
  TorStatus getStatus();

  /// Request a new Tor identity (new circuit)
  void requestNewIdentity();

  /// Versions of the bundled Tor components. Does not need Tor to run.
  TorComponentVersions getComponentVersions();
}

/// Event streams (Native -> Flutter)
@EventChannelApi()
abstract class TorEventsApi {
  /// Log messages from Tor
  TorLogMessage streamLogs();

  /// Status changes
  TorStatus streamStatus();
}

@HostApi()
abstract class IPtProxyController {
  int start(TransportType proxyType, String proxy);
  void stop(TransportType proxyType);
}
