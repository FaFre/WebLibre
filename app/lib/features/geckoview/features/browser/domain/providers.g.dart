// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$availableTabIdsHash() => r'ec3691063293e1c19c997f7b60178938ae631c7f';

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
class AvailableTabIdsFamily extends Family<EquatableValue<List<String>>> {
  /// See also [availableTabIds].
  const AvailableTabIdsFamily();

  /// See also [availableTabIds].
  AvailableTabIdsProvider call(ContainerFilter containerFilter) {
    return AvailableTabIdsProvider(containerFilter);
  }

  @override
  AvailableTabIdsProvider getProviderOverride(
    covariant AvailableTabIdsProvider provider,
  ) {
    return call(provider.containerFilter);
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
    extends AutoDisposeProvider<EquatableValue<List<String>>> {
  /// See also [availableTabIds].
  AvailableTabIdsProvider(ContainerFilter containerFilter)
    : this._internal(
        (ref) => availableTabIds(ref as AvailableTabIdsRef, containerFilter),
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
    EquatableValue<List<String>> Function(AvailableTabIdsRef provider) create,
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
  AutoDisposeProviderElement<EquatableValue<List<String>>> createElement() {
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
    on AutoDisposeProviderRef<EquatableValue<List<String>>> {
  /// The parameter `containerFilter` of this provider.
  ContainerFilter get containerFilter;
}

class _AvailableTabIdsProviderElement
    extends AutoDisposeProviderElement<EquatableValue<List<String>>>
    with AvailableTabIdsRef {
  _AvailableTabIdsProviderElement(super.provider);

  @override
  ContainerFilter get containerFilter =>
      (origin as AvailableTabIdsProvider).containerFilter;
}

String _$availableTabStatesHash() =>
    r'f506b050e1dc4f50fbd2699d97af5a16a037bc4b';

/// See also [availableTabStates].
@ProviderFor(availableTabStates)
const availableTabStatesProvider = AvailableTabStatesFamily();

/// See also [availableTabStates].
class AvailableTabStatesFamily
    extends Family<EquatableValue<Map<String, TabState>>> {
  /// See also [availableTabStates].
  const AvailableTabStatesFamily();

  /// See also [availableTabStates].
  AvailableTabStatesProvider call(ContainerFilter containerFilter) {
    return AvailableTabStatesProvider(containerFilter);
  }

  @override
  AvailableTabStatesProvider getProviderOverride(
    covariant AvailableTabStatesProvider provider,
  ) {
    return call(provider.containerFilter);
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
    extends AutoDisposeProvider<EquatableValue<Map<String, TabState>>> {
  /// See also [availableTabStates].
  AvailableTabStatesProvider(ContainerFilter containerFilter)
    : this._internal(
        (ref) =>
            availableTabStates(ref as AvailableTabStatesRef, containerFilter),
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
    EquatableValue<Map<String, TabState>> Function(
      AvailableTabStatesRef provider,
    )
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
  AutoDisposeProviderElement<EquatableValue<Map<String, TabState>>>
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
    on AutoDisposeProviderRef<EquatableValue<Map<String, TabState>>> {
  /// The parameter `containerFilter` of this provider.
  ContainerFilter get containerFilter;
}

class _AvailableTabStatesProviderElement
    extends AutoDisposeProviderElement<EquatableValue<Map<String, TabState>>>
    with AvailableTabStatesRef {
  _AvailableTabStatesProviderElement(super.provider);

  @override
  ContainerFilter get containerFilter =>
      (origin as AvailableTabStatesProvider).containerFilter;
}

String _$seamlessFilteredTabIdsHash() =>
    r'171e0b942735066e25894dc2c1d99c367bf0d01a';

/// See also [seamlessFilteredTabIds].
@ProviderFor(seamlessFilteredTabIds)
const seamlessFilteredTabIdsProvider = SeamlessFilteredTabIdsFamily();

/// See also [seamlessFilteredTabIds].
class SeamlessFilteredTabIdsFamily
    extends Family<EquatableValue<List<String>>> {
  /// See also [seamlessFilteredTabIds].
  const SeamlessFilteredTabIdsFamily();

  /// See also [seamlessFilteredTabIds].
  SeamlessFilteredTabIdsProvider call(
    TabSearchPartition searchPartition,
    ContainerFilter containerFilter,
  ) {
    return SeamlessFilteredTabIdsProvider(searchPartition, containerFilter);
  }

  @override
  SeamlessFilteredTabIdsProvider getProviderOverride(
    covariant SeamlessFilteredTabIdsProvider provider,
  ) {
    return call(provider.searchPartition, provider.containerFilter);
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
    extends AutoDisposeProvider<EquatableValue<List<String>>> {
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
    EquatableValue<List<String>> Function(SeamlessFilteredTabIdsRef provider)
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
  AutoDisposeProviderElement<EquatableValue<List<String>>> createElement() {
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
    on AutoDisposeProviderRef<EquatableValue<List<String>>> {
  /// The parameter `searchPartition` of this provider.
  TabSearchPartition get searchPartition;

  /// The parameter `containerFilter` of this provider.
  ContainerFilter get containerFilter;
}

class _SeamlessFilteredTabIdsProviderElement
    extends AutoDisposeProviderElement<EquatableValue<List<String>>>
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
    r'c59c2819eda4f132e1a0f5f7784ddb3b5ceec817';

/// See also [seamlessFilteredTabPreviews].
@ProviderFor(seamlessFilteredTabPreviews)
const seamlessFilteredTabPreviewsProvider = SeamlessFilteredTabPreviewsFamily();

/// See also [seamlessFilteredTabPreviews].
class SeamlessFilteredTabPreviewsFamily
    extends Family<EquatableValue<List<TabPreview>>> {
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
    return call(provider.searchPartition, provider.containerFilter);
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
    extends AutoDisposeProvider<EquatableValue<List<TabPreview>>> {
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
    EquatableValue<List<TabPreview>> Function(
      SeamlessFilteredTabPreviewsRef provider,
    )
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
  AutoDisposeProviderElement<EquatableValue<List<TabPreview>>> createElement() {
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
    on AutoDisposeProviderRef<EquatableValue<List<TabPreview>>> {
  /// The parameter `searchPartition` of this provider.
  TabSearchPartition get searchPartition;

  /// The parameter `containerFilter` of this provider.
  ContainerFilter get containerFilter;
}

class _SeamlessFilteredTabPreviewsProviderElement
    extends AutoDisposeProviderElement<EquatableValue<List<TabPreview>>>
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

  String? build({String? domain});
}

/// See also [SelectedBangTrigger].
@ProviderFor(SelectedBangTrigger)
const selectedBangTriggerProvider = SelectedBangTriggerFamily();

/// See also [SelectedBangTrigger].
class SelectedBangTriggerFamily extends Family<String?> {
  /// See also [SelectedBangTrigger].
  const SelectedBangTriggerFamily();

  /// See also [SelectedBangTrigger].
  SelectedBangTriggerProvider call({String? domain}) {
    return SelectedBangTriggerProvider(domain: domain);
  }

  @override
  SelectedBangTriggerProvider getProviderOverride(
    covariant SelectedBangTriggerProvider provider,
  ) {
    return call(domain: provider.domain);
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
  SelectedBangTriggerProvider({String? domain})
    : this._internal(
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
  String? runNotifierBuild(covariant SelectedBangTrigger notifier) {
    return notifier.build(domain: domain);
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

String _$selectedBangDataHash() => r'666858556efe59d2de38a04fda30e8ec227c6675';

abstract class _$SelectedBangData
    extends BuildlessAutoDisposeNotifier<BangData?> {
  late final String? domain;

  BangData? build({String? domain});
}

/// See also [SelectedBangData].
@ProviderFor(SelectedBangData)
const selectedBangDataProvider = SelectedBangDataFamily();

/// See also [SelectedBangData].
class SelectedBangDataFamily extends Family<BangData?> {
  /// See also [SelectedBangData].
  const SelectedBangDataFamily();

  /// See also [SelectedBangData].
  SelectedBangDataProvider call({String? domain}) {
    return SelectedBangDataProvider(domain: domain);
  }

  @override
  SelectedBangDataProvider getProviderOverride(
    covariant SelectedBangDataProvider provider,
  ) {
    return call(domain: provider.domain);
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
  SelectedBangDataProvider({String? domain})
    : this._internal(
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
  BangData? runNotifierBuild(covariant SelectedBangData notifier) {
    return notifier.build(domain: domain);
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

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
