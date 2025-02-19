// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$triggerBangSearchHash() => r'a5cff116ae09b26d4fa476ce6a2e6052fa6fa177';

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

/// See also [triggerBangSearch].
@ProviderFor(triggerBangSearch)
const triggerBangSearchProvider = TriggerBangSearchFamily();

/// See also [triggerBangSearch].
class TriggerBangSearchFamily extends Family<AsyncValue<Uri>> {
  /// See also [triggerBangSearch].
  const TriggerBangSearchFamily();

  /// See also [triggerBangSearch].
  TriggerBangSearchProvider call(
    BangData bang,
    String searchQuery,
  ) {
    return TriggerBangSearchProvider(
      bang,
      searchQuery,
    );
  }

  @override
  TriggerBangSearchProvider getProviderOverride(
    covariant TriggerBangSearchProvider provider,
  ) {
    return call(
      provider.bang,
      provider.searchQuery,
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
  String? get name => r'triggerBangSearchProvider';
}

/// See also [triggerBangSearch].
class TriggerBangSearchProvider extends AutoDisposeFutureProvider<Uri> {
  /// See also [triggerBangSearch].
  TriggerBangSearchProvider(
    BangData bang,
    String searchQuery,
  ) : this._internal(
          (ref) => triggerBangSearch(
            ref as TriggerBangSearchRef,
            bang,
            searchQuery,
          ),
          from: triggerBangSearchProvider,
          name: r'triggerBangSearchProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$triggerBangSearchHash,
          dependencies: TriggerBangSearchFamily._dependencies,
          allTransitiveDependencies:
              TriggerBangSearchFamily._allTransitiveDependencies,
          bang: bang,
          searchQuery: searchQuery,
        );

  TriggerBangSearchProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.bang,
    required this.searchQuery,
  }) : super.internal();

  final BangData bang;
  final String searchQuery;

  @override
  Override overrideWith(
    FutureOr<Uri> Function(TriggerBangSearchRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: TriggerBangSearchProvider._internal(
        (ref) => create(ref as TriggerBangSearchRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        bang: bang,
        searchQuery: searchQuery,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Uri> createElement() {
    return _TriggerBangSearchProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TriggerBangSearchProvider &&
        other.bang == bang &&
        other.searchQuery == searchQuery;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, bang.hashCode);
    hash = _SystemHash.combine(hash, searchQuery.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin TriggerBangSearchRef on AutoDisposeFutureProviderRef<Uri> {
  /// The parameter `bang` of this provider.
  BangData get bang;

  /// The parameter `searchQuery` of this provider.
  String get searchQuery;
}

class _TriggerBangSearchProviderElement
    extends AutoDisposeFutureProviderElement<Uri> with TriggerBangSearchRef {
  _TriggerBangSearchProviderElement(super.provider);

  @override
  BangData get bang => (origin as TriggerBangSearchProvider).bang;
  @override
  String get searchQuery => (origin as TriggerBangSearchProvider).searchQuery;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
