// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tab_search.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$tabSearchRepositoryHash() =>
    r'ac2381c692b9caf93f26f302d15e0160c098917a';

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

abstract class _$TabSearchRepository
    extends
        BuildlessAutoDisposeAsyncNotifier<
          ({String query, List<TabQueryResult> results})?
        > {
  late final TabSearchPartition partition;

  FutureOr<({String query, List<TabQueryResult> results})?> build(
    TabSearchPartition partition,
  );
}

/// See also [TabSearchRepository].
@ProviderFor(TabSearchRepository)
const tabSearchRepositoryProvider = TabSearchRepositoryFamily();

/// See also [TabSearchRepository].
class TabSearchRepositoryFamily
    extends
        Family<AsyncValue<({String query, List<TabQueryResult> results})?>> {
  /// See also [TabSearchRepository].
  const TabSearchRepositoryFamily();

  /// See also [TabSearchRepository].
  TabSearchRepositoryProvider call(TabSearchPartition partition) {
    return TabSearchRepositoryProvider(partition);
  }

  @override
  TabSearchRepositoryProvider getProviderOverride(
    covariant TabSearchRepositoryProvider provider,
  ) {
    return call(provider.partition);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'tabSearchRepositoryProvider';
}

/// See also [TabSearchRepository].
class TabSearchRepositoryProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          TabSearchRepository,
          ({String query, List<TabQueryResult> results})?
        > {
  /// See also [TabSearchRepository].
  TabSearchRepositoryProvider(TabSearchPartition partition)
    : this._internal(
        () => TabSearchRepository()..partition = partition,
        from: tabSearchRepositoryProvider,
        name: r'tabSearchRepositoryProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$tabSearchRepositoryHash,
        dependencies: TabSearchRepositoryFamily._dependencies,
        allTransitiveDependencies:
            TabSearchRepositoryFamily._allTransitiveDependencies,
        partition: partition,
      );

  TabSearchRepositoryProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.partition,
  }) : super.internal();

  final TabSearchPartition partition;

  @override
  FutureOr<({String query, List<TabQueryResult> results})?> runNotifierBuild(
    covariant TabSearchRepository notifier,
  ) {
    return notifier.build(partition);
  }

  @override
  Override overrideWith(TabSearchRepository Function() create) {
    return ProviderOverride(
      origin: this,
      override: TabSearchRepositoryProvider._internal(
        () => create()..partition = partition,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        partition: partition,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<
    TabSearchRepository,
    ({String query, List<TabQueryResult> results})?
  >
  createElement() {
    return _TabSearchRepositoryProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TabSearchRepositoryProvider && other.partition == partition;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, partition.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin TabSearchRepositoryRef
    on
        AutoDisposeAsyncNotifierProviderRef<
          ({String query, List<TabQueryResult> results})?
        > {
  /// The parameter `partition` of this provider.
  TabSearchPartition get partition;
}

class _TabSearchRepositoryProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          TabSearchRepository,
          ({String query, List<TabQueryResult> results})?
        >
    with TabSearchRepositoryRef {
  _TabSearchRepositoryProviderElement(super.provider);

  @override
  TabSearchPartition get partition =>
      (origin as TabSearchRepositoryProvider).partition;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
