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
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weblibre/features/bangs/data/database/database.dart';
import 'package:weblibre/features/bangs/data/models/bang.dart';
import 'package:weblibre/features/bangs/data/models/bang_group.dart';
import 'package:weblibre/features/bangs/data/models/bang_key.dart';
import 'package:weblibre/features/bangs/domain/services/bang_resolution.dart';

Bang _bang(
  String trigger,
  String websiteName, {
  BangGroup group = BangGroup.general,
  Set<String>? additionalTriggers,
}) => Bang(
  trigger: trigger,
  websiteName: websiteName,
  domain: '$trigger.example',
  urlTemplate: 'https://$trigger.example/?q={{{s}}}',
  searxngApi: false,
  group: group,
  additionalTriggers: additionalTriggers,
);

void main() {
  late BangDatabase db;

  setUp(() {
    db = BangDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  Future<List<String>> query(String input) async {
    final results = await db.bangDao.queryBangs(input).get();
    return results.map((bang) => bang.trigger).toList();
  }

  group('trigger ranking', () {
    setUp(() async {
      for (final bang in [
        _bang('g', 'Google'),
        _bang('gh', 'GitHub'),
        _bang('gm', 'Gmail'),
        _bang('gist', 'GitHub Gist'),
        _bang('images', 'Google Images'),
        _bang('maps', 'Google Maps'),
      ]) {
        await db.bangDao.upsertBang(bang);
      }
    });

    test('puts the exactly matching trigger first', () async {
      expect((await query('g')).first, 'g');
    });

    test('treats an explicit bang the same as a bare trigger', () async {
      expect(await query('!g'), await query('g'));
    });

    test('resolves the bang out of a full query, in either spelling', () async {
      expect((await query('!g cats')).first, 'g');
      expect((await query('cats !g')).first, 'g');
    });

    test('ranks prefix matches above unrelated hits', () async {
      final results = await query('gi');
      // `gist` starts with the typed text; `images`/`Google Images` only
      // contain it somewhere.
      expect(results.first, 'gist');
    });

    test('ranks every trigger match above name-only matches', () async {
      // A single character used to skip the index entirely and run
      // `LIKE '%g%'`, whose bm25 is a constant — so "Google Maps" could sort
      // above the `g` bang. Name matches still qualify, they just come last.
      expect(await query('g'), [
        'g', // exact trigger
        'gh', 'gm', 'gist', // trigger prefix
        'images', 'maps', // matched on "Google" in the name only
      ]);
    });
  });

  group('frequency tiebreak', () {
    setUp(() async {
      for (final bang in [_bang('ex1', 'Example'), _bang('ex2', 'Example')]) {
        await db.bangDao.upsertBang(bang);
      }
    });

    test('orders the most-used bang first', () async {
      const hot = BangKey(group: BangGroup.general, trigger: 'ex2');
      for (var i = 0; i < 5; i++) {
        await db.bangDao.increaseBangFrequency(hot);
      }

      expect(await query('example'), ['ex2', 'ex1']);
    });

    test('sorts a never-used bang after a used one', () async {
      await db.bangDao.increaseBangFrequency(
        const BangKey(group: BangGroup.general, trigger: 'ex2'),
      );

      expect(await query('example'), ['ex2', 'ex1']);
    });
  });

  group('additional triggers', () {
    test('an exact alias match outranks a prefix match on the name', () async {
      await db.bangDao.upsertBang(_bang('youtube', 'YouTube'));
      await db.bangDao.upsertBang(
        _bang('ytm', 'YouTube Music', additionalTriggers: {'yt'}),
      );

      expect((await query('yt')).first, 'ytm');
    });
  });

  group('inline trigger resolution', () {
    Future<String?> resolve(String trigger) async {
      final candidates = await db.bangDao.getBangDataByTrigger(trigger).get();
      return pickBangByPrecedence(candidates, trigger)?.trigger;
    }

    test('resolves a trigger exactly', () async {
      await db.bangDao.upsertBang(_bang('g', 'Google'));
      await db.bangDao.upsertBang(_bang('gh', 'GitHub'));

      expect(await resolve('g'), 'g');
    });

    test('is case insensitive', () async {
      await db.bangDao.upsertBang(_bang('g', 'Google'));

      expect(await resolve('G'), 'g');
    });

    test('resolves an alias', () async {
      await db.bangDao.upsertBang(
        _bang('ytm', 'YouTube Music', additionalTriggers: {'yt'}),
      );

      expect(await resolve('yt'), 'ytm');
    });

    test('a real trigger beats another bang using it as an alias', () async {
      await db.bangDao.upsertBang(_bang('yt', 'YouTube'));
      await db.bangDao.upsertBang(
        _bang('ytm', 'YouTube Music', additionalTriggers: {'yt'}),
      );

      expect(await resolve('yt'), 'yt');
    });

    test('resolves nothing for an unknown trigger', () async {
      await db.bangDao.upsertBang(_bang('g', 'Google'));

      expect(await resolve('nope'), isNull);
    });

    test('never partially matches', () async {
      await db.bangDao.upsertBang(_bang('google', 'Google'));

      expect(await resolve('goo'), isNull);
    });
  });

  group('group precedence', () {
    Future<BangGroup?> resolveGroup(String trigger) async {
      final candidates = await db.bangDao.getBangDataByTrigger(trigger).get();
      return pickBangByPrecedence(candidates, trigger)?.group;
    }

    test('a user bang overrides a synced one on the same trigger', () async {
      await db.bangDao.upsertBang(_bang('g', 'Google'));
      await db.bangDao.upsertBang(
        _bang('g', 'My Search', group: BangGroup.user),
      );

      expect(await resolveGroup('g'), BangGroup.user);
    });

    test('it overrides even a much more frequently used bang', () async {
      await db.bangDao.upsertBang(_bang('g', 'Google'));
      await db.bangDao.upsertBang(
        _bang('g', 'My Search', group: BangGroup.user),
      );
      for (var i = 0; i < 50; i++) {
        await db.bangDao.increaseBangFrequency(
          const BangKey(group: BangGroup.general, trigger: 'g'),
        );
      }

      expect(await resolveGroup('g'), BangGroup.user);
    });

    test('a primary trigger still beats a higher-precedence alias', () async {
      // Precedence breaks ties between bangs that claim the word the same
      // way; it does not promote an alias over a bang's own name.
      await db.bangDao.upsertBang(_bang('yt', 'YouTube'));
      await db.bangDao.upsertBang(
        _bang(
          'mine',
          'Mine',
          group: BangGroup.user,
          additionalTriggers: {'yt'},
        ),
      );

      expect(await resolveGroup('yt'), BangGroup.general);
    });

    test('falls back to the group order without a user bang', () async {
      await db.bangDao.upsertBang(_bang('g', 'Google'));
      await db.bangDao.upsertBang(
        _bang('g', 'WebLibre', group: BangGroup.weblibre),
      );

      expect(await resolveGroup('g'), BangGroup.weblibre);
    });

    test('surfaces the user override first in the ranked list', () async {
      await db.bangDao.upsertBang(_bang('g', 'Google'));
      await db.bangDao.upsertBang(
        _bang('g', 'My Search', group: BangGroup.user),
      );

      final results = await db.bangDao.queryBangs('g').get();

      expect(results.first.group, BangGroup.user);
    });

    test(
      'surfaces a primary trigger above a higher-precedence alias',
      () async {
        await db.bangDao.upsertBang(_bang('yt', 'YouTube'));
        await db.bangDao.upsertBang(
          _bang(
            'mine',
            'Mine',
            group: BangGroup.user,
            additionalTriggers: {'yt'},
          ),
        );

        final results = await db.bangDao.queryBangs('yt').get();

        expect(results.first.trigger, 'yt');
        expect(results.first.group, BangGroup.general);
      },
    );
  });

  group('editing aliases', () {
    Future<String?> resolve(String trigger) async {
      final candidates = await db.bangDao.getBangDataByTrigger(trigger).get();
      return pickBangByPrecedence(candidates, trigger)?.trigger;
    }

    test('replacing the alias set retires the old aliases', () async {
      await db.bangDao.upsertBang(
        _bang('ytm', 'YouTube Music', additionalTriggers: {'yt'}),
      );
      expect(await resolve('yt'), 'ytm');

      await db.bangDao.upsertBang(
        _bang('ytm', 'YouTube Music', additionalTriggers: {'music'}),
      );

      expect(await resolve('music'), 'ytm');
      expect(await resolve('yt'), isNull);
    });

    test('clearing every alias leaves only the primary trigger', () async {
      await db.bangDao.upsertBang(
        _bang('ytm', 'YouTube Music', additionalTriggers: {'yt'}),
      );

      await db.bangDao.upsertBang(_bang('ytm', 'YouTube Music'));

      expect(await resolve('yt'), isNull);
      expect(await resolve('ytm'), 'ytm');
    });
  });

  group('result limit', () {
    test('caps a broad query at the search limit', () async {
      for (var i = 0; i < 150; i++) {
        await db.bangDao.upsertBang(_bang('bulk$i', 'Bulk $i'));
      }

      expect(await query('bulk'), hasLength(100));
    });
  });
}
