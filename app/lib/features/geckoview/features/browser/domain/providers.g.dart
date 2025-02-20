// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$availableTabIdsHash() => r'e5c5f25dea67f7739dfb1d0d9e4453079817a7bc';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [availableTabIds].
@ProviderFor(availableTabIds)
const availableTabIdsProvider = AvailableTabIdsFamily();

/// See also [availableTabIds].
class AvailableTabIdsFamily extends Family<EquatableCollection<List<String>>> {
  /// See also [availableTabIds].
  const AvailableTabIdsFamily();

  /// See also [availableTabIds].
  AvailableTabIdsProvider call(
    ContainerFilter containerFilter,
  ) {
    return AvailableTabIdsProvider(
      containerFilter,
    );
  }

  @override
  AvailableTabIdsProvider getProviderOverride(
    covariant AvailableTabIdsProvider provider,
  ) {
    return call(
      provider.containerFilter,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'availableTabIdsProvider';
}

/// See also [availableTabIds].
class AvailableTabIdsProvider
    extends AutoDisposeProvider<EquatableCollection<List<String>>> {
  /// See also [availableTabIds].
  AvailableTabIdsProvider(
    ContainerFilter containerFilter,
  ) : this._internal(
          (ref) => availableTabIds(
            ref as AvailableTabIdsRef,
            containerFilter,
          ),
          from: availableTabIdsProvider,
          name: r'availableTabIdsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$availableTabIdsHash,
          dependencies: AvailableTabIdsFamily._dependencies,
          allTransitiveDependencies:
              AvailableTabIdsFamily._allTransitiveDependencies,
          containerFilter: containerFilter,
        );

  AvailableTabIdsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.containerFilter,
  }) : super.internal();

  final ContainerFilter containerFilter;

