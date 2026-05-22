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
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/experimental/persist.dart';
import 'package:riverpod/riverpod.dart';
import 'package:search_backend/search_backend.dart';
import 'package:weblibre/features/search_credits/domain/controllers/search_token_issuance_controller.dart';
import 'package:weblibre/features/user/data/providers.dart';
import 'package:weblibre/features/web_search/domain/controllers/search_controller.dart';
import 'package:weblibre/features/web_search/domain/entities/fetch_method.dart';
import 'package:weblibre/features/web_search/domain/services/capture_artifact_downloader.dart';

void main() {
  group('MetaSearchController', () {
    test('transitions to needsCredits when no token is available', () async {
      final container = ProviderContainer(
        overrides: [
          metaSearchEnsureTokenAvailableProvider.overrideWithValue(
            () async => TokenAvailabilityOutcome.noCredits,
          ),
          riverpodDatabaseStorageProvider.overrideWith(
            (ref) => Storage.inMemory(),
          ),
        ],
      );
      addTearDown(container.dispose);

      final sub = container.listen(
        metaSearchControllerProvider,
        (_, _) {},
        fireImmediately: true,
      );
      addTearDown(sub.close);

      await container
          .read(metaSearchControllerProvider.notifier)
          .submit('lensai');

      final state = container.read(metaSearchControllerProvider);
      expect(state.status, WebSearchStatus.needsCredits);
      expect(state.query, 'lensai');
    });

    test('transitions to error when token issuance fails', () async {
      final container = ProviderContainer(
        overrides: [
          metaSearchEnsureTokenAvailableProvider.overrideWithValue(
            () async => TokenAvailabilityOutcome.issuanceFailed,
          ),
          riverpodDatabaseStorageProvider.overrideWith(
            (ref) => Storage.inMemory(),
          ),
        ],
      );
      addTearDown(container.dispose);

      final sub = container.listen(
        metaSearchControllerProvider,
        (_, _) {},
        fireImmediately: true,
      );
      addTearDown(sub.close);

      await container
          .read(metaSearchControllerProvider.notifier)
          .submit('lensai');

      final state = container.read(metaSearchControllerProvider);
      expect(state.status, WebSearchStatus.error);
      expect(
        state.errorMessage,
        'Could not issue search tokens. Please try again.',
      );
      expect(state.query, 'lensai');
    });

    test('transitions to error when token availability check fails', () async {
      final container = ProviderContainer(
        overrides: [
          metaSearchEnsureTokenAvailableProvider.overrideWithValue(
            () async => throw Exception('balance unavailable'),
          ),
          riverpodDatabaseStorageProvider.overrideWith(
            (ref) => Storage.inMemory(),
          ),
        ],
      );
      addTearDown(container.dispose);

      final sub = container.listen(
        metaSearchControllerProvider,
        (_, _) {},
        fireImmediately: true,
      );
      addTearDown(sub.close);

      await container
          .read(metaSearchControllerProvider.notifier)
          .submit('lensai');

      final state = container.read(metaSearchControllerProvider);
      expect(state.status, WebSearchStatus.error);
      expect(
        state.errorMessage,
        'Could not check search credits. Please try again.',
      );
      expect(state.query, 'lensai');
    });

    test('search results populate the ready state', () async {
      final session = _FakeMetaSearchSession();
      final container = _createContainer(session);
      addTearDown(container.dispose);

      final sub = container.listen(
        metaSearchControllerProvider,
        (_, _) {},
        fireImmediately: true,
      );
      addTearDown(sub.close);

      await container
          .read(metaSearchControllerProvider.notifier)
          .submit('lensai');

      session.emit(
        StreamMessage(
          type: MessageTypes.searchResults,
          data: _searchResultsPayload(
            query: 'lensai',
            results: [
              {
                'title': 'LensAI result',
                'url': 'https://example.com/result',
                'content': 'Result summary',
                'publishedDate': null,
                'img_src': null,
                'thumbnail': null,
              },
            ],
          ),
        ),
      );
      await _flushMicrotasks();

      final state = container.read(metaSearchControllerProvider);
      expect(state.status, WebSearchStatus.ready);
      expect(state.results, hasLength(1));
      expect(state.results.single.title, 'LensAI result');
      expect(session.submittedQueries, ['lensai']);
    });

    test('image frames update cached media maps', () async {
      final session = _FakeMetaSearchSession();
      final container = _createContainer(session);
      addTearDown(container.dispose);

      final sub = container.listen(
        metaSearchControllerProvider,
        (_, _) {},
        fireImmediately: true,
      );
      addTearDown(sub.close);

      await container
          .read(metaSearchControllerProvider.notifier)
          .submit('lensai');

      session.emit(
        StreamMessage(
          type: MessageTypes.image,
          data: {
            'url': 'https://example.com/image.png',
            'bytes': base64Encode(Uint8List.fromList([4, 5, 6])),
          },
        ),
      );
      await _flushMicrotasks();

      final state = container.read(metaSearchControllerProvider);
      expect(state.imagesByUrl['https://example.com/image.png'], [4, 5, 6]);
    });

    test(
      'fetchPage marks a result in flight and stores fetched documents',
      () async {
        final session = _FakeMetaSearchSession();
        final container = _createContainer(session);
        addTearDown(container.dispose);

        final sub = container.listen(
          metaSearchControllerProvider,
          (_, _) {},
          fireImmediately: true,
        );
        addTearDown(sub.close);

        const resultUrl = 'https://example.com/result';
        await container
            .read(metaSearchControllerProvider.notifier)
            .submit('lensai');
        session.emit(
          StreamMessage(
            type: MessageTypes.searchResults,
            data: _searchResultsPayload(
              query: 'lensai',
              results: [
                {
                  'title': 'LensAI result',
                  'url': resultUrl,
                  'content': null,
                  'publishedDate': null,
                  'img_src': null,
                  'thumbnail': null,
                },
              ],
            ),
          ),
        );
        await _flushMicrotasks();

        await container
            .read(metaSearchControllerProvider.notifier)
            .fetchPage(Uri.parse(resultUrl));

        expect(
          container.read(metaSearchControllerProvider).fetchingUrls,
          contains(Uri.parse(resultUrl)),
        );
        expect(session.fetchRequests, [Uri.parse(resultUrl)]);

        session.emit(
          StreamMessage(
            type: MessageTypes.document,
            data: {
              'url': resultUrl,
              'content': '# Preview\n\nFetched content',
              'metadata': {
                'date': null,
                'description': null,
                'filedate': null,
                'image': null,
                'language': null,
                'pagetype': null,
                'sitename': null,
                'title': 'LensAI result',
                'author': null,
                'license': null,
              },
            },
          ),
        );
        await _flushMicrotasks();

        final state = container.read(metaSearchControllerProvider);
        expect(state.fetchingUrls, isEmpty);
        expect(state.documentsByUrl.keys, contains(Uri.parse(resultUrl)));
        expect(
          state.documentsByUrl[Uri.parse(resultUrl)]?.content,
          contains('Fetched content'),
        );
      },
    );

    test(
      'fetch failures clear in-flight state and preserve search results',
      () async {
        final session = _FakeMetaSearchSession();
        final container = _createContainer(session);
        addTearDown(container.dispose);

        final sub = container.listen(
          metaSearchControllerProvider,
          (_, _) {},
          fireImmediately: true,
        );
        addTearDown(sub.close);

        const resultUrl = 'https://example.com/result';
        await container
            .read(metaSearchControllerProvider.notifier)
            .submit('lensai');
        session.emit(
          StreamMessage(
            type: MessageTypes.searchResults,
            data: _searchResultsPayload(
              query: 'lensai',
              results: [
                {
                  'title': 'LensAI result',
                  'url': resultUrl,
                  'content': null,
                  'publishedDate': null,
                  'img_src': null,
                  'thumbnail': null,
                },
              ],
            ),
          ),
        );
        await _flushMicrotasks();

        await container
            .read(metaSearchControllerProvider.notifier)
            .fetchPage(Uri.parse(resultUrl));
        session.emit(
          StreamMessage(
            type: MessageTypes.error,
            data: {'message': 'Document fetch failed'},
          ),
        );
        await _flushMicrotasks();

        final state = container.read(metaSearchControllerProvider);
        expect(state.status, WebSearchStatus.ready);
        expect(state.results, hasLength(1));
        expect(state.fetchingUrls, isEmpty);
        expect(state.errorMessage, contains('Document fetch failed'));
      },
    );

    test(
      'capturePage dispatches capture request and tracks capturing state',
      () async {
        final session = _FakeMetaSearchSession();
        final container = _createContainer(session);
        addTearDown(container.dispose);

        final sub = container.listen(
          metaSearchControllerProvider,
          (_, _) {},
          fireImmediately: true,
        );
        addTearDown(sub.close);

        const resultUrl = 'https://example.com/result';
        await container
            .read(metaSearchControllerProvider.notifier)
            .submit('lensai');
        session.emit(
          StreamMessage(
            type: MessageTypes.searchResults,
            data: _searchResultsPayload(
              query: 'lensai',
              results: [
                {
                  'title': 'LensAI result',
                  'url': resultUrl,
                  'content': null,
                  'publishedDate': null,
                  'img_src': null,
                  'thumbnail': null,
                },
              ],
            ),
          ),
        );
        await _flushMicrotasks();

        final uri = Uri.parse(resultUrl);
        await container
            .read(metaSearchControllerProvider.notifier)
            .capturePage(uri, choice: FetchMethodChoice.singlefileHtml);

        expect(
          container
              .read(metaSearchControllerProvider)
              .isCapturing(uri, FetchMethodChoice.singlefileHtml),
          isTrue,
        );
        expect(session.captureRequests, hasLength(1));
        expect(session.captureRequests.first.url, uri);
        expect(session.captureRequests.first.method, 'singlefile');
        expect(session.captureRequests.first.variant, 'balanced');
      },
    );

    test('capture frame clears capturing state', () async {
      final session = _FakeMetaSearchSession();
      final container = _createContainer(session);
      addTearDown(container.dispose);

      final sub = container.listen(
        metaSearchControllerProvider,
        (_, _) {},
        fireImmediately: true,
      );
      addTearDown(sub.close);

      const resultUrl = 'https://example.com/result';
      final uri = Uri.parse(resultUrl);
      await container
          .read(metaSearchControllerProvider.notifier)
          .submit('lensai');
      session.emit(
        StreamMessage(
          type: MessageTypes.searchResults,
          data: _searchResultsPayload(
            query: 'lensai',
            results: [
              {
                'title': 'LensAI result',
                'url': resultUrl,
                'content': null,
                'publishedDate': null,
                'img_src': null,
                'thumbnail': null,
              },
            ],
          ),
        ),
      );
      await _flushMicrotasks();

      await container
          .read(metaSearchControllerProvider.notifier)
          .capturePage(uri, choice: FetchMethodChoice.singlefileHtml);

      expect(
        container
            .read(metaSearchControllerProvider)
            .isCapturing(uri, FetchMethodChoice.singlefileHtml),
        isTrue,
      );

      session.emit(
        StreamMessage(
          type: MessageTypes.capture,
          data: {
            'captureId': 'abc123',
            'url': resultUrl,
            'method': 'singlefile',
            'variant': 'balanced',
            'contentType': 'text/html; charset=utf-8',
            'byteLength': 42,
            'downloadToken': 'tok-1',
            'filename': null,
            'finalUrl': null,
          },
        ),
      );
      await _flushMicrotasks();
      expect(
        container.read(metaSearchControllerProvider).capturingByUrl,
        isEmpty,
      );
    });

    test('capture messages do not populate documentsByUrl', () async {
      final session = _FakeMetaSearchSession();
      final container = _createContainer(session);
      addTearDown(container.dispose);

      final sub = container.listen(
        metaSearchControllerProvider,
        (_, _) {},
        fireImmediately: true,
      );
      addTearDown(sub.close);

      const resultUrl = 'https://example.com/result';
      final uri = Uri.parse(resultUrl);
      await container
          .read(metaSearchControllerProvider.notifier)
          .submit('lensai');
      session.emit(
        StreamMessage(
          type: MessageTypes.searchResults,
          data: _searchResultsPayload(
            query: 'lensai',
            results: [
              {
                'title': 'LensAI result',
                'url': resultUrl,
                'content': null,
                'publishedDate': null,
                'img_src': null,
                'thumbnail': null,
              },
            ],
          ),
        ),
      );
      await _flushMicrotasks();

      await container
          .read(metaSearchControllerProvider.notifier)
          .capturePage(uri, choice: FetchMethodChoice.singlefileHtml);

      session.emit(
        StreamMessage(
          type: MessageTypes.capture,
          data: {
            'captureId': 'abc123',
            'url': resultUrl,
            'method': 'singlefile',
            'variant': 'balanced',
            'contentType': 'text/html; charset=utf-8',
            'byteLength': 42,
            'downloadToken': 'tok-1',
            'filename': null,
            'finalUrl': null,
          },
        ),
      );
      await _flushMicrotasks();

      final state = container.read(metaSearchControllerProvider);
      expect(state.documentsByUrl, isEmpty);
      expect(state.capturingByUrl, isEmpty);
      final captured = state.capturedPage(
        uri,
        FetchMethodChoice.singlefileHtml,
      );
      expect(captured, isNotNull);
      expect(captured?.captureId, 'abc123');
    });

    test(
      'URL-scoped error clears specific fetching and capturing URLs',
      () async {
        final session = _FakeMetaSearchSession();
        final container = _createContainer(session);
        addTearDown(container.dispose);

        final sub = container.listen(
          metaSearchControllerProvider,
          (_, _) {},
          fireImmediately: true,
        );
        addTearDown(sub.close);

        const resultUrl = 'https://example.com/result';
        await container
            .read(metaSearchControllerProvider.notifier)
            .submit('lensai');
        session.emit(
          StreamMessage(
            type: MessageTypes.searchResults,
            data: _searchResultsPayload(
              query: 'lensai',
              results: [
                {
                  'title': 'LensAI result',
                  'url': resultUrl,
                  'content': null,
                  'publishedDate': null,
                  'img_src': null,
                  'thumbnail': null,
                },
              ],
            ),
          ),
        );
        await _flushMicrotasks();

        final uri = Uri.parse(resultUrl);
        await container
            .read(metaSearchControllerProvider.notifier)
            .capturePage(uri, choice: FetchMethodChoice.singlefileHtml);

        session.emit(
          StreamMessage(
            type: MessageTypes.error,
            data: {'message': 'Capture failed', 'url': resultUrl},
          ),
        );
        await _flushMicrotasks();

        final state = container.read(metaSearchControllerProvider);
        expect(state.capturingByUrl, isEmpty);
        expect(state.fetchingUrls, isEmpty);
        expect(state.status, WebSearchStatus.ready);
        expect(state.results, hasLength(1));
      },
    );
  });
}

