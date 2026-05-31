import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:search_client/search_client.dart';
import 'package:weblibre/core/branding/proxy_brands.dart';
import 'package:weblibre/domain/services/generic_website.dart';
import 'package:weblibre/features/search_credits/domain/controllers/search_token_issuance_controller.dart';
import 'package:weblibre/features/search_credits/domain/providers.dart';
import 'package:weblibre/features/search_credits/domain/providers/proxy_client.dart';
import 'package:weblibre/features/search_credits/domain/repositories/search_token_stash_repository.dart';
import 'package:weblibre/features/search_credits/domain/repositories/web_search_settings.dart';
import 'package:weblibre/features/tor/domain/extensions/tor_status_x.dart';
import 'package:weblibre/features/tor/domain/services/tor_proxy.dart';
import 'package:weblibre/features/tor/presentation/controllers/start_tor_proxy.dart';
import 'package:weblibre/features/web_search/domain/entities/captured_page_state.dart';
import 'package:weblibre/features/web_search/domain/entities/fetch_method.dart';
import 'package:weblibre/features/web_search/domain/services/capture_artifact_downloader.dart';

part 'search_controller.g.dart';

enum WebSearchStatus { idle, needsCredits, submitting, ready, error }

const _unset = Object();

class MetaSearchState {
  final WebSearchStatus status;
  final String query;
  final List<CompactInfobox> infos;
  final List<CompactSearchResult> results;
  final Map<String, Uint8List> imagesByUrl;
  final Map<Uri, FetchedDocument> documentsByUrl;
  final Set<Uri> fetchingUrls;
  final Map<Uri, Set<FetchMethodChoice>> capturingByUrl;
  final Map<Uri, Map<FetchMethodChoice, CapturedPageState>> capturedPagesByUrl;
  // Per-URL trafilatura fetch errors. Capture-method errors live on
  // CapturedPageState.errorMessage (status == downloadFailed); this map
  // only covers the trafilatura "Preview" path which has no per-method
  // CapturedPageState entry.
  final Map<Uri, String> fetchErrorByUrl;
  final String? errorMessage;
  final bool hasOpenSession;
  // Index of the last page delivered by the backend (0-based). Reset to 0
  // on every fresh submit; advanced as later pages stream in.
  final int currentPage;
  final bool hasMore;
  // True while a loadPage command is in flight. Cleared when the next page
  // arrives or the session closes/errors.
  final bool isLoadingMore;

  const MetaSearchState({
    this.status = WebSearchStatus.idle,
    this.query = '',
    this.infos = const [],
    this.results = const [],
    this.imagesByUrl = const {},
    this.documentsByUrl = const {},
    this.fetchingUrls = const {},
    this.capturingByUrl = const {},
    this.capturedPagesByUrl = const {},
    this.fetchErrorByUrl = const {},
    this.errorMessage,
    this.hasOpenSession = false,
    this.currentPage = 0,
    this.hasMore = false,
    this.isLoadingMore = false,
  });

  bool get isSubmitting => status == WebSearchStatus.submitting;

  bool isFetched(Uri url) => documentsByUrl.containsKey(url);

  bool isFetching(Uri url) => fetchingUrls.contains(url);

  String? fetchError(Uri url) => fetchErrorByUrl[url];

  bool isCapturing(Uri url, FetchMethodChoice method) =>
      capturingByUrl[url]?.contains(method) ?? false;

  bool isAnyCapturing(Uri url) => capturingByUrl[url]?.isNotEmpty ?? false;

  CapturedPageState? capturedPage(Uri url, FetchMethodChoice method) =>
      capturedPagesByUrl[url]?[method];

  Map<FetchMethodChoice, CapturedPageState> capturesFor(Uri url) =>
      capturedPagesByUrl[url] ?? const {};

  bool isMethodBusy(Uri url, FetchMethodChoice method) {
    if (method == FetchMethodChoice.trafilatura) {
      return isFetching(url);
    }
    if (isCapturing(url, method)) {
      return true;
    }
    final captured = capturedPage(url, method);
    return captured != null &&
        (captured.status == CapturedPageStatus.capturing ||
            captured.status == CapturedPageStatus.downloading);
  }

  bool isMethodReady(Uri url, FetchMethodChoice method) {
    if (method == FetchMethodChoice.trafilatura) {
      return isFetched(url);
    }
    return capturedPage(url, method)?.status == CapturedPageStatus.ready;
  }

