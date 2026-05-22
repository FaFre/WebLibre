import 'package:drift/native.dart';
import 'package:flutter_singbox_proxy/flutter_singbox_proxy.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/data/database/functions/lexo_rank_functions.dart';
import 'package:weblibre/features/proxy/domain/repositories/singbox_proxy_credentials.dart';
import 'package:weblibre/features/proxy/domain/repositories/singbox_proxy_profiles.dart';
import 'package:weblibre/features/user/data/database/database.dart';
import 'package:weblibre/features/user/data/database/definitions.drift.dart'
    show ProxyProfile;
import 'package:weblibre/features/user/data/providers.dart';

void main() {
  test(
    'createProfile persists metadata and writes secrets separately',
    () async {
      final credentials = _FakeCredentialsRepository();
      final container = _container(credentials);
      addTearDown(container.dispose);

      final repository = container.read(
        singboxProxyProfilesRepositoryProvider.notifier,
      );
      final created = await repository.createProfile(
        name: 'Mullvad WG',
        type: SingboxProxyProfileType.wireguard,
        configJson: '{"server":"vpn.example"}',
        secretJson: '{"private_key":"secret"}',
      );

      final profiles = await repository.fetchProfiles();

      expect(profiles, hasLength(1));
      expect(profiles.single.id, created.id);
      expect(profiles.single.name, 'Mullvad WG');
      expect(profiles.single.type, SingboxProxyProfileType.wireguard);
      expect(profiles.single.configJson, '{"server":"vpn.example"}');
      expect(credentials.writtenSecrets, {
        created.id: '{"private_key":"secret"}',
      });
    },
  );

  test(
    'updateProfile updates metadata without touching secrets by default',
    () async {
      final credentials = _FakeCredentialsRepository();
      final container = _container(credentials);
      addTearDown(container.dispose);

      final repository = container.read(
        singboxProxyProfilesRepositoryProvider.notifier,
      );
      final profile = _profile(id: 'profile-1', name: 'Original');
      await repository.updateProfile(profile);
      await repository.updateProfile(
        profile.copyWith(name: 'Updated', configJson: '{"type":"http"}'),
      );

      final profiles = await repository.fetchProfiles();

      expect(profiles, hasLength(1));
      expect(profiles.single.id, 'profile-1');
      expect(profiles.single.name, 'Updated');
      expect(profiles.single.configJson, '{"type":"http"}');
      expect(credentials.writtenSecrets, isEmpty);
    },
  );

  test('updateProfile writes secrets only when requested', () async {
    final credentials = _FakeCredentialsRepository();
    final container = _container(credentials);
    addTearDown(container.dispose);

    final repository = container.read(
      singboxProxyProfilesRepositoryProvider.notifier,
    );
    final profile = _profile(id: 'profile-1', name: 'SOCKS');

    await repository.updateProfile(
      profile,
      secretJson: '{"password":"secret"}',
    );

    expect(credentials.writtenSecrets, {'profile-1': '{"password":"secret"}'});
  });

  test('deleteProfile removes metadata and deletes secrets', () async {
    final credentials = _FakeCredentialsRepository();
    final container = _container(credentials);
    addTearDown(container.dispose);

    final repository = container.read(
      singboxProxyProfilesRepositoryProvider.notifier,
    );
    await repository.updateProfile(
      _profile(id: 'profile-1', name: 'SOCKS'),
      secretJson: '{"password":"secret"}',
    );

    await repository.deleteProfile('profile-1');

    expect(await repository.fetchProfiles(), isEmpty);
    expect(credentials.deletedSecretIds, ['profile-1']);
  });
}

ProviderContainer _container(_FakeCredentialsRepository credentials) {
  final db = UserDatabase(
    NativeDatabase.memory(
      setup: (database) {
        registerLexorankFunctions(database);
      },
    ),
  );
  addTearDown(db.close);

  return ProviderContainer(
    overrides: [
      userDatabaseProvider.overrideWith((ref) => db),
      singboxProxyCredentialsRepositoryProvider.overrideWith(() => credentials),
    ],
  );
}

ProxyProfile _profile({required String id, required String name}) {
  final createdAt = DateTime(2026);

  return ProxyProfile(
    id: id,
    name: name,
    type: SingboxProxyProfileType.socks,
    configJson: '{"type":"socks"}',
    createdAt: createdAt,
    updatedAt: createdAt,
  );
}

class _FakeCredentialsRepository extends SingboxProxyCredentialsRepository {
  final writtenSecrets = <String, String?>{};
  final deletedSecretIds = <String>[];

  @override
  Future<void> writeSecretJson(String profileId, String? secretJson) async {
    writtenSecrets[profileId] = secretJson;
  }

  @override
  Future<void> deleteSecretJson(String profileId) async {
    deletedSecretIds.add(profileId);
  }

  @override
  void build() {}
}
