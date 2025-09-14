// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'builtin_bridges.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$builtinBridgesRepositoryHash() =>
    r'05fc40a7742fc266aeb76b4e3f1d9bdfdb8d448f';

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

abstract class _$BuiltinBridgesRepository
    extends BuildlessAutoDisposeNotifier<void> {
  late final MoatService service;

  void build(MoatService service);
}

/// See also [BuiltinBridgesRepository].
@ProviderFor(BuiltinBridgesRepository)
const builtinBridgesRepositoryProvider = BuiltinBridgesRepositoryFamily();

/// See also [BuiltinBridgesRepository].
class BuiltinBridgesRepositoryFamily extends Family<void> {
  /// See also [BuiltinBridgesRepository].
  const BuiltinBridgesRepositoryFamily();

  /// See also [BuiltinBridgesRepository].
  BuiltinBridgesRepositoryProvider call(MoatService service) {
    return BuiltinBridgesRepositoryProvider(service);
  }

  @override
  BuiltinBridgesRepositoryProvider getProviderOverride(
    covariant BuiltinBridgesRepositoryProvider provider,
  ) {
    return call(provider.service);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'builtinBridgesRepositoryProvider';
}

/// See also [BuiltinBridgesRepository].
class BuiltinBridgesRepositoryProvider
    extends AutoDisposeNotifierProviderImpl<BuiltinBridgesRepository, void> {
  /// See also [BuiltinBridgesRepository].
  BuiltinBridgesRepositoryProvider(MoatService service)
    : this._internal(
        () => BuiltinBridgesRepository()..service = service,
        from: builtinBridgesRepositoryProvider,
        name: r'builtinBridgesRepositoryProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$builtinBridgesRepositoryHash,
        dependencies: BuiltinBridgesRepositoryFamily._dependencies,
        allTransitiveDependencies:
            BuiltinBridgesRepositoryFamily._allTransitiveDependencies,
        service: service,
      );

  BuiltinBridgesRepositoryProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.service,
  }) : super.internal();

  final MoatService service;

  @override
  void runNotifierBuild(covariant BuiltinBridgesRepository notifier) {
    return notifier.build(service);
  }

  @override
  Override overrideWith(BuiltinBridgesRepository Function() create) {
    return ProviderOverride(
      origin: this,
      override: BuiltinBridgesRepositoryProvider._internal(
        () => create()..service = service,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        service: service,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<BuiltinBridgesRepository, void>
  createElement() {
    return _BuiltinBridgesRepositoryProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is BuiltinBridgesRepositoryProvider &&
        other.service == service;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, service.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin BuiltinBridgesRepositoryRef on AutoDisposeNotifierProviderRef<void> {
  /// The parameter `service` of this provider.
  MoatService get service;
}

class _BuiltinBridgesRepositoryProviderElement
    extends AutoDisposeNotifierProviderElement<BuiltinBridgesRepository, void>
    with BuiltinBridgesRepositoryRef {
  _BuiltinBridgesRepositoryProviderElement(super.provider);

  @override
  MoatService get service =>
      (origin as BuiltinBridgesRepositoryProvider).service;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
