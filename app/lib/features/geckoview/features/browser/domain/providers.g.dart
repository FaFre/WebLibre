// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SelectedBangTrigger)
const selectedBangTriggerProvider = SelectedBangTriggerFamily._();

final class SelectedBangTriggerProvider
    extends $NotifierProvider<SelectedBangTrigger, BangKey?> {
  const SelectedBangTriggerProvider._({
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
  const SelectedBangTriggerFamily._()
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
    final created = build(domain: _$args);
    final ref = this.ref as $Ref<BangKey?, BangKey?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<BangKey?, BangKey?>,
              BangKey?,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(SelectedBangData)
const selectedBangDataProvider = SelectedBangDataFamily._();

final class SelectedBangDataProvider
    extends $NotifierProvider<SelectedBangData, BangData?> {
  const SelectedBangDataProvider._({
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

String _$selectedBangDataHash() => r'666858556efe59d2de38a04fda30e8ec227c6675';

final class SelectedBangDataFamily extends $Family
    with
        $ClassFamilyOverride<
          SelectedBangData,
          BangData?,
          BangData?,
          BangData?,
          String?
        > {
  const SelectedBangDataFamily._()
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
    final created = build(domain: _$args);
    final ref = this.ref as $Ref<BangData?, BangData?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<BangData?, BangData?>,
              BangData?,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(availableTabIds)
const availableTabIdsProvider = AvailableTabIdsFamily._();

final class AvailableTabIdsProvider
    extends
        $FunctionalProvider<
          EquatableValue<List<String>>,
          EquatableValue<List<String>>,
          EquatableValue<List<String>>
        >
    with $Provider<EquatableValue<List<String>>> {
  const AvailableTabIdsProvider._({
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
  $ProviderElement<EquatableValue<List<String>>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  EquatableValue<List<String>> create(Ref ref) {
    final argument = this.argument as ContainerFilter;
    return availableTabIds(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(EquatableValue<List<String>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<EquatableValue<List<String>>>(value),
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

String _$availableTabIdsHash() => r'aa166b471d45913df5166a3126abeb7c0d791412';

final class AvailableTabIdsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          EquatableValue<List<String>>,
          ContainerFilter
        > {
  const AvailableTabIdsFamily._()
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
const availableTabStatesProvider = AvailableTabStatesFamily._();

final class AvailableTabStatesProvider
    extends
        $FunctionalProvider<
          EquatableValue<Map<String, TabState>>,
          EquatableValue<Map<String, TabState>>,
          EquatableValue<Map<String, TabState>>
        >
    with $Provider<EquatableValue<Map<String, TabState>>> {
  const AvailableTabStatesProvider._({
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
    r'f506b050e1dc4f50fbd2699d97af5a16a037bc4b';

final class AvailableTabStatesFamily extends $Family
    with
        $FunctionalFamilyOverride<
          EquatableValue<Map<String, TabState>>,
          ContainerFilter
        > {
  const AvailableTabStatesFamily._()
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
const fifoTabStatesProvider = FifoTabStatesProvider._();

final class FifoTabStatesProvider
    extends
        $FunctionalProvider<
          EquatableValue<List<FifoTab>>,
          EquatableValue<List<FifoTab>>,
          EquatableValue<List<FifoTab>>
        >
    with $Provider<EquatableValue<List<FifoTab>>> {
  const FifoTabStatesProvider._()
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
const suggestedTabEntitiesProvider = SuggestedTabEntitiesFamily._();

final class SuggestedTabEntitiesProvider
    extends
        $FunctionalProvider<
          EquatableValue<List<TabEntity>>,
          EquatableValue<List<TabEntity>>,
          EquatableValue<List<TabEntity>>
        >
    with $Provider<EquatableValue<List<TabEntity>>> {
  const SuggestedTabEntitiesProvider._({
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
    r'6fb58bf4b7377f826377c88110c8e4aca9f6d6f9';

final class SuggestedTabEntitiesFamily extends $Family
    with $FunctionalFamilyOverride<EquatableValue<List<TabEntity>>, String?> {
  const SuggestedTabEntitiesFamily._()
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
const seamlessFilteredTabEntitiesProvider =
    SeamlessFilteredTabEntitiesFamily._();

final class SeamlessFilteredTabEntitiesProvider
    extends
        $FunctionalProvider<
          EquatableValue<List<TabEntity>>,
          EquatableValue<List<TabEntity>>,
          EquatableValue<List<TabEntity>>
        >
    with $Provider<EquatableValue<List<TabEntity>>> {
  const SeamlessFilteredTabEntitiesProvider._({
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
    r'eb6573514f55b598fbc1a91370079b4b8372c55e';

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
  const SeamlessFilteredTabEntitiesFamily._()
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

@ProviderFor(seamlessFilteredTabPreviews)
const seamlessFilteredTabPreviewsProvider =
    SeamlessFilteredTabPreviewsFamily._();

final class SeamlessFilteredTabPreviewsProvider
    extends
        $FunctionalProvider<
          EquatableValue<List<TabPreview>>,
          EquatableValue<List<TabPreview>>,
          EquatableValue<List<TabPreview>>
        >
    with $Provider<EquatableValue<List<TabPreview>>> {
  const SeamlessFilteredTabPreviewsProvider._({
    required SeamlessFilteredTabPreviewsFamily super.from,
    required (TabSearchPartition, ContainerFilter) super.argument,
  }) : super(
         retry: null,
         name: r'seamlessFilteredTabPreviewsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$seamlessFilteredTabPreviewsHash();

  @override
  String toString() {
    return r'seamlessFilteredTabPreviewsProvider'
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
    return seamlessFilteredTabPreviews(ref, argument.$1, argument.$2);
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
    return other is SeamlessFilteredTabPreviewsProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$seamlessFilteredTabPreviewsHash() =>
    r'ee1d441ca5f5822e201de8fc0b264ea7b8db0776';

final class SeamlessFilteredTabPreviewsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          EquatableValue<List<TabPreview>>,
          (TabSearchPartition, ContainerFilter)
        > {
  const SeamlessFilteredTabPreviewsFamily._()
    : super(
        retry: null,
        name: r'seamlessFilteredTabPreviewsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  SeamlessFilteredTabPreviewsProvider call(
    TabSearchPartition searchPartition,
    ContainerFilter containerFilter,
  ) => SeamlessFilteredTabPreviewsProvider._(
    argument: (searchPartition, containerFilter),
    from: this,
  );

  @override
  String toString() => r'seamlessFilteredTabPreviewsProvider';
}
