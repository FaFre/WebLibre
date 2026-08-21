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
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:weblibre/core/startup/startup_paths.dart';
import 'package:weblibre/features/account/data/account_handoff_ledger.dart';
import 'package:weblibre/features/account/domain/services/account_callback_handler.dart';

const _profileA = '0199a0b1-1111-7111-8111-111111111111';
const _profileB = '0199a0b1-2222-7222-8222-222222222222';

void main() {
  late Directory root;
  late StartupPaths paths;
  late AccountHandoffLedger ledger;

  final at = DateTime.utc(2026, 8, 19, 10);

  setUp(() {
    root = Directory.systemTemp.createTempSync('weblibre_handoff');
    paths = StartupPaths(Directory(p.join(root.path, 'files')));
    ledger = AccountHandoffLedger(paths);
  });

  tearDown(() {
    if (root.existsSync()) root.deleteSync(recursive: true);
  });

  group('handoff ledger', () {
    test(
      'a recorded nonce resolves to the profile that started sign-in',
      () async {
        await ledger.record(
          stateNonce: 'nonce-1',
          profileId: _profileA,
          now: at,
        );

        final record = await ledger.consume(
          'nonce-1',
          ownedBy: _profileA,
          now: at,
        );

        expect(record?.profileId, _profileA);
      },
    );

    test('a nonce is good exactly once', () async {
      // A replayed callback must not be able to redeem a second time.
      await ledger.record(stateNonce: 'nonce-1', profileId: _profileA, now: at);

      expect(
        await ledger.consume('nonce-1', ownedBy: _profileA, now: at),
        isNotNull,
      );
      expect(
        await ledger.consume('nonce-1', ownedBy: _profileA, now: at),
        isNull,
      );
    });

    test('a nonce nobody issued resolves to nothing', () async {
      // The case that matters: any app on the device can fire a callback at us.
      expect(
        await ledger.consume('made-up', ownedBy: _profileA, now: at),
        isNull,
      );
    });

    test('an expired sign-in is refused', () async {
      await ledger.record(stateNonce: 'nonce-1', profileId: _profileA, now: at);

      final late = at.add(accountHandoffTtl);

      expect(
        await ledger.consume('nonce-1', ownedBy: _profileA, now: late),
        isNull,
      );
    });

    test('presenting an expired nonce does not keep it alive', () async {
      await ledger.record(stateNonce: 'nonce-1', profileId: _profileA, now: at);

      await ledger.consume(
        'nonce-1',
        ownedBy: _profileA,
        now: at.add(accountHandoffTtl),
      );

      expect(await ledger.read(), isEmpty);
    });

    test('the nonce itself is never written down', () async {
      // Only its hash. A leaked copy of this file — through a backup, say —
      // must not let anything forge a callback this app would accept.
      await ledger.record(stateNonce: 'nonce-1', profileId: _profileA, now: at);

      final contents = await paths.accountHandoffFile.readAsString();

      expect(contents.contains('nonce-1'), isFalse);
      expect(contents.contains(accountHandoffStateHash('nonce-1')), isTrue);
    });

    test('two profiles can have sign-ins in flight at once', () async {
      await ledger.record(stateNonce: 'a', profileId: _profileA, now: at);
      await ledger.record(stateNonce: 'b', profileId: _profileB, now: at);

      expect(
        (await ledger.consume('a', ownedBy: _profileA, now: at))?.profileId,
        _profileA,
      );
      expect(
        (await ledger.consume('b', ownedBy: _profileB, now: at))?.profileId,
        _profileB,
      );
    });

    test("consuming one profile's nonce leaves the other alone", () async {
      await ledger.record(stateNonce: 'a', profileId: _profileA, now: at);
      await ledger.record(stateNonce: 'b', profileId: _profileB, now: at);

      await ledger.consume('a', ownedBy: _profileA, now: at);

      expect(
        (await ledger.consume('b', ownedBy: _profileB, now: at))?.profileId,
        _profileB,
      );
    });

    test(
      'a callback reaching the wrong profile leaves the record intact',
      () async {
        // The failure this guards: profile A starts a sign-in, the callback is
        // delivered while the process serves B, and B spends the one-time record
        // rejecting it. A could then never finish signing in.
        await ledger.record(stateNonce: 'a', profileId: _profileA, now: at);

        expect(await ledger.consume('a', ownedBy: _profileB, now: at), isNull);

        expect(
          (await ledger.consume('a', ownedBy: _profileA, now: at))?.profileId,
          _profileA,
        );
      },
    );

    test('a wrong-profile callback still clears expired records', () async {
      // Holding another profile's live record does not entitle this one to keep
      // dead ones around.
      await ledger.record(stateNonce: 'stale', profileId: _profileB, now: at);
      await ledger.record(
        stateNonce: 'a',
        profileId: _profileA,
        now: at.add(accountHandoffTtl),
      );

      await ledger.consume(
        'a',
        ownedBy: _profileB,
        now: at.add(accountHandoffTtl),
      );

      final remaining = await ledger.read();
      expect(remaining.map((record) => record.profileId), [_profileA]);
    });

    test(
      'an expired record is dropped whichever profile presents it',
      () async {
        await ledger.record(stateNonce: 'a', profileId: _profileA, now: at);

        expect(
          await ledger.consume(
            'a',
            ownedBy: _profileB,
            now: at.add(accountHandoffTtl),
          ),
          isNull,
        );
        expect(await ledger.read(), isEmpty);
      },
    );

    test('the ledger stays bounded', () async {
      // Not a security boundary — a size one. The file is read on every callback
      // and a user who keeps tapping "sign in" should not be able to grow it.
      for (var index = 0; index < accountHandoffMaxRecords + 5; index++) {
        await ledger.record(
          stateNonce: 'nonce-$index',
          profileId: _profileA,
          now: at,
        );
      }

      expect((await ledger.read()).length, accountHandoffMaxRecords);
    });

    test('the newest sign-in survives eviction', () async {
      for (var index = 0; index < accountHandoffMaxRecords + 5; index++) {
        await ledger.record(
          stateNonce: 'nonce-$index',
          profileId: _profileA,
          now: at,
        );
      }

      const newest = 'nonce-${accountHandoffMaxRecords + 4}';
      expect(
        await ledger.consume(newest, ownedBy: _profileA, now: at),
        isNotNull,
      );
    });

    test('re-recording the same nonce does not duplicate it', () async {
      await ledger.record(stateNonce: 'a', profileId: _profileA, now: at);
      await ledger.record(stateNonce: 'a', profileId: _profileA, now: at);

      expect((await ledger.read()).length, 1);
    });

    test('pruning clears what can no longer be redeemed', () async {
      await ledger.record(stateNonce: 'a', profileId: _profileA, now: at);

      await ledger.prune(now: at.add(accountHandoffTtl));

      expect(await ledger.read(), isEmpty);
    });

    test('a corrupt ledger reads as empty rather than throwing', () async {
      await paths.accountHandoffFile.parent.create(recursive: true);
      await paths.accountHandoffFile.writeAsString('{ not json');

      expect(await ledger.read(), isEmpty);
      expect(await ledger.consume('a', ownedBy: _profileA, now: at), isNull);
    });

    test('a record naming no real profile is dropped', () async {
      await paths.accountHandoffFile.parent.create(recursive: true);
      await paths.accountHandoffFile.writeAsString(
        '{"version":1,"records":[{"stateHash":"x","profileId":"not-a-uuid",'
        '"mode":"handoff","createdAt":"2026-08-19T10:00:00.000Z",'
        '"expiresAt":"2026-08-19T10:20:00.000Z"}]}',
      );

      expect(await ledger.read(), isEmpty);
    });
  });

  group('callback parsing', () {
    test('reads the echoed nonce', () {
      final callback = tryParseAccountCallback(
        'weblibre://account/callback?code=abc&state=nonce-1',
      );

      expect(callback?.handoffCode, 'abc');
      expect(callback?.state, 'nonce-1');
    });

    test('a legacy callback has no nonce, not an empty one', () {
      // The handler branches on null, so an empty string must not look like a
      // nonce that simply failed to validate.
      expect(
        tryParseAccountCallback('weblibre://account/callback?code=abc')?.state,
        isNull,
      );
      expect(
        tryParseAccountCallback(
          'weblibre://account/callback?code=abc&state=',
        )?.state,
        isNull,
      );
    });

    test('a non-callback URI is still not a callback', () {
      expect(tryParseAccountCallback('https://example.org?code=abc'), isNull);
      expect(
        tryParseAccountCallback('weblibre://account/other?code=a'),
        isNull,
      );
    });
  });
}
