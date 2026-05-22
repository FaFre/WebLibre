import 'package:flutter_test/flutter_test.dart';
import 'package:weblibre/features/proxy/domain/services/dns_config_resolver.dart';
import 'package:weblibre/features/user/data/models/proxy_dns_override.dart';

void main() {
  test('mirrors browser DoH through running profiles automatically', () {
    final config = buildDnsConfig(
      overridesByProfileId: const {'profile-1': null},
      runningProfileIds: const {'profile-1'},
      browserDohUrl: 'https://dns.example/dns-query',
    );

    expect(config, isNotNull);
    expect(config!.finalServerTag, 'browser-doh');
    expect(config.servers, hasLength(2));
    expect(config.servers.first.detourTag, isNull);
    expect(config.servers.last.tag, 'browser-doh-profile-1');
    expect(config.servers.last.detourTag, 'out-singbox_profile-1');
    expect(config.servers.last.matchInbounds, ['in-singbox_profile-1']);
  });

  test('profile override replaces automatic browser DoH mirror', () {
    final config = buildDnsConfig(
      overridesByProfileId: {
        'profile-1': ProxyDnsOverride(remoteServerAddress: '10.0.0.53'),
      },
      runningProfileIds: const {'profile-1'},
      browserDohUrl: 'https://dns.example/dns-query',
    );

    expect(config, isNotNull);
    expect(config!.servers.map((s) => s.tag), [
      'browser-doh',
      'override-profile-1',
    ]);
    expect(config.servers.last.address, '10.0.0.53');
    expect(config.servers.last.detourTag, 'out-singbox_profile-1');
    expect(config.servers.last.matchInbounds, ['in-singbox_profile-1']);
  });

  test('returns null when there is no browser DoH or override', () {
    final config = buildDnsConfig(
      overridesByProfileId: const {'profile-1': null},
      runningProfileIds: const {'profile-1'},
      browserDohUrl: null,
    );

    expect(config, isNull);
  });

  test('auto domain strategy emits sing-box as-is strategy', () {
    expect(ProxyDnsDomainStrategy.auto.singboxValue, isEmpty);
  });
}
