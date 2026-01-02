// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

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
  void runBuild() {
    final ref = this.ref as $Ref<BangKey?, BangKey?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<BangKey?, BangKey?>,
              BangKey?,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(domain: _$args));
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
  void runBuild() {
    final ref = this.ref as $Ref<BangData?, BangData?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<BangData?, BangData?>,
              BangData?,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(domain: _$args));
  }
}

@ProviderFor(availableTabIds)
final availableTabIdsProvider = AvailableTabIdsFamily._();

final class AvailableTabIdsProvider
    extends
        $FunctionalProvider<
          EquatableValue<List<DefaultTabEntity>>,
          EquatableValue<List<DefaultTabEntity>>,
          EquatableValue<List<DefaultTabEntity>>
        >
    with $Provider<EquatableValue<List<DefaultTabEntity>>> {
  AvailableTabIdsProvider._({
    required AvailableTabIdsFamily super.from,
    required ContainerFilter super.argument,
  }) : super(
         retry: null,
         name: r'availableTabIdsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$availableTabIdsHash();

  @override
  String toString() {
    return r'availableTabIdsProvider'
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
    return availableTabIds(ref, argument);
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
    return other is AvailableTabIdsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$availableTabIdsHash() => r'fa7280a7a5f9c277faa71a30f5dd50afa30a20b1';

final class AvailableTabIdsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          EquatableValue<List<DefaultTabEntity>>,
          ContainerFilter
        > {
  AvailableTabIdsFamily._()
    : super(
        retry: null,
        name: r'availableTabIdsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  AvailableTabIdsProvider call(ContainerFilter containerFilter) =>
      AvailableTabIdsProvider._(argument: containerFilter, from: this);

  @override
  String toString() => r'availableTabIdsProvider';
}

@ProviderFor(availableTabStates)
final availableTabStatesProvider = AvailableTabStatesFamily._();

final class AvailableTabStatesProvider
    extends
        $FunctionalProvider<
          EquatableValue<Map<String, TabState>>,
          EquatableValue<Map<String, TabState>>,
          EquatableValue<Map<String, TabState>>
        >
    with $Provider<EquatableValue<Map<String, TabState>>> {
  AvailableTabStatesProvider._({
    required AvailableTabStatesFamily super.from,
    required ContainerFilter super.argument,
  }) : super(
         retry: null,
         name: r'availableTabStatesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$availableTabStatesHash();

  @override
  String toString() {
    return r'availableTabStatesProvider'
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
    return availableTabStates(ref, argument);
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
    return other is AvailableTabStatesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$availableTabStatesHash() =>
    r'32f15b0f739495e11025bdc10d324764465b542d';

final class AvailableTabStatesFamily extends $Family
    with
        $FunctionalFamilyOverride<
          EquatableValue<Map<String, TabState>>,
          ContainerFilter
        > {
  AvailableTabStatesFamily._()
    : super(
        retry: null,
        name: r'availableTabStatesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  AvailableTabStatesProvider call(ContainerFilter containerFilter) =>
      AvailableTabStatesProvider._(argument: containerFilter, from: this);

  @override
  String toString() => r'availableTabStatesProvider';
}

@ProviderFor(fifoTabStates)
final fifoTabStatesProvider = FifoTabStatesProvider._();

final class FifoTabStatesProvider
    extends
        $FunctionalProvider<
          EquatableValue<List<FifoTab>>,
          EquatableValue<List<FifoTab>>,
          EquatableValue<List<FifoTab>>
        >
    with $Provider<EquatableValue<List<FifoTab>>> {
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
  $ProviderElement<EquatableValue<List<FifoTab>>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  EquatableValue<List<FifoTab>> create(Ref ref) {
    return fifoTabStates(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(EquatableValue<List<FifoTab>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<EquatableValue<List<FifoTab>>>(
        value,
      ),
    );
  }
}

String _$fifoTabStatesHash() => r'0320c28b328d814ed358ec6a10ec770a1ed634ad';

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
    r'1c3d9a4f85db60301fe5c5b55fb55512d1b59696';

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
    r'f2bf14737bc03f71fc61252359979b4e901e5df7';

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
    r'9fbf6774433e62ce9b63ef66f6db3446e6182109';

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
