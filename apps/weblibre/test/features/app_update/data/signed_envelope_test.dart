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
import 'dart:convert';

import 'package:cryptography/cryptography.dart';
import 'package:cryptography/dart.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weblibre/features/app_update/data/metadata/signed_envelope.dart';

import '../fixtures.dart';

/// Counts every signature verification.
class _CountingEd25519 extends DartEd25519 {
  _CountingEd25519(this.onVerify);

  final void Function() onVerify;

  @override
  Future<bool> verify(List<int> message, {required Signature signature}) {
    onVerify();
    return super.verify(message, signature: signature);
  }
}

void main() {
  late TestSigningKey online;
  late TestSigningKey offline;
  late TestSigningKey stranger;

  setUpAll(() async {
    online = await TestSigningKey.generate('wl-meta-2026a');
    offline = await TestSigningKey.generate('wl-meta-2026b');
    stranger = await TestSigningKey.generate('wl-meta-2026a');
  });

  SignedEnvelopeVerifier verifier() =>
      SignedEnvelopeVerifier([online.trusted, offline.trusted]);

  Matcher rejects(String reason) => throwsA(
    isA<EnvelopeRejected>().having((e) => e.reason, 'reason', contains(reason)),
  );

  Map<String, Object?> decode(List<int> bytes) =>
      jsonDecode(utf8.decode(bytes)) as Map<String, Object?>;

  test('accepts a catalogue signed by the online key', () async {
    final bytes = await envelope(catalogueJson(), keys: [online]);
    final verified = await verifier().verify(bytes);
    expect(verified.keyIds, ['wl-meta-2026a']);
    final payload = jsonDecode(utf8.decode(verified.payload)) as Map;
    expect(payload['revision'], 1);
  });

  test(
    'accepts a catalogue signed by the offline key alone (G2 drill)',
    () async {
      final bytes = await envelope(catalogueJson(), keys: [offline]);
      expect((await verifier().verify(bytes)).keyIds, ['wl-meta-2026b']);
    },
  );

  test('accepts both during a rotation', () async {
    final bytes = await envelope(catalogueJson(), keys: [online, offline]);
    expect((await verifier().verify(bytes)).keyIds, hasLength(2));
  });

  test('rejects an envelope over 256 KiB', () async {
    final big = List<int>.filled(maxEnvelopeBytes + 1, 0x20);
    await expectLater(verifier().verify(big), rejects('too large'));
  });

  test('rejects an envelope that is not JSON or not UTF-8', () async {
    await expectLater(
      verifier().verify(utf8.encode('{"payloadType": ')),
      rejects('malformed'),
    );
    await expectLater(
      verifier().verify([0x7B, 0xFF, 0x7D]),
      rejects('malformed'),
    );
  });

  test('rejects an unknown payloadType', () async {
    final bytes = await envelope(
      catalogueJson(),
      keys: [online],
      payloadType: 'application/json',
    );
    await expectLater(verifier().verify(bytes), rejects('payloadType'));
  });

  test('rejects zero signatures', () async {
    final bytes = await envelope(catalogueJson(), keys: []);
    await expectLater(verifier().verify(bytes), rejects('no signatures'));
  });

  test('rejects signatures only from unknown key IDs', () async {
    final unknown = await TestSigningKey.generate('wl-meta-1999a');
    final bytes = await envelope(catalogueJson(), keys: [unknown]);
    // Unknown is not retired: a damaged key ID must read as damage.
    await expectLater(
      verifier().verify(bytes),
      throwsA(
        isA<EnvelopeRejected>()
            .having((e) => e.reason, 'reason', contains('trusted key'))
            .having((e) => e.retiredSigner, 'retiredSigner', isFalse),
      ),
    );
  });

  group('retired key IDs', () {
    late TestSigningKey retired;
    late TestSigningKey unknown;

    setUpAll(() async {
      retired = await TestSigningKey.generate('wl-meta-2025a');
      unknown = await TestSigningKey.generate('wl-meta-1999a');
    });

    SignedEnvelopeVerifier withRetired() => SignedEnvelopeVerifier(
      [online.trusted],
      retiredKeyIds: {'wl-meta-2025a'},
    );

    test('signed only by retired keys: rejected, marked retired', () async {
      final bytes = await envelope(catalogueJson(), keys: [retired]);
      await expectLater(
        withRetired().verify(bytes),
        throwsA(
          isA<EnvelopeRejected>().having(
            (e) => e.retiredSigner,
            'retiredSigner',
            isTrue,
          ),
        ),
      );
    });

    test('a retired key beside an unknown one is not retired', () async {
      final bytes = await envelope(catalogueJson(), keys: [retired, unknown]);
      await expectLater(
        withRetired().verify(bytes),
        throwsA(
          isA<EnvelopeRejected>().having(
            (e) => e.retiredSigner,
            'retiredSigner',
            isFalse,
          ),
        ),
      );
    });

    test('a retired key beside a trusted one still verifies', () async {
      final bytes = await envelope(catalogueJson(), keys: [retired, online]);
      final verified = await withRetired().verify(bytes);
      expect(verified.keyIds, [online.keyId]);
    });
  });

  test(
    'rejects a signature by a different key under a trusted key ID',
    () async {
      final bytes = await envelope(catalogueJson(), keys: [stranger]);
      // A known key that fails to verify is damage, never a retired key.
      await expectLater(
        verifier().verify(bytes),
        throwsA(
          isA<EnvelopeRejected>()
              .having((e) => e.reason, 'reason', contains('trusted key'))
              .having((e) => e.retiredSigner, 'retiredSigner', isFalse),
        ),
      );
    },
  );

  test(
    'rejects more signature entries than the cap, before verifying',
    () async {
      final json = decode(await envelope(catalogueJson(), keys: [online]));
      final signature = (json['signatures']! as List).first;
      json['signatures'] = List.filled(1500, signature);
      await expectLater(
        verifier().verify(utf8.encode(jsonEncode(json))),
        rejects('too many signatures'),
      );
    },
  );

  test('a repeated signature is verified once per key', () async {
    var verifications = 0;
    final counting = SignedEnvelopeVerifier([
      online.trusted,
      offline.trusted,
    ], algorithm: _CountingEd25519(() => verifications++));
    final json = decode(await envelope(catalogueJson(), keys: [online]));
    final signature = (json['signatures']! as List).first;
    json['signatures'] = List.filled(maxEnvelopeSignatures, signature);
    final verified = await counting.verify(utf8.encode(jsonEncode(json)));
    expect(verified.keyIds, ['wl-meta-2026a']);
    expect(verifications, 1);
  });

  test('rejects a signature of the wrong length', () async {
    final json = decode(await envelope(catalogueJson(), keys: [online]));
    ((json['signatures']! as List).first as Map)['sig'] = base64.encode(
      List.filled(63, 1),
    );
    await expectLater(
      verifier().verify(utf8.encode(jsonEncode(json))),
      rejects('wrong length'),
    );
  });

  test('rejects non-canonical base64', () async {
    final json = decode(await envelope(catalogueJson(), keys: [online]));
    final payload = json['payload']! as String;
    // Same bytes without padding.
    json['payload'] = payload.replaceAll('=', '');
    if (json['payload'] == payload) json['payload'] = '$payload\n';
    await expectLater(
      verifier().verify(utf8.encode(jsonEncode(json))),
      throwsA(isA<EnvelopeRejected>()),
    );
  });

  test('rejects a payload changed after signing', () async {
    final json = decode(await envelope(catalogueJson(), keys: [online]));
    json['payload'] = base64.encode(
      utf8.encode(jsonEncode(catalogueJson(revision: 99))),
    );
    await expectLater(
      verifier().verify(utf8.encode(jsonEncode(json))),
      rejects('trusted key'),
    );
  });
}
