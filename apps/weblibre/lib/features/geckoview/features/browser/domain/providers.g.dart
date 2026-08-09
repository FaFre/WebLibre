// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(canManualTabReorder)
final canManualTabReorderProvider = CanManualTabReorderProvider._();

final class CanManualTabReorderProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  CanManualTabReorderProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'canManualTabReorderProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$canManualTabReorderHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return canManualTabReorder(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$canManualTabReorderHash() =>
    r'ba5d961933464b6e005d7945802908a9a4ae034b';

@ProviderFor(SelectedBangTrigger)
final selectedBangTriggerProvider = SelectedBangTriggerFamily._();

final class SelectedBangTriggerProvider
    extends $NotifierProvider<SelectedBangTrigger, BangKey?> {
  SelectedBangTriggerProvider._({
    required SelectedBangTriggerFamily super.from,
    required String? super.argument,
  }) : super(
         retry: null,
         name: r'selectedBangTriggerProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$selectedBangTriggerHash();

  @override
  String toString() {
    return r'selectedBangTriggerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  SelectedBangTrigger create() => SelectedBangTrigger();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BangKey? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BangKey?>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is SelectedBangTriggerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$selectedBangTriggerHash() =>
    r'162d053d0207b8b98549adc453111111d8ff69d6';

final class SelectedBangTriggerFamily extends $Family
    with
        $ClassFamilyOverride<
          SelectedBangTrigger,
          BangKey?,
          BangKey?,
          BangKey?,
          String?
        > {
  SelectedBangTriggerFamily._()
    : super(
        retry: null,
        name: r'selectedBangTriggerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  SelectedBangTriggerProvider call({String? domain}) =>
      SelectedBangTriggerProvider._(argument: domain, from: this);

  @override
  String toString() => r'selectedBangTriggerProvider';
}

abstract class _$SelectedBangTrigger extends $Notifier<BangKey?> {
  late final _$args = ref.$arg as String?;
  String? get domain => _$args;

  BangKey? build({String? domain});
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<BangKey?, BangKey?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<BangKey?, BangKey?>,
              BangKey?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(domain: _$args));
  }
}

@ProviderFor(SelectedBangData)
final selectedBangDataProvider = SelectedBangDataFamily._();

final class SelectedBangDataProvider
    extends $NotifierProvider<SelectedBangData, BangData?> {
  SelectedBangDataProvider._({
    required SelectedBangDataFamily super.from,
    required String? super.argument,
  }) : super(
         retry: null,
         name: r'selectedBangDataProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$selectedBangDataHash();

  @override
  String toString() {
    return r'selectedBangDataProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  SelectedBangData create() => SelectedBangData();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BangData? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BangData?>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is SelectedBangDataProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$selectedBangDataHash() => r'68bdd0d203cc47a0d26904ecb30651b58aa19486';

final class SelectedBangDataFamily extends $Family
    with
        $ClassFamilyOverride<
          SelectedBangData,
          BangData?,
          BangData?,
          BangData?,
          String?
        > {
  SelectedBangDataFamily._()
    : super(
        retry: null,
        name: r'selectedBangDataProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  SelectedBangDataProvider call({String? domain}) =>
      SelectedBangDataProvider._(argument: domain, from: this);

  @override
  String toString() => r'selectedBangDataProvider';
}

abstract class _$SelectedBangData extends $Notifier<BangData?> {
  late final _$args = ref.$arg as String?;
  String? get domain => _$args;

  BangData? build({String? domain});
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<BangData?, BangData?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<BangData?, BangData?>,
              BangData?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(domain: _$args));
  }
}

@ProviderFor(containerTabEntities)
final containerTabEntitiesProvider = ContainerTabEntitiesFamily._();

final class ContainerTabEntitiesProvider
    extends
        $FunctionalProvider<
          EquatableValue<List<DefaultTabEntity>>,
          EquatableValue<List<DefaultTabEntity>>,
          EquatableValue<List<DefaultTabEntity>>
        >
    with $Provider<EquatableValue<List<DefaultTabEntity>>> {
  ContainerTabEntitiesProvider._({
    required ContainerTabEntitiesFamily super.from,
    required ContainerFilter super.argument,
  }) : super(
         retry: null,
         name: r'containerTabEntitiesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$containerTabEntitiesHash();

  @override
  String toString() {
    return r'containerTabEntitiesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<EquatableValue<List<DefaultTabEntity>>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  EquatableValue<List<DefaultTabEntity>> create(Ref ref) {
    final argument = this.argument as ContainerFilter;
    return containerTabEntities(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(EquatableValue<List<DefaultTabEntity>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride:
          $SyncValueProvider<EquatableValue<List<DefaultTabEntity>>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ContainerTabEntitiesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$containerTabEntitiesHash() =>
    r'bcd932968bae46fb5e27a60819ea7aad7a8e41e7';

final class ContainerTabEntitiesFamily extends $Family
    with
        $FunctionalFamilyOverride<
          EquatableValue<List<DefaultTabEntity>>,
          ContainerFilter
        > {
  ContainerTabEntitiesFamily._()
    : super(
        retry: null,
        name: r'containerTabEntitiesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ContainerTabEntitiesProvider call(ContainerFilter containerFilter) =>
      ContainerTabEntitiesProvider._(argument: containerFilter, from: this);

  @override
  String toString() => r'containerTabEntitiesProvider';
}

@ProviderFor(containerTabStates)
final containerTabStatesProvider = ContainerTabStatesFamily._();

final class ContainerTabStatesProvider
    extends
        $FunctionalProvider<
          EquatableValue<Map<String, TabState>>,
          EquatableValue<Map<String, TabState>>,
          EquatableValue<Map<String, TabState>>
        >
    with $Provider<EquatableValue<Map<String, TabState>>> {
  ContainerTabStatesProvider._({
    required ContainerTabStatesFamily super.from,
    required ContainerFilter super.argument,
  }) : super(
         retry: null,
         name: r'containerTabStatesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$containerTabStatesHash();

  @override
  String toString() {
    return r'containerTabStatesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<EquatableValue<Map<String, TabState>>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  EquatableValue<Map<String, TabState>> create(Ref ref) {
    final argument = this.argument as ContainerFilter;
    return containerTabStates(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(EquatableValue<Map<String, TabState>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride:
          $SyncValueProvider<EquatableValue<Map<String, TabState>>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ContainerTabStatesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$containerTabStatesHash() =>
    r'320f35a2605b53ab57b299caafd9b71804b67c6c';

final class ContainerTabStatesFamily extends $Family
    with
        $FunctionalFamilyOverride<
          EquatableValue<Map<String, TabState>>,
          ContainerFilter
        > {
  ContainerTabStatesFamily._()
    : super(
        retry: null,
        name: r'containerTabStatesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ContainerTabStatesProvider call(ContainerFilter containerFilter) =>
      ContainerTabStatesProvider._(argument: containerFilter, from: this);

  @override
  String toString() => r'containerTabStatesProvider';
}

/// Ids of DB-cached tabs whose native state hasn't arrived yet. Empty once
/// the session restore completed (afterwards a missing native state means
/// the tab is gone, not pending).

@ProviderFor(pendingRestoreTabIds)
final pendingRestoreTabIdsProvider = PendingRestoreTabIdsProvider._();

/// Ids of DB-cached tabs whose native state hasn't arrived yet. Empty once
/// the session restore completed (afterwards a missing native state means
/// the tab is gone, not pending).

final class PendingRestoreTabIdsProvider
    extends
        $FunctionalProvider<
          EquatableValue<Set<String>>,
          EquatableValue<Set<String>>,
          EquatableValue<Set<String>>
        >
    with $Provider<EquatableValue<Set<String>>> {
  /// Ids of DB-cached tabs whose native state hasn't arrived yet. Empty once
  /// the session restore completed (afterwards a missing native state means
  /// the tab is gone, not pending).
  PendingRestoreTabIdsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pendingRestoreTabIdsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pendingRestoreTabIdsHash();

  @$internal
  @override
  $ProviderElement<EquatableValue<Set<String>>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  EquatableValue<Set<String>> create(Ref ref) {
    return pendingRestoreTabIds(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(EquatableValue<Set<String>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<EquatableValue<Set<String>>>(value),
    );
  }
}

String _$pendingRestoreTabIdsHash() =>
    r'a7c1639478ebed7d887d9b1d1296757d829dcc6b';

@ProviderFor(fifoTabStates)
final fifoTabStatesProvider = FifoTabStatesProvider._();

final class FifoTabStatesProvider
    extends
        $FunctionalProvider<
          EquatableValue<List<TabStateWithContainer>>,
          EquatableValue<List<TabStateWithContainer>>,
          EquatableValue<List<TabStateWithContainer>>
        >
    with $Provider<EquatableValue<List<TabStateWithContainer>>> {
  FifoTabStatesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'fifoTabStatesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$fifoTabStatesHash();

  @$internal
  @override
  $ProviderElement<EquatableValue<List<TabStateWithContainer>>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  EquatableValue<List<TabStateWithContainer>> create(Ref ref) {
    return fifoTabStates(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(
    EquatableValue<List<TabStateWithContainer>> value,
  ) {
    return $ProviderOverride(
      origin: this,
      providerOverride:
          $SyncValueProvider<EquatableValue<List<TabStateWithContainer>>>(
            value,
          ),
    );
  }
}

String _$fifoTabStatesHash() => r'a512f96119561096b9cc7d6920e82da6d460ce68';

@ProviderFor(selectedContainerTabStatesWithContainer)
final selectedContainerTabStatesWithContainerProvider =
    SelectedContainerTabStatesWithContainerProvider._();

final class SelectedContainerTabStatesWithContainerProvider
    extends
        $FunctionalProvider<
          EquatableValue<List<TabStateWithContainer>>,
          EquatableValue<List<TabStateWithContainer>>,
          EquatableValue<List<TabStateWithContainer>>
        >
    with $Provider<EquatableValue<List<TabStateWithContainer>>> {
  SelectedContainerTabStatesWithContainerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectedContainerTabStatesWithContainerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() =>
      _$selectedContainerTabStatesWithContainerHash();

  @$internal
  @override
  $ProviderElement<EquatableValue<List<TabStateWithContainer>>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  EquatableValue<List<TabStateWithContainer>> create(Ref ref) {
    return selectedContainerTabStatesWithContainer(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(
    EquatableValue<List<TabStateWithContainer>> value,
  ) {
    return $ProviderOverride(
      origin: this,
      providerOverride:
          $SyncValueProvider<EquatableValue<List<TabStateWithContainer>>>(
            value,
          ),
    );
  }
}

String _$selectedContainerTabStatesWithContainerHash() =>
    r'6e215f983140f7980d84e3f3d05a8afe95e6f1e7';

@ProviderFor(quickTabSwitcherTabStates)
final quickTabSwitcherTabStatesProvider = QuickTabSwitcherTabStatesFamily._();

final class QuickTabSwitcherTabStatesProvider
    extends
        $FunctionalProvider<
          EquatableValue<List<TabStateWithContainer>>,
          EquatableValue<List<TabStateWithContainer>>,
          EquatableValue<List<TabStateWithContainer>>
        >
    with $Provider<EquatableValue<List<TabStateWithContainer>>> {
  QuickTabSwitcherTabStatesProvider._({
    required QuickTabSwitcherTabStatesFamily super.from,
    required QuickTabSwitcherMode super.argument,
  }) : super(
         retry: null,
         name: r'quickTabSwitcherTabStatesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$quickTabSwitcherTabStatesHash();

  @override
  String toString() {
    return r'quickTabSwitcherTabStatesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<EquatableValue<List<TabStateWithContainer>>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  EquatableValue<List<TabStateWithContainer>> create(Ref ref) {
    final argument = this.argument as QuickTabSwitcherMode;
    return quickTabSwitcherTabStates(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(
    EquatableValue<List<TabStateWithContainer>> value,
  ) {
    return $ProviderOverride(
      origin: this,
      providerOverride:
          $SyncValueProvider<EquatableValue<List<TabStateWithContainer>>>(
            value,
          ),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is QuickTabSwitcherTabStatesProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$quickTabSwitcherTabStatesHash() =>
    r'f61847bd68385e799384adfa5bfe735544fedbf5';

final class QuickTabSwitcherTabStatesFamily extends $Family
    with
        $FunctionalFamilyOverride<
          EquatableValue<List<TabStateWithContainer>>,
          QuickTabSwitcherMode
        > {
  QuickTabSwitcherTabStatesFamily._()
    : super(
        retry: null,
        name: r'quickTabSwitcherTabStatesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  QuickTabSwitcherTabStatesProvider call(QuickTabSwitcherMode mode) =>
      QuickTabSwitcherTabStatesProvider._(argument: mode, from: this);

  @override
  String toString() => r'quickTabSwitcherTabStatesProvider';
}

@ProviderFor(quickTabSwitcherHistorySuggestions)
final quickTabSwitcherHistorySuggestionsProvider =
    QuickTabSwitcherHistorySuggestionsFamily._();

final class QuickTabSwitcherHistorySuggestionsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<VisitInfo>>,
          List<VisitInfo>,
          FutureOr<List<VisitInfo>>
        >
    with $FutureModifier<List<VisitInfo>>, $FutureProvider<List<VisitInfo>> {
  QuickTabSwitcherHistorySuggestionsProvider._({
    required QuickTabSwitcherHistorySuggestionsFamily super.from,
    required QuickTabSwitcherMode super.argument,
  }) : super(
         retry: null,
         name: r'quickTabSwitcherHistorySuggestionsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() =>
      _$quickTabSwitcherHistorySuggestionsHash();

  @override
  String toString() {
    return r'quickTabSwitcherHistorySuggestionsProvider'
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
    final argument = this.argument as QuickTabSwitcherMode;
    return quickTabSwitcherHistorySuggestions(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is QuickTabSwitcherHistorySuggestionsProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$quickTabSwitcherHistorySuggestionsHash() =>
    r'3446741dfedf6fda9ab61421c1b74370c7f43f5b';

final class QuickTabSwitcherHistorySuggestionsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<VisitInfo>>,
          QuickTabSwitcherMode
        > {
  QuickTabSwitcherHistorySuggestionsFamily._()
    : super(
        retry: null,
        name: r'quickTabSwitcherHistorySuggestionsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  QuickTabSwitcherHistorySuggestionsProvider call(QuickTabSwitcherMode mode) =>
      QuickTabSwitcherHistorySuggestionsProvider._(argument: mode, from: this);

  @override
  String toString() => r'quickTabSwitcherHistorySuggestionsProvider';
}

/// Number of 48px rows the quick tab switcher bar currently occupies.
/// 0 hides the bar; feeds the toolbar height / GeckoView viewport math.

@ProviderFor(quickTabSwitcherRowCount)
final quickTabSwitcherRowCountProvider = QuickTabSwitcherRowCountProvider._();

/// Number of 48px rows the quick tab switcher bar currently occupies.
/// 0 hides the bar; feeds the toolbar height / GeckoView viewport math.

final class QuickTabSwitcherRowCountProvider
    extends
        $FunctionalProvider<AsyncValue<int>, AsyncValue<int>, AsyncValue<int>>
    with $Provider<AsyncValue<int>> {
  /// Number of 48px rows the quick tab switcher bar currently occupies.
  /// 0 hides the bar; feeds the toolbar height / GeckoView viewport math.
  QuickTabSwitcherRowCountProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'quickTabSwitcherRowCountProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$quickTabSwitcherRowCountHash();

  @$internal
  @override
  $ProviderElement<AsyncValue<int>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AsyncValue<int> create(Ref ref) {
    return quickTabSwitcherRowCount(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<int> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<int>>(value),
    );
  }
}

String _$quickTabSwitcherRowCountHash() =>
    r'81a2bfbdc4dc88fdf2c66dd9f5bfd6d1ce73a073';

@ProviderFor(suggestedTabEntities)
final suggestedTabEntitiesProvider = SuggestedTabEntitiesFamily._();

final class SuggestedTabEntitiesProvider
    extends
        $FunctionalProvider<
          EquatableValue<List<TabEntity>>,
          EquatableValue<List<TabEntity>>,
          EquatableValue<List<TabEntity>>
        >
    with $Provider<EquatableValue<List<TabEntity>>> {
  SuggestedTabEntitiesProvider._({
    required SuggestedTabEntitiesFamily super.from,
    required String? super.argument,
  }) : super(
         retry: null,
         name: r'suggestedTabEntitiesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$suggestedTabEntitiesHash();

  @override
  String toString() {
    return r'suggestedTabEntitiesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<EquatableValue<List<TabEntity>>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  EquatableValue<List<TabEntity>> create(Ref ref) {
    final argument = this.argument as String?;
    return suggestedTabEntities(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(EquatableValue<List<TabEntity>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<EquatableValue<List<TabEntity>>>(
        value,
      ),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is SuggestedTabEntitiesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$suggestedTabEntitiesHash() =>
    r'b140a1d0badad3d976b91ab9154300873a8bd4e9';

final class SuggestedTabEntitiesFamily extends $Family
    with $FunctionalFamilyOverride<EquatableValue<List<TabEntity>>, String?> {
  SuggestedTabEntitiesFamily._()
    : super(
        retry: null,
        name: r'suggestedTabEntitiesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  SuggestedTabEntitiesProvider call(String? containerId) =>
      SuggestedTabEntitiesProvider._(argument: containerId, from: this);

  @override
  String toString() => r'suggestedTabEntitiesProvider';
}

@ProviderFor(seamlessFilteredTabEntities)
final seamlessFilteredTabEntitiesProvider =
    SeamlessFilteredTabEntitiesFamily._();

final class SeamlessFilteredTabEntitiesProvider
    extends
        $FunctionalProvider<
          EquatableValue<List<TabEntity>>,
          EquatableValue<List<TabEntity>>,
          EquatableValue<List<TabEntity>>
        >
    with $Provider<EquatableValue<List<TabEntity>>> {
  SeamlessFilteredTabEntitiesProvider._({
    required SeamlessFilteredTabEntitiesFamily super.from,
    required ({
      TabSearchPartition searchPartition,
      ContainerFilter containerFilter,
      bool groupTrees,
    })
    super.argument,
  }) : super(
         retry: null,
         name: r'seamlessFilteredTabEntitiesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$seamlessFilteredTabEntitiesHash();

  @override
  String toString() {
    return r'seamlessFilteredTabEntitiesProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $ProviderElement<EquatableValue<List<TabEntity>>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  EquatableValue<List<TabEntity>> create(Ref ref) {
    final argument =
        this.argument
            as ({
              TabSearchPartition searchPartition,
              ContainerFilter containerFilter,
              bool groupTrees,
            });
    return seamlessFilteredTabEntities(
      ref,
      searchPartition: argument.searchPartition,
      containerFilter: argument.containerFilter,
      groupTrees: argument.groupTrees,
    );
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(EquatableValue<List<TabEntity>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<EquatableValue<List<TabEntity>>>(
        value,
      ),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is SeamlessFilteredTabEntitiesProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$seamlessFilteredTabEntitiesHash() =>
    r'83113c04be7932c60c7c97b70595fde0145f8040';

final class SeamlessFilteredTabEntitiesFamily extends $Family
    with
        $FunctionalFamilyOverride<
          EquatableValue<List<TabEntity>>,
          ({
            TabSearchPartition searchPartition,
            ContainerFilter containerFilter,
            bool groupTrees,
          })
        > {
  SeamlessFilteredTabEntitiesFamily._()
    : super(
        retry: null,
        name: r'seamlessFilteredTabEntitiesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  SeamlessFilteredTabEntitiesProvider call({
    required TabSearchPartition searchPartition,
    required ContainerFilter containerFilter,
    required bool groupTrees,
  }) => SeamlessFilteredTabEntitiesProvider._(
    argument: (
      searchPartition: searchPartition,
      containerFilter: containerFilter,
      groupTrees: groupTrees,
    ),
    from: this,
  );

  @override
  String toString() => r'seamlessFilteredTabEntitiesProvider';
}

@ProviderFor(filteredTabPreviews)
final filteredTabPreviewsProvider = FilteredTabPreviewsFamily._();

final class FilteredTabPreviewsProvider
    extends
        $FunctionalProvider<
          EquatableValue<List<TabPreview>>,
          EquatableValue<List<TabPreview>>,
          EquatableValue<List<TabPreview>>
        >
    with $Provider<EquatableValue<List<TabPreview>>> {
  FilteredTabPreviewsProvider._({
    required FilteredTabPreviewsFamily super.from,
    required (TabSearchPartition, ContainerFilter) super.argument,
  }) : super(
         retry: null,
         name: r'filteredTabPreviewsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$filteredTabPreviewsHash();

  @override
  String toString() {
    return r'filteredTabPreviewsProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $ProviderElement<EquatableValue<List<TabPreview>>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  EquatableValue<List<TabPreview>> create(Ref ref) {
    final argument = this.argument as (TabSearchPartition, ContainerFilter);
    return filteredTabPreviews(ref, argument.$1, argument.$2);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(EquatableValue<List<TabPreview>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<EquatableValue<List<TabPreview>>>(
        value,
      ),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is FilteredTabPreviewsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$filteredTabPreviewsHash() =>
    r'e291cdb7848c9607d388f8fdfb640f25265fca03';

final class FilteredTabPreviewsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          EquatableValue<List<TabPreview>>,
          (TabSearchPartition, ContainerFilter)
        > {
  FilteredTabPreviewsFamily._()
    : super(
        retry: null,
        name: r'filteredTabPreviewsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  FilteredTabPreviewsProvider call(
    TabSearchPartition searchPartition,
    ContainerFilter containerFilter,
  ) => FilteredTabPreviewsProvider._(
    argument: (searchPartition, containerFilter),
    from: this,
  );

  @override
  String toString() => r'filteredTabPreviewsProvider';
}

/// Grouped flat-list rendering for the list and grid views.
///
/// Parent rows always render before their descendants. [TabDirection]
/// applies both to root group ordering and to sibling ordering below each
/// parent, so parent-child pairs stay together while child order still follows
/// the configured direction.
///
/// Returns `null` when the input data is not yet available (loading).

@ProviderFor(groupedTabListItems)
final groupedTabListItemsProvider = GroupedTabListItemsFamily._();

/// Grouped flat-list rendering for the list and grid views.
///
/// Parent rows always render before their descendants. [TabDirection]
/// applies both to root group ordering and to sibling ordering below each
/// parent, so parent-child pairs stay together while child order still follows
/// the configured direction.
///
/// Returns `null` when the input data is not yet available (loading).

final class GroupedTabListItemsProvider
    extends
        $FunctionalProvider<
          EquatableValue<List<TabListItemEntity>>,
          EquatableValue<List<TabListItemEntity>>,
          EquatableValue<List<TabListItemEntity>>
        >
    with $Provider<EquatableValue<List<TabListItemEntity>>> {
  /// Grouped flat-list rendering for the list and grid views.
  ///
  /// Parent rows always render before their descendants. [TabDirection]
  /// applies both to root group ordering and to sibling ordering below each
  /// parent, so parent-child pairs stay together while child order still follows
  /// the configured direction.
  ///
  /// Returns `null` when the input data is not yet available (loading).
  GroupedTabListItemsProvider._({
    required GroupedTabListItemsFamily super.from,
    required String? super.argument,
  }) : super(
         retry: null,
         name: r'groupedTabListItemsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$groupedTabListItemsHash();

  @override
  String toString() {
    return r'groupedTabListItemsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<EquatableValue<List<TabListItemEntity>>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  EquatableValue<List<TabListItemEntity>> create(Ref ref) {
    final argument = this.argument as String?;
    return groupedTabListItems(ref, containerId: argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(EquatableValue<List<TabListItemEntity>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride:
          $SyncValueProvider<EquatableValue<List<TabListItemEntity>>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is GroupedTabListItemsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$groupedTabListItemsHash() =>
    r'd7158c50ca34014d63044e7fb52a7197245c59ad';

/// Grouped flat-list rendering for the list and grid views.
///
/// Parent rows always render before their descendants. [TabDirection]
/// applies both to root group ordering and to sibling ordering below each
/// parent, so parent-child pairs stay together while child order still follows
/// the configured direction.
///
/// Returns `null` when the input data is not yet available (loading).

final class GroupedTabListItemsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          EquatableValue<List<TabListItemEntity>>,
          String?
        > {
  GroupedTabListItemsFamily._()
    : super(
        retry: null,
        name: r'groupedTabListItemsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Grouped flat-list rendering for the list and grid views.
  ///
  /// Parent rows always render before their descendants. [TabDirection]
  /// applies both to root group ordering and to sibling ordering below each
  /// parent, so parent-child pairs stay together while child order still follows
  /// the configured direction.
  ///
  /// Returns `null` when the input data is not yet available (loading).

  GroupedTabListItemsProvider call({required String? containerId}) =>
      GroupedTabListItemsProvider._(argument: containerId, from: this);

  @override
  String toString() => r'groupedTabListItemsProvider';
}

/// The final row order the tab tray renders, i.e.
/// [groupedTabListItemsProvider] plus the flat-mode post-processing: with
/// hierarchy display turned off there are no groups to keep together, so
/// pinned tabs move ahead of unpinned ones across the whole list.
///
/// Shared by the list view, the grid view and sequential tab navigation so all
/// three agree on what "the tab after this one" means.

@ProviderFor(visibleTabListItems)
final visibleTabListItemsProvider = VisibleTabListItemsFamily._();

/// The final row order the tab tray renders, i.e.
/// [groupedTabListItemsProvider] plus the flat-mode post-processing: with
/// hierarchy display turned off there are no groups to keep together, so
/// pinned tabs move ahead of unpinned ones across the whole list.
///
/// Shared by the list view, the grid view and sequential tab navigation so all
/// three agree on what "the tab after this one" means.

final class VisibleTabListItemsProvider
    extends
        $FunctionalProvider<
          EquatableValue<List<TabListItemEntity>>,
          EquatableValue<List<TabListItemEntity>>,
          EquatableValue<List<TabListItemEntity>>
        >
    with $Provider<EquatableValue<List<TabListItemEntity>>> {
  /// The final row order the tab tray renders, i.e.
  /// [groupedTabListItemsProvider] plus the flat-mode post-processing: with
  /// hierarchy display turned off there are no groups to keep together, so
  /// pinned tabs move ahead of unpinned ones across the whole list.
  ///
  /// Shared by the list view, the grid view and sequential tab navigation so all
  /// three agree on what "the tab after this one" means.
  VisibleTabListItemsProvider._({
    required VisibleTabListItemsFamily super.from,
    required String? super.argument,
  }) : super(
         retry: null,
         name: r'visibleTabListItemsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$visibleTabListItemsHash();

  @override
  String toString() {
    return r'visibleTabListItemsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<EquatableValue<List<TabListItemEntity>>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  EquatableValue<List<TabListItemEntity>> create(Ref ref) {
    final argument = this.argument as String?;
    return visibleTabListItems(ref, containerId: argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(EquatableValue<List<TabListItemEntity>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride:
          $SyncValueProvider<EquatableValue<List<TabListItemEntity>>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is VisibleTabListItemsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$visibleTabListItemsHash() =>
    r'5249a3e7e1f0b24e408987956856926d0958b0db';

/// The final row order the tab tray renders, i.e.
/// [groupedTabListItemsProvider] plus the flat-mode post-processing: with
/// hierarchy display turned off there are no groups to keep together, so
/// pinned tabs move ahead of unpinned ones across the whole list.
///
/// Shared by the list view, the grid view and sequential tab navigation so all
/// three agree on what "the tab after this one" means.

final class VisibleTabListItemsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          EquatableValue<List<TabListItemEntity>>,
          String?
        > {
  VisibleTabListItemsFamily._()
    : super(
        retry: null,
        name: r'visibleTabListItemsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The final row order the tab tray renders, i.e.
  /// [groupedTabListItemsProvider] plus the flat-mode post-processing: with
  /// hierarchy display turned off there are no groups to keep together, so
  /// pinned tabs move ahead of unpinned ones across the whole list.
  ///
  /// Shared by the list view, the grid view and sequential tab navigation so all
  /// three agree on what "the tab after this one" means.

  VisibleTabListItemsProvider call({required String? containerId}) =>
      VisibleTabListItemsProvider._(argument: containerId, from: this);

  @override
  String toString() => r'visibleTabListItemsProvider';
}

/// Flat tab id order used by sequential tab navigation: the tab bar swipe
/// action and the next/previous tab gestures.
///
/// Navigation follows the rendered order instead of the raw storage
/// `order_key`, so it carries the active sort type, tree grouping, collapsed
/// groups, pinned-first handling and the tab-type/date filter — stepping to the
/// tab the user sees next to the current one rather than to an unrelated
/// `order_key` neighbour.
///
/// It spans **all** containers, keeping the boundary-crossing reach the
/// storage-order walk had: each container contributes the rows its tray would
/// render, and the containers follow one another in the order the quick tab
/// switcher lays them out — the unassigned bucket first, then containers by
/// pinned/`order_key`. Stepping off the end of one container therefore
/// continues into the next, and selecting that tab moves the selected container
/// along with it. Containers without tabs are skipped so their tree query never
/// runs.
///
/// "Previous" is a step towards the top of that order and "next" a step
/// towards its end, so direction follows `tabListDirection` (baked into the
/// order) rather than `tabBarDirection`. The two only disagree when the user
/// sets them apart, and the rendered order is the one the sequence is built
/// from.
///
/// The tray's own search results are deliberately not part of this: the swipe
/// and the gestures are only reachable with the tray closed.
///
/// `null` means the underlying tree data has not arrived yet — the only state
/// in which the caller may fall back to storage order. An empty list is a real
/// answer ("the filter leaves nothing to move to") and must not be mistaken for
/// a missing one, or the filter the user set would be bypassed.
///
/// Kept alive and actively listened to by [TabRepository]: it is consumed by a
/// synchronous `ref.read` at the moment of the swipe/gesture, from outside the
/// widget tree. Without a listener Riverpod pauses the chain when nothing is on
/// screen watching it, so the order could go stale — or be created empty on the
/// read, with its tree stream still loading, and silently drop navigation back
/// to storage order. The selected container's chain is alive anyway whenever the
/// quick tab switcher or the tray is on screen; the price of crossing container
/// boundaries is that the other populated containers' tree queries are kept
/// alive too.

@ProviderFor(sequentialTabNavigationOrder)
final sequentialTabNavigationOrderProvider =
    SequentialTabNavigationOrderProvider._();

/// Flat tab id order used by sequential tab navigation: the tab bar swipe
/// action and the next/previous tab gestures.
///
/// Navigation follows the rendered order instead of the raw storage
/// `order_key`, so it carries the active sort type, tree grouping, collapsed
/// groups, pinned-first handling and the tab-type/date filter — stepping to the
/// tab the user sees next to the current one rather than to an unrelated
/// `order_key` neighbour.
///
/// It spans **all** containers, keeping the boundary-crossing reach the
/// storage-order walk had: each container contributes the rows its tray would
/// render, and the containers follow one another in the order the quick tab
/// switcher lays them out — the unassigned bucket first, then containers by
/// pinned/`order_key`. Stepping off the end of one container therefore
/// continues into the next, and selecting that tab moves the selected container
/// along with it. Containers without tabs are skipped so their tree query never
/// runs.
///
/// "Previous" is a step towards the top of that order and "next" a step
/// towards its end, so direction follows `tabListDirection` (baked into the
/// order) rather than `tabBarDirection`. The two only disagree when the user
/// sets them apart, and the rendered order is the one the sequence is built
/// from.
///
/// The tray's own search results are deliberately not part of this: the swipe
/// and the gestures are only reachable with the tray closed.
///
/// `null` means the underlying tree data has not arrived yet — the only state
/// in which the caller may fall back to storage order. An empty list is a real
/// answer ("the filter leaves nothing to move to") and must not be mistaken for
/// a missing one, or the filter the user set would be bypassed.
///
/// Kept alive and actively listened to by [TabRepository]: it is consumed by a
/// synchronous `ref.read` at the moment of the swipe/gesture, from outside the
/// widget tree. Without a listener Riverpod pauses the chain when nothing is on
/// screen watching it, so the order could go stale — or be created empty on the
/// read, with its tree stream still loading, and silently drop navigation back
/// to storage order. The selected container's chain is alive anyway whenever the
/// quick tab switcher or the tray is on screen; the price of crossing container
/// boundaries is that the other populated containers' tree queries are kept
/// alive too.

final class SequentialTabNavigationOrderProvider
    extends
        $FunctionalProvider<
          EquatableValue<List<String>?>,
          EquatableValue<List<String>?>,
          EquatableValue<List<String>?>
        >
    with $Provider<EquatableValue<List<String>?>> {
  /// Flat tab id order used by sequential tab navigation: the tab bar swipe
  /// action and the next/previous tab gestures.
  ///
  /// Navigation follows the rendered order instead of the raw storage
  /// `order_key`, so it carries the active sort type, tree grouping, collapsed
  /// groups, pinned-first handling and the tab-type/date filter — stepping to the
  /// tab the user sees next to the current one rather than to an unrelated
  /// `order_key` neighbour.
  ///
  /// It spans **all** containers, keeping the boundary-crossing reach the
  /// storage-order walk had: each container contributes the rows its tray would
  /// render, and the containers follow one another in the order the quick tab
  /// switcher lays them out — the unassigned bucket first, then containers by
  /// pinned/`order_key`. Stepping off the end of one container therefore
  /// continues into the next, and selecting that tab moves the selected container
  /// along with it. Containers without tabs are skipped so their tree query never
  /// runs.
  ///
  /// "Previous" is a step towards the top of that order and "next" a step
  /// towards its end, so direction follows `tabListDirection` (baked into the
  /// order) rather than `tabBarDirection`. The two only disagree when the user
  /// sets them apart, and the rendered order is the one the sequence is built
  /// from.
  ///
  /// The tray's own search results are deliberately not part of this: the swipe
  /// and the gestures are only reachable with the tray closed.
  ///
  /// `null` means the underlying tree data has not arrived yet — the only state
  /// in which the caller may fall back to storage order. An empty list is a real
  /// answer ("the filter leaves nothing to move to") and must not be mistaken for
  /// a missing one, or the filter the user set would be bypassed.
  ///
  /// Kept alive and actively listened to by [TabRepository]: it is consumed by a
  /// synchronous `ref.read` at the moment of the swipe/gesture, from outside the
  /// widget tree. Without a listener Riverpod pauses the chain when nothing is on
  /// screen watching it, so the order could go stale — or be created empty on the
  /// read, with its tree stream still loading, and silently drop navigation back
  /// to storage order. The selected container's chain is alive anyway whenever the
  /// quick tab switcher or the tray is on screen; the price of crossing container
  /// boundaries is that the other populated containers' tree queries are kept
  /// alive too.
  SequentialTabNavigationOrderProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sequentialTabNavigationOrderProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sequentialTabNavigationOrderHash();

  @$internal
  @override
  $ProviderElement<EquatableValue<List<String>?>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  EquatableValue<List<String>?> create(Ref ref) {
    return sequentialTabNavigationOrder(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(EquatableValue<List<String>?> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<EquatableValue<List<String>?>>(
        value,
      ),
    );
  }
}

String _$sequentialTabNavigationOrderHash() =>
    r'cd8f2337012473028084f2efb1bff540e80abdf4';
