// The notifier subclasses below are test doubles: recording what a collaborator
// was asked to do is their whole purpose.
// ignore_for_file: riverpod_lint/avoid_public_notifier_properties

import 'dart:convert';

import 'package:flutter_singbox_proxy/flutter_singbox_proxy.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/features/proxy/data/models/proxy_import_failure.dart';
import 'package:weblibre/features/proxy/data/models/proxy_profile_seed.dart';
import 'package:weblibre/features/proxy/domain/repositories/singbox_proxy_profiles.dart';
import 'package:weblibre/features/proxy/domain/repositories/singbox_proxy_runtime.dart';
import 'package:weblibre/features/proxy/domain/services/proxy_input_consumer.dart';
import 'package:weblibre/features/user/data/database/definitions.drift.dart'
    show ProxyProfile;

const _privateKey = 'AQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQE=';
const _peerPublicKey = 'AgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgI=';

Map<String, Object?> _wireguardEndpoint({
  String tag = 'wg-lv',
  List<Map<String, Object?>>? peers,
}) {
  return {
    'type': 'wireguard',
    'tag': tag,
    'address': ['10.64.0.2/32'],
    'private_key': _privateKey,
    'mtu': 1280,
    'udp_fragment': true,
    'peers':
        peers ??
        [
          {
            'address': 'lv.example.com',
            'port': 51820,
            'public_key': _peerPublicKey,
            'allowed_ips': ['0.0.0.0/0', '::/0'],
          },
        ],
  };
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _FakeProfilesRepository profiles;
  late _FakeRuntimeRepository runtime;
  late ProviderContainer container;

  setUp(() {
    profiles = _FakeProfilesRepository();
    runtime = _FakeRuntimeRepository();
    container = ProviderContainer(
      overrides: [
        singboxProxyProfilesRepositoryProvider.overrideWith(() => profiles),
        singboxProxyRuntimeRepositoryProvider.overrideWith(() => runtime),
      ],
    );
  });

  tearDown(() => container.dispose());

  Future<ProxyInputOutcome> consume(Object json) => container
      .read(proxyInputConsumerProvider.notifier)
      .consumeRawText(jsonEncode(json), defaultName: (n) => 'Imported $n');

  test(
    'a whole config with one proxy seeds the editor with that proxy',
    () async {
      // "sing-box JSON" used to mean one outbound object only; a full config
      // failed with "missing a top-level type".
      final outcome = await consume({
        'log': {'level': 'warn'},
        'outbounds': [
          {'type': 'direct', 'tag': 'direct'},
          {'type': 'block', 'tag': 'block'},
        ],
        'endpoints': [_wireguardEndpoint()],
      });

      final seed = (outcome as ProxyInputSeed).seed;
      expect(seed.type, SingboxProxyProfileType.wireguard);
      expect(seed.name, 'wg-lv');
      // sing-box's endpoint format, read into the profile's fields.
      expect(seed.values['server'], 'lv.example.com');
      expect(seed.values['server_port'], '51820');
      expect(seed.values['peer_public_key'], _peerPublicKey);
      expect(seed.values['local_address'], '10.64.0.2/32');
      expect(seed.values['allowed_ips'], '0.0.0.0/0\n::/0');
      // What the form has no field for survives into the saved profile.
      final base = jsonDecode(seed.baseConfigJson!) as Map<String, dynamic>;
      expect(base['udp_fragment'], isTrue);
      expect(base.containsKey('peers'), isFalse);
      expect(seed.notes, isEmpty);
    },
  );

  test('a whole config with several proxies imports each of them', () async {
    final outcome = await consume({
      'outbounds': [
        {
          'type': 'socks',
          'tag': 'office',
          'server': '192.0.2.10',
          'server_port': 1080,
        },
        {'type': 'direct', 'tag': 'direct'},
      ],
      'endpoints': [_wireguardEndpoint()],
    });

    final imported = outcome as ProxyInputImportedMany;
    expect(imported.skipped, 0);
    expect(imported.created.map((profile) => profile.name), [
      'office',
      'wg-lv',
    ]);
  });

  test('a proxy whose fields do not validate is skipped, not stored', () async {
    final outcome = await consume({
      'endpoints': [
        _wireguardEndpoint(),
        _wireguardEndpoint(
          tag: 'broken',
          peers: [
            {
              'address': 'nl.example.com',
              'port': 51820,
              'public_key': 'not-a-key',
            },
          ],
        ),
      ],
    });

    final imported = outcome as ProxyInputImportedMany;
    expect(imported.created.map((profile) => profile.name), ['wg-lv']);
    expect(imported.skipped, 1);
  });

  test('an endpoint with two peers is refused, not merged', () async {
    final outcome = await consume(
      _wireguardEndpoint(
        peers: [
          {'address': 'one.example.com', 'port': 51820, 'public_key': 'a'},
          {'address': 'two.example.com', 'port': 51820, 'public_key': 'b'},
        ],
      ),
    );

    expect(outcome, isA<ProxyInputError>());
  });

  test(
    'a proxy in a config that cannot be read is skipped, not the config',
    () async {
      final outcome = await consume({
        'outbounds': [
          for (final tag in ['a', 'b'])
            {
              'type': 'socks',
              'tag': tag,
              'server': '192.0.2.10',
              'server_port': 1080,
            },
        ],
        'endpoints': [
          _wireguardEndpoint(
            peers: [
              {'address': 'one.example.com', 'port': 51820, 'public_key': 'a'},
              {'address': 'two.example.com', 'port': 51820, 'public_key': 'b'},
            ],
          ),
        ],
      });

      final imported = outcome as ProxyInputImportedMany;
      expect(imported.created.map((profile) => profile.name), ['a', 'b']);
      expect(imported.skipped, 1);
    },
  );

  test(
    'one usable proxy next to a skipped one is imported, not edited',
    () async {
      // The editor would drop what was skipped without a word.
      final outcome = await consume({
        'outbounds': [
          {
            'type': 'socks',
            'tag': 'only',
            'server': '192.0.2.10',
            'server_port': 1080,
          },
        ],
        'endpoints': [
          _wireguardEndpoint(peers: [{}, {}]),
        ],
      });

      final imported = outcome as ProxyInputImportedMany;
      expect(imported.created.map((profile) => profile.name), ['only']);
      expect(imported.skipped, 1);
    },
  );

  test('a proxy whose import throws is counted, the rest kept', () async {
    runtime.throwFor = 'b';
    final outcome = await consume({
      'outbounds': [
        for (final tag in ['a', 'b', 'c'])
          {
            'type': 'socks',
            'tag': tag,
            'server': '192.0.2.10',
            'server_port': 1080,
          },
      ],
    });

    final imported = outcome as ProxyInputImportedMany;
    expect(imported.created.map((profile) => profile.name), ['a', 'c']);
    expect(imported.skipped, 1);
  });

  test("pasted proxies without a tag get the caller's default name", () async {
    final outcome = await consume({
      'outbounds': [
        for (var i = 0; i < 2; i++)
          {'type': 'socks', 'server': '192.0.2.10', 'server_port': 1080},
      ],
    });

    final imported = outcome as ProxyInputImportedMany;
    expect(imported.created.map((profile) => profile.name), [
      'Imported 1',
      'Imported 2',
    ]);
  });

  test('a proxy that dials through another one is refused', () async {
    // Dropping the detour would dial the server directly, showing it the
    // address the chain was there to hide.
    final outcome = await consume({
      'type': 'socks',
      'tag': 'exit',
      'server': 'proxy.example.com',
      'server_port': 1080,
      'detour': 'entry',
    });

    final failure = (outcome as ProxyInputError).error as ProxyImportFailure;
    expect(failure.kind, ProxyImportFailureKind.unresolvedDetour);
    expect(failure.detail, 'entry');
  });

  test(
    'an outbound on its own asks for its config to judge a detour',
    () async {
      // Copied out of a config, it cannot say what `direct` is there: one that
      // binds an interface would be dropped along with the route it enforces.
      final outcome = await consume({
        'type': 'socks',
        'tag': 'office',
        'server': 'proxy.example.com',
        'server_port': 1080,
        'detour': 'direct',
      });

      final failure = (outcome as ProxyInputError).error as ProxyImportFailure;
      expect(failure.kind, ProxyImportFailureKind.unresolvedDetour);
      expect(failure.detail, 'direct');
    },
  );

  test('a chained proxy in a config is skipped, its entry imported', () async {
    final outcome = await consume({
      'outbounds': [
        {
          'type': 'socks',
          'tag': 'entry',
          'server': '192.0.2.10',
          'server_port': 1080,
        },
        {
          'type': 'socks',
          'tag': 'exit',
          'server': '192.0.2.20',
          'server_port': 1080,
          'detour': 'entry',
        },
      ],
    });

    final imported = outcome as ProxyInputImportedMany;
    expect(imported.created.map((profile) => profile.name), ['entry']);
    expect(imported.skipped, 1);
    expect(profiles.created.single.configJson, isNot(contains('detour')));
  });

  test(
    'a detour into the direct outbound and a foreign resolver are dropped',
    () async {
      final outcome = await consume({
        'outbounds': [
          {
            'type': 'socks',
            'tag': 'office',
            'server': 'proxy.example.com',
            'server_port': 1080,
            'detour': 'direct-out',
            'domain_resolver': {
              'server': 'dns-remote',
              'strategy': 'ipv4_only',
            },
          },
          {'type': 'direct', 'tag': 'direct-out'},
        ],
      });

      final seed = (outcome as ProxyInputSeed).seed;
      final base = jsonDecode(seed.baseConfigJson!) as Map<String, dynamic>;
      // Tags of the config it came from: sing-box refuses them in ours.
      expect(base.containsKey('detour'), isFalse);
      expect(base.containsKey('domain_resolver'), isFalse);
      expect(seed.values['detour'] ?? '', isEmpty);
    },
  );

  test('a detour into a configured direct outbound is refused', () async {
    for (final setting in <String, Object>{
      'bind_interface': 'wlan0',
      'inet4_bind_address': '192.0.2.1',
      'routing_mark': 1234,
      'domain_resolver': 'dns-local',
    }.entries) {
      final outcome = await consume({
        'outbounds': [
          {
            'type': 'socks',
            'tag': 'office',
            'server': 'proxy.example.com',
            'server_port': 1080,
            'detour': 'wifi-only',
          },
          {'type': 'direct', 'tag': 'wifi-only', setting.key: setting.value},
        ],
      });

      // Dropped, the binding is gone and the dial takes the default network.
      final failure = (outcome as ProxyInputError).error as ProxyImportFailure;
      expect(
        failure.kind,
        ProxyImportFailureKind.detourThroughOtherOutbound,
        reason: setting.key,
      );
      expect(failure.detail, 'wifi-only');
    }
    expect(profiles.created, isEmpty);
  });

  test('a domain resolver every runtime has is kept', () async {
    final outcome = await consume({
      'type': 'socks',
      'server': 'proxy.example.com',
      'server_port': 1080,
      'domain_resolver': 'local',
    });

    final seed = (outcome as ProxyInputSeed).seed;
    final base = jsonDecode(seed.baseConfigJson!) as Map<String, dynamic>;
    expect(base['domain_resolver'], 'local');
  });

  test('a split tunnel is pointed out before saving', () async {
    final outcome = await consume(
      _wireguardEndpoint(
        peers: [
          {
            'address': 'lv.example.com',
            'port': 51820,
            'public_key': _peerPublicKey,
            'allowed_ips': ['192.168.0.0/16'],
          },
        ],
      ),
    );

    final notes = (outcome as ProxyInputSeed).seed.notes;
    expect(notes.single, isA<ProxyImportSplitTunnel>());
  });

  test('a split tunnel imported with others is still pointed out', () async {
    final outcome = await consume({
      'endpoints': [
        _wireguardEndpoint(),
        _wireguardEndpoint(
          tag: 'office',
          peers: [
            {
              'address': 'office.example.com',
              'port': 51820,
              'public_key': _peerPublicKey,
              'allowed_ips': ['10.0.0.0/8'],
            },
          ],
        ),
      ],
    });

    // Stored without the editor, so the note has to come back with them.
    final imported = outcome as ProxyInputImportedMany;
    expect(imported.created, hasLength(2));
    expect(imported.notes.single.profileName, 'office');
    expect(imported.notes.single.note, isA<ProxyImportSplitTunnel>());
  });

  test('a config with nothing to connect to says so', () async {
    final outcome = await consume({
      'outbounds': [
        {'type': 'direct', 'tag': 'direct'},
        {'type': 'block', 'tag': 'block'},
      ],
    });

    expect(outcome, isA<ProxyInputError>());
  });

  test('a config whose outbounds are not a list is an error', () async {
    // Used to escape as a TypeError, which nothing caught.
    final outcome = await consume({
      'outbounds': {'type': 'socks'},
    });

    expect(outcome, isA<ProxyInputError>());
  });
}

class _FakeProfilesRepository extends SingboxProxyProfilesRepository {
  final created = <ProxyProfile>[];

  @override
  Future<ProxyProfile> createProfile({
    required String name,
    required SingboxProxyProfileType type,
    required String configJson,
    String? secretJson,
    String? dnsOverrideJson,
    bool autostart = false,
  }) async {
    final profile = ProxyProfile(
      id: 'id-${created.length}',
      name: name,
      type: type,
      configJson: configJson,
      dnsOverrideJson: dnsOverrideJson,
      autostart: autostart,
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
    );
    created.add(profile);
    return profile;
  }

  @override
  Stream<List<ProxyProfile>> build() => Stream.value(created);
}

class _FakeRuntimeRepository extends SingboxProxyRuntimeRepository {
  /// Name of the profile whose validation throws, as a platform call can.
  String? throwFor;

  @override
  Future<String?> validateProfileDraft(
    ProxyProfile profile, {
    String? secretJson,
  }) async {
    if (profile.name == throwFor) throw StateError('platform call failed');
    return null;
  }

  @override
  Future<SingboxProxyRuntimeState> build() async => SingboxProxyRuntimeState(
    status: SingboxProxyRuntimeStatus.stopped,
    endpoints: const [],
  );
}
