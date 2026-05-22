import 'package:flutter_test/flutter_test.dart';
import 'package:weblibre/features/proxy/data/models/wireguard_config_import.dart';

void main() {
  group('WireguardConfigImport', () {
    test('imports standard WireGuard config text', () {
      final imported = WireguardConfigImport.fromConfigText('''
        [Interface]
        PrivateKey = private-key
        Address = 10.0.0.2/32, fd00::2/128
        MTU = 1420
        DNS = 1.1.1.1

        [Peer]
        PublicKey = peer-public-key
        PresharedKey = pre-shared-key
        AllowedIPs = 0.0.0.0/0, ::/0
        Endpoint = wg.example.com:51820
      ''');

      expect(imported.values, {
        'server': 'wg.example.com',
        'server_port': '51820',
        'local_address': '10.0.0.2/32\nfd00::2/128',
        'private_key': 'private-key',
        'peer_public_key': 'peer-public-key',
        'pre_shared_key': 'pre-shared-key',
        'mtu': '1420',
      });
      expect(imported.primaryDnsAddress, 'udp://1.1.1.1');
    });

    test('imports bracketed IPv6 WireGuard endpoint', () {
      final imported = WireguardConfigImport.fromConfigText('''
        [Interface]
        PrivateKey = private-key
        Address = fd00::2/128

        [Peer]
        PublicKey = peer-public-key
        Endpoint = [2001:db8::1]:51820
      ''');

      expect(imported.values['server'], '2001:db8::1');
      expect(imported.values['server_port'], '51820');
      expect(imported.values['mtu'], '1408');
    });

    test('rejects configs without interface and peer sections', () {
      expect(
        () => WireguardConfigImport.fromConfigText('PrivateKey = private-key'),
        throwsFormatException,
      );
    });
  });
}
