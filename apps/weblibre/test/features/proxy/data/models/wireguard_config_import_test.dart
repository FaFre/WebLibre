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
        'persistent_keepalive_interval': '25',
      });
      expect(imported.primaryDnsAddress, 'udp://1.1.1.1');
    });

    test('a bare Address is read as a single host', () {
      final imported = WireguardConfigImport.fromConfigText('''
        [Interface]
        PrivateKey = private-key
        Address = 10.0.0.2, fd00::2

        [Peer]
        PublicKey = peer-public-key
        Endpoint = wg.example.com:51820
      ''');

      expect(
        imported.values['local_address'],
        '10.0.0.2/32\nfd00::2/128',
        reason:
            'sing-box refuses to parse a bare address, so a config wg-quick '
            'accepts would import cleanly and then fail to start',
      );
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
      expect(imported.values['mtu'], '1280');
    });

    test('brackets an IPv6 resolver so the address stays parseable', () {
      final imported = WireguardConfigImport.fromConfigText('''
        [Interface]
        PrivateKey = private-key
        Address = fd00::2/128
        DNS = fd00::1

        [Peer]
        PublicKey = peer-public-key
        Endpoint = wg.example.com:51820
      ''');

      // A `DNS =` line carries the literal bare; `udp://fd00::1` has no
      // readable host and the runtime refuses to start on it.
      expect(imported.primaryDnsAddress, 'udp://[fd00::1]');
    });

    test('keeps a resolver that already carries a scheme', () {
      final imported = WireguardConfigImport.fromConfigText('''
        [Interface]
        PrivateKey = private-key
        Address = 10.0.0.2/32
        DNS = https://dns.example/dns-query

        [Peer]
        PublicKey = peer-public-key
        Endpoint = wg.example.com:51820
      ''');

      expect(imported.primaryDnsAddress, 'https://dns.example/dns-query');
    });

    test('keeps an MTU the config specifies', () {
      final imported = WireguardConfigImport.fromConfigText('''
        [Interface]
        PrivateKey = private-key
        Address = 10.0.0.2/32
        MTU = 1420

        [Peer]
        PublicKey = peer-public-key
        Endpoint = wg.example.com:51820
      ''');

      expect(imported.values['mtu'], '1420');
    });

    test('keeps the configured keepalive interval', () {
      final imported = WireguardConfigImport.fromConfigText('''
        [Interface]
        PrivateKey = private-key
        Address = 10.0.0.2/32

        [Peer]
        PublicKey = peer-public-key
        Endpoint = wg.example.com:51820
        PersistentKeepalive = 15
      ''');

      expect(imported.values['persistent_keepalive_interval'], '15');
    });

    test('defaults keepalive on so an idle NAT mapping cannot expire', () {
      final imported = WireguardConfigImport.fromConfigText('''
        [Interface]
        PrivateKey = private-key
        Address = 10.0.0.2/32

        [Peer]
        PublicKey = peer-public-key
        Endpoint = wg.example.com:51820
      ''');

      expect(imported.values['persistent_keepalive_interval'], '25');
    });

    test('rejects configs without interface and peer sections', () {
      expect(
        () => WireguardConfigImport.fromConfigText('PrivateKey = private-key'),
        throwsFormatException,
      );
    });
  });
}
