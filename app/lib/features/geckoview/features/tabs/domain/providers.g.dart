// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$containersWithCountHash() =>
    r'ee0734e4b71472b79636816616a158f54fa6bc23';

/// See also [containersWithCount].
@ProviderFor(containersWithCount)
final containersWithCountProvider =
    AutoDisposeStreamProvider<List<ContainerDataWithCount>>.internal(
      containersWithCount,
      name: r'containersWithCountProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$containersWithCountHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ContainersWithCountRef =
    AutoDisposeStreamProviderRef<List<ContainerDataWithCount>>;
String _$matchSortedContainersWithCountHash() =>
    r'bc2077602c3c1d86c5b916e4ad920053310993e4';

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

/// See also [matchSortedContainersWithCount].
@ProviderFor(matchSortedContainersWithCount)
const matchSortedContainersWithCountProvider =
    MatchSortedContainersWithCountFamily();

/// See also [matchSortedContainersWithCount].
class MatchSortedContainersWithCountFamily
    extends Family<AsyncValue<List<ContainerDataWithCount>>> {
  /// See also [matchSortedContainersWithCount].
  const MatchSortedContainersWithCountFamily();

  /// See also [matchSortedContainersWithCount].
  MatchSortedContainersWithCountProvider call(String? searchText) {
    return MatchSortedContainersWithCountProvider(searchText);
  }

  @override
  MatchSortedContainersWithCountProvider getProviderOverride(
    covariant MatchSortedContainersWithCountProvider provider,
  ) {
    return call(provider.searchText);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'matchSortedContainersWithCountProvider';
}

/// See also [matchSortedContainersWithCount].
class MatchSortedContainersWithCountProvider
    extends AutoDisposeProvider<AsyncValue<List<ContainerDataWithCount>>> {
  /// See also [matchSortedContainersWithCount].
  MatchSortedContainersWithCountProvider(String? searchText)
    : this._internal(
        (ref) => matchSortedContainersWithCount(
          ref as MatchSortedContainersWithCountRef,
          searchText,
        ),
        from: matchSortedContainersWithCountProvider,
        name: r'matchSortedContainersWithCountProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$matchSortedContainersWithCountHash,
        dependencies: MatchSortedContainersWithCountFamily._dependencies,
        allTransitiveDependencies:
            MatchSortedContainersWithCountFamily._allTransitiveDependencies,
        searchText: searchText,
      );

  MatchSortedContainersWithCountProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.searchText,
  }) : super.internal();

  final String? searchText;

  @override
  Override overrideWith(
    AsyncValue<List<ContainerDataWithCount>> Function(
      MatchSortedContainersWithCountRef provider,
    )
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: MatchSortedContainersWithCountProvider._internal(
        (ref) => create(ref as MatchSortedContainersWithCountRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        searchText: searchText,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<AsyncValue<List<ContainerDataWithCount>>>
  createElement() {
    return _MatchSortedContainersWithCountProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MatchSortedContainersWithCountProvider &&
        other.searchText == searchText;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, searchText.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin MatchSortedContainersWithCountRef
    on AutoDisposeProviderRef<AsyncValue<List<ContainerDataWithCount>>> {
  /// The parameter `searchText` of this provider.
  String? get searchText;
}

class _MatchSortedContainersWithCountProviderElement
    extends AutoDisposeProviderElement<AsyncValue<List<ContainerDataWithCount>>>
    with MatchSortedContainersWithCountRef {
  _MatchSortedContainersWithCountProviderElement(super.provider);

  @override
  String? get searchText =>
      (origin as MatchSortedContainersWithCountProvider).searchText;
}

String _$containerTabIdsHash() => r'61716a2ae74ffa590c1498d259382e69e24ad7f1';

/// See also [containerTabIds].
@ProviderFor(containerTabIds)
const containerTabIdsProvider = ContainerTabIdsFamily();

/// See also [containerTabIds].
class ContainerTabIdsFamily extends Family<AsyncValue<List<String>>> {
  /// See also [containerTabIds].
  const ContainerTabIdsFamily();

  /// See also [containerTabIds].
  ContainerTabIdsProvider call(ContainerFilter containerFilter) {
    return ContainerTabIdsProvider(containerFilter);
  }

  @override
  ContainerTabIdsProvider getProviderOverride(
    covariant ContainerTabIdsProvider provider,
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
  String? get name => r'containerTabIdsProvider';
}

/// See also [containerTabIds].
class ContainerTabIdsProvider extends AutoDisposeStreamProvider<List<String>> {
  /// See also [containerTabIds].
  ContainerTabIdsProvider(ContainerFilter containerFilter)
    : this._internal(
        (ref) => containerTabIds(ref as ContainerTabIdsRef, containerFilter),
        from: containerTabIdsProvider,
        name: r'containerTabIdsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$containerTabIdsHash,
        dependencies: ContainerTabIdsFamily._dependencies,
        allTransitiveDependencies:
            ContainerTabIdsFamily._allTransitiveDependencies,
        containerFilter: containerFilter,
      );

  ContainerTabIdsProvider._internal(
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
    Stream<List<String>> Function(ContainerTabIdsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ContainerTabIdsProvider._internal(
        (ref) => create(ref as ContainerTabIdsRef),
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
  AutoDisposeStreamProviderElement<List<String>> createElement() {
    return _ContainerTabIdsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ContainerTabIdsProvider &&
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
mixin ContainerTabIdsRef on AutoDisposeStreamProviderRef<List<String>> {
  /// The parameter `containerFilter` of this provider.
  ContainerFilter get containerFilter;
}

class _ContainerTabIdsProviderElement
    extends AutoDisposeStreamProviderElement<List<String>>
    with ContainerTabIdsRef {
  _ContainerTabIdsProviderElement(super.provider);

  @override
  ContainerFilter get containerFilter =>
      (origin as ContainerTabIdsProvider).containerFilter;
}

String _$containerTabCountHash() => r'586e83429b527b546d43232a58453635ab860d69';

/// See also [containerTabCount].
@ProviderFor(containerTabCount)
const containerTabCountProvider = ContainerTabCountFamily();

/// See also [containerTabCount].
class ContainerTabCountFamily extends Family<AsyncValue<int>> {
  /// See also [containerTabCount].
  const ContainerTabCountFamily();

  /// See also [containerTabCount].
  ContainerTabCountProvider call(ContainerFilter containerFilter) {
    return ContainerTabCountProvider(containerFilter);
  }

  @override
  ContainerTabCountProvider getProviderOverride(
    covariant ContainerTabCountProvider provider,
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
  String? get name => r'containerTabCountProvider';
}

/// See also [containerTabCount].
class ContainerTabCountProvider extends AutoDisposeFutureProvider<int> {
  /// See also [containerTabCount].
  ContainerTabCountProvider(ContainerFilter containerFilter)
    : this._internal(
        (ref) =>
            containerTabCount(ref as ContainerTabCountRef, containerFilter),
        from: containerTabCountProvider,
        name: r'containerTabCountProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$containerTabCountHash,
        dependencies: ContainerTabCountFamily._dependencies,
        allTransitiveDependencies:
            ContainerTabCountFamily._allTransitiveDependencies,
        containerFilter: containerFilter,
      );

  ContainerTabCountProvider._internal(
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
    FutureOr<int> Function(ContainerTabCountRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ContainerTabCountProvider._internal(
        (ref) => create(ref as ContainerTabCountRef),
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
  AutoDisposeFutureProviderElement<int> createElement() {
    return _ContainerTabCountProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ContainerTabCountProvider &&
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
mixin ContainerTabCountRef on AutoDisposeFutureProviderRef<int> {
  /// The parameter `containerFilter` of this provider.
  ContainerFilter get containerFilter;
}

class _ContainerTabCountProviderElement
    extends AutoDisposeFutureProviderElement<int>
    with ContainerTabCountRef {
  _ContainerTabCountProviderElement(super.provider);

  @override
  ContainerFilter get containerFilter =>
      (origin as ContainerTabCountProvider).containerFilter;
}

String _$tabTreesHash() => r'b7b7f7136827207dd01a7894a915be3d17b1ae63';

/// See also [tabTrees].
@ProviderFor(tabTrees)
final tabTreesProvider =
    AutoDisposeStreamProvider<List<TabTreesResult>>.internal(
      tabTrees,
      name: r'tabTreesProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$tabTreesHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TabTreesRef = AutoDisposeStreamProviderRef<List<TabTreesResult>>;
String _$tabDescendantsHash() => r'93e19df9896e4876dc911370c02bf10f1ee9a9e6';

/// See also [tabDescendants].
@ProviderFor(tabDescendants)
const tabDescendantsProvider = TabDescendantsFamily();

/// See also [tabDescendants].
class TabDescendantsFamily extends Family<AsyncValue<Map<String, String?>>> {
  /// See also [tabDescendants].
  const TabDescendantsFamily();

  /// See also [tabDescendants].
  TabDescendantsProvider call(String tabId) {
    return TabDescendantsProvider(tabId);
  }

  @override
  TabDescendantsProvider getProviderOverride(
    covariant TabDescendantsProvider provider,
  ) {
    return call(provider.tabId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'tabDescendantsProvider';
}

/// See also [tabDescendants].
class TabDescendantsProvider
    extends AutoDisposeStreamProvider<Map<String, String?>> {
  /// See also [tabDescendants].
  TabDescendantsProvider(String tabId)
    : this._internal(
        (ref) => tabDescendants(ref as TabDescendantsRef, tabId),
        from: tabDescendantsProvider,
        name: r'tabDescendantsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$tabDescendantsHash,
        dependencies: TabDescendantsFamily._dependencies,
        allTransitiveDependencies:
            TabDescendantsFamily._allTransitiveDependencies,
        tabId: tabId,
      );

  TabDescendantsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.tabId,
  }) : super.internal();

  final String tabId;

  @override
  Override overrideWith(
    Stream<Map<String, String?>> Function(TabDescendantsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: TabDescendantsProvider._internal(
        (ref) => create(ref as TabDescendantsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        tabId: tabId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<Map<String, String?>> createElement() {
    return _TabDescendantsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TabDescendantsProvider && other.tabId == tabId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, tabId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin TabDescendantsRef on AutoDisposeStreamProviderRef<Map<String, String?>> {
  /// The parameter `tabId` of this provider.
  String get tabId;
}

class _TabDescendantsProviderElement
    extends AutoDisposeStreamProviderElement<Map<String, String?>>
    with TabDescendantsRef {
  _TabDescendantsProviderElement(super.provider);

  @override
  String get tabId => (origin as TabDescendantsProvider).tabId;
}

String _$containerTabsDataHash() => r'2961c89fc9e16c8e6005342356ecf677fb2ff63c';

/// See also [containerTabsData].
@ProviderFor(containerTabsData)
const containerTabsDataProvider = ContainerTabsDataFamily();

/// See also [containerTabsData].
class ContainerTabsDataFamily extends Family<AsyncValue<List<TabData>>> {
  /// See also [containerTabsData].
  const ContainerTabsDataFamily();

  /// See also [containerTabsData].
  ContainerTabsDataProvider call(String? containerId) {
    return ContainerTabsDataProvider(containerId);
  }

  @override
  ContainerTabsDataProvider getProviderOverride(
    covariant ContainerTabsDataProvider provider,
  ) {
    return call(provider.containerId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'containerTabsDataProvider';
}

/// See also [containerTabsData].
class ContainerTabsDataProvider
    extends AutoDisposeStreamProvider<List<TabData>> {
  /// See also [containerTabsData].
  ContainerTabsDataProvider(String? containerId)
    : this._internal(
        (ref) => containerTabsData(ref as ContainerTabsDataRef, containerId),
        from: containerTabsDataProvider,
        name: r'containerTabsDataProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$containerTabsDataHash,
        dependencies: ContainerTabsDataFamily._dependencies,
        allTransitiveDependencies:
            ContainerTabsDataFamily._allTransitiveDependencies,
        containerId: containerId,
      );

  ContainerTabsDataProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.containerId,
  }) : super.internal();

  final String? containerId;

  @override
  Override overrideWith(
    Stream<List<TabData>> Function(ContainerTabsDataRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ContainerTabsDataProvider._internal(
        (ref) => create(ref as ContainerTabsDataRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        containerId: containerId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<TabData>> createElement() {
    return _ContainerTabsDataProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ContainerTabsDataProvider &&
        other.containerId == containerId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, containerId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ContainerTabsDataRef on AutoDisposeStreamProviderRef<List<TabData>> {
  /// The parameter `containerId` of this provider.
  String? get containerId;
}

class _ContainerTabsDataProviderElement
    extends AutoDisposeStreamProviderElement<List<TabData>>
    with ContainerTabsDataRef {
  _ContainerTabsDataProviderElement(super.provider);

  @override
  String? get containerId => (origin as ContainerTabsDataProvider).containerId;
}

String _$containerDataHash() => r'6adbec128876069189954832af35109b0779148c';

/// See also [containerData].
@ProviderFor(containerData)
const containerDataProvider = ContainerDataFamily();

/// See also [containerData].
class ContainerDataFamily extends Family<AsyncValue<ContainerData?>> {
  /// See also [containerData].
  const ContainerDataFamily();

  /// See also [containerData].
  ContainerDataProvider call(String containerId) {
    return ContainerDataProvider(containerId);
  }

  @override
  ContainerDataProvider getProviderOverride(
    covariant ContainerDataProvider provider,
  ) {
    return call(provider.containerId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'containerDataProvider';
}

/// See also [containerData].
class ContainerDataProvider extends AutoDisposeStreamProvider<ContainerData?> {
  /// See also [containerData].
  ContainerDataProvider(String containerId)
    : this._internal(
        (ref) => containerData(ref as ContainerDataRef, containerId),
        from: containerDataProvider,
        name: r'containerDataProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$containerDataHash,
        dependencies: ContainerDataFamily._dependencies,
        allTransitiveDependencies:
            ContainerDataFamily._allTransitiveDependencies,
        containerId: containerId,
      );

  ContainerDataProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.containerId,
  }) : super.internal();

  final String containerId;

  @override
  Override overrideWith(
    Stream<ContainerData?> Function(ContainerDataRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ContainerDataProvider._internal(
        (ref) => create(ref as ContainerDataRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        containerId: containerId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<ContainerData?> createElement() {
    return _ContainerDataProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ContainerDataProvider && other.containerId == containerId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, containerId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ContainerDataRef on AutoDisposeStreamProviderRef<ContainerData?> {
  /// The parameter `containerId` of this provider.
  String get containerId;
}

class _ContainerDataProviderElement
    extends AutoDisposeStreamProviderElement<ContainerData?>
    with ContainerDataRef {
  _ContainerDataProviderElement(super.provider);

  @override
  String get containerId => (origin as ContainerDataProvider).containerId;
}

String _$watchContainerTabIdHash() =>
    r'b8f107e462f417b128221240242167a0754f040f';

/// See also [watchContainerTabId].
@ProviderFor(watchContainerTabId)
const watchContainerTabIdProvider = WatchContainerTabIdFamily();

/// See also [watchContainerTabId].
class WatchContainerTabIdFamily extends Family<AsyncValue<String?>> {
  /// See also [watchContainerTabId].
  const WatchContainerTabIdFamily();

  /// See also [watchContainerTabId].
  WatchContainerTabIdProvider call(String tabId) {
    return WatchContainerTabIdProvider(tabId);
  }

  @override
  WatchContainerTabIdProvider getProviderOverride(
    covariant WatchContainerTabIdProvider provider,
  ) {
    return call(provider.tabId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'watchContainerTabIdProvider';
}

/// See also [watchContainerTabId].
class WatchContainerTabIdProvider extends AutoDisposeStreamProvider<String?> {
  /// See also [watchContainerTabId].
  WatchContainerTabIdProvider(String tabId)
    : this._internal(
        (ref) => watchContainerTabId(ref as WatchContainerTabIdRef, tabId),
        from: watchContainerTabIdProvider,
        name: r'watchContainerTabIdProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$watchContainerTabIdHash,
        dependencies: WatchContainerTabIdFamily._dependencies,
        allTransitiveDependencies:
            WatchContainerTabIdFamily._allTransitiveDependencies,
        tabId: tabId,
      );

  WatchContainerTabIdProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.tabId,
  }) : super.internal();

  final String tabId;

  @override
  Override overrideWith(
    Stream<String?> Function(WatchContainerTabIdRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: WatchContainerTabIdProvider._internal(
        (ref) => create(ref as WatchContainerTabIdRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        tabId: tabId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<String?> createElement() {
    return _WatchContainerTabIdProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is WatchContainerTabIdProvider && other.tabId == tabId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, tabId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin WatchContainerTabIdRef on AutoDisposeStreamProviderRef<String?> {
  /// The parameter `tabId` of this provider.
  String get tabId;
}

class _WatchContainerTabIdProviderElement
    extends AutoDisposeStreamProviderElement<String?>
    with WatchContainerTabIdRef {
  _WatchContainerTabIdProviderElement(super.provider);

  @override
  String get tabId => (origin as WatchContainerTabIdProvider).tabId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
