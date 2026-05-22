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
import 'package:path/path.dart' as p;
import 'package:weblibre/features/web_search/domain/services/capture_server.dart';

void main() {
  late Directory tempDir;
  late CaptureServer server;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('capture_server_test_');
    server = CaptureServer(storageDir: tempDir);
  });

  tearDown(() async {
    await server.stop();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  Future<File> writeCapture(String captureId, String html) async {
    final file = File(p.join(tempDir.path, '$captureId.html'));
    await file.writeAsString(html);
    return file;
  }

  group('captures route', () {
    test('serves stored HTML with CSP + nosniff', () async {
      await writeCapture('abc123', '<html>hi</html>');
      final url = await server.publish('abc123');

      final res = await _get(url);
      expect(res.statusCode, 200);
      expect(res.body, contains('hi'));
      expect(
        res.headers['content-security-policy'],
        contains("script-src 'none'"),
      );
      expect(res.headers['x-content-type-options'], 'nosniff');
      expect(res.headers['cache-control'], 'no-store');
    });

    test('rejects wrong token with 403', () async {
      await writeCapture('abc123', 'x');
      await server.publish('abc123');
      final base = await server.publish('abc123');
      final bad = base.replace(queryParameters: {'t': 'invalid'});
      final res = await _get(bad);
      expect(res.statusCode, 403);
    });

    test('rejects unknown capture with 403', () async {
      final port = await server.ensureStarted();
      final url = Uri.parse(
        'http://127.0.0.1:$port/captures/unknown.html?t=irrelevant',
      );
      final res = await _get(url);
      expect(res.statusCode, 403);
    });
  });

  group('loader route', () {
    test('pending capture returns long-poll shell + locked CSP', () async {
      final url = await server.loaderUrl(tabId: 'tab-1', captureId: 'pending1');
      final res = await _get(url);
      expect(res.statusCode, 200);
      // New design: no meta-refresh; the shell ships an inline long-poll
      // script that hits /loader/wait. Sanity-check the script is present
      // and the pending UI starts in the visible state.
      expect(res.body, contains('Capturing'));
      expect(res.body, contains('/loader/wait?tab='));
      expect(res.body, contains('id="pending"'));
      expect(res.body, contains('window.__CAPTURE_ID__="pending1"'));
      // Loader CSP must allow inline script (for the long-poll JS) but
      // forbid remote subresources — this is the safety boundary that
      // makes the inline script acceptable.
      expect(
        res.headers['content-security-policy'],
        contains("script-src 'unsafe-inline'"),
      );
      expect(
        res.headers['content-security-policy'],
        contains("default-src 'none'"),
      );
    });

    test('ready capture exposes captureUrl via /loader/wait', () async {
      await writeCapture('ready1', '<html>final</html>');
      await server.publish('ready1');
      final port = await server.ensureStarted();
      // The transition to ready is observed via the long-poll endpoint, not
      // a Refresh header on /loader. Hit /loader/wait directly and assert
      // it returns the loopback capture URL.
      final waitUrl = Uri.parse(
        'http://127.0.0.1:$port/loader/wait?tab=tab-1&capture=ready1',
      );
      final res = await _get(waitUrl);
      expect(res.statusCode, 200);
      expect(res.headers['content-type'], startsWith('application/json'));
      final decoded = jsonDecode(res.body) as Map<String, dynamic>;
      expect(decoded['status'], 'ready');
      expect(decoded['url'], contains('/captures/ready1.html'));
      expect(decoded['url'], contains('t='));
    });

    test('err=1 starts the loader in the error pane with a retry button',
        () async {
      final url = await server.loaderUrl(
        tabId: 'tab-9',
        captureId: 'failed9',
        error: true,
      );
      final res = await _get(url);
      expect(res.statusCode, 200);
      // Retry is now a JS-driven button, not an HTML form — assert the
      // shell starts in error mode (error pane visible, pending hidden)
      // and that the button + JS retry endpoint string are present.
      expect(res.body, contains('id="retry"'));
      expect(res.body, contains('id="error" class="error"'));
      expect(res.body, contains('id="pending" class="hidden"'));
      expect(res.body, contains('/loader/retry?tab='));
    });

    test('loader with invalid capture id returns 404', () async {
      final port = await server.ensureStarted();
      final url = Uri.parse(
        'http://127.0.0.1:$port/loader?tab=t&capture=not%2Fclean',
      );
      final res = await _get(url);
      expect(res.statusCode, 404);
    });
  });

  group('/loader/wait', () {
    test('failed capture returns status=failed immediately', () async {
      await server.publish('cap-failed');
      server.markFailed('cap-failed');
      final port = await server.ensureStarted();
      final res = await _get(
        Uri.parse(
          'http://127.0.0.1:$port/loader/wait?tab=t&capture=cap-failed',
        ),
      );
      expect(res.statusCode, 200);
      final decoded = jsonDecode(res.body) as Map<String, dynamic>;
      expect(decoded['status'], 'failed');
      expect(decoded.containsKey('url'), isFalse);
    });

    test('publish() wakes an in-flight long-poll', () async {
      final port = await server.ensureStarted();
      // Start the long-poll while nothing has been published yet — it
      // should block on the per-id completer, not busy-poll the filesystem.
      final pollFuture = _get(
        Uri.parse(
          'http://127.0.0.1:$port/loader/wait?tab=t&capture=signaled',
        ),
      );
      // Race-free: publish only after the request hit the handler. A short
      // microtask flush gives the handler time to register its waiter.
      await Future<void>.delayed(const Duration(milliseconds: 100));
      await writeCapture('signaled', '<html/>');
      await server.publish('signaled');

      final res = await pollFuture.timeout(const Duration(seconds: 2));
      final decoded = jsonDecode(res.body) as Map<String, dynamic>;
      expect(decoded['status'], 'ready');
      expect(decoded['url'], contains('/captures/signaled.html'));
    });
  });

  group('retry route', () {
    test('emits a RetryRequest on retryRequests stream and returns 204',
        () async {
      final port = await server.ensureStarted();
      final retryFuture = server.retryRequests.first;

      final res = await _post(
        Uri.parse(
          'http://127.0.0.1:$port/loader/retry?tab=tab-42&capture=cap42',
        ),
      );
      // 204 No Content — the JS loader re-polls; a body would be wasted.
      expect(res.statusCode, 204);

      final req = await retryFuture.timeout(const Duration(seconds: 2));
      expect(req.tabId, 'tab-42');
      expect(req.captureId, 'cap42');
    });

    test('retry rejects GET with 405', () async {
      final port = await server.ensureStarted();
      final res = await _get(
        Uri.parse('http://127.0.0.1:$port/loader/retry?tab=x&capture=y'),
      );
      expect(res.statusCode, 405);
    });
  });

  group('isReady', () {
    test('false until publish + file exist', () async {
      expect(server.isReady('x'), isFalse);
      await server.publish('x');
      expect(server.isReady('x'), isFalse);
      await writeCapture('x', '<html/>');
      expect(server.isReady('x'), isTrue);
    });
  });
}

class _Response {
  final int statusCode;
  final Map<String, String> headers;
  final String body;
  _Response(this.statusCode, this.headers, this.body);
}

Future<_Response> _get(Uri url) async {
  final client = HttpClient();
  try {
    final req = await client.getUrl(url);
    req.followRedirects = false;
    final res = await req.close();
    return await _readResponse(res);
  } finally {
    client.close(force: true);
  }
}

Future<_Response> _post(Uri url) async {
  final client = HttpClient();
  try {
    final req = await client.postUrl(url);
    req.followRedirects = false;
    final res = await req.close();
    return await _readResponse(res);
  } finally {
    client.close(force: true);
  }
}

Future<_Response> _readResponse(HttpClientResponse response) async {
  final bytes = await response.fold<List<int>>(<int>[], (a, c) => a..addAll(c));
  final headers = <String, String>{};
  response.headers.forEach((name, values) {
    headers[name.toLowerCase()] = values.join(',');
  });
  return _Response(response.statusCode, headers, utf8.decode(bytes));
}
