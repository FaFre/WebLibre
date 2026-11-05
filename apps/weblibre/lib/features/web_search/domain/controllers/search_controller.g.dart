// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_controller.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$MetaSearchStateCWProxy {
  MetaSearchState status(WebSearchStatus status);

  MetaSearchState query(String query);

  MetaSearchState infos(List<CompactInfobox> infos);

  MetaSearchState results(List<CompactSearchResult> results);

  MetaSearchState imagesByUrl(Map<String, Uint8List> imagesByUrl);

  MetaSearchState documentsByUrl(Map<Uri, FetchedDocument> documentsByUrl);

  MetaSearchState fetchingUrls(Set<Uri> fetchingUrls);

  MetaSearchState capturingByUrl(
    Map<Uri, Set<FetchMethodChoice>> capturingByUrl,
  );

  MetaSearchState capturedPagesByUrl(
    Map<Uri, Map<FetchMethodChoice, CapturedPageState>> capturedPagesByUrl,
  );

  MetaSearchState fetchErrorByUrl(Map<Uri, String> fetchErrorByUrl);

  MetaSearchState errorMessage(String? errorMessage);

  MetaSearchState hasOpenSession(bool hasOpenSession);

  MetaSearchState currentPage(int currentPage);

  MetaSearchState hasMore(bool hasMore);

  MetaSearchState isLoadingMore(bool isLoadingMore);

  /// Creates a new instance with the provided field values.
  /// Omitted fields keep their values; explicit `null` clears nullable fields.
  /// The public API rejects `null` for non-nullable fields. To update a single field use `MetaSearchState(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// MetaSearchState(...).copyWith(id: 12, name: "My name")
  /// ```
  MetaSearchState call({
    WebSearchStatus status,
    String query,
    List<CompactInfobox> infos,
    List<CompactSearchResult> results,
    Map<String, Uint8List> imagesByUrl,
    Map<Uri, FetchedDocument> documentsByUrl,
    Set<Uri> fetchingUrls,
    Map<Uri, Set<FetchMethodChoice>> capturingByUrl,
    Map<Uri, Map<FetchMethodChoice, CapturedPageState>> capturedPagesByUrl,
    Map<Uri, String> fetchErrorByUrl,
    String? errorMessage,
    bool hasOpenSession,
    int currentPage,
    bool hasMore,
    bool isLoadingMore,
  });
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfMetaSearchState.copyWith(...)` or call `instanceOfMetaSearchState.copyWith.fieldName(value)` for a single field.
class _$MetaSearchStateCWProxyImpl implements _$MetaSearchStateCWProxy {
  const _$MetaSearchStateCWProxyImpl(this._value);

  final MetaSearchState _value;

  @override
  MetaSearchState status(WebSearchStatus status) => call(status: status);

  @override
  MetaSearchState query(String query) => call(query: query);

  @override
  MetaSearchState infos(List<CompactInfobox> infos) => call(infos: infos);

  @override
  MetaSearchState results(List<CompactSearchResult> results) =>
      call(results: results);

  @override
  MetaSearchState imagesByUrl(Map<String, Uint8List> imagesByUrl) =>
      call(imagesByUrl: imagesByUrl);

  @override
  MetaSearchState documentsByUrl(Map<Uri, FetchedDocument> documentsByUrl) =>
      call(documentsByUrl: documentsByUrl);

  @override
  MetaSearchState fetchingUrls(Set<Uri> fetchingUrls) =>
      call(fetchingUrls: fetchingUrls);

  @override
  MetaSearchState capturingByUrl(
    Map<Uri, Set<FetchMethodChoice>> capturingByUrl,
  ) => call(capturingByUrl: capturingByUrl);

  @override
  MetaSearchState capturedPagesByUrl(
    Map<Uri, Map<FetchMethodChoice, CapturedPageState>> capturedPagesByUrl,
  ) => call(capturedPagesByUrl: capturedPagesByUrl);

  @override
  MetaSearchState fetchErrorByUrl(Map<Uri, String> fetchErrorByUrl) =>
      call(fetchErrorByUrl: fetchErrorByUrl);

  @override
  MetaSearchState errorMessage(String? errorMessage) =>
      call(errorMessage: errorMessage);

  @override
  MetaSearchState hasOpenSession(bool hasOpenSession) =>
      call(hasOpenSession: hasOpenSession);

  @override
  MetaSearchState currentPage(int currentPage) =>
      call(currentPage: currentPage);

  @override
  MetaSearchState hasMore(bool hasMore) => call(hasMore: hasMore);

  @override
  MetaSearchState isLoadingMore(bool isLoadingMore) =>
      call(isLoadingMore: isLoadingMore);

  /// Creates a new instance with the provided field values.
  /// Omitted fields keep their values; explicit `null` clears nullable fields.
  /// The public API rejects `null` for non-nullable fields. To update a single field use `MetaSearchState(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// MetaSearchState(...).copyWith(id: 12, name: "My name")
  /// ```
  @override
  MetaSearchState call({
    Object? status = const $CopyWithPlaceholder(),
    Object? query = const $CopyWithPlaceholder(),
    Object? infos = const $CopyWithPlaceholder(),
    Object? results = const $CopyWithPlaceholder(),
    Object? imagesByUrl = const $CopyWithPlaceholder(),
    Object? documentsByUrl = const $CopyWithPlaceholder(),
    Object? fetchingUrls = const $CopyWithPlaceholder(),
    Object? capturingByUrl = const $CopyWithPlaceholder(),
    Object? capturedPagesByUrl = const $CopyWithPlaceholder(),
    Object? fetchErrorByUrl = const $CopyWithPlaceholder(),
    Object? errorMessage = const $CopyWithPlaceholder(),
    Object? hasOpenSession = const $CopyWithPlaceholder(),
    Object? currentPage = const $CopyWithPlaceholder(),
    Object? hasMore = const $CopyWithPlaceholder(),
    Object? isLoadingMore = const $CopyWithPlaceholder(),
  }) {
    return MetaSearchState(
      status: status == const $CopyWithPlaceholder() || status == null
          ? _value.status
          // ignore: cast_nullable_to_non_nullable
          : status as WebSearchStatus,
      query: query == const $CopyWithPlaceholder() || query == null
          ? _value.query
          // ignore: cast_nullable_to_non_nullable
          : query as String,
      infos: infos == const $CopyWithPlaceholder() || infos == null
          ? _value.infos
          // ignore: cast_nullable_to_non_nullable
          : infos as List<CompactInfobox>,
      results: results == const $CopyWithPlaceholder() || results == null
          ? _value.results
          // ignore: cast_nullable_to_non_nullable
          : results as List<CompactSearchResult>,
      imagesByUrl:
          imagesByUrl == const $CopyWithPlaceholder() || imagesByUrl == null
          ? _value.imagesByUrl
          // ignore: cast_nullable_to_non_nullable
          : imagesByUrl as Map<String, Uint8List>,
      documentsByUrl:
          documentsByUrl == const $CopyWithPlaceholder() ||
              documentsByUrl == null
          ? _value.documentsByUrl
          // ignore: cast_nullable_to_non_nullable
          : documentsByUrl as Map<Uri, FetchedDocument>,
      fetchingUrls:
          fetchingUrls == const $CopyWithPlaceholder() || fetchingUrls == null
          ? _value.fetchingUrls
          // ignore: cast_nullable_to_non_nullable
          : fetchingUrls as Set<Uri>,
      capturingByUrl:
          capturingByUrl == const $CopyWithPlaceholder() ||
              capturingByUrl == null
          ? _value.capturingByUrl
          // ignore: cast_nullable_to_non_nullable
          : capturingByUrl as Map<Uri, Set<FetchMethodChoice>>,
      capturedPagesByUrl:
          capturedPagesByUrl == const $CopyWithPlaceholder() ||
              capturedPagesByUrl == null
          ? _value.capturedPagesByUrl
          // ignore: cast_nullable_to_non_nullable
          : capturedPagesByUrl
                as Map<Uri, Map<FetchMethodChoice, CapturedPageState>>,
      fetchErrorByUrl:
          fetchErrorByUrl == const $CopyWithPlaceholder() ||
              fetchErrorByUrl == null
          ? _value.fetchErrorByUrl
          // ignore: cast_nullable_to_non_nullable
          : fetchErrorByUrl as Map<Uri, String>,
      errorMessage: errorMessage == const $CopyWithPlaceholder()
          ? _value.errorMessage
          // ignore: cast_nullable_to_non_nullable
          : errorMessage as String?,
      hasOpenSession:
          hasOpenSession == const $CopyWithPlaceholder() ||
              hasOpenSession == null
          ? _value.hasOpenSession
          // ignore: cast_nullable_to_non_nullable
          : hasOpenSession as bool,
      currentPage:
          currentPage == const $CopyWithPlaceholder() || currentPage == null
          ? _value.currentPage
          // ignore: cast_nullable_to_non_nullable
          : currentPage as int,
      hasMore: hasMore == const $CopyWithPlaceholder() || hasMore == null
          ? _value.hasMore
          // ignore: cast_nullable_to_non_nullable
          : hasMore as bool,
      isLoadingMore:
          isLoadingMore == const $CopyWithPlaceholder() || isLoadingMore == null
          ? _value.isLoadingMore
          // ignore: cast_nullable_to_non_nullable
          : isLoadingMore as bool,
    );
  }
}

