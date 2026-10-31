/*
 * Copyright (c) 2024-2026 Fabian Freund.
 *
 * This file is part of WebLibre
 * (see https://weblibre.eu).
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/features/proxy/domain/services/proxy_pref_baseline.dart';

const _applyPrefsChannel =
    'dev.flutter.pigeon.flutter_mozilla_components.GeckoPrefApi.applyPrefs';
const _resetPrefsChannel =
    'dev.flutter.pigeon.flutter_mozilla_components.GeckoPrefApi.resetPrefs';

const _codec = StandardMessageCodec();

/// One Pigeon call the baseline made, in the order it was made.
sealed class _PrefCall {}

class _Apply extends _PrefCall {
  _Apply(this.prefs);

  final Map<String, Object?> prefs;
}

class _Reset extends _PrefCall {
  _Reset(this.names);

  final List<String> names;
}

/// Stands in for the native `GeckoPrefApi`: records every call and keeps the
/// profile's user branch, so a test can seed it and read the result back.
class _FakeGeckoPrefs {
  _FakeGeckoPrefs([Map<String, Object?> userBranch = const {}])
    : userBranch = {...userBranch};

  final Map<String, Object?> userBranch;
  final calls = <_PrefCall>[];

  void install() {
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

    messenger.setMockMessageHandler(_applyPrefsChannel, (message) async {
      final args = _codec.decodeMessage(message)! as List<Object?>;
      final prefs = (args.single! as Map<Object?, Object?>)
          .cast<String, Object?>();
      calls.add(_Apply(prefs));
      userBranch.addAll(prefs);
      // The baseline ignores the read-back, so an empty map is enough.
      return _codec.encodeMessage([<String, Object?>{}]);
    });

    messenger.setMockMessageHandler(_resetPrefsChannel, (message) async {
      final args = _codec.decodeMessage(message)! as List<Object?>;
      final names = (args.single! as List<Object?>).cast<String>();
      calls.add(_Reset(names));
      names.forEach(userBranch.remove);
      return _codec.encodeMessage([null]);
    });
  }

  void uninstall() {
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMessageHandler(_applyPrefsChannel, null);
    messenger.setMockMessageHandler(_resetPrefsChannel, null);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _FakeGeckoPrefs prefs;
  late ProviderContainer container;

  void setUpPrefs([Map<String, Object?> userBranch = const {}]) {
    prefs = _FakeGeckoPrefs(userBranch)..install();
    addTearDown(prefs.uninstall);
    container = ProviderContainer();
    addTearDown(container.dispose);
  }

  ProxyPrefBaseline baseline() =>
      container.read(proxyPrefBaselineProvider.notifier);

  test('arming writes the dead SOCKS5 proxy with SOCKS5 remote DNS', () async {
    setUpPrefs();

    await baseline().setRequired(required: true);

    expect(prefs.calls, hasLength(1));
    final apply = prefs.calls.single as _Apply;
    expect(apply.prefs, {
      'network.proxy.allow_bypass': false,
      'network.proxy.failover_direct': false,
      'network.proxy.type': 1,
      'network.proxy.socks': '127.0.0.1',
      'network.proxy.socks_port': 1,
      'network.proxy.socks_version': 5,
      'network.proxy.socks5_remote_dns': true,
      'network.proxy.socks_remote_dns': true,
    });
  });

  test(
    'arming overrides a false socks5_remote_dns on the user branch',
    () async {
      setUpPrefs({'network.proxy.socks5_remote_dns': false});

      await baseline().setRequired(required: true);

      final apply = prefs.calls.single as _Apply;
      expect(apply.prefs['network.proxy.socks5_remote_dns'], isTrue);
      expect(prefs.userBranch['network.proxy.socks5_remote_dns'], isTrue);
    },
  );

  test(
    'disarming drops the proxy type first, then resets the endpoint',
    () async {
      setUpPrefs();
      await baseline().setRequired(required: true);
      prefs.calls.clear();

      await baseline().setRequired(required: false);

      expect(prefs.calls, hasLength(2));
      final apply = prefs.calls[0] as _Apply;
      expect(apply.prefs, {
        'network.proxy.allow_bypass': false,
        'network.proxy.failover_direct': false,
        'network.proxy.type': 0,
        'network.proxy.socks_remote_dns': true,
      });
      final reset = prefs.calls[1] as _Reset;
      expect(
        reset.names,
        unorderedEquals([
          'network.proxy.socks',
          'network.proxy.socks_port',
          'network.proxy.socks_version',
          'network.proxy.socks5_remote_dns',
        ]),
      );

      expect(prefs.userBranch, {
        'network.proxy.allow_bypass': false,
        'network.proxy.failover_direct': false,
        'network.proxy.type': 0,
        'network.proxy.socks_remote_dns': true,
      });
    },
  );

  test('repeating the current state writes nothing', () async {
    setUpPrefs();

    await baseline().setRequired(required: true);
    await baseline().setRequired(required: true);
    expect(prefs.calls, hasLength(1));

    await baseline().setRequired(required: false);
    await baseline().setRequired(required: false);
    expect(prefs.calls, hasLength(3));
  });

  test('a failed write is retried on the next call', () async {
    setUpPrefs();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler(
          _applyPrefsChannel,
          (message) async => _codec.encodeMessage(['error', 'failed', null]),
        );

    await expectLater(
      baseline().setRequired(required: true),
      throwsA(isA<PlatformException>()),
    );

    prefs.install();
    await baseline().setRequired(required: true);

    expect(prefs.calls, hasLength(1));
    expect(prefs.userBranch['network.proxy.type'], 1);
  });
}
