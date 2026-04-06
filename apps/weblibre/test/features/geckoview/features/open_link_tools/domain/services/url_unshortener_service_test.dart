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
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:riverpod/riverpod.dart';
import 'package:weblibre/features/geckoview/features/open_link_tools/domain/services/url_unshortener_service.dart';

void main() {
  late ProviderContainer container;
  late UrlUnshortenerService service;

  setUp(() {
    container = ProviderContainer();
    service = container.read(urlUnshortenerServiceProvider.notifier);
  });

  tearDown(() {
    container.dispose();
  });

  group('warning list asset compatibility', () {
    test('parses current MISP url-shortener list format', () {
      final rawJson = File(
        'assets/preferences/url-shortener-list.json',
      ).readAsStringSync();

      final decoded = jsonDecode(rawJson) as Map<String, dynamic>;
      expect(decoded['type'], 'hostname');
      expect(decoded['matching_attributes'], isA<List<dynamic>>());
      expect(decoded['list'], isA<List<dynamic>>());

      final hosts = service.parseSupportedShortenerHosts(rawJson);
      expect(hosts.length, greaterThan(200));
      expect(hosts, contains('bit.ly'));
      expect(service.isSupportedShortenerHost('www.bit.ly', hosts), isTrue);
      expect(
        service.isSupportedShortenerUrl('https://example.com', hosts),
        isFalse,
      );
    });
  });

  group('supported shortener host checks', () {
    test('parses list hosts from warning list json', () {
      final hosts = service.parseSupportedShortenerHosts(
        jsonEncode({
          'list': ['bit.ly', 't.co', 'TinyURL.com', '*.short.cm'],
        }),
      );

      expect(hosts, containsAll({'bit.ly', 't.co', 'tinyurl.com', 'short.cm'}));
    });

    test('normalizes URL-like entries to hostnames', () {
      final hosts = service.parseSupportedShortenerHosts(
        jsonEncode({
          'list': ['https://bit.ly/abc', 'tinyurl.com/path?a=1', 't.co/#frag'],
        }),
      );

      expect(hosts, containsAll({'bit.ly', 'tinyurl.com', 't.co'}));
    });

    test('matches exact and subdomain hosts', () {
      const supportedHosts = {'bit.ly', 't.co'};

      expect(
        service.isSupportedShortenerUrl('https://bit.ly/abc', supportedHosts),
        isTrue,
      );
      expect(
        service.isSupportedShortenerUrl('https://www.t.co/abc', supportedHosts),
        isTrue,
      );
      expect(
        service.isSupportedShortenerUrl(
          'https://example.com/abc',
          supportedHosts,
        ),
        isFalse,
      );
    });

    test('matches urls without a scheme', () {
      const supportedHosts = {'tinyurl.com'};

      expect(
        service.isSupportedShortenerUrl('tinyurl.com/abc', supportedHosts),
        isTrue,
      );
      expect(
        service.isSupportedShortenerUrl('notinyurl.com/abc', supportedHosts),
        isFalse,
      );
    });
  });

  group('unshortenUrl', () {
    group('unauthenticated requests', () {
      test('resolves shortened URL successfully', () async {
        final client = MockClient((request) async {
          expect(request.url.host, 'unshorten.me');
          expect(request.url.pathSegments, contains('json'));
          expect(request.headers, isNot(contains('Authorization')));

          return http.Response(
            jsonEncode({
              'success': true,
              'resolved_url': 'https://example.com/full-article',
              'remaining_calls': 8,
              'usage_count': 10,
            }),
            200,
          );
        });

        final result = await service.unshortenUrl(
          'https://bit.ly/abc123',
          client: client,
        );

        expect(result.success, isTrue);
        expect(result.finalUrl, 'https://example.com/full-article');
        expect(result.remainingCalls, 8);
        expect(result.usageCount, 10);
        expect(result.error, isNull);
      });

      test('encodes URL in request path', () async {
        late Uri capturedUri;
        final client = MockClient((request) async {
          capturedUri = request.url;
          return http.Response(
            jsonEncode({
              'success': true,
              'resolved_url': 'https://example.com',
            }),
            200,
          );
        });

        await service.unshortenUrl(
          'https://bit.ly/test?a=1&b=2',
          client: client,
        );

        expect(
          capturedUri.toString(),
          contains(Uri.encodeComponent('https://bit.ly/test?a=1&b=2')),
        );
      });

      test('returns error on API failure', () async {
        final client = MockClient((request) async {
          return http.Response(
            jsonEncode({'success': false, 'error': 'Could not resolve URL'}),
            200,
          );
        });

        final result = await service.unshortenUrl(
          'https://invalid-short.url/x',
          client: client,
        );

        expect(result.success, isFalse);
        expect(result.error, 'Could not resolve URL');
        expect(result.finalUrl, isNull);
      });

      test('returns error on HTTP error status', () async {
        final client = MockClient((request) async {
          return http.Response('Server Error', 500);
        });

        final result = await service.unshortenUrl(
          'https://bit.ly/abc',
          client: client,
        );

        expect(result.success, isFalse);
        expect(result.error, 'HTTP 500');
      });

      test('returns error on rate limit', () async {
        final client = MockClient((request) async {
          return http.Response('Too Many Requests', 429);
        });

        final result = await service.unshortenUrl(
          'https://bit.ly/abc',
          client: client,
        );

        expect(result.success, isFalse);
        expect(result.error, 'HTTP 429');
      });

      test('handles missing success field', () async {
        final client = MockClient((request) async {
          return http.Response(
            jsonEncode({'resolved_url': 'https://example.com'}),
            200,
          );
        });

        final result = await service.unshortenUrl(
          'https://bit.ly/abc',
          client: client,
        );

        // success defaults to false when missing
        expect(result.success, isFalse);
      });

      test('handles missing error field on failure', () async {
        final client = MockClient((request) async {
          return http.Response(jsonEncode({'success': false}), 200);
        });

        final result = await service.unshortenUrl(
          'https://bit.ly/abc',
          client: client,
        );

        expect(result.success, isFalse);
        expect(result.error, 'Unknown error');
      });
    });

    group('authenticated requests', () {
      test('sends token in Authorization header', () async {
        late Map<String, String> capturedHeaders;
        final client = MockClient((request) async {
          capturedHeaders = request.headers;
          return http.Response(
            jsonEncode({
              'unshortened_url': 'https://example.com/page',
              'remaining_calls': 95,
              'usage_count': 100,
            }),
            200,
          );
        });

        await service.unshortenUrl(
          'https://bit.ly/abc',
          token: 'my-api-token',
          client: client,
        );

        expect(capturedHeaders['Authorization'], 'Token my-api-token');
      });

      test('uses v2 API endpoint with token', () async {
        late Uri capturedUri;
        final client = MockClient((request) async {
          capturedUri = request.url;
          return http.Response(
            jsonEncode({'unshortened_url': 'https://example.com'}),
            200,
          );
        });

        await service.unshortenUrl(
          'https://bit.ly/abc',
          token: 'token123',
          client: client,
        );

        expect(capturedUri.pathSegments, contains('v2'));
        expect(capturedUri.pathSegments, contains('unshorten'));
        expect(capturedUri.queryParameters['url'], isNotNull);
      });

      test('resolves URL with token successfully', () async {
        final client = MockClient((request) async {
          return http.Response(
            jsonEncode({
              'unshortened_url': 'https://example.com/target',
              'remaining_calls': 50,
              'usage_count': 100,
            }),
            200,
          );
        });

        final result = await service.unshortenUrl(
          'https://t.co/abc',
          token: 'valid-token',
          client: client,
        );

        expect(result.success, isTrue);
        expect(result.finalUrl, 'https://example.com/target');
        expect(result.remainingCalls, 50);
        expect(result.usageCount, 100);
      });

      test('returns error from authenticated API', () async {
        final client = MockClient((request) async {
          return http.Response(jsonEncode({'error': 'Invalid token'}), 200);
        });

        final result = await service.unshortenUrl(
          'https://bit.ly/abc',
          token: 'bad-token',
          client: client,
        );

        expect(result.success, isFalse);
        expect(result.error, 'Invalid token');
      });

      test('handles empty error field as success', () async {
        final client = MockClient((request) async {
          return http.Response(
            jsonEncode({'error': '', 'unshortened_url': 'https://example.com'}),
            200,
          );
        });

        final result = await service.unshortenUrl(
          'https://bit.ly/abc',
          token: 'token',
          client: client,
        );

        expect(result.success, isTrue);
        expect(result.finalUrl, 'https://example.com');
      });
    });
  });
}
