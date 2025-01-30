// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'preference_settings.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$preferenceSettingGroupsHash() =>
    r'fa9286248cc71c88c888a518441721dc99b7e0c2';

/// See also [_preferenceSettingGroups].
@ProviderFor(_preferenceSettingGroups)
final _preferenceSettingGroupsProvider =
    FutureProvider<Map<String, PreferenceSettingGroup>>.internal(
  _preferenceSettingGroups,
  name: r'_preferenceSettingGroupsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$preferenceSettingGroupsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef _PreferenceSettingGroupsRef
    = FutureProviderRef<Map<String, PreferenceSettingGroup>>;
String _$preferenceSettingGroupHash() =>
    r'960169ab9f6985a5b73a63663e671a8eac7cd776';

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
    String groupName,
  ) {
    return _PreferenceSettingGroupProvider(
      groupName,
    );
  }

  @override
  _PreferenceSettingGroupProvider getProviderOverride(
    covariant _PreferenceSettingGroupProvider provider,
  ) {
    return call(
      provider.groupName,
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
  String? get name => r'_preferenceSettingGroupProvider';
}

/// See also [_preferenceSettingGroup].
class _PreferenceSettingGroupProvider
    extends FutureProvider<PreferenceSettingGroup> {
  /// See also [_preferenceSettingGroup].
  _PreferenceSettingGroupProvider(
    String groupName,
  ) : this._internal(
          (ref) => _preferenceSettingGroup(
            ref as _PreferenceSettingGroupRef,
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
          groupName: groupName,
        );

  _PreferenceSettingGroupProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.groupName,
  }) : super.internal();

  final String groupName;

  @override
  Override overrideWith(
    FutureOr<PreferenceSettingGroup> Function(
            _PreferenceSettingGroupRef provider)
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
        other.groupName == groupName;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, groupName.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin _PreferenceSettingGroupRef on FutureProviderRef<PreferenceSettingGroup> {
  /// The parameter `groupName` of this provider.
  String get groupName;
}

class _PreferenceSettingGroupProviderElement
    extends FutureProviderElement<PreferenceSettingGroup>
    with _PreferenceSettingGroupRef {
  _PreferenceSettingGroupProviderElement(super.provider);

  @override
  String get groupName => (origin as _PreferenceSettingGroupProvider).groupName;
}

String _$preferenceRepositoryHash() =>
    r'53c0cbbf60e44c3834fe3e3255836f7e27f09c7f';

/// See also [_PreferenceRepository].
@ProviderFor(_PreferenceRepository)
final _preferenceRepositoryProvider = AutoDisposeNotifierProvider<
    _PreferenceRepository, Raw<Stream<Map<String, Object>>>>.internal(
  _PreferenceRepository.new,
  name: r'_preferenceRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$preferenceRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$PreferenceRepository
    = AutoDisposeNotifier<Raw<Stream<Map<String, Object>>>>;
String _$preferenceSettingsGeneralRepositoryHash() =>
    r'24a70de8284107bb43778e1014abe41bd805987a';

/// See also [PreferenceSettingsGeneralRepository].
@ProviderFor(PreferenceSettingsGeneralRepository)
final preferenceSettingsGeneralRepositoryProvider =
    AutoDisposeStreamNotifierProvider<PreferenceSettingsGeneralRepository,
        Map<String, PreferenceSettingGroup>>.internal(
  PreferenceSettingsGeneralRepository.new,
  name: r'preferenceSettingsGeneralRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$preferenceSettingsGeneralRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$PreferenceSettingsGeneralRepository
    = AutoDisposeStreamNotifier<Map<String, PreferenceSettingGroup>>;
String _$preferenceSettingsGroupRepositoryHash() =>
    r'023794294c5639ac6c6941f87a4ed91e1551fbc9';

abstract class _$PreferenceSettingsGroupRepository
    extends BuildlessAutoDisposeStreamNotifier<PreferenceSettingGroup> {
  late final String groupName;

  Stream<PreferenceSettingGroup> build(
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
    String groupName,
  ) {
    return PreferenceSettingsGroupRepositoryProvider(
      groupName,
    );
  }

  @override
  PreferenceSettingsGroupRepositoryProvider getProviderOverride(
    covariant PreferenceSettingsGroupRepositoryProvider provider,
  ) {
    return call(
      provider.groupName,
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
  String? get name => r'preferenceSettingsGroupRepositoryProvider';
}

/// See also [PreferenceSettingsGroupRepository].
class PreferenceSettingsGroupRepositoryProvider
    extends AutoDisposeStreamNotifierProviderImpl<
        PreferenceSettingsGroupRepository, PreferenceSettingGroup> {
  /// See also [PreferenceSettingsGroupRepository].
  PreferenceSettingsGroupRepositoryProvider(
    String groupName,
  ) : this._internal(
          () => PreferenceSettingsGroupRepository()..groupName = groupName,
          from: preferenceSettingsGroupRepositoryProvider,
          name: r'preferenceSettingsGroupRepositoryProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$preferenceSettingsGroupRepositoryHash,
          dependencies: PreferenceSettingsGroupRepositoryFamily._dependencies,
          allTransitiveDependencies: PreferenceSettingsGroupRepositoryFamily
              ._allTransitiveDependencies,
          groupName: groupName,
        );

  PreferenceSettingsGroupRepositoryProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.groupName,
  }) : super.internal();

  final String groupName;

  @override
  Stream<PreferenceSettingGroup> runNotifierBuild(
    covariant PreferenceSettingsGroupRepository notifier,
  ) {
    return notifier.build(
      groupName,
    );
  }

  @override
  Override overrideWith(PreferenceSettingsGroupRepository Function() create) {
    return ProviderOverride(
      origin: this,
      override: PreferenceSettingsGroupRepositoryProvider._internal(
        () => create()..groupName = groupName,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        groupName: groupName,
      ),
    );
  }

  @override
  AutoDisposeStreamNotifierProviderElement<PreferenceSettingsGroupRepository,
      PreferenceSettingGroup> createElement() {
    return _PreferenceSettingsGroupRepositoryProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PreferenceSettingsGroupRepositoryProvider &&
        other.groupName == groupName;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, groupName.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin PreferenceSettingsGroupRepositoryRef
    on AutoDisposeStreamNotifierProviderRef<PreferenceSettingGroup> {
  /// The parameter `groupName` of this provider.
  String get groupName;
}

class _PreferenceSettingsGroupRepositoryProviderElement
    extends AutoDisposeStreamNotifierProviderElement<
        PreferenceSettingsGroupRepository,
        PreferenceSettingGroup> with PreferenceSettingsGroupRepositoryRef {
  _PreferenceSettingsGroupRepositoryProviderElement(super.provider);

  @override
  String get groupName =>
      (origin as PreferenceSettingsGroupRepositoryProvider).groupName;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
