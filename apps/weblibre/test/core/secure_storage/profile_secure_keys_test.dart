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
 */
import 'package:flutter_test/flutter_test.dart';
import 'package:weblibre/core/secure_storage/profile_secure_keys.dart';

const _a = '0199a0b1-1111-7111-8111-111111111111';
const _b = '0199a0b1-2222-7222-8222-222222222222';

void main() {
  group('profile-scoped secure keys', () {
    test('a scoped key round-trips its owner and its base', () {
      final key = profileScopedSecureKey('account_auth_data', _a);

      expect(profileOfSecureKey(key), _a);
      expect(baseOfSecureKey(key), 'account_auth_data');
    });

    test('two profiles never collide on the same base key', () {
      // The whole point: before this, one bare `account_auth_data` record meant
      // signing in on one profile signed in on all of them.
      expect(
        profileScopedSecureKey('account_auth_data', _a),
        isNot(profileScopedSecureKey('account_auth_data', _b)),
      );
    });

    test('case does not change ownership', () {
      expect(
        profileScopedSecureKey('k', _a.toUpperCase()),
        profileScopedSecureKey('k', _a),
      );
      expect(secureKeyBelongsTo(profileScopedSecureKey('k', _a), _a.toUpperCase()), isTrue);
    });

    test('an unqualified key has no owner', () {
      // Must read as "unknown", never as "mine": a legacy record silently
      // adopted by whichever profile asked first is the bug being fixed.
      expect(profileOfSecureKey('account_auth_data'), isNull);
      expect(secureKeyBelongsTo('account_auth_data', _a), isFalse);
      expect(baseOfSecureKey('account_auth_data'), 'account_auth_data');
    });

    test('a parked key belongs to no profile', () {
      const parked = 'account_auth_data$secureKeyUnattributedSuffix';

      expect(profileOfSecureKey(parked), isNull);
      expect(secureKeyBelongsTo(parked, _a), isFalse);
    });

    test('a separator that is not followed by a UUID is not ownership', () {
      // Otherwise any base key containing the separator would be mistaken for a
      // qualified one and mis-attributed.
      expect(profileOfSecureKey('weird${secureKeyProfileSeparator}notauuid'), isNull);
      expect(
        baseOfSecureKey('weird${secureKeyProfileSeparator}notauuid'),
        'weird${secureKeyProfileSeparator}notauuid',
      );
    });

    test('a base key that itself contains a UUID is not ownership', () {
      // Proxy secrets are keyed by a proxy-profile UUID, so this is the live
      // case, not a hypothetical: only the trailing separator decides.
      const key = 'singbox_proxy.secret.$_b';

      expect(profileOfSecureKey(key), isNull);
      expect(profileOfSecureKey(profileScopedSecureKey(key, _a)), _a);
      expect(baseOfSecureKey(profileScopedSecureKey(key, _a)), key);
    });

    test('a key qualified for another profile is not mine', () {
      expect(secureKeyBelongsTo(profileScopedSecureKey('k', _b), _a), isFalse);
    });
  });
}
