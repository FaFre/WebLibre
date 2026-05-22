import 'package:flutter_test/flutter_test.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/models/container_data.dart';
import 'package:weblibre/features/proxy/data/proxy_connection.dart';

void main() {
  group('ContainerMetadata proxy serialization', () {
    test('round-trips proxyConnectionId through JSON', () {
      final metadata = ContainerMetadata.withDefaults(
        proxyConnectionId: const SingboxProxyConnectionId('profile-1'),
        clearDataOnExit: true,
      );

      final json = metadata.toJson();
      final restored = ContainerMetadata.fromJson(json);

      expect(
        json['proxyConnectionId'],
        const SingboxProxyConnectionId('profile-1').encode(),
      );
      expect(json['clearDataOnExit'], isTrue);
      expect(restored.proxyConnectionId, metadata.proxyConnectionId);
      expect(restored.usesTorProxy, isFalse);
    });

    test('usesTorProxy is true only for the Tor connection id', () {
      final tor = ContainerMetadata.withDefaults(
        proxyConnectionId: const TorProxyConnectionId(),
      );

      expect(tor.usesTorProxy, isTrue);
    });
  });
}
