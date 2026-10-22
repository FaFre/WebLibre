import 'dart:convert';

import 'package:flutter_singbox_proxy/flutter_singbox_proxy.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weblibre/features/proxy/data/forms/singbox_form_spec.dart';
import 'package:weblibre/features/proxy/data/forms/singbox_form_specs.dart';
import 'package:weblibre/features/proxy/data/parsers/singbox_json_import.dart';
import 'package:weblibre/features/proxy/data/parsers/singbox_proxy_uri.dart';

// Real-shaped WireGuard keys (base64 of 32 bytes): the form checks the format.
const _privateKey = 'AQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQE=';
const _peerPublicKey = 'AgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgI=';
const _preSharedKey = 'AwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwM=';

void main() {
  group('SingboxProxyFormSpec', () {
    test('builds public and secret JSON for Shadowsocks', () {
      final spec = singboxProxyFormSpecs[SingboxProxyProfileType.shadowsocks]!;
      final values = {
        'server': 'ss.example.com',
        'server_port': '8388',
        'method': '2022-blake3-aes-128-gcm',
        'password': 'secret',
      };

      expect(spec.validate(values), isNull);

      final config = jsonDecode(spec.toConfigJson(values));
      final secrets = jsonDecode(spec.toSecretJson(values)!);

      expect(config, {
        'type': 'shadowsocks',
        'server': 'ss.example.com',
        'server_port': 8388,
        'method': '2022-blake3-aes-128-gcm',
      });
      expect(secrets, {'password': 'secret'});
    });

    test('serializes SOCKS version as a JSON string', () {
      final spec = singboxProxyFormSpecs[SingboxProxyProfileType.socks]!;
      final values = {
        'server': '127.0.0.1',
        'server_port': '9050',
        'version': '5',
      };

      expect(spec.validate(values), isNull);

      final config =
          jsonDecode(spec.toConfigJson(values)) as Map<String, dynamic>;

      // sing-box rejects a numeric version; it must be the string "5".
      expect(config['version'], '5');
      expect(config['version'], isA<String>());
    });

    test('rejects an out-of-range SOCKS version', () {
      final spec = singboxProxyFormSpecs[SingboxProxyProfileType.socks]!;
      final values = {
        'server': '127.0.0.1',
        'server_port': '9050',
        'version': '6',
      };

      expect(spec.validate(values), isNotNull);
    });

    test('hydrates structured values from public and secret JSON', () {
      final spec = singboxProxyFormSpecs[SingboxProxyProfileType.vless]!;

      final values = spec.valuesFromJson(
        configJson: '''
        {
          "type": "vless",
          "server": "vless.example.com",
          "server_port": 443,
          "flow": "xtls-rprx-vision"
        }''',
        secretJson: '{"uuid":"00000000-0000-0000-0000-000000000000"}',
      );

      expect(values['server'], 'vless.example.com');
      expect(values['server_port'], '443');
      expect(values['uuid'], '00000000-0000-0000-0000-000000000000');
      expect(values['flow'], 'xtls-rprx-vision');
    });

    test('rejects invalid server ports', () {
      final spec = singboxProxyFormSpecs[SingboxProxyProfileType.http]!;

      final error = spec.validate({
        'server': 'proxy.example.com',
        'server_port': '70000',
      });

      expect(error, isNotNull);
      expect(error!.field.key, 'server_port');
      expect(error.kind, SingboxFieldErrorKind.outOfPortRange);
    });

    test('builds nested advanced config fields', () {
      final spec = singboxProxyFormSpecs[SingboxProxyProfileType.vless]!;
      final values = {
        'server': 'vless.example.com',
        'server_port': '443',
        'uuid': '00000000-0000-0000-0000-000000000000',
        'flow': 'xtls-rprx-vision',
        'tls.enabled': 'true',
        'tls.server_name': 'front.example.com',
        'tls.alpn': 'h2, http/1.1',
        'transport.type': 'ws',
        'transport.path': '/proxy',
        'multiplex.enabled': 'true',
        'multiplex.max_connections': '4',
        'domain_strategy': 'prefer_ipv4',
      };

      expect(spec.validate(values), isNull);

      final config =
          jsonDecode(spec.toConfigJson(values)) as Map<String, dynamic>;
      final secrets =
          jsonDecode(spec.toSecretJson(values)!) as Map<String, dynamic>;

      expect(config['tls'], {
        'enabled': true,
        'server_name': 'front.example.com',
        'alpn': ['h2', 'http/1.1'],
      });
      expect(config['transport'], {'type': 'ws', 'path': '/proxy'});
      expect(config['multiplex'], {'enabled': true, 'max_connections': 4});
      expect(config['domain_strategy'], 'prefer_ipv4');
      expect(secrets, {'uuid': '00000000-0000-0000-0000-000000000000'});
    });

    test('builds public and secret JSON for WireGuard', () {
      final spec = singboxProxyFormSpecs[SingboxProxyProfileType.wireguard]!;
      final values = {
        'server': 'wg.example.com',
        'server_port': '51820',
        'local_address': '10.0.0.2/32\nfd00::2/128',
        'private_key': _privateKey,
        'peer_public_key': _peerPublicKey,
        'pre_shared_key': _preSharedKey,
        'mtu': '1420',
        'reserved': '1, 2, 3',
      };

      expect(spec.validate(values), isNull);

      final config = jsonDecode(spec.toConfigJson(values));
      final secrets = jsonDecode(spec.toSecretJson(values)!);

      expect(config, {
        'type': 'wireguard',
        'server': 'wg.example.com',
        'server_port': 51820,
        'local_address': ['10.0.0.2/32', 'fd00::2/128'],
        'peer_public_key': _peerPublicKey,
        'mtu': 1420,
        'reserved': [1, 2, 3],
      });
      expect(secrets, {
        'private_key': _privateKey,
        'pre_shared_key': _preSharedKey,
      });
    });

    test('a WireGuard address without a prefix is written out as one', () {
      final spec = singboxProxyFormSpecs[SingboxProxyProfileType.wireguard]!;
      final values = {
        'server': 'wg.example.com',
        'server_port': '51820',
        'local_address': '10.0.0.2\nfd00::2',
        'private_key': _privateKey,
        'peer_public_key': _peerPublicKey,
      };

      expect(spec.validate(values), isNull);

      final config =
          jsonDecode(spec.toConfigJson(values)) as Map<String, Object?>;
      expect(
        config['local_address'],
        ['10.0.0.2/32', 'fd00::2/128'],
        reason: 'sing-box only accepts prefixes, and refuses to start without',
      );
    });

    test('a WireGuard address that is not an address is refused', () {
      final spec = singboxProxyFormSpecs[SingboxProxyProfileType.wireguard]!;
      final values = {
        'server': 'wg.example.com',
        'server_port': '51820',
        'local_address': '10.0.0.2\nnot-an-address',
        'private_key': _privateKey,
        'peer_public_key': _peerPublicKey,
      };

      final error = spec.validate(values);

      expect(error, isNotNull);
      expect(error!.kind, SingboxFieldErrorKind.invalidCidr);
      expect(error.stringParam, 'not-an-address');
    });

    test('hydrates WireGuard values from public and secret JSON', () {
      final spec = singboxProxyFormSpecs[SingboxProxyProfileType.wireguard]!;

      final values = spec.valuesFromJson(
        configJson: '''
        {
          "type": "wireguard",
          "server": "wg.example.com",
          "server_port": 51820,
          "local_address": ["10.0.0.2/32"],
          "peer_public_key": "peer-public-key",
          "mtu": 1420,
          "reserved": [1, 2, 3]
        }''',
        secretJson: '''
        {
          "private_key": "private-key",
          "pre_shared_key": "pre-shared-key"
        }''',
      );

      expect(values['server'], 'wg.example.com');
      expect(values['server_port'], '51820');
      expect(values['local_address'], '10.0.0.2/32');
      expect(values['private_key'], 'private-key');
      expect(values['peer_public_key'], 'peer-public-key');
      expect(values['pre_shared_key'], 'pre-shared-key');
      expect(values['mtu'], '1420');
      expect(values['reserved'], '1\n2\n3');
    });

    test('rejects invalid WireGuard reserved bytes', () {
      final spec = singboxProxyFormSpecs[SingboxProxyProfileType.wireguard]!;

      final error = spec.validate({
        'server': 'wg.example.com',
        'server_port': '51820',
        'local_address': '10.0.0.2/32',
        'private_key': _privateKey,
        'peer_public_key': _peerPublicKey,
        'mtu': '1420',
        'reserved': '1, 2',
      });

      expect(error, isNotNull);
      expect(error!.field.key, 'reserved');
      expect(error.kind, SingboxFieldErrorKind.wrongListLength);
      expect(error.intParam, 3);
    });
  });

  group('importSingboxProxyUri', () {
    test('imports Shadowsocks SIP002 URI', () {
      final credentials = base64Url.encode(
        utf8.encode('aes-256-gcm:secret-password'),
      );

      final imported = importSingboxProxyUri(
        'ss://$credentials@ss.example.com:8388#Work%20SS',
      );

      expect(imported.type, SingboxProxyProfileType.shadowsocks);
      expect(imported.name, 'Work SS');
      expect(imported.values, {
        'server': 'ss.example.com',
        'server_port': '8388',
        'method': 'aes-256-gcm',
        'password': 'secret-password',
      });
    });

    test('imports legacy base64 Shadowsocks URI', () {
      final payload = base64Url.encode(
        utf8.encode('chacha20-ietf-poly1305:secret@[2001:db8::1]:8388'),
      );

      final imported = importSingboxProxyUri('ss://$payload');

      expect(imported.type, SingboxProxyProfileType.shadowsocks);
      expect(imported.values['server'], '2001:db8::1');
      expect(imported.values['server_port'], '8388');
      expect(imported.values['method'], 'chacha20-ietf-poly1305');
      expect(imported.values['password'], 'secret');
    });

    test('imports Trojan URI', () {
      final imported = importSingboxProxyUri(
        'trojan://secret%20password@trojan.example.com:443#Trojan',
      );

      expect(imported.type, SingboxProxyProfileType.trojan);
      expect(imported.name, 'Trojan');
      expect(imported.values, {
        'server': 'trojan.example.com',
        'server_port': '443',
        'password': 'secret password',
        'tls.enabled': 'true',
      });
    });

    test('imports VLESS URI', () {
      final imported = importSingboxProxyUri(
        'vless://00000000-0000-0000-0000-000000000000@vless.example.com:443?flow=xtls-rprx-vision#VLESS',
      );

      expect(imported.type, SingboxProxyProfileType.vless);
      expect(imported.name, 'VLESS');
      expect(imported.values, {
        'server': 'vless.example.com',
        'server_port': '443',
        'uuid': '00000000-0000-0000-0000-000000000000',
        'flow': 'xtls-rprx-vision',
      });
    });

    test('imports VMess URI', () {
      final payload = base64Url.encode(
        utf8.encode(
          jsonEncode({
            'v': '2',
            'ps': 'VMess',
            'add': 'vmess.example.com',
            'port': '443',
            'id': '00000000-0000-0000-0000-000000000000',
            'aid': '0',
            'scy': 'auto',
          }),
        ),
      );

      final imported = importSingboxProxyUri('vmess://$payload');

      expect(imported.type, SingboxProxyProfileType.vmess);
      expect(imported.name, 'VMess');
      expect(imported.values, {
        'server': 'vmess.example.com',
        'server_port': '443',
        'uuid': '00000000-0000-0000-0000-000000000000',
        'security': 'auto',
        'alter_id': '0',
        'tls.enabled': '',
        'tls.server_name': '',
        'transport.type': '',
        'transport.path': '',
      });
    });

    test('imports SOCKS URI', () {
      final imported = importSingboxProxyUri(
        'socks://user:secret@socks.example.com:1080#SOCKS',
      );

      expect(imported.type, SingboxProxyProfileType.socks);
      expect(imported.name, 'SOCKS');
      expect(imported.values, {
        'server': 'socks.example.com',
        'server_port': '1080',
        'version': '5',
        'username': 'user',
        'password': 'secret',
      });
    });

    test('imports HTTPS proxy URI', () {
      final imported = importSingboxProxyUri(
        'https://user:secret@proxy.example.com:443?sni=proxy.example.com#HTTP',
      );

      expect(imported.type, SingboxProxyProfileType.http);
      expect(imported.values['server'], 'proxy.example.com');
      expect(imported.values['server_port'], '443');
      expect(imported.values['username'], 'user');
      expect(imported.values['password'], 'secret');
      expect(imported.values['tls.enabled'], 'true');
      expect(imported.values['tls.server_name'], 'proxy.example.com');
    });

    test('imports Hysteria2 URI', () {
      final imported = importSingboxProxyUri(
        'hy2://secret@hy2.example.com:443?obfs=salamander&obfs-password=obfs-secret&sni=front.example.com#HY2',
      );

      expect(imported.type, SingboxProxyProfileType.hysteria2);
      expect(imported.name, 'HY2');
      expect(imported.values['server'], 'hy2.example.com');
      expect(imported.values['server_port'], '443');
      expect(imported.values['password'], 'secret');
      expect(imported.values['obfs.type'], 'salamander');
      expect(imported.values['obfs.password'], 'obfs-secret');
      expect(imported.values['tls.enabled'], 'true');
      expect(imported.values['tls.server_name'], 'front.example.com');
    });

    test('imports TUIC URI', () {
      final imported = importSingboxProxyUri(
        'tuic://00000000-0000-0000-0000-000000000000:secret@tuic.example.com:443?congestion_control=bbr&udp_relay_mode=quic&sni=front.example.com#TUIC',
      );

      expect(imported.type, SingboxProxyProfileType.tuic);
      expect(imported.name, 'TUIC');
      expect(imported.values['server'], 'tuic.example.com');
      expect(imported.values['server_port'], '443');
      expect(imported.values['uuid'], '00000000-0000-0000-0000-000000000000');
      expect(imported.values['password'], 'secret');
      expect(imported.values['congestion_control'], 'bbr');
      expect(imported.values['udp_relay_mode'], 'quic');
      expect(imported.values['tls.enabled'], 'true');
      expect(imported.values['tls.server_name'], 'front.example.com');
    });

    test('rejects unsupported URI schemes', () {
      expect(
        () => importSingboxProxyUri('hysteria2://example.com:443'),
        throwsFormatException,
      );
    });

    test('rejects a WireGuard key that is not one', () {
      final spec = singboxProxyFormSpecs[SingboxProxyProfileType.wireguard]!;

      final error = spec.validate({
        'server': 'wg.example.com',
        'server_port': '51820',
        'local_address': '10.0.0.2/32',
        'peer_public_key': 'not-a-key',
        'private_key': _privateKey,
      });

      expect(error?.field.key, 'peer_public_key');
      expect(error?.kind, SingboxFieldErrorKind.invalidWireguardKey);
    });

    test('a WireGuard key is standard, padded base64', () {
      expect(isWireguardKey(_privateKey), isTrue);
      // Both decode to 32 bytes in Dart; sing-box refuses both.
      expect(isWireguardKey('-_${_privateKey.substring(2)}'), isFalse);
      expect(
        isWireguardKey(_privateKey.substring(0, _privateKey.length - 1)),
        isFalse,
      );
    });

    test('writes AllowedIPs for the peer', () {
      final spec = singboxProxyFormSpecs[SingboxProxyProfileType.wireguard]!;

      final config =
          jsonDecode(
                spec.toConfigJson({
                  'server': 'wg.example.com',
                  'server_port': '51820',
                  'local_address': '10.0.0.2/32',
                  'peer_public_key': _peerPublicKey,
                  'allowed_ips': '10.0.0.0/8\nfd00::/8',
                }),
              )
              as Map<String, dynamic>;

      expect(config['allowed_ips'], ['10.0.0.0/8', 'fd00::/8']);
    });

    test('a save keeps the keys the form has no field for', () {
      // Imported or hand-written keys used to vanish on the first edit:
      // the JSON was rebuilt from the fields alone.
      final spec = singboxProxyFormSpecs[SingboxProxyProfileType.wireguard]!;
      const base =
          """
      {
        "type": "wireguard",
        "server": "old.example.com",
        "server_port": 51820,
        "local_address": ["10.0.0.2/32"],
        "peer_public_key": "$_peerPublicKey",
        "private_key": "$_privateKey",
        "mtu": 1420,
        "udp_fragment": true,
        "workers": 2
      }""";

      final config =
          jsonDecode(
                spec.toConfigJson({
                  'server': 'new.example.com',
                  'server_port': '51820',
                  'local_address': '10.0.0.2/32',
                  'peer_public_key': _peerPublicKey,
                  'private_key': _privateKey,
                  // Cleared by the user: really removed, not left from base.
                  'mtu': '',
                }, baseConfigJson: base),
              )
              as Map<String, dynamic>;

      expect(config['server'], 'new.example.com');
      expect(config['udp_fragment'], isTrue);
      expect(config['workers'], 2);
      expect(config.containsKey('mtu'), isFalse);
      // A secret found in the config JSON moves to the secret JSON.
      expect(config.containsKey('private_key'), isFalse);
    });

    test('a cleared nested field is removed with its empty parent', () {
      final spec = singboxProxyFormSpecs[SingboxProxyProfileType.vless]!;
      const base = """
      {
        "type": "vless",
        "server": "example.com",
        "server_port": 443,
        "uuid": "00000000-0000-0000-0000-000000000000",
        "tls": { "enabled": true, "server_name": "example.com" }
      }""";

      final config =
          jsonDecode(
                spec.toConfigJson({
                  'server': 'example.com',
                  'server_port': '443',
                  'uuid': '00000000-0000-0000-0000-000000000000',
                }, baseConfigJson: base),
              )
              as Map<String, dynamic>;

      expect(config.containsKey('tls'), isFalse);
    });

    test('a credential the form has no field for is kept as a secret', () {
      // `auth` (hysteria's binary auth) and `plugin_opts` have no field. They
      // used to be dropped; keeping unknown keys must not leave them in the
      // plaintext config.
      final spec = singboxProxyFormSpecs[SingboxProxyProfileType.hysteria]!;
      const base = """
      {
        "type": "hysteria",
        "server": "example.com",
        "server_port": 443,
        "auth": "c2VjcmV0",
        "tls": { "certificate_path": "/x", "password": "p" },
        "hop_interval": "30s"
      }""";
      final values = {'server': 'example.com', 'server_port': '443'};

      final config =
          jsonDecode(spec.toConfigJson(values, baseConfigJson: base))
              as Map<String, dynamic>;
      final secrets =
          jsonDecode(spec.toSecretJson(values, baseConfigJson: base)!)
              as Map<String, dynamic>;

      expect(config.containsKey('auth'), isFalse);
      expect(config['hop_interval'], '30s');
      expect(config['tls'], {'certificate_path': '/x'});
      expect(secrets, {
        'auth': 'c2VjcmV0',
        'tls': {'password': 'p'},
      });
    });

    test('an imported TLS client key is kept as a secret', () {
      const imported = '''
      {
        "type": "vless",
        "tag": "work",
        "server": "example.com",
        "server_port": 443,
        "uuid": "bf000d23-0752-40b4-affe-68f7707a9661",
        "tls": {
          "enabled": true,
          "client_certificate": ["-----BEGIN CERTIFICATE-----"],
          "client_key": ["-----BEGIN PRIVATE KEY-----"]
        }
      }''';
      final seed = seedsFromSingboxJson(imported).seeds.single;
      final spec = singboxProxyFormSpecs[seed.type]!;

      final config =
          jsonDecode(
                spec.toConfigJson(
                  seed.values,
                  baseConfigJson: seed.baseConfigJson,
                ),
              )
              as Map<String, dynamic>;
      final secretJson = spec.toSecretJson(
        seed.values,
        baseConfigJson: seed.baseConfigJson,
      );
      final secrets = jsonDecode(secretJson!) as Map<String, dynamic>;

      expect(config['tls'], {
        'enabled': true,
        'client_certificate': ['-----BEGIN CERTIFICATE-----'],
      });
      expect(secrets['tls'], {
        'client_key': ['-----BEGIN PRIVATE KEY-----'],
      });
      // Read back for editing, the profile still has everything it had.
      expect(
        spec.valuesFromJson(
          configJson: jsonEncode(config),
          secretJson: secretJson,
        ),
        seed.values,
      );
    });

    test('a list holding a credential moves to the secrets whole', () {
      final spec = singboxProxyFormSpecs[SingboxProxyProfileType.shadowsocks]!;
      const base = """
      {
        "type": "shadowsocks",
        "server": "example.com",
        "server_port": 8388,
        "method": "aes-128-gcm",
        "extra": [{ "name": "a", "password": "p" }]
      }""";
      final values = {
        'server': 'example.com',
        'server_port': '8388',
        'method': 'aes-128-gcm',
        'password': 'secret',
      };

      final config =
          jsonDecode(spec.toConfigJson(values, baseConfigJson: base))
              as Map<String, dynamic>;
      final secrets =
          jsonDecode(spec.toSecretJson(values, baseConfigJson: base)!)
              as Map<String, dynamic>;

      expect(config.containsKey('extra'), isFalse);
      expect(secrets, {
        'password': 'secret',
        'extra': [
          {'name': 'a', 'password': 'p'},
        ],
      });
    });

    test('a nested secret field hydrates beside its plain sibling', () {
      final spec = singboxProxyFormSpecs[SingboxProxyProfileType.hysteria2]!;

      final values = spec.valuesFromJson(
        configJson: '{"type":"hysteria2","obfs":{"type":"salamander"}}',
        secretJson: '{"password":"p","obfs":{"password":"o"}}',
      );

      expect(values['obfs.type'], 'salamander');
      expect(values['obfs.password'], 'o');
    });
  });
}
