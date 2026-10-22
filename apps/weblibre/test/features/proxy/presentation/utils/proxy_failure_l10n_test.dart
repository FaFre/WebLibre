import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:flutter_singbox_proxy/flutter_singbox_proxy.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weblibre/features/proxy/domain/repositories/singbox_proxy_runtime.dart';
import 'package:weblibre/features/proxy/presentation/utils/proxy_failure_l10n.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';

void main() {
  final l10n = lookupAppLocalizations(const Locale('en'));
  String framed(String detail) => 'Failed: $detail';

  test('a start that failed on a profile names it', () {
    final error = SingboxStartException.fromPlatformException(
      PlatformException(
        code: SingboxStartException.code,
        message: 'lookup vpn.example: no such host',
        details: {'profileId': 'singbox:a', 'profileName': 'Home VPN'},
      ),
    );

    expect(
      describeProxyFailure(l10n, error!, framed: framed),
      'Home VPN could not start: lookup vpn.example: no such host',
    );
  });

  test('a start that failed on no profile is framed by the caller', () {
    const error = SingboxStartException(reason: 'runtime is not linked');

    expect(
      describeProxyFailure(l10n, error, framed: framed),
      'Failed: runtime is not linked',
    );
  });

  test('a platform error shows its message, not its toString', () {
    final error = PlatformException(code: 'Oops', message: 'went wrong');

    expect(
      describeProxyFailure(l10n, error, framed: framed),
      'Failed: went wrong',
    );
  });

  test('a platform error with no message does not show its code', () {
    final error = PlatformException(code: 'channel-error');

    expect(
      describeProxyFailure(l10n, error, framed: framed),
      'Failed: Unknown error',
    );
  });

  test('each refused profile gets a line', () {
    const error = SingboxProfilesRejected({
      'singbox:a': (name: 'A', message: 'bad key'),
      'singbox:b': (name: 'B', message: 'bad port'),
    });

    expect(
      describeProxyFailure(l10n, error, framed: framed),
      'A cannot be used: bad key\nB cannot be used: bad port',
    );
  });

  test('another platform error code is not taken for a start failure', () {
    expect(
      SingboxStartException.fromPlatformException(
        PlatformException(code: 'other', message: 'x'),
      ),
      isNull,
    );
  });
}
