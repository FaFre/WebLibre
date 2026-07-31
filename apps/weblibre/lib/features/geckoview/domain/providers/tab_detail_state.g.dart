// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tab_detail_state.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Load progress (0-100) per tab. Ticks continuously while a page loads.

@ProviderFor(TabProgressStates)
final tabProgressStatesProvider = TabProgressStatesProvider._();

/// Load progress (0-100) per tab. Ticks continuously while a page loads.
final class TabProgressStatesProvider
    extends $NotifierProvider<TabProgressStates, Map<String, int>> {
  /// Load progress (0-100) per tab. Ticks continuously while a page loads.
  TabProgressStatesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tabProgressStatesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tabProgressStatesHash();

  @$internal
  @override
  TabProgressStates create() => TabProgressStates();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<String, int> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<String, int>>(value),
    );
  }
}

String _$tabProgressStatesHash() => r'60bb03e33e4322eb2869b90b5cc5802d3cdc225d';

/// Load progress (0-100) per tab. Ticks continuously while a page loads.

abstract class _$TabProgressStates extends $Notifier<Map<String, int>> {
  Map<String, int> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<Map<String, int>, Map<String, int>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Map<String, int>, Map<String, int>>,
              Map<String, int>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(tabProgress)
final tabProgressProvider = TabProgressFamily._();

final class TabProgressProvider extends $FunctionalProvider<int, int, int>
    with $Provider<int> {
  TabProgressProvider._({
    required TabProgressFamily super.from,
    required String? super.argument,
  }) : super(
         retry: null,
         name: r'tabProgressProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$tabProgressHash();

  @override
  String toString() {
    return r'tabProgressProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<int> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  int create(Ref ref) {
    final argument = this.argument as String?;
    return tabProgress(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is TabProgressProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$tabProgressHash() => r'83c4990d96f2160e919ee99882905c09872e8bb7';

final class TabProgressFamily extends $Family
    with $FunctionalFamilyOverride<int, String?> {
  TabProgressFamily._()
    : super(
        retry: null,
        name: r'tabProgressProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  TabProgressProvider call(String? tabId) =>
      TabProgressProvider._(argument: tabId, from: this);

  @override
  String toString() => r'tabProgressProvider';
}

/// Page screenshots per tab. Refreshed on a 10s timer for the selected tab and
/// consumed only by the tab tray previews.

@ProviderFor(TabThumbnails)
final tabThumbnailsProvider = TabThumbnailsProvider._();

/// Page screenshots per tab. Refreshed on a 10s timer for the selected tab and
/// consumed only by the tab tray previews.
final class TabThumbnailsProvider
    extends $NotifierProvider<TabThumbnails, Map<String, EquatableImage>> {
  /// Page screenshots per tab. Refreshed on a 10s timer for the selected tab and
  /// consumed only by the tab tray previews.
  TabThumbnailsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tabThumbnailsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tabThumbnailsHash();

  @$internal
  @override
  TabThumbnails create() => TabThumbnails();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<String, EquatableImage> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<String, EquatableImage>>(value),
    );
  }
}

String _$tabThumbnailsHash() => r'16c4bb6edff2e6413100d9ce02c1ae7948740cfe';

/// Page screenshots per tab. Refreshed on a 10s timer for the selected tab and
/// consumed only by the tab tray previews.

abstract class _$TabThumbnails extends $Notifier<Map<String, EquatableImage>> {
  Map<String, EquatableImage> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<Map<String, EquatableImage>, Map<String, EquatableImage>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                Map<String, EquatableImage>,
                Map<String, EquatableImage>
              >,
              Map<String, EquatableImage>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(tabThumbnail)
final tabThumbnailProvider = TabThumbnailFamily._();

final class TabThumbnailProvider
    extends
        $FunctionalProvider<EquatableImage?, EquatableImage?, EquatableImage?>
    with $Provider<EquatableImage?> {
  TabThumbnailProvider._({
    required TabThumbnailFamily super.from,
    required String? super.argument,
  }) : super(
         retry: null,
         name: r'tabThumbnailProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$tabThumbnailHash();

  @override
  String toString() {
    return r'tabThumbnailProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<EquatableImage?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  EquatableImage? create(Ref ref) {
    final argument = this.argument as String?;
    return tabThumbnail(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(EquatableImage? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<EquatableImage?>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is TabThumbnailProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$tabThumbnailHash() => r'7c8b591abdb5e8cc914ab8e44247a4bca6bddd15';

final class TabThumbnailFamily extends $Family
    with $FunctionalFamilyOverride<EquatableImage?, String?> {
  TabThumbnailFamily._()
    : super(
        retry: null,
        name: r'tabThumbnailProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  TabThumbnailProvider call(String? tabId) =>
      TabThumbnailProvider._(argument: tabId, from: this);

  @override
  String toString() => r'tabThumbnailProvider';
}

/// Session history (back/forward stack) per tab.

@ProviderFor(TabHistoryStates)
final tabHistoryStatesProvider = TabHistoryStatesProvider._();

/// Session history (back/forward stack) per tab.
final class TabHistoryStatesProvider
    extends $NotifierProvider<TabHistoryStates, Map<String, HistoryState>> {
  /// Session history (back/forward stack) per tab.
  TabHistoryStatesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tabHistoryStatesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tabHistoryStatesHash();

  @$internal
  @override
  TabHistoryStates create() => TabHistoryStates();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<String, HistoryState> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<String, HistoryState>>(value),
    );
  }
}

String _$tabHistoryStatesHash() => r'3920410334c4354ca66da605d9bfe85b4853f3bf';

/// Session history (back/forward stack) per tab.

abstract class _$TabHistoryStates extends $Notifier<Map<String, HistoryState>> {
  Map<String, HistoryState> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<Map<String, HistoryState>, Map<String, HistoryState>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Map<String, HistoryState>, Map<String, HistoryState>>,
              Map<String, HistoryState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(tabHistoryState)
final tabHistoryStateProvider = TabHistoryStateFamily._();

final class TabHistoryStateProvider
    extends $FunctionalProvider<HistoryState, HistoryState, HistoryState>
    with $Provider<HistoryState> {
  TabHistoryStateProvider._({
    required TabHistoryStateFamily super.from,
    required String? super.argument,
  }) : super(
         retry: null,
         name: r'tabHistoryStateProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$tabHistoryStateHash();

  @override
  String toString() {
    return r'tabHistoryStateProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<HistoryState> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  HistoryState create(Ref ref) {
    final argument = this.argument as String?;
    return tabHistoryState(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HistoryState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HistoryState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is TabHistoryStateProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$tabHistoryStateHash() => r'5bca69fddb6fc2f3db6caf5c84bd1a7f5728e1d9';

final class TabHistoryStateFamily extends $Family
    with $FunctionalFamilyOverride<HistoryState, String?> {
  TabHistoryStateFamily._()
    : super(
        retry: null,
        name: r'tabHistoryStateProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  TabHistoryStateProvider call(String? tabId) =>
      TabHistoryStateProvider._(argument: tabId, from: this);

  @override
  String toString() => r'tabHistoryStateProvider';
}

/// Find-in-page match counters per tab. Emitted at a high rate by Gecko while
/// a search is running.

@ProviderFor(TabFindResultStates)
final tabFindResultStatesProvider = TabFindResultStatesProvider._();

/// Find-in-page match counters per tab. Emitted at a high rate by Gecko while
/// a search is running.
final class TabFindResultStatesProvider
    extends
        $NotifierProvider<TabFindResultStates, Map<String, FindResultState>> {
  /// Find-in-page match counters per tab. Emitted at a high rate by Gecko while
  /// a search is running.
  TabFindResultStatesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tabFindResultStatesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tabFindResultStatesHash();

  @$internal
  @override
  TabFindResultStates create() => TabFindResultStates();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<String, FindResultState> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<String, FindResultState>>(value),
    );
  }
}

String _$tabFindResultStatesHash() =>
    r'f57dee1658eae789002ac3cff15808cbc96b7883';

/// Find-in-page match counters per tab. Emitted at a high rate by Gecko while
/// a search is running.

abstract class _$TabFindResultStates
    extends $Notifier<Map<String, FindResultState>> {
  Map<String, FindResultState> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<Map<String, FindResultState>, Map<String, FindResultState>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                Map<String, FindResultState>,
                Map<String, FindResultState>
              >,
              Map<String, FindResultState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(tabFindResultState)
final tabFindResultStateProvider = TabFindResultStateFamily._();

final class TabFindResultStateProvider
    extends
        $FunctionalProvider<FindResultState, FindResultState, FindResultState>
    with $Provider<FindResultState> {
  TabFindResultStateProvider._({
    required TabFindResultStateFamily super.from,
    required String? super.argument,
  }) : super(
         retry: null,
         name: r'tabFindResultStateProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$tabFindResultStateHash();

  @override
  String toString() {
    return r'tabFindResultStateProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<FindResultState> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  FindResultState create(Ref ref) {
    final argument = this.argument as String?;
    return tabFindResultState(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FindResultState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FindResultState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is TabFindResultStateProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$tabFindResultStateHash() =>
    r'0f58040111bb43d830e14ae44569265b9ae804d9';

final class TabFindResultStateFamily extends $Family
    with $FunctionalFamilyOverride<FindResultState, String?> {
  TabFindResultStateFamily._()
    : super(
        retry: null,
        name: r'tabFindResultStateProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  TabFindResultStateProvider call(String? tabId) =>
      TabFindResultStateProvider._(argument: tabId, from: this);

  @override
  String toString() => r'tabFindResultStateProvider';
}

/// Translation progress/result per tab.

@ProviderFor(TabTranslationStates)
final tabTranslationStatesProvider = TabTranslationStatesProvider._();

/// Translation progress/result per tab.
final class TabTranslationStatesProvider
    extends
        $NotifierProvider<TabTranslationStates, Map<String, TranslationState>> {
  /// Translation progress/result per tab.
  TabTranslationStatesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tabTranslationStatesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tabTranslationStatesHash();

  @$internal
  @override
  TabTranslationStates create() => TabTranslationStates();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<String, TranslationState> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<String, TranslationState>>(
        value,
      ),
    );
  }
}

String _$tabTranslationStatesHash() =>
    r'f04004026dc5fd638319528a55e2f10e0f64c9b3';

/// Translation progress/result per tab.

abstract class _$TabTranslationStates
    extends $Notifier<Map<String, TranslationState>> {
  Map<String, TranslationState> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<
              Map<String, TranslationState>,
              Map<String, TranslationState>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                Map<String, TranslationState>,
                Map<String, TranslationState>
              >,
              Map<String, TranslationState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(tabTranslationState)
final tabTranslationStateProvider = TabTranslationStateFamily._();

final class TabTranslationStateProvider
    extends
        $FunctionalProvider<
          TranslationState,
          TranslationState,
          TranslationState
        >
    with $Provider<TranslationState> {
  TabTranslationStateProvider._({
    required TabTranslationStateFamily super.from,
    required String? super.argument,
  }) : super(
         retry: null,
         name: r'tabTranslationStateProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$tabTranslationStateHash();

  @override
  String toString() {
    return r'tabTranslationStateProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<TranslationState> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  TranslationState create(Ref ref) {
    final argument = this.argument as String?;
    return tabTranslationState(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TranslationState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TranslationState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is TabTranslationStateProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$tabTranslationStateHash() =>
    r'886365e36167542b2e4dbdbeb97c942a414a752e';

final class TabTranslationStateFamily extends $Family
    with $FunctionalFamilyOverride<TranslationState, String?> {
  TabTranslationStateFamily._()
    : super(
        retry: null,
        name: r'tabTranslationStateProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  TabTranslationStateProvider call(String? tabId) =>
      TabTranslationStateProvider._(argument: tabId, from: this);

  @override
  String toString() => r'tabTranslationStateProvider';
}
