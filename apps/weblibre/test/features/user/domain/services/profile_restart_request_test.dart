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
import 'package:simple_intent_receiver/simple_intent_receiver.dart';
import 'package:weblibre/core/startup/atomic_json_file.dart';
import 'package:weblibre/core/startup/restart_authorization_store.dart';
import 'package:weblibre/core/startup/startup_paths.dart';
import 'package:weblibre/features/user/domain/services/profile_restart_request.dart';

Intent intentWith({String? action, Map<String, Object?> extra = const {}}) =>
    Intent(
      fromPackageName: 'eu.weblibre',
      action: action,
      data: null,
      categories: const [],
      mimeType: null,
      extra: extra,
    );

const _profileId = '0199a0b1-1111-7111-8111-111111111111';
const _otherProfileId = '0199a0b1-2222-7222-8222-222222222222';
const _extraKey = 'eu.weblibre.extra.RESTART_PROFILE_ID';
const _authorizationKey = 'eu.weblibre.extra.RESTART_AUTHORIZATION';

Intent requestFor(
  String profileId, {
  String? token,
  String action = restartIntoProfileAction,
}) => intentWith(
  action: action,
  extra: {_extraKey: profileId, if (token != null) _authorizationKey: token},
);

void main() {
  group('restart request claims', () {
    test('reads the id off the native mismatch-dialog intent', () {
      expect(restartProfileIdClaim(requestFor(_profileId)), _profileId);
    });

    test('canonicalises the id it will bind the next process to', () {
      expect(
        restartProfileIdClaim(requestFor(_profileId.toUpperCase())),
        _profileId,
      );
    });

    test('ignores every other intent', () {
      // Otherwise a share or a deep link could end the process. The action is
      // what addresses the request to this handler at all.
      expect(
        restartProfileIdClaim(
          requestFor(_profileId, action: 'android.intent.action.VIEW'),
        ),
        isNull,
      );
      expect(restartProfileIdClaim(intentWith(action: null)), isNull);
    });

    test('refuses an id that is not a UUID', () {
      // The id decides which profile the next process binds to, and that cannot
      // be revised once the runtime is up — so it is validated before it is
      // used, not after.
      for (final value in ['', 'not-a-uuid', '../../etc', 42]) {
        expect(
          restartProfileIdClaim(
            intentWith(
              action: restartIntoProfileAction,
              extra: {_extraKey: value},
            ),
          ),
          isNull,
          reason: 'accepted $value',
        );
      }
    });

    test('refuses a request with no id at all', () {
      expect(
        restartProfileIdClaim(intentWith(action: restartIntoProfileAction)),
        isNull,
      );
    });
  });

  group('restart request authorization', () {
    late Directory dir;
    late StartupPaths paths;
    late RestartAuthorizationStore store;

    /// Writes the record native writes just before it sends the intent, and
    /// returns the token that goes on the intent.
    Future<String> issue({
      String profileId = _profileId,
      Duration ttl = const Duration(minutes: 2),
      DateTime? at,
    }) async {
      const token = 'a-token-only-this-app-could-know';
      final createdAt = (at ?? DateTime.now()).toUtc();

      await AtomicJsonFile(paths.restartAuthorizationFile).write(
        RestartAuthorization(
          tokenHash: restartAuthorizationTokenHash(token),
          targetProfileId: profileId,
          createdAt: createdAt,
          expiresAt: createdAt.add(ttl),
        ).toJson(),
      );

      return token;
    }

    setUp(() async {
      dir = await Directory.systemTemp.createTemp('restart-authorization');
      paths = StartupPaths(dir);
      store = RestartAuthorizationStore(paths);
    });

    tearDown(() async {
      if (dir.existsSync()) await dir.delete(recursive: true);
    });

    test('honours a request this app authorized', () async {
      final token = await issue();

      expect(
        await consumeRestartRequest(
          requestFor(_profileId, token: token),
          store: store,
        ),
        _profileId,
      );
    });

    test('refuses a request no record authorizes', () async {
      // The whole finding: MainActivity is exported, so this intent is one any
      // app on the device can send. A correctly shaped UUID is not evidence of
      // anything, and honouring it would let another app close the browser and
      // reopen it on a profile of its choosing.
      expect(
        await consumeRestartRequest(
          requestFor(_profileId, token: 'guessed'),
          store: store,
        ),
        isNull,
      );
      expect(
        await consumeRestartRequest(requestFor(_profileId), store: store),
        isNull,
      );
    });

    test('refuses a token that does not match the record', () async {
      await issue();

      expect(
        await consumeRestartRequest(
          requestFor(_profileId, token: 'not-the-issued-token'),
          store: store,
        ),
        isNull,
      );
    });

    test('a forged request cannot spend the real one', () async {
      // The token is 256 unguessable bits with a two-minute life, so retiring the
      // record on every attempt buys nothing against brute force — and would let
      // any app on the device cancel the restart the user just asked for by
      // firing one intent with a made-up token.
      final token = await issue();

      expect(
        await consumeRestartRequest(
          requestFor(_profileId, token: 'wrong'),
          store: store,
        ),
        isNull,
      );
      expect(
        await consumeRestartRequest(
          requestFor(_profileId, token: token),
          store: store,
        ),
        _profileId,
      );
    });

    test('a redirected request still spends the token it matched', () async {
      final token = await issue();

      expect(
        await consumeRestartRequest(
          requestFor(_otherProfileId, token: token),
          store: store,
        ),
        isNull,
      );
      expect(await store.read(), isNull);
    });

    test('a used authorization cannot be replayed', () async {
      final token = await issue();
      final intent = requestFor(_profileId, token: token);

      expect(await consumeRestartRequest(intent, store: store), _profileId);
      expect(await consumeRestartRequest(intent, store: store), isNull);
    });

    test('refuses an authorization that has expired', () async {
      final token = await issue(
        at: DateTime.utc(2026, 8, 21, 10),
        ttl: const Duration(minutes: 2),
      );

      expect(
        await consumeRestartRequest(
          requestFor(_profileId, token: token),
          store: store,
          now: DateTime.utc(2026, 8, 21, 10, 5),
        ),
        isNull,
      );
    });

    test('refuses a request redirected to another profile', () async {
      // The record names the profile the user answered the dialog for. A token
      // that leaked onto an intent naming a different one must not select it.
      final token = await issue();

      expect(
        await consumeRestartRequest(
          requestFor(_otherProfileId, token: token),
          store: store,
        ),
        isNull,
      );
    });

    test('leaves the record alone for intents that are not requests', () async {
      final token = await issue();

      expect(
        await consumeRestartRequest(
          requestFor(
            _profileId,
            token: token,
            action: 'android.intent.action.VIEW',
          ),
          store: store,
        ),
        isNull,
      );
      // Otherwise any passing share would spend the authorization the user just
      // granted, and the restart they asked for would never happen.
      expect(await store.read(), isNotNull);
    });
  });
}
