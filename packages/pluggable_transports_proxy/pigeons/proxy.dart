import 'package:pigeon/pigeon.dart';

enum ProxyType { obfs4, meekLite, webtunnel, snowflake }

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/pigeons/proxy.g.dart',
    dartOptions: DartOptions(),
    kotlinOut:
        'android/src/main/kotlin/eu/weblibre/pluggable_transports_proxy/pigeons/Proxy.g.kt',
    kotlinOptions: KotlinOptions(
      package: 'eu.weblibre.pluggable_transports_proxy.pigeons',
    ),
    dartPackageName: 'pluggable_transports_proxy',
  ),
)
@HostApi()
abstract class IPtProxyController {
  int start(ProxyType proxyType, String proxy);
  void stop(ProxyType proxyType);
}