extension $MetaSearchStateCopyWith on MetaSearchState {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfMetaSearchState.copyWith(...)` or `instanceOfMetaSearchState.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$MetaSearchStateCWProxy get copyWith => _$MetaSearchStateCWProxyImpl(this);
}

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(MetaSearchController)
final metaSearchControllerProvider = MetaSearchControllerProvider._();

final class MetaSearchControllerProvider
    extends $NotifierProvider<MetaSearchController, MetaSearchState> {
  MetaSearchControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'metaSearchControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$metaSearchControllerHash();

  @$internal
  @override
  MetaSearchController create() => MetaSearchController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MetaSearchState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MetaSearchState>(value),
    );
  }
}

String _$metaSearchControllerHash() =>
    r'82b6564c0815960c24640deba5102cc7e2acde64';

abstract class _$MetaSearchController extends $Notifier<MetaSearchState> {
  MetaSearchState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<MetaSearchState, MetaSearchState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<MetaSearchState, MetaSearchState>,
              MetaSearchState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Persisted vertical scroll offset of the web-search results list. Kept
/// alive (like [MetaSearchController]) so returning to the search screen
/// after opening a result restores the user's place instead of jumping
/// back to the top. Reset to 0 on every fresh submit and on reset().

@ProviderFor(WebSearchScrollOffset)
final webSearchScrollOffsetProvider = WebSearchScrollOffsetProvider._();

/// Persisted vertical scroll offset of the web-search results list. Kept
/// alive (like [MetaSearchController]) so returning to the search screen
/// after opening a result restores the user's place instead of jumping
/// back to the top. Reset to 0 on every fresh submit and on reset().
final class WebSearchScrollOffsetProvider
    extends $NotifierProvider<WebSearchScrollOffset, double> {
  /// Persisted vertical scroll offset of the web-search results list. Kept
  /// alive (like [MetaSearchController]) so returning to the search screen
  /// after opening a result restores the user's place instead of jumping
  /// back to the top. Reset to 0 on every fresh submit and on reset().
  WebSearchScrollOffsetProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'webSearchScrollOffsetProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$webSearchScrollOffsetHash();

  @$internal
  @override
  WebSearchScrollOffset create() => WebSearchScrollOffset();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(double value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<double>(value),
    );
  }
}

String _$webSearchScrollOffsetHash() =>
    r'404573c2e5e52a0f260d182b7947f4878df45820';

/// Persisted vertical scroll offset of the web-search results list. Kept
/// alive (like [MetaSearchController]) so returning to the search screen
/// after opening a result restores the user's place instead of jumping
/// back to the top. Reset to 0 on every fresh submit and on reset().

abstract class _$WebSearchScrollOffset extends $Notifier<double> {
  double build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<double, double>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<double, double>,
              double,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
