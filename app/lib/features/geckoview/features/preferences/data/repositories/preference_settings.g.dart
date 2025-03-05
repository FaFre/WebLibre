// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'preference_settings.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$preferenceSettingContentHash() =>
    r'a8a61fdf8800cb7adb365c100409ddce09c574b1';

/// See also [_preferenceSettingContent].
@ProviderFor(_preferenceSettingContent)
final _preferenceSettingContentProvider =
    FutureProvider<Map<String, dynamic>>.internal(
      _preferenceSettingContent,
      name: r'_preferenceSettingContentProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$preferenceSettingContentHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef _PreferenceSettingContentRef = FutureProviderRef<Map<String, dynamic>>;
String _$preferenceSettingGroupsHash() =>
    r'd267dacf82a11568c9cf0cc864f434db35f93394';

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

/// See also [_preferenceSettingGroups].
@ProviderFor(_preferenceSettingGroups)
const _preferenceSettingGroupsProvider = _PreferenceSettingGroupsFamily();

/// See also [_preferenceSettingGroups].
class _PreferenceSettingGroupsFamily
    extends Family<AsyncValue<Map<String, PreferenceSettingGroup>>> {
  /// See also [_preferenceSettingGroups].
  const _PreferenceSettingGroupsFamily();

  /// See also [_preferenceSettingGroups].
  _PreferenceSettingGroupsProvider call(PreferencePartition partition) {
    return _PreferenceSettingGroupsProvider(partition);
  }

  @override
  _PreferenceSettingGroupsProvider getProviderOverride(
    covariant _PreferenceSettingGroupsProvider provider,
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
  String? get name => r'_preferenceSettingGroupsProvider';
}

/// See also [_preferenceSettingGroups].
class _PreferenceSettingGroupsProvider
    extends FutureProvider<Map<String, PreferenceSettingGroup>> {
  /// See also [_preferenceSettingGroups].
  _PreferenceSettingGroupsProvider(PreferencePartition partition)
    : this._internal(
        (ref) => _preferenceSettingGroups(
          ref as _PreferenceSettingGroupsRef,
          partition,
        ),
        from: _preferenceSettingGroupsProvider,
        name: r'_preferenceSettingGroupsProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$preferenceSettingGroupsHash,
        dependencies: _PreferenceSettingGroupsFamily._dependencies,
        allTransitiveDependencies:
            _PreferenceSettingGroupsFamily._allTransitiveDependencies,
        partition: partition,
      );

  _PreferenceSettingGroupsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.partition,
  }) : super.internal();

  final PreferencePartition partition;

  @override
  Override overrideWith(
    FutureOr<Map<String, PreferenceSettingGroup>> Function(
      _PreferenceSettingGroupsRef provider,
    )
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: _PreferenceSettingGroupsProvider._internal(
        (ref) => create(ref as _PreferenceSettingGroupsRef),
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
  FutureProviderElement<Map<String, PreferenceSettingGroup>> createElement() {
    return _PreferenceSettingGroupsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is _PreferenceSettingGroupsProvider &&
        other.partition == partition;
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
mixin _PreferenceSettingGroupsRef
    on FutureProviderRef<Map<String, PreferenceSettingGroup>> {
  /// The parameter `partition` of this provider.
  PreferencePartition get partition;
}

class _PreferenceSettingGroupsProviderElement
    extends FutureProviderElement<Map<String, PreferenceSettingGroup>>
    with _PreferenceSettingGroupsRef {
  _PreferenceSettingGroupsProviderElement(super.provider);

  @override
  PreferencePartition get partition =>
      (origin as _PreferenceSettingGroupsProvider).partition;
}

String _$preferenceSettingGroupHash() =>
    r'64d80a37928d7e5aea7d3d567dde8ade7292cd5f';

/// See also [_preferenceSettingGroup].
@ProviderFor(_preferenceSettingGroup)
const _preferenceSettingGroupProvider = _PreferenceSettingGroupFamily();

/// See also [_preferenceSettingGroup].
class _PreferenceSettingGroupFamily
    extends Family<AsyncValue<PreferenceSettingGroup>> {
  /// See also [_preferenceSettingGroup].
  const _PreferenceSettingGroupFamily();

  /// See also [_preferenceSettingGroup].
  _PreferenceSettingGroupProvider call(
    PreferencePartition partition,
    String groupName,
  ) {
    return _PreferenceSettingGroupProvider(partition, groupName);
  }

  @override
  _PreferenceSettingGroupProvider getProviderOverride(
    covariant _PreferenceSettingGroupProvider provider,
  ) {
    return call(provider.partition, provider.groupName);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'_preferenceSettingGroupProvider';
}

/// See also [_preferenceSettingGroup].
class _PreferenceSettingGroupProvider
    extends FutureProvider<PreferenceSettingGroup> {
  /// See also [_preferenceSettingGroup].
  _PreferenceSettingGroupProvider(
    PreferencePartition partition,
    String groupName,
  ) : this._internal(
        (ref) => _preferenceSettingGroup(
          ref as _PreferenceSettingGroupRef,
          partition,
          groupName,
        ),
        from: _preferenceSettingGroupProvider,
        name: r'_preferenceSettingGroupProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$preferenceSettingGroupHash,
        dependencies: _PreferenceSettingGroupFamily._dependencies,
        allTransitiveDependencies:
            _PreferenceSettingGroupFamily._allTransitiveDependencies,
        partition: partition,
        groupName: groupName,
      );

  _PreferenceSettingGroupProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.partition,
    required this.groupName,
  }) : super.internal();

  final PreferencePartition partition;
  final String groupName;

  @override
  Override overrideWith(
    FutureOr<PreferenceSettingGroup> Function(
      _PreferenceSettingGroupRef provider,
    )
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: _PreferenceSettingGroupProvider._internal(
        (ref) => create(ref as _PreferenceSettingGroupRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        partition: partition,
        groupName: groupName,
      ),
    );
  }

  @override
  FutureProviderElement<PreferenceSettingGroup> createElement() {
    return _PreferenceSettingGroupProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is _PreferenceSettingGroupProvider &&
        other.partition == partition &&
        other.groupName == groupName;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, partition.hashCode);
    hash = _SystemHash.combine(hash, groupName.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin _PreferenceSettingGroupRef on FutureProviderRef<PreferenceSettingGroup> {
  /// The parameter `partition` of this provider.
  PreferencePartition get partition;

  /// The parameter `groupName` of this provider.
  String get groupName;
}

class _PreferenceSettingGroupProviderElement
    extends FutureProviderElement<PreferenceSettingGroup>
    with _PreferenceSettingGroupRef {
  _PreferenceSettingGroupProviderElement(super.provider);

  @override
  PreferencePartition get partition =>
      (origin as _PreferenceSettingGroupProvider).partition;
  @override
  String get groupName => (origin as _PreferenceSettingGroupProvider).groupName;
}

String _$preferenceRepositoryHash() =>
    r'b2b7f75b3d30842b3006bb18af89f7ff90ba4ce7';

/// See also [_PreferenceRepository].
@ProviderFor(_PreferenceRepository)
final _preferenceRepositoryProvider = AutoDisposeNotifierProvider<
  _PreferenceRepository,
  Raw<Stream<Map<String, Object>>>
>.internal(
  _PreferenceRepository.new,
  name: r'_preferenceRepositoryProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$preferenceRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$PreferenceRepository =
    AutoDisposeNotifier<Raw<Stream<Map<String, Object>>>>;
String _$unifiedPreferenceSettingsRepositoryHash() =>
    r'35aa16ffa7aa1453c8331ed7470ef85a68d27178';

abstract class _$UnifiedPreferenceSettingsRepository
    extends
        BuildlessAutoDisposeStreamNotifier<
          Map<String, PreferenceSettingGroup>
        > {
  late final PreferencePartition partition;

  Stream<Map<String, PreferenceSettingGroup>> build(
    PreferencePartition partition,
  );
}

/// See also [UnifiedPreferenceSettingsRepository].
@ProviderFor(UnifiedPreferenceSettingsRepository)
const unifiedPreferenceSettingsRepositoryProvider =
    UnifiedPreferenceSettingsRepositoryFamily();

/// See also [UnifiedPreferenceSettingsRepository].
class UnifiedPreferenceSettingsRepositoryFamily
    extends Family<AsyncValue<Map<String, PreferenceSettingGroup>>> {
  /// See also [UnifiedPreferenceSettingsRepository].
  const UnifiedPreferenceSettingsRepositoryFamily();

  /// See also [UnifiedPreferenceSettingsRepository].
  UnifiedPreferenceSettingsRepositoryProvider call(
    PreferencePartition partition,
  ) {
    return UnifiedPreferenceSettingsRepositoryProvider(partition);
  }

  @override
  UnifiedPreferenceSettingsRepositoryProvider getProviderOverride(
    covariant UnifiedPreferenceSettingsRepositoryProvider provider,
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
  String? get name => r'unifiedPreferenceSettingsRepositoryProvider';
}

/// See also [UnifiedPreferenceSettingsRepository].
class UnifiedPreferenceSettingsRepositoryProvider
    extends
        AutoDisposeStreamNotifierProviderImpl<
          UnifiedPreferenceSettingsRepository,
          Map<String, PreferenceSettingGroup>
        > {
  /// See also [UnifiedPreferenceSettingsRepository].
  UnifiedPreferenceSettingsRepositoryProvider(PreferencePartition partition)
    : this._internal(
        () => UnifiedPreferenceSettingsRepository()..partition = partition,
        from: unifiedPreferenceSettingsRepositoryProvider,
        name: r'unifiedPreferenceSettingsRepositoryProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$unifiedPreferenceSettingsRepositoryHash,
        dependencies: UnifiedPreferenceSettingsRepositoryFamily._dependencies,
        allTransitiveDependencies:
            UnifiedPreferenceSettingsRepositoryFamily
                ._allTransitiveDependencies,
        partition: partition,
      );

  UnifiedPreferenceSettingsRepositoryProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.partition,
  }) : super.internal();

  final PreferencePartition partition;

  @override
  Stream<Map<String, PreferenceSettingGroup>> runNotifierBuild(
    covariant UnifiedPreferenceSettingsRepository notifier,
  ) {
    return notifier.build(partition);
  }

  @override
  Override overrideWith(UnifiedPreferenceSettingsRepository Function() create) {
    return ProviderOverride(
      origin: this,
      override: UnifiedPreferenceSettingsRepositoryProvider._internal(
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
  AutoDisposeStreamNotifierProviderElement<
    UnifiedPreferenceSettingsRepository,
    Map<String, PreferenceSettingGroup>
  >
  createElement() {
    return _UnifiedPreferenceSettingsRepositoryProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is UnifiedPreferenceSettingsRepositoryProvider &&
        other.partition == partition;
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
mixin UnifiedPreferenceSettingsRepositoryRef
    on
        AutoDisposeStreamNotifierProviderRef<
          Map<String, PreferenceSettingGroup>
        > {
  /// The parameter `partition` of this provider.
  PreferencePartition get partition;
}

class _UnifiedPreferenceSettingsRepositoryProviderElement
    extends
        AutoDisposeStreamNotifierProviderElement<
          UnifiedPreferenceSettingsRepository,
          Map<String, PreferenceSettingGroup>
        >
    with UnifiedPreferenceSettingsRepositoryRef {
  _UnifiedPreferenceSettingsRepositoryProviderElement(super.provider);

  @override
  PreferencePartition get partition =>
      (origin as UnifiedPreferenceSettingsRepositoryProvider).partition;
}

String _$preferenceSettingsGroupRepositoryHash() =>
    r'60f416ffe1cde4d535fb5b643a80aead20836bae';

abstract class _$PreferenceSettingsGroupRepository
    extends BuildlessAutoDisposeStreamNotifier<PreferenceSettingGroup> {
  late final PreferencePartition partition;
  late final String groupName;

  Stream<PreferenceSettingGroup> build(
    PreferencePartition partition,
    String groupName,
  );
}

/// See also [PreferenceSettingsGroupRepository].
@ProviderFor(PreferenceSettingsGroupRepository)
const preferenceSettingsGroupRepositoryProvider =
    PreferenceSettingsGroupRepositoryFamily();

/// See also [PreferenceSettingsGroupRepository].
class PreferenceSettingsGroupRepositoryFamily
    extends Family<AsyncValue<PreferenceSettingGroup>> {
  /// See also [PreferenceSettingsGroupRepository].
  const PreferenceSettingsGroupRepositoryFamily();

  /// See also [PreferenceSettingsGroupRepository].
  PreferenceSettingsGroupRepositoryProvider call(
    PreferencePartition partition,
    String groupName,
  ) {
    return PreferenceSettingsGroupRepositoryProvider(partition, groupName);
  }

  @override
  PreferenceSettingsGroupRepositoryProvider getProviderOverride(
    covariant PreferenceSettingsGroupRepositoryProvider provider,
  ) {
    return call(provider.partition, provider.groupName);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'preferenceSettingsGroupRepositoryProvider';
}

/// See also [PreferenceSettingsGroupRepository].
class PreferenceSettingsGroupRepositoryProvider
    extends
        AutoDisposeStreamNotifierProviderImpl<
          PreferenceSettingsGroupRepository,
          PreferenceSettingGroup
        > {
  /// See also [PreferenceSettingsGroupRepository].
  PreferenceSettingsGroupRepositoryProvider(
    PreferencePartition partition,
    String groupName,
  ) : this._internal(
        () =>
            PreferenceSettingsGroupRepository()
              ..partition = partition
              ..groupName = groupName,
        from: preferenceSettingsGroupRepositoryProvider,
        name: r'preferenceSettingsGroupRepositoryProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$preferenceSettingsGroupRepositoryHash,
        dependencies: PreferenceSettingsGroupRepositoryFamily._dependencies,
        allTransitiveDependencies:
            PreferenceSettingsGroupRepositoryFamily._allTransitiveDependencies,
        partition: partition,
        groupName: groupName,
      );

  PreferenceSettingsGroupRepositoryProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.partition,
    required this.groupName,
  }) : super.internal();

  final PreferencePartition partition;
  final String groupName;

  @override
  Stream<PreferenceSettingGroup> runNotifierBuild(
    covariant PreferenceSettingsGroupRepository notifier,
  ) {
    return notifier.build(partition, groupName);
  }

  @override
  Override overrideWith(PreferenceSettingsGroupRepository Function() create) {
    return ProviderOverride(
      origin: this,
      override: PreferenceSettingsGroupRepositoryProvider._internal(
        () =>
            create()
              ..partition = partition
              ..groupName = groupName,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        partition: partition,
        groupName: groupName,
      ),
    );
  }

  @override
  AutoDisposeStreamNotifierProviderElement<
    PreferenceSettingsGroupRepository,
    PreferenceSettingGroup
  >
  createElement() {
    return _PreferenceSettingsGroupRepositoryProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PreferenceSettingsGroupRepositoryProvider &&
        other.partition == partition &&
        other.groupName == groupName;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, partition.hashCode);
    hash = _SystemHash.combine(hash, groupName.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin PreferenceSettingsGroupRepositoryRef
    on AutoDisposeStreamNotifierProviderRef<PreferenceSettingGroup> {
  /// The parameter `partition` of this provider.
  PreferencePartition get partition;

  /// The parameter `groupName` of this provider.
  String get groupName;
}

class _PreferenceSettingsGroupRepositoryProviderElement
    extends
        AutoDisposeStreamNotifierProviderElement<
          PreferenceSettingsGroupRepository,
          PreferenceSettingGroup
        >
    with PreferenceSettingsGroupRepositoryRef {
  _PreferenceSettingsGroupRepositoryProviderElement(super.provider);

  @override
  PreferencePartition get partition =>
      (origin as PreferenceSettingsGroupRepositoryProvider).partition;
  @override
  String get groupName =>
      (origin as PreferenceSettingsGroupRepositoryProvider).groupName;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
