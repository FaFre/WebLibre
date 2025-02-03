// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$unusedRandomContainerColorHash() =>
    r'913499b3de281ea0020db97ed67121652f53ec08';

/// See also [unusedRandomContainerColor].
@ProviderFor(unusedRandomContainerColor)
final unusedRandomContainerColorProvider =
    AutoDisposeFutureProvider<Color>.internal(
  unusedRandomContainerColor,
  name: r'unusedRandomContainerColorProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$unusedRandomContainerColorHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UnusedRandomContainerColorRef = AutoDisposeFutureProviderRef<Color>;
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
typedef ContainersWithCountRef
    = AutoDisposeStreamProviderRef<List<ContainerDataWithCount>>;
String _$filteredContainersWithCountHash() =>
    r'3a7284df29182a32f9b7831867a3a0b3e171b382';

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

/// See also [filteredContainersWithCount].
@ProviderFor(filteredContainersWithCount)
const filteredContainersWithCountProvider = FilteredContainersWithCountFamily();

/// See also [filteredContainersWithCount].
class FilteredContainersWithCountFamily
    extends Family<AsyncValue<List<ContainerDataWithCount>>> {
  /// See also [filteredContainersWithCount].
  const FilteredContainersWithCountFamily();

  /// See also [filteredContainersWithCount].
  FilteredContainersWithCountProvider call(
    String? searchText,
  ) {
    return FilteredContainersWithCountProvider(
      searchText,
    );
  }

  @override
  FilteredContainersWithCountProvider getProviderOverride(
    covariant FilteredContainersWithCountProvider provider,
  ) {
    return call(
      provider.searchText,
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
  String? get name => r'filteredContainersWithCountProvider';
}

/// See also [filteredContainersWithCount].
class FilteredContainersWithCountProvider
    extends AutoDisposeProvider<AsyncValue<List<ContainerDataWithCount>>> {
  /// See also [filteredContainersWithCount].
  FilteredContainersWithCountProvider(
    String? searchText,
  ) : this._internal(
          (ref) => filteredContainersWithCount(
            ref as FilteredContainersWithCountRef,
            searchText,
          ),
          from: filteredContainersWithCountProvider,
          name: r'filteredContainersWithCountProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$filteredContainersWithCountHash,
          dependencies: FilteredContainersWithCountFamily._dependencies,
          allTransitiveDependencies:
              FilteredContainersWithCountFamily._allTransitiveDependencies,
          searchText: searchText,
        );

  FilteredContainersWithCountProvider._internal(
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
            FilteredContainersWithCountRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: FilteredContainersWithCountProvider._internal(
        (ref) => create(ref as FilteredContainersWithCountRef),
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
    return _FilteredContainersWithCountProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FilteredContainersWithCountProvider &&
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
mixin FilteredContainersWithCountRef
    on AutoDisposeProviderRef<AsyncValue<List<ContainerDataWithCount>>> {
  /// The parameter `searchText` of this provider.
  String? get searchText;
}

class _FilteredContainersWithCountProviderElement
    extends AutoDisposeProviderElement<AsyncValue<List<ContainerDataWithCount>>>
    with FilteredContainersWithCountRef {
  _FilteredContainersWithCountProviderElement(super.provider);

  @override
  String? get searchText =>
      (origin as FilteredContainersWithCountProvider).searchText;
}

String _$containerTabIdsHash() => r'7545a6c500b1832bf81c0838e257dfe5e051463d';

/// See also [containerTabIds].
@ProviderFor(containerTabIds)
const containerTabIdsProvider = ContainerTabIdsFamily();

/// See also [containerTabIds].
class ContainerTabIdsFamily extends Family<AsyncValue<List<String>>> {
  /// See also [containerTabIds].
  const ContainerTabIdsFamily();

  /// See also [containerTabIds].
  ContainerTabIdsProvider call(
    String? containerId,
  ) {
    return ContainerTabIdsProvider(
      containerId,
    );
  }

  @override
  ContainerTabIdsProvider getProviderOverride(
    covariant ContainerTabIdsProvider provider,
  ) {
    return call(
      provider.containerId,
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
  String? get name => r'containerTabIdsProvider';
}

/// See also [containerTabIds].
class ContainerTabIdsProvider extends AutoDisposeStreamProvider<List<String>> {
  /// See also [containerTabIds].
  ContainerTabIdsProvider(
    String? containerId,
  ) : this._internal(
          (ref) => containerTabIds(
            ref as ContainerTabIdsRef,
            containerId,
          ),
          from: containerTabIdsProvider,
          name: r'containerTabIdsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$containerTabIdsHash,
          dependencies: ContainerTabIdsFamily._dependencies,
          allTransitiveDependencies:
              ContainerTabIdsFamily._allTransitiveDependencies,
          containerId: containerId,
        );

  ContainerTabIdsProvider._internal(
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
        containerId: containerId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<String>> createElement() {
    return _ContainerTabIdsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ContainerTabIdsProvider && other.containerId == containerId;
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
mixin ContainerTabIdsRef on AutoDisposeStreamProviderRef<List<String>> {
  /// The parameter `containerId` of this provider.
  String? get containerId;
}

class _ContainerTabIdsProviderElement
    extends AutoDisposeStreamProviderElement<List<String>>
    with ContainerTabIdsRef {
  _ContainerTabIdsProviderElement(super.provider);

  @override
  String? get containerId => (origin as ContainerTabIdsProvider).containerId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