  MetaSearchState copyWith({
    WebSearchStatus? status,
    String? query,
    List<CompactInfobox>? infos,
    List<CompactSearchResult>? results,
    Map<String, Uint8List>? imagesByUrl,
    Map<Uri, FetchedDocument>? documentsByUrl,
    Set<Uri>? fetchingUrls,
    Map<Uri, Set<FetchMethodChoice>>? capturingByUrl,
    Map<Uri, Map<FetchMethodChoice, CapturedPageState>>? capturedPagesByUrl,
    Map<Uri, String>? fetchErrorByUrl,
    Object? errorMessage = _unset,
    bool? hasOpenSession,
    int? currentPage,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return MetaSearchState(
      status: status ?? this.status,
      query: query ?? this.query,
      infos: infos ?? this.infos,
      results: results ?? this.results,
      imagesByUrl: imagesByUrl ?? this.imagesByUrl,
      documentsByUrl: documentsByUrl ?? this.documentsByUrl,
      fetchingUrls: fetchingUrls ?? this.fetchingUrls,
      capturingByUrl: capturingByUrl ?? this.capturingByUrl,
      capturedPagesByUrl: capturedPagesByUrl ?? this.capturedPagesByUrl,
      fetchErrorByUrl: fetchErrorByUrl ?? this.fetchErrorByUrl,
      errorMessage: errorMessage == _unset
          ? this.errorMessage
          : errorMessage as String?,
      hasOpenSession: hasOpenSession ?? this.hasOpenSession,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

abstract interface class MetaSearchSession {
  Stream<StreamMessage> get messages;

  bool get isClosed;

  void submitQuery(
    String query, {
    required SearchMode mode,
    String? language,
    String? region,
    SafeSearch? safeSearch,
    TimeRange? timeRange,
  });

  void fetchPage(Uri url);

  void capturePage(
    Uri url, {
    required String method,
    required String variant,
    CaptureDimensions? dimensions,
  });

  void loadPage(int page);

  Future<void> close();
}

final class LiveMetaSearchSession implements MetaSearchSession {
  final SearchSession _session;

  const LiveMetaSearchSession(this._session);

  @override
  Stream<StreamMessage> get messages => _session.messages;

  @override
  bool get isClosed => _session.isClosed;

  @override
  void submitQuery(
    String query, {
    required SearchMode mode,
    String? language,
    String? region,
    SafeSearch? safeSearch,
    TimeRange? timeRange,
  }) {
    _session.submitQuery(
      query,
      mode: mode,
      language: language,
      region: region,
      safeSearch: safeSearch,
      timeRange: timeRange,
    );
  }

  @override
  void fetchPage(Uri url) {
    _session.fetchPage(url);
  }

  @override
  void capturePage(
    Uri url, {
    required String method,
    required String variant,
    CaptureDimensions? dimensions,
  }) {
    _session.capturePage(
      url,
      method: method,
      variant: variant,
      dimensions: dimensions,
    );
  }

  @override
  void loadPage(int page) {
    _session.loadPage(page);
  }

  @override
  Future<void> close() => _session.close();
}

typedef MetaSearchEnsureTokenAvailable =
    Future<TokenAvailabilityOutcome> Function();
typedef MetaSearchSessionFactory = Future<MetaSearchSession?> Function();

final metaSearchEnsureTokenAvailableProvider =
    Provider<MetaSearchEnsureTokenAvailable>((ref) {
      return () => ref.read(searchTokenAvailabilityProvider).ensureAvailable();
    });

final metaSearchSessionFactoryProvider = Provider<MetaSearchSessionFactory>((
  ref,
) {
  return () async {
    final session = await SearchSession.openFromStash(
      endpoints: ref.read(searchBackendEndpointsProvider),
      stash: ref.read(searchTokenStashProvider),
      logger: ref.read(searchClientLoggerProvider),
      customClient: ref.read(searchHttpClientProvider),
    );
    return session == null ? null : LiveMetaSearchSession(session);
  };
});

@Riverpod(keepAlive: true)
class MetaSearchController extends _$MetaSearchController {
  MetaSearchSession? _session;
  StreamSubscription<StreamMessage>? _sub;
  // Flipped by ref.onDispose so async tasks (notably HTTP downloads which
  // have no cancellation handle of their own) can short-circuit before
  // touching state. Cheaper and more deterministic than re-checking
  // ref.mounted after every await.
  bool _disposed = false;

  @override
  MetaSearchState build() {
    ref.onDispose(() {
      _disposed = true;
      unawaited(_closeActiveSession());
    });
    return const MetaSearchState();
  }

  bool isFetched(Uri url) => state.isFetched(url);

  bool isFetching(Uri url) => state.isFetching(url);

  Future<void> submit(
    String query, {
    SearchMode mode = SearchMode.general,
    String? language,
    String? region,
    SafeSearch? safeSearch,
    TimeRange? timeRange,
  }) async {
    final normalizedQuery = query.trim();
    if (normalizedQuery.isEmpty || state.isSubmitting) {
      return;
    }

    await _closeActiveSession();
    ref.read(webSearchScrollOffsetProvider.notifier).reset();
    state = MetaSearchState(
      status: WebSearchStatus.submitting,
      query: normalizedQuery,
    );

    if (!await _ensureTorReadyIfRequested()) {
      state = state.copyWith(
        status: WebSearchStatus.error,
        errorMessage:
            'Could not start $torBrand for the search. Disable the $torBrand toggle or try again.',
        hasOpenSession: false,
      );
      return;
    }

    final TokenAvailabilityOutcome availability;
    try {
      availability = await ref.read(metaSearchEnsureTokenAvailableProvider)();
    } catch (error, stackTrace) {
      ref
          .read(searchClientLoggerProvider)
          .e(
            'Failed to check search credit availability',
            error: error,
            stackTrace: stackTrace,
          );
      state = state.copyWith(
        status: WebSearchStatus.error,
        errorMessage: 'Could not check search credits. Please try again.',
        hasOpenSession: false,
      );
      return;
    }
    switch (availability) {
      case TokenAvailabilityOutcome.available:
        break;
      case TokenAvailabilityOutcome.noCredits:
        state = state.copyWith(
          status: WebSearchStatus.needsCredits,
          hasOpenSession: false,
        );
        return;
      case TokenAvailabilityOutcome.issuanceFailed:
        state = state.copyWith(
          status: WebSearchStatus.error,
          errorMessage: 'Could not issue search tokens. Please try again.',
          hasOpenSession: false,
        );
        return;
    }

    final sessionFactory = ref.read(metaSearchSessionFactoryProvider);
    final session = await sessionFactory();

    if (session == null) {
      state = state.copyWith(
        status: WebSearchStatus.needsCredits,
        hasOpenSession: false,
      );
      return;
    }

    _session = session;
    final subscription = session.messages.listen(
      _handleMessage,
      onError: (Object error, StackTrace stackTrace) {
        ref
            .read(searchClientLoggerProvider)
            .e('Search socket error', error: error, stackTrace: stackTrace);
        final message = error is SearchSessionCloseException
            ? _closeCodeUserMessage(error.closeCode)
            : 'Search connection error. Please try again.';
        _applyError(message, sessionClosed: true);
      },
      onDone: () {
        if (!ref.mounted) {
          return;
        }

        _session = null;
        _sub = null;

        // Guard against a silent close while still waiting for the first
        // result (e.g. the server drops the TCP connection without a proper
        // WebSocket close frame, so no error event was emitted above).
        if (state.status == WebSearchStatus.submitting) {
          state = state.copyWith(
            status: WebSearchStatus.error,
            errorMessage:
                'Search connection closed before results arrived. '
                'Please try again.',
            hasOpenSession: false,
            isLoadingMore: false,
          );
        } else {
          state = state.copyWith(hasOpenSession: false, isLoadingMore: false);
        }
      },
    );
    _sub = subscription;
    state = state.copyWith(hasOpenSession: true);

    try {
      session.submitQuery(
        normalizedQuery,
        mode: mode,
        language: language,
        region: region,
        safeSearch: safeSearch,
        timeRange: timeRange,
      );
    } catch (error, stackTrace) {
      ref
          .read(searchClientLoggerProvider)
          .e('Failed to submit query', error: error, stackTrace: stackTrace);
      // Guarantee the subscription we just attached is torn down even if
      // _closeActiveSession races with the onDone callback (which clears
      // _sub itself). Cancel the local handle directly and only fall back
      // to the field-based close for the SearchSession itself.
      unawaited(subscription.cancel());
      if (identical(_sub, subscription)) {
        _sub = null;
      }
      _applyError('Failed to submit query: $error', sessionClosed: true);
      unawaited(_closeActiveSession());
    }
  }

  Future<void> fetchPage(Uri url) async {
    if (state.fetchingUrls.contains(url) ||
        state.documentsByUrl.containsKey(url)) {
      return;
    }

    final session = _session;
    if (session == null || session.isClosed) {
      _applyError(
        'Search session is no longer available. Run the search again.',
        failedFetchUrl: url,
        sessionClosed: true,
      );
      return;
    }

    final nextFetching = {...state.fetchingUrls, url};
    final nextFetchErrors = {...state.fetchErrorByUrl}..remove(url);
    state = state.copyWith(
      fetchingUrls: nextFetching,
      fetchErrorByUrl: nextFetchErrors,
      errorMessage: null,
    );

    try {
      session.fetchPage(url);
    } catch (error, stackTrace) {
      ref
          .read(searchClientLoggerProvider)
          .e(
            'Failed to request page fetch',
            error: error,
            stackTrace: stackTrace,
          );
      _applyError('Failed to fetch page: $error', failedFetchUrl: url);
    }
  }

  Future<void> capturePage(
    Uri url, {
    required FetchMethodChoice choice,
    CaptureDimensions? dimensions,
  }) async {
    final method = choice.method;
    final variant = choice.variant;
    if (method == null || variant == null) {
      return;
    }

    if (state.isCapturing(url, choice)) {
      return;
    }
    final existing = state.capturedPage(url, choice);
    if (existing != null &&
        existing.status != CapturedPageStatus.downloadFailed) {
      return;
    }

    final session = _session;
    if (session == null || session.isClosed) {
      _applyError(
        'Search session is no longer available. Run the search again.',
        failedFetchUrl: url,
        sessionClosed: true,
      );
      return;
    }

    final nextCapturing = _withMethodAdded(state.capturingByUrl, url, choice);
    state = state.copyWith(capturingByUrl: nextCapturing, errorMessage: null);

    try {
      session.capturePage(
        url,
        method: method,
        variant: variant,
        dimensions: dimensions,
      );
    } catch (error, stackTrace) {
      ref
          .read(searchClientLoggerProvider)
          .e(
            'Failed to request page capture',
            error: error,
            stackTrace: stackTrace,
          );
      _applyError('Failed to capture page: $error', failedFetchUrl: url);
    }
  }

  static Map<Uri, Set<FetchMethodChoice>> _withMethodAdded(
    Map<Uri, Set<FetchMethodChoice>> source,
    Uri url,
    FetchMethodChoice method,
  ) {
    final next = {
      for (final entry in source.entries) entry.key: {...entry.value},
    };
    (next[url] ??= <FetchMethodChoice>{}).add(method);
    return next;
  }

  static Map<Uri, Set<FetchMethodChoice>> _withMethodRemoved(
    Map<Uri, Set<FetchMethodChoice>> source,
    Uri url,
    FetchMethodChoice method,
  ) {
    final next = {
      for (final entry in source.entries) entry.key: {...entry.value},
    };
    final bucket = next[url];
    if (bucket != null) {
      bucket.remove(method);
      if (bucket.isEmpty) {
        next.remove(url);
      }
    }
    return next;
  }

  static Map<Uri, Map<FetchMethodChoice, CapturedPageState>> _withCaptureSet(
    Map<Uri, Map<FetchMethodChoice, CapturedPageState>> source,
    Uri url,
    FetchMethodChoice method,
    CapturedPageState value,
  ) {
    final next = {
      for (final entry in source.entries) entry.key: {...entry.value},
    };
    (next[url] ??= <FetchMethodChoice, CapturedPageState>{})[method] = value;
    return next;
  }

  static Map<Uri, Map<FetchMethodChoice, CapturedPageState>>
  _failInProgressCapturesForUrl(
    Map<Uri, Map<FetchMethodChoice, CapturedPageState>> source,
    Uri url, {
    required Set<FetchMethodChoice> capturingMethods,
    String errorMessage = 'Capture was interrupted',
  }) {
    final urlCaptures = source[url] ?? const {};
    var changed = false;
    final updated = <FetchMethodChoice, CapturedPageState>{};
    for (final entry in urlCaptures.entries) {
      if (entry.value.status == CapturedPageStatus.capturing ||
          entry.value.status == CapturedPageStatus.downloading) {
        updated[entry.key] = entry.value.copyWith(
          status: CapturedPageStatus.downloadFailed,
          errorMessage: errorMessage,
        );
        changed = true;
      } else {
        updated[entry.key] = entry.value;
      }
    }
    // Synthesize downloadFailed entries for methods that were mid-capture
    // (in capturingByUrl) but for which the backend never produced a
    // capture frame — otherwise the busy chip vanishes with no replacement
    // and the user is left wondering what happened to the PDF/Image they
    // requested.
    for (final method in capturingMethods) {
      if (updated.containsKey(method)) continue;
      updated[method] = CapturedPageState(
        sourceUrl: url,
        status: CapturedPageStatus.downloadFailed,
        errorMessage: errorMessage,
      );
      changed = true;
    }
    if (!changed) return source;
    return {
      for (final entry in source.entries)
        if (entry.key != url) entry.key: entry.value,
      url: updated,
    };
  }

  static Map<Uri, Map<FetchMethodChoice, CapturedPageState>>
  _failAllInProgressCaptures(
    Map<Uri, Map<FetchMethodChoice, CapturedPageState>> source, {
    required Map<Uri, Set<FetchMethodChoice>> capturingByUrl,
    String errorMessage = 'Capture was interrupted',
  }) {
    var changed = false;
    final result = <Uri, Map<FetchMethodChoice, CapturedPageState>>{};
    for (final urlEntry in source.entries) {
      final updated = <FetchMethodChoice, CapturedPageState>{};
      for (final methodEntry in urlEntry.value.entries) {
        if (methodEntry.value.status == CapturedPageStatus.capturing ||
            methodEntry.value.status == CapturedPageStatus.downloading) {
          updated[methodEntry.key] = methodEntry.value.copyWith(
            status: CapturedPageStatus.downloadFailed,
            errorMessage: errorMessage,
          );
          changed = true;
        } else {
          updated[methodEntry.key] = methodEntry.value;
        }
      }
      result[urlEntry.key] = updated;
    }
    // Synthesize entries for URLs/methods that were mid-capture but had no
    // CapturedPageState yet, so the busy chip is replaced by a red error
    // chip instead of vanishing silently.
    for (final entry in capturingByUrl.entries) {
      final url = entry.key;
      final bucket = result[url] ?? <FetchMethodChoice, CapturedPageState>{};
      var bucketChanged = false;
      for (final method in entry.value) {
        if (bucket.containsKey(method)) continue;
        bucket[method] = CapturedPageState(
          sourceUrl: url,
          status: CapturedPageStatus.downloadFailed,
          errorMessage: errorMessage,
        );
        bucketChanged = true;
      }
      if (bucketChanged) {
        result[url] = bucket;
        changed = true;
      }
    }
    if (!changed) return source;
    return result;
  }

  void reset() {
    unawaited(_closeActiveSession());
    ref.read(webSearchScrollOffsetProvider.notifier).reset();
    state = const MetaSearchState();
  }

  /// When the user has opted to route web search through Tor, ensure the
  /// Tor proxy is running and a SOCKS port is known before the search
  /// session is opened. Returns false if Tor could not be brought up.
  Future<bool> _ensureTorReadyIfRequested() async {
    final route = ref.read(webSearchSettingsControllerProvider).routeThroughTor;
    if (!route) return true;

    if (ref.read(searchProxyPortProvider) != null) return true;

    try {
      await ref.read(startProxyControllerProvider.notifier).startProxy();
    } catch (error, stackTrace) {
      ref
          .read(searchClientLoggerProvider)
          .e(
            'Failed to start Tor for search',
            error: error,
            stackTrace: stackTrace,
          );
      return false;
    }

    // startProxy() returns as soon as the Tor process has been launched, but
    // the SOCKS port only becomes usable once bootstrap reaches 100%.
    // Pushing the just-launched status into the stream synchronously is not
    // enough — at that point bootstrap is still near 0, so
    // searchProxyPortProvider stays null and the search fails even though
    // Tor is coming up fine. Wait for the status stream to report a fully
    // bootstrapped, running proxy before opening the search session.
    await ref.read(torProxyServiceProvider.notifier).requestSync();
    if (ref.read(searchProxyPortProvider) != null) return true;

    final completer = Completer<bool>();
    final subscription = ref.listen(torProxyServiceProvider, (previous, next) {
      if (next.isReady) {
        if (!completer.isCompleted) completer.complete(true);
      }
    });

    try {
      return await completer.future.timeout(
        const Duration(seconds: 90),
        onTimeout: () => false,
      );
    } finally {
      subscription.close();
    }
  }

  Future<void> _closeActiveSession() async {
    final sub = _sub;
    final session = _session;
    _sub = null;
    _session = null;
    await sub?.cancel();
    await session?.close();
  }

  void _handleMessage(StreamMessage message) {
    switch (message.type) {
      case MessageTypes.searchResults:
        _safeHandle('search results', () => _handleSearchResults(message.data));
      case MessageTypes.favicon:
        _safeHandle('favicon', () => _handleFavicon(message.data));
      case MessageTypes.image:
        _safeHandle('image', () => _handleImage(message.data));
      case MessageTypes.document:
        _safeHandle('document', () => _handleDocument(message.data));
      case MessageTypes.capture:
        _safeHandle('capture', () => _handleCapture(message.data));
      case MessageTypes.checkpoint:
        _handleCheckpoint(message.data);
      case MessageTypes.error:
        _handleStreamError(message.data);
      case MessageTypes.documentSnippets:
      case MessageTypes.answer:
      case MessageTypes.references:
      case MessageTypes.evidences:
        break;
    }
  }

  /// Wraps a frame decoder so a malformed payload doesn't tear down the
  /// whole socket — every frame handler used to duplicate this try/log/swallow
  /// block. Search-results frames get special-cased: if decoding fails
  /// mid-loadMore, the spinner needs to be cleared.
  void _safeHandle(String frameKind, void Function() body) {
    try {
      body();
    } catch (error, stackTrace) {
      if (frameKind == 'search results' && state.isLoadingMore) {
        state = state.copyWith(isLoadingMore: false);
      }
      ref
          .read(searchClientLoggerProvider)
          .w(
            'Failed to decode $frameKind frame',
            error: error,
            stackTrace: stackTrace,
          );
    }
  }

  void _handleSearchResults(Object payload) {
    final raw = payload as Map<String, dynamic>;
    final response = PagedSearchResponse.fromJson(raw);
    final isFirstPage = response.page == 0;
    state = state.copyWith(
      status: WebSearchStatus.ready,
      // Page 0 is authoritative for infos; later pages omit them.
      infos: isFirstPage ? response.infos : state.infos,
      // Page 0 replaces; later pages append. The backend dedupes pages
      // server-side (deliveredPages set), so duplicate appends are not
      // expected — but if one slips through it surfaces as duplicate
      // cards rather than crashing.
      results: isFirstPage
          ? response.results
          : [...state.results, ...response.results],
      currentPage: response.page,
      hasMore: response.hasMore,
      isLoadingMore: false,
      errorMessage: null,
    );
  }

  /// Request the next page of results from the active session. No-op if
  /// already loading, no more pages exist, or the session has closed.
  Future<void> loadNextPage() async {
    if (state.isLoadingMore || !state.hasMore) {
      return;
    }
    final session = _session;
    if (session == null || session.isClosed) {
      return;
    }

    final nextPage = state.currentPage + 1;
    state = state.copyWith(isLoadingMore: true);
    try {
      session.loadPage(nextPage);
    } catch (error, stackTrace) {
      ref
          .read(searchClientLoggerProvider)
          .e(
            'Failed to request next search page',
            error: error,
            stackTrace: stackTrace,
          );
      // Keep existing results visible; just let the UI try again. We do
      // NOT mark hasMore=false here — the failure may be transient (e.g.
      // a write to a closing socket) and clearing hasMore would
      // permanently hide the load-more affordance.
      state = state.copyWith(isLoadingMore: false);
    }
  }

  void _handleFavicon(Object payload) {
    final raw = payload as Map<String, dynamic>;
    final authority = raw['authority']?.toString();
    final bytes = raw['bytes']?.toString();
    if (authority == null || authority.isEmpty || bytes == null) {
      return;
    }

    final decodedBytes = base64Decode(bytes);

    final matchedResults = state.results.where(
      (r) => r.url.authority == authority,
    );

    final origins = <String>{};
    for (final result in matchedResults) {
      final origin = result.url.origin;
      if (origins.add(origin)) {
        unawaited(
          ref
              .read(genericWebsiteServiceProvider.notifier)
              .primeCachedIcon(result.url, decodedBytes),
        );
      }
    }
  }

  void _handleImage(Object payload) {
    final raw = payload as Map<String, dynamic>;
    final url = raw['url']?.toString();
    final bytes = raw['bytes']?.toString();
    if (url == null || url.isEmpty || bytes == null) {
      return;
    }

    state = state.copyWith(
      imagesByUrl: {...state.imagesByUrl, url: base64Decode(bytes)},
    );
  }

  void _handleDocument(Object payload) {
    final raw = payload as Map<String, dynamic>;
    final document = FetchedDocument.fromJson(raw);
    final nextFetching = {...state.fetchingUrls}..remove(document.url);
    final nextFetchErrors = {...state.fetchErrorByUrl}..remove(document.url);
    state = state.copyWith(
      documentsByUrl: {...state.documentsByUrl, document.url: document},
      fetchingUrls: nextFetching,
      fetchErrorByUrl: nextFetchErrors,
      errorMessage: null,
    );
  }

  void _handleCapture(Object payload) {
    final raw = payload as Map<String, dynamic>;
    final receipt = CaptureArtifactReceipt.fromJson(raw);
    final url = receipt.url;
    final choice = FetchMethodChoice.forCapture(
      method: receipt.method,
      variant: receipt.variant,
    );
    if (choice == null) {
      ref
          .read(searchClientLoggerProvider)
          .w(
            'Received capture for unknown method/variant: '
            '${receipt.method}/${receipt.variant}',
          );
      return;
    }

    final captured = CapturedPageState(
      sourceUrl: url,
      status: CapturedPageStatus.downloading,
      captureId: receipt.captureId,
      finalUrl: receipt.finalUrl,
      filename: receipt.filename,
      method: receipt.method,
      variant: receipt.variant,
      contentType: receipt.contentType,
      byteLength: receipt.byteLength,
      downloadToken: receipt.downloadToken,
    );
    state = state.copyWith(
      capturingByUrl: _withMethodRemoved(state.capturingByUrl, url, choice),
      capturedPagesByUrl: _withCaptureSet(
        state.capturedPagesByUrl,
        url,
        choice,
        captured,
      ),
    );
    unawaited(_downloadCapture(receipt, choice));
  }

  Future<void> _downloadCapture(
    CaptureArtifactReceipt receipt,
    FetchMethodChoice choice,
  ) async {
    final downloader = ref.read(captureArtifactDownloaderProvider);
    final url = receipt.url;
    try {
      final localPath = await downloader.download(receipt);
      if (_disposed) {
        return;
      }
      final current = state.capturedPage(url, choice);
      if (current == null || current.captureId != receipt.captureId) {
        return;
      }
      state = state.copyWith(
        capturedPagesByUrl: _withCaptureSet(
          state.capturedPagesByUrl,
          url,
          choice,
          current.copyWith(
            status: CapturedPageStatus.ready,
            localPath: localPath,
            errorMessage: null,
          ),
        ),
      );
    } catch (error, stackTrace) {
      if (_disposed) {
        return;
      }
      ref
          .read(searchClientLoggerProvider)
          .w(
            'Failed to download capture artifact',
            error: error,
            stackTrace: stackTrace,
          );
      final current = state.capturedPage(url, choice);
      if (current == null || current.captureId != receipt.captureId) {
        return;
      }
      state = state.copyWith(
        capturedPagesByUrl: _withCaptureSet(
          state.capturedPagesByUrl,
          url,
          choice,
          current.copyWith(
            status: CapturedPageStatus.downloadFailed,
            errorMessage: error.toString(),
          ),
        ),
      );
    }
  }

  Future<void> retryCaptureDownload(Uri url, FetchMethodChoice choice) async {
    final current = state.capturedPage(url, choice);
    if (current == null ||
        current.captureId == null ||
        current.downloadToken == null) {
      return;
    }
    if (current.status != CapturedPageStatus.downloadFailed) {
      return;
    }

    state = state.copyWith(
      capturedPagesByUrl: _withCaptureSet(
        state.capturedPagesByUrl,
        url,
        choice,
        current.copyWith(
          status: CapturedPageStatus.downloading,
          errorMessage: null,
        ),
      ),
    );

    await _downloadCapture(
      CaptureArtifactReceipt(
        captureId: current.captureId!,
        url: url,
        method: current.method!,
        variant: current.variant!,
        contentType: current.contentType!,
        byteLength: current.byteLength ?? 0,
        downloadToken: current.downloadToken!,
        filename: current.filename,
        finalUrl: current.finalUrl,
      ),
      choice,
    );
  }

  void _handleCheckpoint(Object payload) {
    if (payload is! Map<String, dynamic>) {
      return;
    }

    final urlString = payload['url']?.toString();
    final checkpointName = payload['checkpoint']?.toString();
    final url = urlString == null ? null : Uri.tryParse(urlString);
    if (url == null || checkpointName == null) {
      return;
    }

    // `captureStarted`/`captureFinished` are intentionally ignored: the
    // checkpoint payload does not carry method/variant info, so per-method
    // capture state is driven instead by capturePage() / the capture frame.
    switch (checkpointName) {
      case 'documentFetchStarted':
        state = state.copyWith(fetchingUrls: {...state.fetchingUrls, url});
      case 'documentFetchFinished':
        state = state.copyWith(
          fetchingUrls: {...state.fetchingUrls}..remove(url),
        );
    }
  }

  static String _closeCodeUserMessage(int code) {
    return switch (code) {
      4001 => 'Search session timed out. Please try again.',
      4401 =>
        'Your search credit could not be validated. '
            'The credit may have been spent — please try again.',
      4403 => 'The requested page is not permitted by the search policy.',
      4500 => 'The search failed on the server. Please try again.',
      _ =>
        'Search connection closed unexpectedly (code $code). '
            'Please try again.',
    };
  }

  /// Translate a backend error `code` (see search_handler.dart on the server
  /// for the full set: `protocol_error`, `search_failed`, `fetch_failed`,
  /// `fetch_not_allowed`, `capture_failed`, `document_extract_failed`) into
  /// a user-facing message. The raw server `detail` is appended so the
  /// detail dialog has something specific to show.
  static String _userMessageForStreamError(String? code, String detail) {
    final fallbackDetail = detail.isEmpty ? 'unknown error' : detail;
    return switch (code) {
      'protocol_error' =>
        'Search protocol error. The session has ended — please try '
            'again. ($fallbackDetail)',
      'search_failed' =>
        'The search failed on the server. Please try again. '
            '($fallbackDetail)',
      'fetch_failed' =>
        'Could not fetch this page from the source. ($fallbackDetail)',
      'document_extract_failed' =>
        'Could not extract a readable preview from this page. '
            '($fallbackDetail)',
      'fetch_not_allowed' =>
        'This page is not permitted by the search policy. '
            '($fallbackDetail)',
      'capture_failed' => 'Page capture failed. ($fallbackDetail)',
      _ => 'Search error: $fallbackDetail',
    };
  }

  /// True for codes that always tear down the WebSocket on the server side
  /// (a close frame follows). These can never be per-URL recoverable, so we
  /// fold them into a session-fatal error path even when a `url` is present
  /// in the payload (which can happen for `fetch_not_allowed`).
  static bool _isSessionFatalCode(String? code) {
    return code == 'protocol_error' || code == 'search_failed';
  }

  void _handleStreamError(Object payload) {
    final map = payload is Map<String, dynamic> ? payload : null;
    final code = map?['code']?.toString();
    final detail = map?['message']?.toString() ?? payload.toString();
    final urlString = map?['url']?.toString();
    final explicitUrl = urlString != null ? Uri.tryParse(urlString) : null;
    final message = _userMessageForStreamError(code, detail);

    ref
        .read(searchClientLoggerProvider)
        .w(
          'Search stream error frame: code=$code, url=$urlString, '
          'detail=$detail',
        );

    if (_isSessionFatalCode(code)) {
      _applyError(message, sessionClosed: true);
      return;
    }

    if (explicitUrl != null) {
      _applyPerUrlError(explicitUrl, code, message);
      return;
    }

    if (state.fetchingUrls.isNotEmpty ||
        state.capturingByUrl.isNotEmpty ||
        state.results.isNotEmpty) {
      final inferredUrl = _singleBusyUrlOrNull();
      if (inferredUrl != null) {
        _applyPerUrlError(inferredUrl, code, message);
        return;
      }
      _applyError(message, failedFetchUrl: null);
      return;
    }

    _applyError(message, sessionClosed: true);
  }

  /// Route an error frame that names (or can be inferred to belong to) a
  /// single URL into per-URL state: clear that URL's in-flight bookkeeping,
  /// stamp `fetchErrorByUrl` for the trafilatura preview path, and convert
  /// any in-progress capture for the same URL into a `downloadFailed`
  /// CapturedPageState carrying the same message. The session itself is
  /// preserved (search results stay visible) for non-fatal codes.
  void _applyPerUrlError(Uri url, String? code, String message) {
    final nextFetching = {...state.fetchingUrls}..remove(url);
    final capturingForUrl =
        state.capturingByUrl[url] ?? const <FetchMethodChoice>{};
    final nextCapturing = {
      for (final entry in state.capturingByUrl.entries)
        entry.key: {...entry.value},
    }..remove(url);

    final nextCapturedPages = _failInProgressCapturesForUrl(
      state.capturedPagesByUrl,
      url,
      capturingMethods: capturingForUrl,
      errorMessage: message,
    );

    // Trafilatura ("Preview") doesn't have a CapturedPageState entry to hold
    // an error; keep its failure on a side map so the chip can render red
    // and a tap can pop the detail dialog.
    final nextFetchErrors = {...state.fetchErrorByUrl, url: message};

    final nextStatus = state.results.isEmpty
        ? WebSearchStatus.error
        : WebSearchStatus.ready;

    state = state.copyWith(
      status: nextStatus,
      fetchingUrls: nextFetching,
      capturingByUrl: nextCapturing,
      capturedPagesByUrl: nextCapturedPages,
      fetchErrorByUrl: nextFetchErrors,
      errorMessage: message,
    );
  }

  Uri? _singleBusyUrlOrNull() {
    final allBusy = {...state.fetchingUrls, ...state.capturingByUrl.keys};
    if (allBusy.length == 1) {
      return allBusy.first;
    }
    return null;
  }

  void _applyError(
    String message, {
    Uri? failedFetchUrl,
    bool sessionClosed = false,
  }) {
    final nextFetching = {...state.fetchingUrls};
    var nextCapturing = {
      for (final entry in state.capturingByUrl.entries)
        entry.key: {...entry.value},
    };
    Map<Uri, Map<FetchMethodChoice, CapturedPageState>> nextCapturedPages =
        state.capturedPagesByUrl;
    if (failedFetchUrl != null) {
      final capturingForUrl =
          state.capturingByUrl[failedFetchUrl] ?? const <FetchMethodChoice>{};
      nextFetching.remove(failedFetchUrl);
      nextCapturing.remove(failedFetchUrl);
      nextCapturedPages = _failInProgressCapturesForUrl(
        nextCapturedPages,
        failedFetchUrl,
        capturingMethods: capturingForUrl,
        errorMessage: message,
      );
    } else if (state.results.isNotEmpty ||
        nextFetching.isNotEmpty ||
        nextCapturing.isNotEmpty) {
      nextFetching.clear();
      final priorCapturing = nextCapturing;
      nextCapturing = {};
      nextCapturedPages = _failAllInProgressCaptures(
        nextCapturedPages,
        capturingByUrl: priorCapturing,
        errorMessage: message,
      );
    }

    final nextStatus = state.results.isEmpty
        ? WebSearchStatus.error
        : WebSearchStatus.ready;

    state = state.copyWith(
      status: nextStatus,
      fetchingUrls: nextFetching,
      capturingByUrl: nextCapturing,
      capturedPagesByUrl: nextCapturedPages,
      errorMessage: message,
      hasOpenSession: !sessionClosed && state.hasOpenSession,
      // A non-URL session error during loadPage (e.g. page_out_of_range,
      // protocol_error) leaves the loadMore spinner stuck otherwise.
      isLoadingMore: false,
    );
  }
}

/// Persisted vertical scroll offset of the web-search results list. Kept
/// alive (like [MetaSearchController]) so returning to the search screen
/// after opening a result restores the user's place instead of jumping
/// back to the top. Reset to 0 on every fresh submit and on reset().
@Riverpod(keepAlive: true)
class WebSearchScrollOffset extends _$WebSearchScrollOffset {
  @override
  double build() => 0;

  void update(double offset) {
    if (state == offset) return;
    state = offset;
  }

  void reset() => state = 0;
}
