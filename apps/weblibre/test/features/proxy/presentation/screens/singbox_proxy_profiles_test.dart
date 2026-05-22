import 'package:flutter/material.dart';
import 'package:flutter_singbox_proxy/flutter_singbox_proxy.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/features/proxy/data/models/proxy_profile_seed.dart';
import 'package:weblibre/features/proxy/data/proxy_connection.dart';
import 'package:weblibre/features/proxy/domain/repositories/singbox_proxy_credentials.dart';
import 'package:weblibre/features/proxy/domain/repositories/singbox_proxy_profiles.dart';
import 'package:weblibre/features/proxy/domain/repositories/singbox_proxy_runtime.dart';
import 'package:weblibre/features/proxy/presentation/screens/singbox_proxy_profile_editor.dart';
import 'package:weblibre/features/proxy/presentation/screens/singbox_proxy_profiles.dart';
import 'package:weblibre/features/proxy/presentation/widgets/profile_list/profile_tile.dart';
import 'package:weblibre/features/user/data/database/definitions.drift.dart'
    show ProxyProfile;

void main() {
  testWidgets('deleting a running profile stops through runtime repository', (
    tester,
  ) async {
    final profile = _profile(id: 'profile-1', name: 'Mullvad');
    final profilesRepository = _FakeProfilesRepository([profile]);
    final runtimeRepository = _FakeRuntimeRepository(
      SingboxProxyRuntimeState(
        status: SingboxProxyRuntimeStatus.running,
        endpoints: [
          SingboxProxyRuntimeEndpoint(
            profileId: SingboxProxyConnectionId(profile.id).encode(),
            host: '127.0.0.1',
            port: 12080,
            username: 'user',
            password: 'pass',
          ),
        ],
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          singboxProxyProfilesRepositoryProvider.overrideWith(
            () => profilesRepository,
          ),
          singboxProxyRuntimeRepositoryProvider.overrideWith(
            () => runtimeRepository,
          ),
        ],
        child: const MaterialApp(home: SingboxProxyProfilesScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Mullvad'), findsOneWidget);

    await tester.tap(
      find.descendant(
        of: find.byType(ProfileTile),
        matching: find.byIcon(Icons.more_vert),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(find.text('Stop and Delete'), findsOneWidget);

    await tester.tap(find.text('Stop and Delete'));
    await tester.pumpAndSettle();

    expect(runtimeRepository.deletedProfileIds, ['profile-1']);
  });

  testWidgets('proxy URI import populates structured editor fields', (
    tester,
  ) async {
    await _pumpEditor(
      tester,
      profilesRepository: _FakeProfilesRepository([]),
      seed: ProxyProfileSeed(
        type: SingboxProxyProfileType.vless,
        name: 'Imported VLESS',
        values: {
          'server': 'vless.example.com',
          'server_port': '443',
          'uuid': '00000000-0000-0000-0000-000000000000',
          'flow': 'xtls-rprx-vision',
          'tls.server_name': 'front.example.com',
        },
      ),
    );

    expect(find.text('Imported VLESS'), findsOneWidget);
    expect(find.text('VLESS'), findsOneWidget);
    expect(find.text('Connection'), findsWidgets);
    expect(find.text('Credentials'), findsOneWidget);
    expect(find.text('TLS'), findsOneWidget);
    expect(_fieldText(tester, 'Server Address *'), 'vless.example.com');
    expect(_fieldText(tester, 'Server Port *'), '443');
    expect(
      _fieldText(tester, 'UUID *'),
      '00000000-0000-0000-0000-000000000000',
    );
  });

  testWidgets('WireGuard config import populates WireGuard form fields', (
    tester,
  ) async {
    await _pumpEditor(
      tester,
      profilesRepository: _FakeProfilesRepository([]),
      seed: ProxyProfileSeed(
        type: SingboxProxyProfileType.wireguard,
        values: {
          'server': 'wg.example.com',
          'server_port': '51820',
          'local_address': '10.0.0.2/32',
          'private_key': 'private-key',
          'peer_public_key': 'peer-public-key',
        },
      ),
    );

    expect(_fieldText(tester, 'Server Address *'), 'wg.example.com');
    expect(_fieldText(tester, 'Server Port *'), '51820');
    expect(_fieldText(tester, 'Local Address *'), '10.0.0.2/32');
    expect(_fieldText(tester, 'Private Key *'), 'private-key');
  });
}

Future<void> _pumpEditor(
  WidgetTester tester, {
  required _FakeProfilesRepository profilesRepository,
  String? profileId,
  ProxyProfileSeed? seed,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        singboxProxyProfilesRepositoryProvider.overrideWith(
          () => profilesRepository,
        ),
        singboxProxyCredentialsRepositoryProvider.overrideWith(
          _FakeCredentialsRepository.new,
        ),
        singboxProxyRuntimeRepositoryProvider.overrideWith(
          () => _FakeRuntimeRepository(
            SingboxProxyRuntimeState(
              status: SingboxProxyRuntimeStatus.stopped,
              endpoints: const [],
            ),
          ),
        ),
      ],
      child: MaterialApp(
        home: SingboxProxyProfileEditorScreen(profileId: profileId, seed: seed),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

String _fieldText(WidgetTester tester, String labelText) {
  final textField = tester.widget<TextField>(
    find.ancestor(of: find.text(labelText), matching: find.byType(TextField)),
  );
  return textField.controller!.text;
}

ProxyProfile _profile({
  required String id,
  required String name,
  SingboxProxyProfileType type = SingboxProxyProfileType.customOutbound,
  String configJson = '{"type":"socks"}',
}) {
  final createdAt = DateTime(2026);

  return ProxyProfile(
    id: id,
    name: name,
    type: type,
    configJson: configJson,
    createdAt: createdAt,
    updatedAt: createdAt,
  );
}

class _FakeProfilesRepository extends SingboxProxyProfilesRepository {
  final List<ProxyProfile> profiles;

  _FakeProfilesRepository(this.profiles);

  @override
  Stream<List<ProxyProfile>> build() => Stream.value(profiles);
}

class _FakeCredentialsRepository extends SingboxProxyCredentialsRepository {
  @override
  Future<String?> readSecretJson(String profileId) async => null;

  @override
  void build() {}
}

class _FakeRuntimeRepository extends SingboxProxyRuntimeRepository {
  final SingboxProxyRuntimeState initialState;
  final deletedProfileIds = <String>[];

  _FakeRuntimeRepository(this.initialState);

  @override
  Future<SingboxProxyRuntimeState> build() async => initialState;

  @override
  Future<void> deleteProfile(String profileId) async {
    deletedProfileIds.add(profileId);
  }
}
