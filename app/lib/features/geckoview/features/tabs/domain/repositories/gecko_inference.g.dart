// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gecko_inference.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$containerTopicHash() => r'b680381eab3dded9ca6f174fbcc5da5c59d7e9f0';

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

/// See also [containerTopic].
@ProviderFor(containerTopic)
const containerTopicProvider = ContainerTopicFamily();

/// See also [containerTopic].
class ContainerTopicFamily extends Family<AsyncValue<String?>> {
  /// See also [containerTopic].
  const ContainerTopicFamily();

  /// See also [containerTopic].
  ContainerTopicProvider call(String containerId) {
    return ContainerTopicProvider(containerId);
  }

  @override
  ContainerTopicProvider getProviderOverride(
    covariant ContainerTopicProvider provider,
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
  String? get name => r'containerTopicProvider';
}

/// See also [containerTopic].
class ContainerTopicProvider extends FutureProvider<String?> {
  /// See also [containerTopic].
  ContainerTopicProvider(String containerId)
    : this._internal(
        (ref) => containerTopic(ref as ContainerTopicRef, containerId),
        from: containerTopicProvider,
        name: r'containerTopicProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$containerTopicHash,
        dependencies: ContainerTopicFamily._dependencies,
        allTransitiveDependencies:
            ContainerTopicFamily._allTransitiveDependencies,
        containerId: containerId,
      );

  ContainerTopicProvider._internal(
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
    FutureOr<String?> Function(ContainerTopicRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ContainerTopicProvider._internal(
        (ref) => create(ref as ContainerTopicRef),
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
  FutureProviderElement<String?> createElement() {
    return _ContainerTopicProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ContainerTopicProvider && other.containerId == containerId;
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
mixin ContainerTopicRef on FutureProviderRef<String?> {
  /// The parameter `containerId` of this provider.
  String get containerId;
}

class _ContainerTopicProviderElement extends FutureProviderElement<String?>
    with ContainerTopicRef {
  _ContainerTopicProviderElement(super.provider);

  @override
  String get containerId => (origin as ContainerTopicProvider).containerId;
}

String _$containerTabSuggestionsHash() =>
    r'ab8e596f0c7e8562bf998c701145e48eb1e520d5';

/// See also [containerTabSuggestions].
@ProviderFor(containerTabSuggestions)
const containerTabSuggestionsProvider = ContainerTabSuggestionsFamily();

/// See also [containerTabSuggestions].
class ContainerTabSuggestionsFamily extends Family<AsyncValue<List<String>?>> {
  /// See also [containerTabSuggestions].
  const ContainerTabSuggestionsFamily();

  /// See also [containerTabSuggestions].
  ContainerTabSuggestionsProvider call(String? containerId) {
    return ContainerTabSuggestionsProvider(containerId);
  }

  @override
  ContainerTabSuggestionsProvider getProviderOverride(
    covariant ContainerTabSuggestionsProvider provider,
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
  String? get name => r'containerTabSuggestionsProvider';
}

/// See also [containerTabSuggestions].
class ContainerTabSuggestionsProvider
    extends AutoDisposeFutureProvider<List<String>?> {
  /// See also [containerTabSuggestions].
  ContainerTabSuggestionsProvider(String? containerId)
    : this._internal(
        (ref) => containerTabSuggestions(
          ref as ContainerTabSuggestionsRef,
          containerId,
        ),
        from: containerTabSuggestionsProvider,
        name: r'containerTabSuggestionsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$containerTabSuggestionsHash,
        dependencies: ContainerTabSuggestionsFamily._dependencies,
        allTransitiveDependencies:
            ContainerTabSuggestionsFamily._allTransitiveDependencies,
        containerId: containerId,
      );

  ContainerTabSuggestionsProvider._internal(
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
    FutureOr<List<String>?> Function(ContainerTabSuggestionsRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ContainerTabSuggestionsProvider._internal(
        (ref) => create(ref as ContainerTabSuggestionsRef),
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
  AutoDisposeFutureProviderElement<List<String>?> createElement() {
    return _ContainerTabSuggestionsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ContainerTabSuggestionsProvider &&
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
mixin ContainerTabSuggestionsRef
    on AutoDisposeFutureProviderRef<List<String>?> {
  /// The parameter `containerId` of this provider.
  String? get containerId;
}

class _ContainerTabSuggestionsProviderElement
    extends AutoDisposeFutureProviderElement<List<String>?>
    with ContainerTabSuggestionsRef {
  _ContainerTabSuggestionsProviderElement(super.provider);

  @override
  String? get containerId =>
      (origin as ContainerTabSuggestionsProvider).containerId;
}

String _$geckoInferenceRepositoryHash() =>
    r'bdae6dab14c33c6503f37f2e17b8d50fb820ac26';

/// See also [GeckoInferenceRepository].
@ProviderFor(GeckoInferenceRepository)
final geckoInferenceRepositoryProvider =
    NotifierProvider<GeckoInferenceRepository, void>.internal(
      GeckoInferenceRepository.new,
      name: r'geckoInferenceRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$geckoInferenceRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$GeckoInferenceRepository = Notifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
