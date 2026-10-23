// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'empty_state_content.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(searchEmptyHistoryHighlights)
final searchEmptyHistoryHighlightsProvider =
    SearchEmptyHistoryHighlightsFamily._();

final class SearchEmptyHistoryHighlightsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<HistoryHighlight>>,
          List<HistoryHighlight>,
          FutureOr<List<HistoryHighlight>>
        >
    with
        $FutureModifier<List<HistoryHighlight>>,
        $FutureProvider<List<HistoryHighlight>> {
  SearchEmptyHistoryHighlightsProvider._({
    required SearchEmptyHistoryHighlightsFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'searchEmptyHistoryHighlightsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$searchEmptyHistoryHighlightsHash();

  @override
  String toString() {
    return r'searchEmptyHistoryHighlightsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<HistoryHighlight>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<HistoryHighlight>> create(Ref ref) {
    final argument = this.argument as int;
    return searchEmptyHistoryHighlights(ref, count: argument);
  }

  @override
  bool operator ==(Object other) {
    return other is SearchEmptyHistoryHighlightsProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$searchEmptyHistoryHighlightsHash() =>
    r'f12206cb05c5c03ecdc2b84e3ffd20706aa4c986';

final class SearchEmptyHistoryHighlightsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<HistoryHighlight>>, int> {
  SearchEmptyHistoryHighlightsFamily._()
    : super(
        retry: null,
        name: r'searchEmptyHistoryHighlightsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  SearchEmptyHistoryHighlightsProvider call({int count = 25}) =>
      SearchEmptyHistoryHighlightsProvider._(argument: count, from: this);

  @override
  String toString() => r'searchEmptyHistoryHighlightsProvider';
}

@ProviderFor(searchEmptyRecentHistory)
final searchEmptyRecentHistoryProvider = SearchEmptyRecentHistoryFamily._();

final class SearchEmptyRecentHistoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<VisitInfo>>,
          List<VisitInfo>,
          FutureOr<List<VisitInfo>>
        >
    with $FutureModifier<List<VisitInfo>>, $FutureProvider<List<VisitInfo>> {
  SearchEmptyRecentHistoryProvider._({
    required SearchEmptyRecentHistoryFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'searchEmptyRecentHistoryProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$searchEmptyRecentHistoryHash();

  @override
  String toString() {
    return r'searchEmptyRecentHistoryProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<VisitInfo>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<VisitInfo>> create(Ref ref) {
    final argument = this.argument as int;
    return searchEmptyRecentHistory(ref, count: argument);
  }

  @override
  bool operator ==(Object other) {
    return other is SearchEmptyRecentHistoryProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$searchEmptyRecentHistoryHash() =>
    r'bd7b9a67edfb1751d6d5cf6a8392516911796cb0';

final class SearchEmptyRecentHistoryFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<VisitInfo>>, int> {
  SearchEmptyRecentHistoryFamily._()
    : super(
        retry: null,
        name: r'searchEmptyRecentHistoryProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  SearchEmptyRecentHistoryProvider call({int count = 25}) =>
      SearchEmptyRecentHistoryProvider._(argument: count, from: this);

  @override
  String toString() => r'searchEmptyRecentHistoryProvider';
}

@ProviderFor(searchEmptyRecentFeedArticles)
final searchEmptyRecentFeedArticlesProvider =
    SearchEmptyRecentFeedArticlesFamily._();

final class SearchEmptyRecentFeedArticlesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<FeedArticleSummary>>,
          AsyncValue<List<FeedArticleSummary>>,
          AsyncValue<List<FeedArticleSummary>>
        >
    with $Provider<AsyncValue<List<FeedArticleSummary>>> {
  SearchEmptyRecentFeedArticlesProvider._({
    required SearchEmptyRecentFeedArticlesFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'searchEmptyRecentFeedArticlesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$searchEmptyRecentFeedArticlesHash();

  @override
  String toString() {
    return r'searchEmptyRecentFeedArticlesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<AsyncValue<List<FeedArticleSummary>>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AsyncValue<List<FeedArticleSummary>> create(Ref ref) {
    final argument = this.argument as int;
    return searchEmptyRecentFeedArticles(ref, count: argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<List<FeedArticleSummary>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride:
          $SyncValueProvider<AsyncValue<List<FeedArticleSummary>>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is SearchEmptyRecentFeedArticlesProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$searchEmptyRecentFeedArticlesHash() =>
    r'148792eb7469774f1734461540183bd1173801d3';

final class SearchEmptyRecentFeedArticlesFamily extends $Family
    with $FunctionalFamilyOverride<AsyncValue<List<FeedArticleSummary>>, int> {
  SearchEmptyRecentFeedArticlesFamily._()
    : super(
        retry: null,
        name: r'searchEmptyRecentFeedArticlesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  SearchEmptyRecentFeedArticlesProvider call({int count = 25}) =>
      SearchEmptyRecentFeedArticlesProvider._(argument: count, from: this);

  @override
  String toString() => r'searchEmptyRecentFeedArticlesProvider';
}

@ProviderFor(searchEmptyRecentTabs)
final searchEmptyRecentTabsProvider = SearchEmptyRecentTabsFamily._();

final class SearchEmptyRecentTabsProvider
    extends
        $FunctionalProvider<
          List<TabStateWithContainer>,
          List<TabStateWithContainer>,
          List<TabStateWithContainer>
        >
    with $Provider<List<TabStateWithContainer>> {
  SearchEmptyRecentTabsProvider._({
    required SearchEmptyRecentTabsFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'searchEmptyRecentTabsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$searchEmptyRecentTabsHash();

  @override
  String toString() {
    return r'searchEmptyRecentTabsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<List<TabStateWithContainer>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  List<TabStateWithContainer> create(Ref ref) {
    final argument = this.argument as int;
    return searchEmptyRecentTabs(ref, count: argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<TabStateWithContainer> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<TabStateWithContainer>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is SearchEmptyRecentTabsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$searchEmptyRecentTabsHash() =>
    r'6000970dd261f243326900555967956508b84660';

final class SearchEmptyRecentTabsFamily extends $Family
    with $FunctionalFamilyOverride<List<TabStateWithContainer>, int> {
  SearchEmptyRecentTabsFamily._()
    : super(
        retry: null,
        name: r'searchEmptyRecentTabsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  SearchEmptyRecentTabsProvider call({int count = 25}) =>
      SearchEmptyRecentTabsProvider._(argument: count, from: this);

  @override
  String toString() => r'searchEmptyRecentTabsProvider';
}

/// Whether every visible module on [surface] that loads its content
/// asynchronously has received its first value.
///
/// Those modules either hide while their list is empty (recent history,
/// highlights, articles, recent tabs) or change height once their content lands
/// (shortcuts, quote). Home centres its content as one block, so each late
/// arrival shifted the whole page a few frames after it first showed (#665).
/// Its host holds the page back until this is true. An error counts as
/// settled, since waiting will not resolve it.
///
/// Watching the module providers here keeps them alive alongside the modules'
/// own subscriptions; the arguments must match the modules' exactly, or this
/// would wait on a separate query.

@ProviderFor(moduleSurfaceSettled)
final moduleSurfaceSettledProvider = ModuleSurfaceSettledFamily._();

/// Whether every visible module on [surface] that loads its content
/// asynchronously has received its first value.
///
/// Those modules either hide while their list is empty (recent history,
/// highlights, articles, recent tabs) or change height once their content lands
/// (shortcuts, quote). Home centres its content as one block, so each late
/// arrival shifted the whole page a few frames after it first showed (#665).
/// Its host holds the page back until this is true. An error counts as
/// settled, since waiting will not resolve it.
///
/// Watching the module providers here keeps them alive alongside the modules'
/// own subscriptions; the arguments must match the modules' exactly, or this
/// would wait on a separate query.

final class ModuleSurfaceSettledProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Whether every visible module on [surface] that loads its content
  /// asynchronously has received its first value.
  ///
  /// Those modules either hide while their list is empty (recent history,
  /// highlights, articles, recent tabs) or change height once their content lands
  /// (shortcuts, quote). Home centres its content as one block, so each late
  /// arrival shifted the whole page a few frames after it first showed (#665).
  /// Its host holds the page back until this is true. An error counts as
  /// settled, since waiting will not resolve it.
  ///
  /// Watching the module providers here keeps them alive alongside the modules'
  /// own subscriptions; the arguments must match the modules' exactly, or this
  /// would wait on a separate query.
  ModuleSurfaceSettledProvider._({
    required ModuleSurfaceSettledFamily super.from,
    required ModuleSurface super.argument,
  }) : super(
         retry: null,
         name: r'moduleSurfaceSettledProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$moduleSurfaceSettledHash();

  @override
  String toString() {
    return r'moduleSurfaceSettledProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    final argument = this.argument as ModuleSurface;
    return moduleSurfaceSettled(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ModuleSurfaceSettledProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$moduleSurfaceSettledHash() =>
    r'93dcf6195fe13ea80f9fee155fcb41894ef4a1ed';

/// Whether every visible module on [surface] that loads its content
/// asynchronously has received its first value.
///
/// Those modules either hide while their list is empty (recent history,
/// highlights, articles, recent tabs) or change height once their content lands
/// (shortcuts, quote). Home centres its content as one block, so each late
/// arrival shifted the whole page a few frames after it first showed (#665).
/// Its host holds the page back until this is true. An error counts as
/// settled, since waiting will not resolve it.
///
/// Watching the module providers here keeps them alive alongside the modules'
/// own subscriptions; the arguments must match the modules' exactly, or this
/// would wait on a separate query.

final class ModuleSurfaceSettledFamily extends $Family
    with $FunctionalFamilyOverride<bool, ModuleSurface> {
  ModuleSurfaceSettledFamily._()
    : super(
        retry: null,
        name: r'moduleSurfaceSettledProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Whether every visible module on [surface] that loads its content
  /// asynchronously has received its first value.
  ///
  /// Those modules either hide while their list is empty (recent history,
  /// highlights, articles, recent tabs) or change height once their content lands
  /// (shortcuts, quote). Home centres its content as one block, so each late
  /// arrival shifted the whole page a few frames after it first showed (#665).
  /// Its host holds the page back until this is true. An error counts as
  /// settled, since waiting will not resolve it.
  ///
  /// Watching the module providers here keeps them alive alongside the modules'
  /// own subscriptions; the arguments must match the modules' exactly, or this
  /// would wait on a separate query.

  ModuleSurfaceSettledProvider call(ModuleSurface surface) =>
      ModuleSurfaceSettledProvider._(argument: surface, from: this);

  @override
  String toString() => r'moduleSurfaceSettledProvider';
}
