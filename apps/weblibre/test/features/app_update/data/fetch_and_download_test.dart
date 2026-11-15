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
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:path/path.dart' as p;
import 'package:weblibre/features/app_update/data/github/allowlisted_fetcher.dart';
import 'package:weblibre/features/app_update/data/github/apk_download_service.dart';
import 'package:weblibre/features/app_update/data/github/update_endpoints.dart';
import 'package:weblibre/features/app_update/domain/entities/release_metadata.dart';
import 'package:weblibre/features/app_update/domain/entities/update_failure.dart';
import 'package:weblibre/features/app_update/domain/services/update_backend.dart';

Matcher failsWith(UpdateFailureKind kind) =>
    throwsA(isA<UpdateFailure>().having((f) => f.kind, 'kind', kind));

final artifactUrl = Uri.parse(
  'https://github.com/FaFre/WebLibre/releases/download/v0.43.0/app-stable-arm64-v8a-release.apk',
);

void main() {
  group('AllowlistedFetcher (7.2)', () {
    late List<http.BaseRequest> seen;

    AllowlistedFetcher fetcher(
      Future<http.StreamedResponse> Function(http.BaseRequest request)
      handler, {
      FetchLimits limits = const FetchLimits(),
    }) {
      seen = [];
      return AllowlistedFetcher(
        client: MockClient.streaming((request, body) {
          seen.add(request);
          return handler(request);
        }),
        limits: limits,
      );
    }

    http.StreamedResponse respond(
      int status, {
      List<int> body = const [],
      Map<String, String> headers = const {},
    }) => http.StreamedResponse(
      Stream.value(body),
      status,
      headers: headers,
      // As IOClient sets it for a GET.
      isRedirect: const {301, 302, 303, 307, 308}.contains(status),
    );

    test(
      'fetches the catalogue with a fixed agent, no cookies, no credentials',
      () async {
        final f = fetcher((_) async => respond(200, body: utf8.encode('{}')));
        expect(await f.fetchCatalogue('eu.weblibre.gecko'), utf8.encode('{}'));
        final request = seen.single;
        expect(
          request.url.toString(),
          'https://updates.weblibre.eu/v1/eu.weblibre.gecko/catalogue.json',
        );
        expect(request.headers['user-agent'], updaterUserAgent);
        expect(request.headers.keys, isNot(contains('authorization')));
        expect(request.headers.keys, isNot(contains('cookie')));
        expect(request.headers.keys, isNot(contains('referer')));
        expect(request.followRedirects, isFalse);
      },
    );

    test('follows allowed artifact redirects by hand', () async {
      final f = fetcher((request) async {
        if (request.url.host == 'github.com') {
          return respond(
            302,
            headers: {
              'location': 'https://objects.githubusercontent.com/asset?sig=1',
            },
          );
        }
        return respond(200, body: [1, 2, 3]);
      });
      final response = await f.openArtifact(artifactUrl, cancel: CancelToken());
      expect(response.statusCode, 200);
      expect(seen.map((r) => r.url.host), [
        'github.com',
        'objects.githubusercontent.com',
      ]);
    });

    test(
      'rejects a redirect outside the allowlist before requesting it',
      () async {
        final f = fetcher(
          (request) async =>
              respond(302, headers: {'location': 'https://evil.example/apk'}),
        );
        await expectLater(
          f.openArtifact(artifactUrl, cancel: CancelToken()),
          failsWith(UpdateFailureKind.network),
        );
        expect(seen, hasLength(1));
      },
    );

    test(
      'rejects an HTTPS downgrade, userinfo and non-default ports',
      () async {
        for (final location in [
          'http://objects.githubusercontent.com/a',
          'https://user@objects.githubusercontent.com/a',
          'https://objects.githubusercontent.com:8443/a',
        ]) {
          final f = fetcher(
            (request) async => respond(302, headers: {'location': location}),
          );
          await expectLater(
            f.openArtifact(artifactUrl, cancel: CancelToken()),
            failsWith(UpdateFailureKind.network),
            reason: location,
          );
        }
      },
    );

    test('a redirect loop ends after five hops', () async {
      final f = fetcher(
        (request) async =>
            respond(302, headers: {'location': artifactUrl.toString()}),
      );
      await expectLater(
        f.openArtifact(artifactUrl, cancel: CancelToken()),
        failsWith(UpdateFailureKind.network),
      );
      expect(seen, hasLength(6));
    });

    test('an artifact outside the release path is never requested', () {
      final f = fetcher((_) async => respond(200));
      expect(
        () => f.openArtifact(
          Uri.parse('https://github.com/other/repo/x.apk'),
          cancel: CancelToken(),
        ),
        failsWith(UpdateFailureKind.metadataInvalid),
      );
      expect(seen, isEmpty);
    });

    test('a request that gets no response in time is aborted', () async {
      final aborted = Completer<void>();
      final f = fetcher(
        (request) {
          unawaited(
            (request as http.Abortable).abortTrigger!.then(
              (_) => aborted.complete(),
            ),
          );
          // Never answers.
          return Completer<http.StreamedResponse>().future;
        },
        limits: const FetchLimits(catalogueTimeout: Duration(milliseconds: 10)),
      );
      await expectLater(
        f.fetchCatalogue('eu.weblibre.gecko'),
        failsWith(UpdateFailureKind.network),
      );
      await aborted.future.timeout(const Duration(seconds: 1));
    });

    test('cancelling still aborts the request', () async {
      final aborted = Completer<void>();
      final cancel = CancelToken();
      final f = fetcher(
        (request) {
          unawaited(
            (request as http.Abortable).abortTrigger!.then(
              (_) => aborted.complete(),
            ),
          );
          return Completer<http.StreamedResponse>().future;
        },
        limits: const FetchLimits(catalogueTimeout: Duration(milliseconds: 50)),
      );
      final fetch = f.fetchCatalogue('eu.weblibre.gecko', cancel: cancel);
      await pumpEventQueue();
      cancel.cancel();
      await aborted.future.timeout(const Duration(seconds: 1));
      // MockClient ignores the trigger; the timeout then ends the fetch, as
      // the cancellation it is.
      await expectLater(fetch, throwsA(isA<OperationCancelled>()));
    });

    test(
      'a catalogue that trickles is cut off at the overall deadline',
      () async {
        // A byte every 5 ms never trips an inactivity timeout; the deadline
        // covers the whole exchange.
        final f = fetcher(
          (_) async => http.StreamedResponse(
            Stream.periodic(const Duration(milliseconds: 5), (_) => [0x20]),
            200,
          ),
          limits: const FetchLimits(
            catalogueTimeout: Duration(milliseconds: 60),
          ),
        );
        final watch = Stopwatch()..start();
        await expectLater(
          f
              .fetchCatalogue('eu.weblibre.gecko')
              .timeout(const Duration(seconds: 2)),
          failsWith(UpdateFailureKind.network),
        );
        expect(watch.elapsed, lessThan(const Duration(seconds: 1)));
      },
    );

    test('Cancel ends the wait for routing at once', () async {
      final routing = Completer<void>();
      final requests = <http.BaseRequest>[];
      final f = AllowlistedFetcher(
        client: MockClient.streaming((request, body) async {
          requests.add(request);
          return respond(200);
        }),
        awaitRouting: () => routing.future,
      );
      final cancel = CancelToken();
      final open = f.openArtifact(artifactUrl, cancel: cancel);
      await pumpEventQueue();
      cancel.cancel();
      await expectLater(
        open.timeout(const Duration(seconds: 1)),
        throwsA(isA<OperationCancelled>()),
      );
      expect(requests, isEmpty);
      // Routing failing later is dropped, not an unhandled error.
      routing.completeError(StateError('routing gave up'));
      await pumpEventQueue();
    });

    test(
      'Cancel during the body ends the read and closes the stream',
      () async {
        final closed = Completer<void>();
        final body = StreamController<List<int>>(onCancel: closed.complete)
          ..add([0x7B]);
        final f = fetcher((_) async => http.StreamedResponse(body.stream, 200));
        final cancel = CancelToken();
        final fetch = f.fetchCatalogue('eu.weblibre.gecko', cancel: cancel);
        await pumpEventQueue();
        cancel.cancel();
        await expectLater(fetch, throwsA(isA<OperationCancelled>()));
        await closed.future.timeout(const Duration(seconds: 1));
      },
    );

    test('an oversized catalogue is rejected while streaming', () async {
      final f = fetcher(
        (_) async => respond(200, body: List.filled(2048, 0x20)),
        limits: const FetchLimits(catalogueBytes: 1024),
      );
      await expectLater(
        f.fetchCatalogue('eu.weblibre.gecko'),
        failsWith(UpdateFailureKind.metadataInvalid),
      );
    });
  });

  group('ApkDownloadService (7.3)', () {
    late Directory dir;
    final bytes = List<int>.generate(10000, (i) => i % 251);
    final artifact = ArtifactRef(
      url: artifactUrl,
      byteLength: bytes.length,
      sha256: sha256.convert(bytes).toString(),
    );

    setUp(() async {
      dir = await Directory.systemTemp.createTemp('download');
    });

    tearDown(() => dir.delete(recursive: true));

    ApkDownloadService service(
      Future<http.StreamedResponse> Function(http.BaseRequest request)
      handler, {
      FetchLimits limits = const FetchLimits(attempts: 1),
    }) => ApkDownloadService(
      fetcher: AllowlistedFetcher(
        client: MockClient.streaming((request, body) => handler(request)),
        limits: limits,
      ),
      stagingDir: dir.path,
      limits: limits,
      retryDelay: Duration.zero,
    );

    File part() => File(p.join(dir.path, '${artifact.sha256}.part'));

    test('downloads to <sha256>.part and checks length and digest', () async {
      final s = service(
        (_) async => http.StreamedResponse(Stream.value(bytes), 200),
      );
      await s.download(artifact, onProgress: (_, _) {}, cancel: CancelToken());
      expect(await part().readAsBytes(), bytes);
    });

    test(
      'a false or missing Content-Length is not an error; the signed length decides',
      () async {
        final s = service(
          (_) async =>
              http.StreamedResponse(Stream.value(bytes), 200, contentLength: 5),
        );
        await s.download(
          artifact,
          onProgress: (_, _) {},
          cancel: CancelToken(),
        );
        expect(await part().readAsBytes(), bytes);
        await part().delete();
        final none = service(
          (_) async => http.StreamedResponse(Stream.value(bytes), 200),
        );
        await none.download(
          artifact,
          onProgress: (_, _) {},
          cancel: CancelToken(),
        );
        expect(await part().length(), bytes.length);
      },
    );

    test('aborts the moment the body exceeds the signed length', () async {
      final s = service(
        (_) async =>
            http.StreamedResponse(Stream.value([...bytes, 1, 2, 3]), 200),
      );
      await expectLater(
        s.download(artifact, onProgress: (_, _) {}, cancel: CancelToken()),
        failsWith(UpdateFailureKind.downloadTooLarge),
      );
      expect(await part().exists(), isFalse);
    });

    test(
      'the digest is left to native verification: a full-length body is kept',
      () async {
        final tampered = [...bytes]..[0] ^= 0xff;
        final s = service(
          (_) async => http.StreamedResponse(Stream.value(tampered), 200),
        );
        await s.download(
          artifact,
          onProgress: (_, _) {},
          cancel: CancelToken(),
        );
        expect(await part().readAsBytes(), tampered);
      },
    );

    test('progress is throttled and always ends with the total', () async {
      final chunks = [
        for (var i = 0; i < bytes.length; i += 100) bytes.sublist(i, i + 100),
      ];
      final reports = <int>[];
      final s = ApkDownloadService(
        fetcher: AllowlistedFetcher(
          client: MockClient.streaming(
            (request, body) async =>
                http.StreamedResponse(Stream.fromIterable(chunks), 200),
          ),
          limits: const FetchLimits(attempts: 1),
        ),
        stagingDir: dir.path,
        limits: const FetchLimits(attempts: 1),
        retryDelay: Duration.zero,
        progressInterval: const Duration(hours: 1),
      );
      await s.download(
        artifact,
        onProgress: (received, _) => reports.add(received),
        cancel: CancelToken(),
      );
      expect(reports, [0, bytes.length]);
    });

    test('a truncated body keeps the partial file for resume', () async {
      final s = service(
        (_) async =>
            http.StreamedResponse(Stream.value(bytes.sublist(0, 4000)), 200),
      );
      await expectLater(
        s.download(artifact, onProgress: (_, _) {}, cancel: CancelToken()),
        failsWith(UpdateFailureKind.network),
      );
      expect(await part().length(), 4000);
    });

    test('resumes with Range on a matching 206', () async {
      await part().writeAsBytes(bytes.sublist(0, 4000));
      String? range;
      final s = service((request) async {
        range = request.headers['range'];
        return http.StreamedResponse(
          Stream.value(bytes.sublist(4000)),
          206,
          headers: {'content-range': 'bytes 4000-9999/10000'},
        );
      });
      await s.download(artifact, onProgress: (_, _) {}, cancel: CancelToken());
      expect(range, 'bytes=4000-');
      expect(await part().readAsBytes(), bytes);
    });

    test('a 200 to a range request starts over', () async {
      await part().writeAsBytes(List.filled(4000, 7));
      final s = service(
        (_) async => http.StreamedResponse(Stream.value(bytes), 200),
      );
      await s.download(artifact, onProgress: (_, _) {}, cancel: CancelToken());
      expect(await part().readAsBytes(), bytes);
    });

    test(
      'cancelling a stalled download returns promptly and keeps the part',
      () async {
        final stalled = StreamController<List<int>>();
        final s = service((request) async {
          final abortable = request as http.Abortable;
          unawaited(
            abortable.abortTrigger?.then((_) {
              stalled.addError(http.RequestAbortedException(request.url));
              unawaited(stalled.close());
            }),
          );
          stalled.add(bytes.sublist(0, 100));
          return http.StreamedResponse(stalled.stream, 200);
        });
        final cancel = CancelToken();
        final download = s.download(
          artifact,
          onProgress: (_, _) {},
          cancel: cancel,
        );
        await Future<void>.delayed(const Duration(milliseconds: 50));
        cancel.cancel();
        await expectLater(
          download.timeout(const Duration(seconds: 2)),
          throwsA(isA<OperationCancelled>()),
        );
        expect(await part().exists(), isTrue);
      },
    );

    test(
      'a stream that stalls past the stall timeout fails as network',
      () async {
        final s = service(
          (_) async =>
              http.StreamedResponse(StreamController<List<int>>().stream, 200),
          limits: const FetchLimits(
            attempts: 1,
            stallTimeout: Duration(milliseconds: 50),
          ),
        );
        await expectLater(
          s.download(artifact, onProgress: (_, _) {}, cancel: CancelToken()),
          failsWith(UpdateFailureKind.network),
        );
      },
    );

    test(
      'a staging file that cannot be written is storage, not retried',
      () async {
        // A directory where the .part file goes: opening it for writing fails
        // the way a full disk would, with a FileSystemException.
        await Directory(part().path).create();
        var requests = 0;
        final s = service((_) async {
          requests++;
          return http.StreamedResponse(Stream.value(bytes), 200);
        }, limits: const FetchLimits());
        await expectLater(
          s.download(artifact, onProgress: (_, _) {}, cancel: CancelToken()),
          failsWith(UpdateFailureKind.insufficientStorage),
        );
        expect(requests, 1);
      },
    );

    test('larger than the hard cap is refused before any request', () async {
      final s = service(
        (_) async => fail('must not request'),
        limits: const FetchLimits(attempts: 1, artifactHardCap: 100),
      );
      await expectLater(
        s.download(artifact, onProgress: (_, _) {}, cancel: CancelToken()),
        failsWith(UpdateFailureKind.downloadTooLarge),
      );
    });
  });
}
