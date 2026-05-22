import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_singbox_proxy/flutter_singbox_proxy.dart';

void main() {
  test('profile model keeps generic sing-box config boundary', () {
    final profile = SingboxProxyProfile(
      id: 'wg-home',
      name: 'WireGuard Home',
      type: SingboxProxyProfileType.wireguard,
      configJson: '{"server":"example.test"}',
      secretJson: '{"private_key":"secret"}',
    );

    expect(profile.id, 'wg-home');
    expect(profile.type, SingboxProxyProfileType.wireguard);
    expect(profile.secretJson, contains('private_key'));
  });

  test('runtime options default to blocking unmatched traffic', () {
    final options = SingboxProxyRuntimeOptions();

    expect(options.preferredBasePort, isNull);
    expect(options.blockUnmatchedTraffic, isTrue);
  });
}
