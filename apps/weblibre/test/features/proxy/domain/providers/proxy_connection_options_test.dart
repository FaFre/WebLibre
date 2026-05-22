import 'package:flutter_singbox_proxy/flutter_singbox_proxy.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';
import 'package:weblibre/features/proxy/data/proxy_connection.dart';
import 'package:weblibre/features/proxy/domain/providers/proxy_connection_options.dart';
import 'package:weblibre/features/proxy/domain/repositories/singbox_proxy_profiles.dart';
import 'package:weblibre/features/user/data/database/definitions.drift.dart'
    show ProxyProfile;

void main() {
  group('proxyConnectionOptionsProvider', () {
    test('returns Tor and saved sing-box profiles', () async {
      final createdAt = DateTime(2026);
      final container = ProviderContainer(
        overrides: [
          singboxProxyProfilesRepositoryProvider.overrideWith(
            () => _FakeProfilesRepository([
              ProxyProfile(
                id: 'profile-1',
                name: 'Mullvad',
                type: SingboxProxyProfileType.customOutbound,
                configJson: '{"type":"socks"}',
                createdAt: createdAt,
                updatedAt: createdAt,
              ),
            ]),
          ),
        ],
      );
      addTearDown(container.dispose);

      container.listen(
        singboxProxyProfilesRepositoryProvider,
        (_, _) {},
        fireImmediately: true,
      );
      await Future<void>.delayed(Duration.zero);
      final options = container.read(proxyConnectionOptionsProvider);

      expect(options.map((option) => option.id), [
        const TorProxyConnectionId(),
        const SingboxProxyConnectionId('profile-1'),
      ]);
      expect(options.map((option) => option.title), ['Tor', 'Mullvad']);
    });

    test('labels unknown proxy ids explicitly', () {
      expect(
        proxyConnectionTitle(
          const [],
          const SingboxProxyConnectionId('missing'),
        ),
        'Unknown proxy',
      );
    });
  });
}

class _FakeProfilesRepository extends SingboxProxyProfilesRepository {
  final List<ProxyProfile> profiles;

  _FakeProfilesRepository(this.profiles);

  @override
  Stream<List<ProxyProfile>> build() => Stream.value(profiles);
}
