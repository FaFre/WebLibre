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

import 'package:flutter_test/flutter_test.dart';
import 'package:weblibre/features/app_update/data/metadata/catalogue_codec.dart';
import 'package:weblibre/features/app_update/domain/entities/component_identity.dart';
import 'package:weblibre/features/app_update/domain/entities/installed_build_info.dart';
import 'package:weblibre/features/app_update/domain/entities/release_metadata.dart';
import 'package:weblibre/features/app_update/domain/entities/update_failure.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';

import '../fixtures.dart';

void main() {
  const codec = CatalogueCodec(packageId: packageId);

  ReleaseCatalogue decode(Map<String, Object?> json) =>
      codec.decode(utf8.encode(jsonEncode(json)));

  Matcher invalid([String? reason]) => throwsA(
    isA<CatalogueInvalid>().having(
      (e) => e.reason,
      'reason',
      reason == null ? anything : contains(reason),
    ),
  );

  test('parses releases, targets, components and advisories', () {
    final catalogue = decode(
      catalogueJson(
        revision: 57,
        releases: [releaseJson(sequence: 43), releaseJson(sequence: 44)],
        advisories: [
          {
            'id': 'WL-2026-003',
            'url': 'https://weblibre.eu/a',
            'severity': 'critical',
            'affected': {'introducedInSequence': 31, 'fixedInSequence': 44},
          },
        ],
      ),
    );

    expect(catalogue.revision, 57);
    expect(catalogue.releases.map((r) => r.logicalReleaseSequence), [44, 43]);
    final release = catalogue.releases.first;
    expect(release.targets, hasLength(7));
    expect(
      release.components[ComponentId.gecko],
      ComponentKnown('44.0', buildId: '20261124093000'),
    );
    expect(release.components[ComponentId.tor], ComponentUnknown());
    final play = release.targets.last;
    expect(play.distribution, Distribution.play);
    expect(play.artifact, isNull);
    expect(catalogue.advisories.single.severity, AdvisorySeverity.critical);
  });

  test('a schema other than 1 is invalid and says the client is too old', () {
    final json = catalogueJson()..['schemaVersion'] = 2;
    expect(
      () => decode(json),
      throwsA(
        isA<CatalogueInvalid>().having((e) => e.clientTooOld, 'old', isTrue),
      ),
    );
  });

  test('the reader reports a too-new schema as its own kind', () async {
    final key = await TestSigningKey.generate('wl-meta-2026a');
    final json = catalogueJson()..['schemaVersion'] = 2;
    await expectLater(
      readerFor([key]).read(await envelope(json, keys: [key])),
      throwsA(
        isA<UpdateFailure>().having(
          (f) => f.kind,
          'kind',
          UpdateFailureKind.metadataClientTooOld,
        ),
      ),
    );
  });

  test('a catalogue for another package is invalid', () {
    expect(
      () => decode(catalogueJson(scopePackage: 'eu.weblibre.gecko.alpha')),
      invalid('another package'),
    );
  });

  test('unknown fields are ignored', () {
    final json = catalogueJson()..['futureField'] = {'x': 1};
    expect(decode(json).revision, 1);
  });

  test('an unknown enum value makes only that target unselectable', () {
    final release = releaseJson(sequence: 43);
    final targets = release['targets']! as List;
    (targets.first as Map)['renderer'] = 'vulkan';
    (targets[1] as Map)['distribution'] = 'appgallery';
    final parsed = decode(catalogueJson(releases: [release])).releases.single;
    expect(parsed.targets.first.renderer, isNull);
    expect(parsed.targets[1].distribution, Distribution.unknown);
    expect(parsed.targets[2].renderer, Renderer.skia);
  });

  test('a target ID used by two releases is invalid', () {
    // Authorization finds a target by ID across the whole catalogue, so the
    // ID must name one target there, not only within its release.
    final older = releaseJson(sequence: 43);
    final newer = releaseJson(sequence: 44);
    ((newer['targets']! as List).first as Map)['id'] =
        ((older['targets']! as List).first as Map)['id'];
    expect(
      () => decode(catalogueJson(releases: [newer, older])),
      invalid('duplicate target id'),
    );
  });

  test('a structure error names the class and field, and rejects all', () {
    final release = releaseJson(sequence: 43);
    ((release['targets']! as List).first as Map)['versionCode'] = '431';
    expect(
      () => decode(catalogueJson(releases: [release])),
      invalid('UpdateTarget.versionCode'),
    );
    expect(
      () => decode(catalogueJson()..['scope'] = 'eu.weblibre.gecko'),
      invalid('scope is not an object'),
    );
  });

  test('malformed security and notes never reject a release', () {
    final release = releaseJson(sequence: 43)
      ..['security'] = 'critical'
      ..['releaseNotes'] = 7;
    final parsed = decode(catalogueJson(releases: [release])).releases.single;
    expect(parsed.security, SecurityClassification.unknown);
    expect(parsed.releaseNotes, ReleaseNotes.none);
  });

  test('rejects malformed artifacts', () {
    for (final mutate in <void Function(Map<String, Object?>)>[
      (a) => a['url'] = 'http://github.com/x.apk',
      (a) => a['sha256'] = 'ABC',
      (a) => a['byteLength'] = -1,
      (a) => a['byteLength'] = 0,
    ]) {
      final release = releaseJson(sequence: 43);
      mutate(
        ((release['targets']! as List).first as Map)['artifact']
            as Map<String, Object?>,
      );
      expect(() => decode(catalogueJson(releases: [release])), invalid());
    }
  });

  test('rejects timestamps that are not UTC and expiry before issue', () {
    expect(
      () => decode(catalogueJson()..['issuedAt'] = '2026-12-01T06:00:00+01:00'),
      invalid('UTC'),
    );
    expect(
      () => decode(
        catalogueJson(
          issuedAt: DateTime.utc(2026, 12, 2),
          expiresAt: DateTime.utc(2026, 12, 1),
        ),
      ),
      invalid('expiresAt'),
    );
  });

  group('release-note summaries', () {
    Map<String, Object?> withNotes(Object? summary, {String? url}) =>
        releaseJson(
          sequence: 43,
          notes: {
            'url':
                url ?? 'https://github.com/FaFre/WebLibre/releases/tag/v0.43.0',
            'summary': summary,
          },
        );

    test('kept per locale, with en required', () {
      final notes = decode(
        catalogueJson(
          releases: [
            withNotes({'en': 'New', 'de': 'Neu'}),
          ],
        ),
      ).releases.single.releaseNotes;
      expect(notes.summary, {'en': 'New', 'de': 'Neu'});
      expect(notes.summaryFor('de'), 'Neu');
      expect(notes.summaryFor('ru'), 'New');
      expect(notes.url, isNotNull);
    });

    test(
      'dropped when en is missing, too long or not text; the release stays',
      () {
        for (final summary in [
          {'de': 'Neu'},
          {'en': 'x' * (maxSummaryChars + 1)},
          {'en': 'ü' * 1600}, // 3200 bytes of UTF-8, under 2000 chars
          {'en': 'ok', 'de': 5},
          'just a string',
        ]) {
          final release = decode(
            catalogueJson(releases: [withNotes(summary)]),
          ).releases.single;
          expect(release.releaseNotes.summary, isEmpty, reason: '$summary');
          expect(release.targets, isNotEmpty);
        }
      },
    );

    test('languages the app does not ship are left out', () {
      final notes = decode(
        catalogueJson(
          releases: [
            withNotes({'en': 'New', 'fr': 'Nouveau'}),
          ],
        ),
      ).releases.single.releaseNotes;
      expect(notes.summary.keys, ['en']);
    });

    test('only the newest five releases carry summaries', () {
      final releases = [
        for (var s = 50; s > 43; s--)
          releaseJson(
            sequence: s,
            notes: {
              'summary': {'en': 'r$s'},
            },
          ),
      ];
      final parsed = decode(catalogueJson(releases: releases)).releases;
      expect(
        parsed.where((r) => r.releaseNotes.summary.isNotEmpty),
        hasLength(5),
      );
    });

    test('the newest five keep summaries when listed oldest first', () {
      final releases = [
        for (var s = 44; s <= 50; s++)
          releaseJson(
            sequence: s,
            notes: {
              'summary': {'en': 'r$s'},
            },
          ),
      ];
      final parsed = decode(catalogueJson(releases: releases)).releases;
      expect(
        [
          for (final r in parsed)
            if (r.releaseNotes.summary.isNotEmpty) r.logicalReleaseSequence,
        ],
        [50, 49, 48, 47, 46],
      );
    });

    test('Markdown and HTML stay literal text', () {
      const text = '- [link](https://evil.example) <b>bold</b> ![img](x)';
      final notes = decode(
        catalogueJson(
          releases: [
            withNotes({'en': text}),
          ],
        ),
      ).releases.single.releaseNotes;
      expect(notes.summary['en'], text);
    });

    test('a notes URL outside the compiled prefix is dropped', () {
      final notes = decode(
        catalogueJson(
          releases: [
            withNotes({'en': 'x'}, url: 'https://evil.example/notes'),
          ],
        ),
      ).releases.single.releaseNotes;
      expect(notes.url, isNull);
      expect(notes.summary, {'en': 'x'});
    });
  });

  test('the summary languages are the shipped UI languages', () {
    expect(
      AppLocalizations.supportedLocales.map((l) => l.languageCode).toSet(),
      shippedSummaryLanguages,
    );
  });
}
