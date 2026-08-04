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
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weblibre/extensions/uri.dart';
import 'package:weblibre/features/geckoview/features/top_sites/domain/entities/top_site_host.dart';
import 'package:weblibre/features/geckoview/features/top_sites/domain/repositories/top_site_repository.dart';

TopFrecentSiteInfo _site(String url, {String? title}) =>
    TopFrecentSiteInfo(url: url, title: title);

void main() {
  group('canonicalTopSiteHost', () {
    test('lowercases the host', () {
      expect(
        canonicalTopSiteHost(Uri.parse('https://EXAMPLE.com/x')),
        'example.com',
      );
    });

    test('strips a leading www.', () {
      expect(
        canonicalTopSiteHost(Uri.parse('https://www.example.com')),
        'example.com',
      );
    });

    test('strips only one leading www.', () {
      expect(
        canonicalTopSiteHost(Uri.parse('https://www.www.example.com')),
        'www.example.com',
      );
    });

    test('drops the port', () {
      expect(
        canonicalTopSiteHost(Uri.parse('https://example.com:8443/x')),
        'example.com',
      );
    });

    test('keeps subdomains distinct', () {
      expect(
        canonicalTopSiteHost(Uri.parse('https://app.discord.com')),
        isNot(canonicalTopSiteHost(Uri.parse('https://discord.com'))),
      );
    });

    test('handles IP literals', () {
      expect(
        canonicalTopSiteHost(Uri.parse('http://127.0.0.1:8080')),
        '127.0.0.1',
      );
    });

    test('returns empty for authority-less URLs so it never matches', () {
      expect(canonicalTopSiteHost(Uri.parse('about:blank')), isEmpty);
      expect(canonicalTopSiteHost(Uri.parse('data:text/plain,hi')), isEmpty);
    });
  });

  group('filterFrecentTopSites', () {
    test('maps frecent sites to history-sourced shortcuts', () {
      final items = filterFrecentTopSites(
        sites: [_site('https://example.com', title: 'Example')],
        limit: 5,
        excludeUrls: const {},
        excludeHosts: const {},
      );

      expect(items, hasLength(1));
      expect(items.single.title, 'Example');
      expect(items.single.url, Uri.parse('https://example.com'));
    });

    test('falls back to the host when a site has no title', () {
      final items = filterFrecentTopSites(
        sites: [_site('https://example.com/page')],
        limit: 5,
        excludeUrls: const {},
        excludeHosts: const {},
      );

      expect(items.single.title, 'example.com');
    });

    test('a hidden URL suppresses the matching history entry', () {
      // Regression test: the hidden list was only ever applied to the bundled
      // defaults, so removing a frecency-ranked shortcut looked like it worked
      // and then the site reappeared on the next refresh.
      final items = filterFrecentTopSites(
        sites: [_site('https://example.com'), _site('https://other.com')],
        limit: 5,
        excludeUrls: {Uri.parse('https://example.com').normalized.toString()},
        excludeHosts: const {},
      );

      expect(items.map((i) => i.url.host), ['other.com']);
    });

    test('a hidden host suppresses every URL on it (issue #267)', () {
      // The reported case: a PWA occupying 19 of 25 slots with distinct URLs.
      final items = filterFrecentTopSites(
        sites: [
          for (var i = 0; i < 19; i++) _site('https://discord.com/channels/$i'),
          _site('https://example.com'),
          _site('https://other.com'),
        ],
        limit: 25,
        excludeUrls: const {},
        excludeHosts: {'discord.com'},
      );

      expect(
        items.any((i) => i.url.host == 'discord.com'),
        isFalse,
        reason: 'hiding the domain must clear every one of its URLs',
      );
      expect(items.map((i) => i.url.host), ['example.com', 'other.com']);
    });

    test('host exclusion ignores www. and case', () {
      final items = filterFrecentTopSites(
        sites: [_site('https://WWW.Discord.com/app')],
        limit: 5,
        excludeUrls: const {},
        excludeHosts: {'discord.com'},
      );

      expect(items, isEmpty);
    });

    test('still fills up to the limit once exclusions are applied', () {
      final items = filterFrecentTopSites(
        sites: [
          for (var i = 0; i < 10; i++) _site('https://blocked.com/$i'),
          for (var i = 0; i < 5; i++) _site('https://site$i.com'),
        ],
        limit: 3,
        excludeUrls: const {},
        excludeHosts: {'blocked.com'},
      );

      expect(items, hasLength(3));
    });

    test('never returns more than the limit', () {
      final items = filterFrecentTopSites(
        sites: [for (var i = 0; i < 20; i++) _site('https://site$i.com')],
        limit: 4,
        excludeUrls: const {},
        excludeHosts: const {},
      );

      expect(items, hasLength(4));
    });

    test('a pinned site is unaffected by its host being hidden', () {
      // Regression guard for the fix to addPinnedSite: pinned entries are
      // returned ahead of these filters, so pinning one URL never needs to
      // lift a domain-wide hide — doing so would restore every other page on
      // that domain the user had just removed.
      final items = filterFrecentTopSites(
        sites: [_site('https://discord.com/a'), _site('https://discord.com/b')],
        limit: 25,
        excludeUrls: const {},
        excludeHosts: {'discord.com'},
      );

      expect(
        items,
        isEmpty,
        reason: 'the host stays hidden for everything that is not pinned',
      );
    });

    test('skips unparseable URLs instead of throwing', () {
      final items = filterFrecentTopSites(
        sites: [_site('::::not a url'), _site('https://example.com')],
        limit: 5,
        excludeUrls: const {},
        excludeHosts: const {},
      );

      expect(items.map((i) => i.url.host), ['example.com']);
    });
  });
}