Map<String, dynamic> _searchResultsPayload({
  required String query,
  required List<Map<String, dynamic>> results,
  int page = 0,
  int pageSize = 10,
  int? totalResults,
  bool hasMore = false,
}) {
  return {
    'query': query,
    'infos': const <Object>[],
    'results': results,
    'page': page,
    'pageSize': pageSize,
    'totalResults': totalResults ?? results.length,
    'hasMore': hasMore,
  };
}

ProviderContainer _createContainer(_FakeMetaSearchSession session) {
  return ProviderContainer(
    overrides: [
      metaSearchEnsureTokenAvailableProvider.overrideWithValue(
        () async => TokenAvailabilityOutcome.available,
      ),
      metaSearchSessionFactoryProvider.overrideWithValue(() async => session),
      captureArtifactDownloaderProvider.overrideWith(
        (ref) => _FakeCaptureDownloader(),
      ),
      riverpodDatabaseStorageProvider.overrideWith((ref) => Storage.inMemory()),
    ],
  );
}

class _FakeCaptureDownloader implements CaptureArtifactDownloader {
  @override
  Future<String> download(CaptureArtifactReceipt receipt) async {
    return '/fake/path/${receipt.captureId}.html';
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<void> _flushMicrotasks() {
  return Future<void>.delayed(Duration.zero);
}

class _FakeMetaSearchSession implements MetaSearchSession {
  final _messages = StreamController<StreamMessage>.broadcast();

  final List<String> submittedQueries = <String>[];
  final List<Uri> fetchRequests = <Uri>[];
  final List<_CaptureRequest> captureRequests = <_CaptureRequest>[];
  bool _closed = false;

  @override
  Stream<StreamMessage> get messages => _messages.stream;

  @override
  bool get isClosed => _closed;

  void emit(StreamMessage message) {
    _messages.add(message);
  }

  @override
  void fetchPage(Uri url) {
    fetchRequests.add(url);
  }

  @override
  void capturePage(
    Uri url, {
    required String method,
    required String variant,
    CaptureDimensions? dimensions,
  }) {
    captureRequests.add(
      _CaptureRequest(url: url, method: method, variant: variant),
    );
  }

  @override
  Future<void> close() async {
    _closed = true;
    await _messages.close();
  }

  @override
  void submitQuery(
    String query, {
    required SearchMode mode,
    String? language,
    String? region,
    SafeSearch? safeSearch,
    TimeRange? timeRange,
  }) {
    submittedQueries.add(query);
  }

  final List<int> loadPageRequests = <int>[];

  @override
  void loadPage(int page) {
    loadPageRequests.add(page);
  }
}

class _CaptureRequest {
  final Uri url;
  final String method;
  final String variant;
  _CaptureRequest({
    required this.url,
    required this.method,
    required this.variant,
  });
}