  @override
  Override overrideWith(
    EquatableCollection<List<String>> Function(AvailableTabIdsRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: AvailableTabIdsProvider._internal(
        (ref) => create(ref as AvailableTabIdsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        containerFilter: containerFilter,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<EquatableCollection<List<String>>>
      createElement() {
    return _AvailableTabIdsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AvailableTabIdsProvider &&
        other.containerFilter == containerFilter;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, containerFilter.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin AvailableTabIdsRef
    on AutoDisposeProviderRef<EquatableCollection<List<String>>> {
  /// The parameter `containerFilter` of this provider.
  ContainerFilter get containerFilter;
}

class _AvailableTabIdsProviderElement
    extends AutoDisposeProviderElement<EquatableCollection<List<String>>>
    with AvailableTabIdsRef {
  _AvailableTabIdsProviderElement(super.provider);

  @override
  ContainerFilter get containerFilter =>
      (origin as AvailableTabIdsProvider).containerFilter;
}

String _$availableTabStatesHash() =>
    r'ca42dc8cb88070fb58ab085ab6c9bcbf31ef4f0b';

/// See also [availableTabStates].
@ProviderFor(availableTabStates)
const availableTabStatesProvider = AvailableTabStatesFamily();

/// See also [availableTabStates].
class AvailableTabStatesFamily
    extends Family<EquatableCollection<Map<String, TabState>>> {
  /// See also [availableTabStates].
  const AvailableTabStatesFamily();

  /// See also [availableTabStates].
  AvailableTabStatesProvider call(
    ContainerFilter containerFilter,
  ) {
    return AvailableTabStatesProvider(
      containerFilter,
    );
  }

  @override
  AvailableTabStatesProvider getProviderOverride(
    covariant AvailableTabStatesProvider provider,
  ) {
    return call(
      provider.containerFilter,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'availableTabStatesProvider';
}

/// See also [availableTabStates].
class AvailableTabStatesProvider
    extends AutoDisposeProvider<EquatableCollection<Map<String, TabState>>> {
  /// See also [availableTabStates].
  AvailableTabStatesProvider(
    ContainerFilter containerFilter,
  ) : this._internal(
          (ref) => availableTabStates(
            ref as AvailableTabStatesRef,
            containerFilter,
          ),
          from: availableTabStatesProvider,
          name: r'availableTabStatesProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$availableTabStatesHash,
          dependencies: AvailableTabStatesFamily._dependencies,
          allTransitiveDependencies:
              AvailableTabStatesFamily._allTransitiveDependencies,
          containerFilter: containerFilter,
        );

  AvailableTabStatesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.containerFilter,
  }) : super.internal();

  final ContainerFilter containerFilter;

  @override
  Override overrideWith(
    EquatableCollection<Map<String, TabState>> Function(
            AvailableTabStatesRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: AvailableTabStatesProvider._internal(
        (ref) => create(ref as AvailableTabStatesRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        containerFilter: containerFilter,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<EquatableCollection<Map<String, TabState>>>
      createElement() {
    return _AvailableTabStatesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AvailableTabStatesProvider &&
        other.containerFilter == containerFilter;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, containerFilter.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin AvailableTabStatesRef
    on AutoDisposeProviderRef<EquatableCollection<Map<String, TabState>>> {
  /// The parameter `containerFilter` of this provider.
  ContainerFilter get containerFilter;
}

class _AvailableTabStatesProviderElement extends AutoDisposeProviderElement<
    EquatableCollection<Map<String, TabState>>> with AvailableTabStatesRef {
  _AvailableTabStatesProviderElement(super.provider);

  @override
  ContainerFilter get containerFilter =>
      (origin as AvailableTabStatesProvider).containerFilter;
}

String _$seamlessFilteredTabIdsHash() =>
    r'2e29ca53c35be89972d3f9aea24198fe1feb9e05';

/// See also [seamlessFilteredTabIds].
@ProviderFor(seamlessFilteredTabIds)
const seamlessFilteredTabIdsProvider = SeamlessFilteredTabIdsFamily();

/// See also [seamlessFilteredTabIds].
class SeamlessFilteredTabIdsFamily
    extends Family<EquatableCollection<List<String>>> {
  /// See also [seamlessFilteredTabIds].
  const SeamlessFilteredTabIdsFamily();

  /// See also [seamlessFilteredTabIds].
  SeamlessFilteredTabIdsProvider call(
    TabSearchPartition searchPartition,
    ContainerFilter containerFilter,
  ) {
    return SeamlessFilteredTabIdsProvider(
      searchPartition,
      containerFilter,
    );
  }

  @override
  SeamlessFilteredTabIdsProvider getProviderOverride(
    covariant SeamlessFilteredTabIdsProvider provider,
  ) {
    return call(
      provider.searchPartition,
      provider.containerFilter,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'seamlessFilteredTabIdsProvider';
}

/// See also [seamlessFilteredTabIds].
class SeamlessFilteredTabIdsProvider
    extends AutoDisposeProvider<EquatableCollection<List<String>>> {
  /// See also [seamlessFilteredTabIds].
  SeamlessFilteredTabIdsProvider(
    TabSearchPartition searchPartition,
    ContainerFilter containerFilter,
  ) : this._internal(
          (ref) => seamlessFilteredTabIds(
            ref as SeamlessFilteredTabIdsRef,
            searchPartition,
            containerFilter,
          ),
          from: seamlessFilteredTabIdsProvider,
          name: r'seamlessFilteredTabIdsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$seamlessFilteredTabIdsHash,
          dependencies: SeamlessFilteredTabIdsFamily._dependencies,
          allTransitiveDependencies:
              SeamlessFilteredTabIdsFamily._allTransitiveDependencies,
          searchPartition: searchPartition,
          containerFilter: containerFilter,
        );

  SeamlessFilteredTabIdsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.searchPartition,
    required this.containerFilter,
  }) : super.internal();

  final TabSearchPartition searchPartition;
  final ContainerFilter containerFilter;

  @override
  Override overrideWith(
    EquatableCollection<List<String>> Function(
            SeamlessFilteredTabIdsRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: SeamlessFilteredTabIdsProvider._internal(
        (ref) => create(ref as SeamlessFilteredTabIdsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        searchPartition: searchPartition,
        containerFilter: containerFilter,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<EquatableCollection<List<String>>>
      createElement() {
    return _SeamlessFilteredTabIdsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SeamlessFilteredTabIdsProvider &&
        other.searchPartition == searchPartition &&
        other.containerFilter == containerFilter;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, searchPartition.hashCode);
    hash = _SystemHash.combine(hash, containerFilter.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin SeamlessFilteredTabIdsRef
    on AutoDisposeProviderRef<EquatableCollection<List<String>>> {
  /// The parameter `searchPartition` of this provider.
  TabSearchPartition get searchPartition;

  /// The parameter `containerFilter` of this provider.
  ContainerFilter get containerFilter;
}

class _SeamlessFilteredTabIdsProviderElement
    extends AutoDisposeProviderElement<EquatableCollection<List<String>>>
    with SeamlessFilteredTabIdsRef {
  _SeamlessFilteredTabIdsProviderElement(super.provider);

  @override
  TabSearchPartition get searchPartition =>
      (origin as SeamlessFilteredTabIdsProvider).searchPartition;
  @override
  ContainerFilter get containerFilter =>
      (origin as SeamlessFilteredTabIdsProvider).containerFilter;
}

String _$seamlessFilteredTabPreviewsHash() =>
    r'7a70eb2f3f59de5188d94a73790e39c339a6293b';

/// See also [seamlessFilteredTabPreviews].
@ProviderFor(seamlessFilteredTabPreviews)
const seamlessFilteredTabPreviewsProvider = SeamlessFilteredTabPreviewsFamily();

/// See also [seamlessFilteredTabPreviews].
class SeamlessFilteredTabPreviewsFamily
    extends Family<EquatableCollection<List<TabPreview>>> {
  /// See also [seamlessFilteredTabPreviews].
  const SeamlessFilteredTabPreviewsFamily();

  /// See also [seamlessFilteredTabPreviews].
  SeamlessFilteredTabPreviewsProvider call(
    TabSearchPartition searchPartition,
    ContainerFilter containerFilter,
  ) {
    return SeamlessFilteredTabPreviewsProvider(
      searchPartition,
      containerFilter,
    );
  }

  @override
  SeamlessFilteredTabPreviewsProvider getProviderOverride(
    covariant SeamlessFilteredTabPreviewsProvider provider,
  ) {
    return call(
      provider.searchPartition,
      provider.containerFilter,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'seamlessFilteredTabPreviewsProvider';
}

/// See also [seamlessFilteredTabPreviews].
class SeamlessFilteredTabPreviewsProvider
    extends AutoDisposeProvider<EquatableCollection<List<TabPreview>>> {
  /// See also [seamlessFilteredTabPreviews].
  SeamlessFilteredTabPreviewsProvider(
    TabSearchPartition searchPartition,
    ContainerFilter containerFilter,
  ) : this._internal(
          (ref) => seamlessFilteredTabPreviews(
            ref as SeamlessFilteredTabPreviewsRef,
            searchPartition,
            containerFilter,
          ),
          from: seamlessFilteredTabPreviewsProvider,
          name: r'seamlessFilteredTabPreviewsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$seamlessFilteredTabPreviewsHash,
          dependencies: SeamlessFilteredTabPreviewsFamily._dependencies,
          allTransitiveDependencies:
              SeamlessFilteredTabPreviewsFamily._allTransitiveDependencies,
          searchPartition: searchPartition,
          containerFilter: containerFilter,
        );

  SeamlessFilteredTabPreviewsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.searchPartition,
    required this.containerFilter,
  }) : super.internal();

  final TabSearchPartition searchPartition;
  final ContainerFilter containerFilter;

  @override
  Override overrideWith(
    EquatableCollection<List<TabPreview>> Function(
            SeamlessFilteredTabPreviewsRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: SeamlessFilteredTabPreviewsProvider._internal(
        (ref) => create(ref as SeamlessFilteredTabPreviewsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        searchPartition: searchPartition,
        containerFilter: containerFilter,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<EquatableCollection<List<TabPreview>>>
      createElement() {
    return _SeamlessFilteredTabPreviewsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SeamlessFilteredTabPreviewsProvider &&
        other.searchPartition == searchPartition &&
        other.containerFilter == containerFilter;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, searchPartition.hashCode);
    hash = _SystemHash.combine(hash, containerFilter.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin SeamlessFilteredTabPreviewsRef
    on AutoDisposeProviderRef<EquatableCollection<List<TabPreview>>> {
  /// The parameter `searchPartition` of this provider.
  TabSearchPartition get searchPartition;

  /// The parameter `containerFilter` of this provider.
  ContainerFilter get containerFilter;
}

class _SeamlessFilteredTabPreviewsProviderElement
    extends AutoDisposeProviderElement<EquatableCollection<List<TabPreview>>>
    with SeamlessFilteredTabPreviewsRef {
  _SeamlessFilteredTabPreviewsProviderElement(super.provider);

  @override
  TabSearchPartition get searchPartition =>
      (origin as SeamlessFilteredTabPreviewsProvider).searchPartition;
  @override
  ContainerFilter get containerFilter =>
      (origin as SeamlessFilteredTabPreviewsProvider).containerFilter;
}

String _$selectedBangTriggerHash() =>
    r'b0e12bc95e93d50d04f1c658230cea9f15ff0385';

abstract class _$SelectedBangTrigger extends BuildlessNotifier<String?> {
  late final String? domain;

  String? build({
    String? domain,
  });
}

/// See also [SelectedBangTrigger].
@ProviderFor(SelectedBangTrigger)
const selectedBangTriggerProvider = SelectedBangTriggerFamily();

/// See also [SelectedBangTrigger].
class SelectedBangTriggerFamily extends Family<String?> {
  /// See also [SelectedBangTrigger].
  const SelectedBangTriggerFamily();

  /// See also [SelectedBangTrigger].
  SelectedBangTriggerProvider call({
    String? domain,
  }) {
    return SelectedBangTriggerProvider(
      domain: domain,
    );
  }

  @override
  SelectedBangTriggerProvider getProviderOverride(
    covariant SelectedBangTriggerProvider provider,
  ) {
    return call(
      domain: provider.domain,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'selectedBangTriggerProvider';
}

/// See also [SelectedBangTrigger].
class SelectedBangTriggerProvider
    extends NotifierProviderImpl<SelectedBangTrigger, String?> {
  /// See also [SelectedBangTrigger].
  SelectedBangTriggerProvider({
    String? domain,
  }) : this._internal(
          () => SelectedBangTrigger()..domain = domain,
          from: selectedBangTriggerProvider,
          name: r'selectedBangTriggerProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$selectedBangTriggerHash,
          dependencies: SelectedBangTriggerFamily._dependencies,
          allTransitiveDependencies:
              SelectedBangTriggerFamily._allTransitiveDependencies,
          domain: domain,
        );

  SelectedBangTriggerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.domain,
  }) : super.internal();

  final String? domain;

  @override
  String? runNotifierBuild(
    covariant SelectedBangTrigger notifier,
  ) {
    return notifier.build(
      domain: domain,
    );
  }

  @override
  Override overrideWith(SelectedBangTrigger Function() create) {
    return ProviderOverride(
      origin: this,
      override: SelectedBangTriggerProvider._internal(
        () => create()..domain = domain,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        domain: domain,
      ),
    );
  }

  @override
  NotifierProviderElement<SelectedBangTrigger, String?> createElement() {
    return _SelectedBangTriggerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SelectedBangTriggerProvider && other.domain == domain;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, domain.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin SelectedBangTriggerRef on NotifierProviderRef<String?> {
  /// The parameter `domain` of this provider.
  String? get domain;
}

class _SelectedBangTriggerProviderElement
    extends NotifierProviderElement<SelectedBangTrigger, String?>
    with SelectedBangTriggerRef {
  _SelectedBangTriggerProviderElement(super.provider);

  @override
  String? get domain => (origin as SelectedBangTriggerProvider).domain;
}

String _$selectedBangDataHash() => r'28c394e5989e108870ca5733e916b80b3cf8972c';

abstract class _$SelectedBangData
    extends BuildlessAutoDisposeNotifier<BangData?> {
  late final String? domain;

  BangData? build({
    String? domain,
  });
}

/// See also [SelectedBangData].
@ProviderFor(SelectedBangData)
const selectedBangDataProvider = SelectedBangDataFamily();

/// See also [SelectedBangData].
class SelectedBangDataFamily extends Family<BangData?> {
  /// See also [SelectedBangData].
  const SelectedBangDataFamily();

  /// See also [SelectedBangData].
  SelectedBangDataProvider call({
    String? domain,
  }) {
    return SelectedBangDataProvider(
      domain: domain,
    );
  }

  @override
  SelectedBangDataProvider getProviderOverride(
    covariant SelectedBangDataProvider provider,
  ) {
    return call(
      domain: provider.domain,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'selectedBangDataProvider';
}

/// See also [SelectedBangData].
class SelectedBangDataProvider
    extends AutoDisposeNotifierProviderImpl<SelectedBangData, BangData?> {
  /// See also [SelectedBangData].
  SelectedBangDataProvider({
    String? domain,
  }) : this._internal(
          () => SelectedBangData()..domain = domain,
          from: selectedBangDataProvider,
          name: r'selectedBangDataProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$selectedBangDataHash,
          dependencies: SelectedBangDataFamily._dependencies,
          allTransitiveDependencies:
              SelectedBangDataFamily._allTransitiveDependencies,
          domain: domain,
        );

  SelectedBangDataProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.domain,
  }) : super.internal();

  final String? domain;

  @override
  BangData? runNotifierBuild(
    covariant SelectedBangData notifier,
  ) {
    return notifier.build(
      domain: domain,
    );
  }

  @override
  Override overrideWith(SelectedBangData Function() create) {
    return ProviderOverride(
      origin: this,
      override: SelectedBangDataProvider._internal(
        () => create()..domain = domain,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        domain: domain,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<SelectedBangData, BangData?>
      createElement() {
    return _SelectedBangDataProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SelectedBangDataProvider && other.domain == domain;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, domain.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin SelectedBangDataRef on AutoDisposeNotifierProviderRef<BangData?> {
  /// The parameter `domain` of this provider.
  String? get domain;
}

class _SelectedBangDataProviderElement
    extends AutoDisposeNotifierProviderElement<SelectedBangData, BangData?>
    with SelectedBangDataRef {
  _SelectedBangDataProviderElement(super.provider);

  @override
  String? get domain => (origin as SelectedBangDataProvider).domain;
}

String _$showFindInPageHash() => r'7ee5703f7d0c7e8a8dd6b0849d7b1e0a41fe24d9';

/// See also [ShowFindInPage].
@ProviderFor(ShowFindInPage)
final showFindInPageProvider = NotifierProvider<ShowFindInPage, bool>.internal(
  ShowFindInPage.new,
  name: r'showFindInPageProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$showFindInPageHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ShowFindInPage = Notifier<bool>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
