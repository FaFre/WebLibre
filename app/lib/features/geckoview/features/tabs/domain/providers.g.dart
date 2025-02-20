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
typedef ContainersWithCountRef
    = AutoDisposeStreamProviderRef<List<ContainerDataWithCount>>;
String _$matchSortedContainersWithCountHash() =>
    r'0ed555f0cb72f4990a2841114d72f57d8178d5c3';

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
  MatchSortedContainersWithCountProvider call(
    String? searchText,
  ) {
    return MatchSortedContainersWithCountProvider(
      searchText,
    );
  }

  @override
  MatchSortedContainersWithCountProvider getProviderOverride(
    covariant MatchSortedContainersWithCountProvider provider,
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
  String? get name => r'matchSortedContainersWithCountProvider';
}

/// See also [matchSortedContainersWithCount].
class MatchSortedContainersWithCountProvider
    extends AutoDisposeProvider<AsyncValue<List<ContainerDataWithCount>>> {
  /// See also [matchSortedContainersWithCount].
  MatchSortedContainersWithCountProvider(
    String? searchText,
  ) : this._internal(
          (ref) => matchSortedContainersWithCount(
            ref as MatchSortedContainersWithCountRef,
            searchText,
          ),
          from: matchSortedContainersWithCountProvider,
          name: r'matchSortedContainersWithCountProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
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
            MatchSortedContainersWithCountRef provider)
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

String _$containerTabIdsHash() => r'355c65523db29f376faa293ab1f1ed8273696548';

/// See also [containerTabIds].
@ProviderFor(containerTabIds)
const containerTabIdsProvider = ContainerTabIdsFamily();

/// See also [containerTabIds].
class ContainerTabIdsFamily extends Family<AsyncValue<List<String>>> {
  /// See also [containerTabIds].
  const ContainerTabIdsFamily();

  /// See also [containerTabIds].
  ContainerTabIdsProvider call(
    ContainerFilter containerFilter,
  ) {
    return ContainerTabIdsProvider(
      containerFilter,
    );
  }

  @override
  ContainerTabIdsProvider getProviderOverride(
    covariant ContainerTabIdsProvider provider,
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
  String? get name => r'containerTabIdsProvider';
}

/// See also [containerTabIds].
class ContainerTabIdsProvider extends AutoDisposeStreamProvider<List<String>> {
  /// See also [containerTabIds].
  ContainerTabIdsProvider(
    ContainerFilter containerFilter,
  ) : this._internal(
          (ref) => containerTabIds(
            ref as ContainerTabIdsRef,
            containerFilter,
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
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
