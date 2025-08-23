// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tab_state.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$tabStateHash() => r'f57b2353acc99ca73670d504b45ea5ff19df38c7';

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

/// See also [tabState].
@ProviderFor(tabState)
const tabStateProvider = TabStateFamily();

/// See also [tabState].
class TabStateFamily extends Family<TabState?> {
  /// See also [tabState].
  const TabStateFamily();

  /// See also [tabState].
  TabStateProvider call(String? tabId) {
    return TabStateProvider(tabId);
  }

  @override
  TabStateProvider getProviderOverride(covariant TabStateProvider provider) {
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
  String? get name => r'tabStateProvider';
}

/// See also [tabState].
class TabStateProvider extends AutoDisposeProvider<TabState?> {
  /// See also [tabState].
  TabStateProvider(String? tabId)
    : this._internal(
        (ref) => tabState(ref as TabStateRef, tabId),
        from: tabStateProvider,
        name: r'tabStateProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$tabStateHash,
        dependencies: TabStateFamily._dependencies,
        allTransitiveDependencies: TabStateFamily._allTransitiveDependencies,
        tabId: tabId,
      );

  TabStateProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.tabId,
  }) : super.internal();

  final String? tabId;

  @override
  Override overrideWith(TabState? Function(TabStateRef provider) create) {
    return ProviderOverride(
      origin: this,
      override: TabStateProvider._internal(
        (ref) => create(ref as TabStateRef),
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
  AutoDisposeProviderElement<TabState?> createElement() {
    return _TabStateProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TabStateProvider && other.tabId == tabId;
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
mixin TabStateRef on AutoDisposeProviderRef<TabState?> {
  /// The parameter `tabId` of this provider.
  String? get tabId;
}

class _TabStateProviderElement extends AutoDisposeProviderElement<TabState?>
    with TabStateRef {
  _TabStateProviderElement(super.provider);

  @override
  String? get tabId => (origin as TabStateProvider).tabId;
}

String _$selectedTabStateHash() => r'dbd36af7af286bd9d079f30e8e11bbda23bf7728';

/// See also [selectedTabState].
@ProviderFor(selectedTabState)
final selectedTabStateProvider = AutoDisposeProvider<TabState?>.internal(
  selectedTabState,
  name: r'selectedTabStateProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$selectedTabStateHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SelectedTabStateRef = AutoDisposeProviderRef<TabState?>;
String _$selectedTabTypeHash() => r'53093fc6db8becde7500163661e087fb0a2eb955';

/// See also [selectedTabType].
@ProviderFor(selectedTabType)
final selectedTabTypeProvider = AutoDisposeProvider<TabType?>.internal(
  selectedTabType,
  name: r'selectedTabTypeProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$selectedTabTypeHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SelectedTabTypeRef = AutoDisposeProviderRef<TabType?>;
String _$selectedTabContainerIdHash() =>
    r'9f0246a02a069b1a66211a3924f32e9d75f0f344';

/// See also [selectedTabContainerId].
@ProviderFor(selectedTabContainerId)
final selectedTabContainerIdProvider = Provider<AsyncValue<String?>>.internal(
  selectedTabContainerId,
  name: r'selectedTabContainerIdProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$selectedTabContainerIdHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SelectedTabContainerIdRef = ProviderRef<AsyncValue<String?>>;
String _$tabScrollYHash() => r'dcb1e82b42bab98c4fc2ee4c7a22f37a28b8ce9e';

/// See also [tabScrollY].
@ProviderFor(tabScrollY)
const tabScrollYProvider = TabScrollYFamily();

/// See also [tabScrollY].
class TabScrollYFamily extends Family<AsyncValue<int>> {
  /// See also [tabScrollY].
  const TabScrollYFamily();

  /// See also [tabScrollY].
  TabScrollYProvider call(String? tabId, Duration sampleTime) {
    return TabScrollYProvider(tabId, sampleTime);
  }

  @override
  TabScrollYProvider getProviderOverride(
    covariant TabScrollYProvider provider,
  ) {
    return call(provider.tabId, provider.sampleTime);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'tabScrollYProvider';
}

/// See also [tabScrollY].
class TabScrollYProvider extends AutoDisposeStreamProvider<int> {
  /// See also [tabScrollY].
  TabScrollYProvider(String? tabId, Duration sampleTime)
    : this._internal(
        (ref) => tabScrollY(ref as TabScrollYRef, tabId, sampleTime),
        from: tabScrollYProvider,
        name: r'tabScrollYProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$tabScrollYHash,
        dependencies: TabScrollYFamily._dependencies,
        allTransitiveDependencies: TabScrollYFamily._allTransitiveDependencies,
        tabId: tabId,
        sampleTime: sampleTime,
      );

  TabScrollYProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.tabId,
    required this.sampleTime,
  }) : super.internal();

  final String? tabId;
  final Duration sampleTime;

  @override
  Override overrideWith(Stream<int> Function(TabScrollYRef provider) create) {
    return ProviderOverride(
      origin: this,
      override: TabScrollYProvider._internal(
        (ref) => create(ref as TabScrollYRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        tabId: tabId,
        sampleTime: sampleTime,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<int> createElement() {
    return _TabScrollYProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TabScrollYProvider &&
        other.tabId == tabId &&
        other.sampleTime == sampleTime;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, tabId.hashCode);
    hash = _SystemHash.combine(hash, sampleTime.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin TabScrollYRef on AutoDisposeStreamProviderRef<int> {
  /// The parameter `tabId` of this provider.
  String? get tabId;

  /// The parameter `sampleTime` of this provider.
  Duration get sampleTime;
}

class _TabScrollYProviderElement extends AutoDisposeStreamProviderElement<int>
    with TabScrollYRef {
  _TabScrollYProviderElement(super.provider);

  @override
  String? get tabId => (origin as TabScrollYProvider).tabId;
  @override
  Duration get sampleTime => (origin as TabScrollYProvider).sampleTime;
}

String _$tabStatesHash() => r'66cff6a7b36328ee23b89fdd53046987b346bfcd';

/// See also [TabStates].
@ProviderFor(TabStates)
final tabStatesProvider =
    NotifierProvider<TabStates, Map<String, TabState>>.internal(
      TabStates.new,
      name: r'tabStatesProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$tabStatesHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$TabStates = Notifier<Map<String, TabState>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
