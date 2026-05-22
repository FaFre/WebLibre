import 'package:flutter_singbox_proxy/flutter_singbox_proxy.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/features/proxy/data/models/proxy_profile_seed.dart';
import 'package:weblibre/features/proxy/domain/repositories/singbox_proxy_credentials.dart';
import 'package:weblibre/features/proxy/domain/repositories/singbox_proxy_profiles.dart';
import 'package:weblibre/features/proxy/domain/repositories/singbox_proxy_runtime.dart';
import 'package:weblibre/features/proxy/presentation/controllers/proxy_profile_draft_controller.dart';
import 'package:weblibre/features/user/data/database/definitions.drift.dart'
    show ProxyProfile;

void main() {
  test('save validates and creates a seeded structured profile', () async {
    final runtimeRepository = _FakeRuntimeRepository();
    final profilesRepository = _FakeProfilesRepository();
    final container = _container(
      runtimeRepository: runtimeRepository,
      profilesRepository: profilesRepository,
    );
    addTearDown(container.dispose);

    final provider = proxyProfileDraftProvider(
      seed: ProxyProfileSeed(
        type: SingboxProxyProfileType.socks,
        name: 'Imported SOCKS',
        values: {
          'server': 'proxy.example',
          'server_port': '1080',
          'username': 'alice',
          'password': 'secret',
        },
      ),
    );

    final outcome = await container.read(provider.notifier).save();

    expect(outcome, isA<SaveSucceeded>());
    expect(runtimeRepository.validatedProfiles, hasLength(1));
    expect(profilesRepository.createdProfiles, hasLength(1));
    expect(profilesRepository.createdProfiles.single.name, 'Imported SOCKS');
    expect(
      profilesRepository.createdProfiles.single.configJson,
      contains('"server": "proxy.example"'),
    );
    expect(
      profilesRepository.createdSecrets.single,
      contains('"password": "secret"'),
    );
  });

  test('editing writes null secret to clear secure storage', () async {
    final credentialsRepository = _FakeCredentialsRepository(
      secrets: {'profile-1': '{"password":"old-secret"}'},
    );
    final profilesRepository = _FakeProfilesRepository(
      existingProfile: _profile(
        id: 'profile-1',
        name: 'SOCKS',
        type: SingboxProxyProfileType.socks,
        configJson:
            '{"type":"socks","server":"proxy.example","server_port":1080}',
      ),
    );
    final container = _container(
      profilesRepository: profilesRepository,
      credentialsRepository: credentialsRepository,
    );
    addTearDown(container.dispose);

    final provider = proxyProfileDraftProvider(profileId: 'profile-1');
    final subscription = container.listen(
      provider,
      (_, _) {},
      fireImmediately: true,
    );
    addTearDown(subscription.close);
    await _drainAsyncLoad();

    container.read(provider.notifier).setFieldValue('password', '');
    final outcome = await container.read(provider.notifier).save();

    expect(outcome, isA<SaveSucceeded>());
    expect(profilesRepository.updatedProfiles, hasLength(1));
    expect(credentialsRepository.writtenSecrets, {'profile-1': null});
  });
}

ProviderContainer _container({
  _FakeRuntimeRepository? runtimeRepository,
  _FakeProfilesRepository? profilesRepository,
  _FakeCredentialsRepository? credentialsRepository,
}) {
  return ProviderContainer(
    overrides: [
      singboxProxyRuntimeRepositoryProvider.overrideWith(
        () => runtimeRepository ?? _FakeRuntimeRepository(),
      ),
      singboxProxyProfilesRepositoryProvider.overrideWith(
        () => profilesRepository ?? _FakeProfilesRepository(),
      ),
      singboxProxyCredentialsRepositoryProvider.overrideWith(
        () => credentialsRepository ?? _FakeCredentialsRepository(),
      ),
    ],
  );
}

Future<void> _drainAsyncLoad() => pumpEventQueue();

ProxyProfile _profile({
  required String id,
  required String name,
  required SingboxProxyProfileType type,
  required String configJson,
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

class _FakeRuntimeRepository extends SingboxProxyRuntimeRepository {
  final validatedProfiles = <ProxyProfile>[];
  final validatedSecrets = <String?>[];

  @override
  Future<String?> validateProfileDraft(
    ProxyProfile profile, {
    String? secretJson,
  }) async {
    validatedProfiles.add(profile);
    validatedSecrets.add(secretJson);
    return null;
  }

  @override
  Future<SingboxProxyRuntimeState> build() async {
    return SingboxProxyRuntimeState(
      status: SingboxProxyRuntimeStatus.stopped,
      endpoints: const [],
    );
  }
}

class _FakeProfilesRepository extends SingboxProxyProfilesRepository {
  final ProxyProfile? existingProfile;
  final createdProfiles = <ProxyProfile>[];
  final createdSecrets = <String?>[];
  final updatedProfiles = <ProxyProfile>[];

  _FakeProfilesRepository({this.existingProfile});

  @override
  Future<ProxyProfile?> findProfile(String id) async => existingProfile;

  @override
  Future<ProxyProfile> createProfile({
    required String name,
    required SingboxProxyProfileType type,
    required String configJson,
    String? secretJson,
    String? dnsOverrideJson,
  }) async {
    final profile = _profile(
      id: 'created-profile',
      name: name,
      type: type,
      configJson: configJson,
    );
    createdProfiles.add(profile);
    createdSecrets.add(secretJson);
    return profile;
  }

  @override
  Future<void> updateProfile(ProxyProfile profile, {String? secretJson}) async {
    updatedProfiles.add(profile);
  }

  @override
  Stream<List<ProxyProfile>> build() {
    return Stream.value([if (existingProfile != null) existingProfile!]);
  }
}

class _FakeCredentialsRepository extends SingboxProxyCredentialsRepository {
  final Map<String, String?> secrets;
  final writtenSecrets = <String, String?>{};

  _FakeCredentialsRepository({this.secrets = const {}});

  @override
  Future<String?> readSecretJson(String profileId) async => secrets[profileId];

  @override
  Future<void> writeSecretJson(String profileId, String? secretJson) async {
    writtenSecrets[profileId] = secretJson;
  }

  @override
  void build() {}
}
