// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_controller.dart';

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
    r'eea46b9be86f50fb1bfcbe89fd77a68c8f2233e0';

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
