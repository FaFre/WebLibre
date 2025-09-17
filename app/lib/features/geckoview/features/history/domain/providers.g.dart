// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$browsingHistoryHash() => r'1f644757c60473f00dd94c9d312647baeaec525a';

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

/// See also [browsingHistory].
@ProviderFor(browsingHistory)
const browsingHistoryProvider = BrowsingHistoryFamily();

/// See also [browsingHistory].
class BrowsingHistoryFamily extends Family<AsyncValue<List<VisitInfo>>> {
  /// See also [browsingHistory].
  const BrowsingHistoryFamily();

  /// See also [browsingHistory].
  BrowsingHistoryProvider call({
    required DateTime start,
    required DateTime end,
    required Set<VisitType> types,
  }) {
    return BrowsingHistoryProvider(start: start, end: end, types: types);
  }

  @override
  BrowsingHistoryProvider getProviderOverride(
    covariant BrowsingHistoryProvider provider,
  ) {
    return call(
      start: provider.start,
      end: provider.end,
      types: provider.types,
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
  String? get name => r'browsingHistoryProvider';
}

/// See also [browsingHistory].
class BrowsingHistoryProvider
    extends AutoDisposeFutureProvider<List<VisitInfo>> {
  /// See also [browsingHistory].
  BrowsingHistoryProvider({
    required DateTime start,
    required DateTime end,
    required Set<VisitType> types,
  }) : this._internal(
         (ref) => browsingHistory(
           ref as BrowsingHistoryRef,
           start: start,
           end: end,
           types: types,
         ),
         from: browsingHistoryProvider,
         name: r'browsingHistoryProvider',
         debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
             ? null
             : _$browsingHistoryHash,
         dependencies: BrowsingHistoryFamily._dependencies,
         allTransitiveDependencies:
             BrowsingHistoryFamily._allTransitiveDependencies,
         start: start,
         end: end,
         types: types,
       );

  BrowsingHistoryProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.start,
    required this.end,
    required this.types,
  }) : super.internal();

  final DateTime start;
  final DateTime end;
  final Set<VisitType> types;

  @override
  Override overrideWith(
    FutureOr<List<VisitInfo>> Function(BrowsingHistoryRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: BrowsingHistoryProvider._internal(
        (ref) => create(ref as BrowsingHistoryRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        start: start,
        end: end,
        types: types,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<VisitInfo>> createElement() {
    return _BrowsingHistoryProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is BrowsingHistoryProvider &&
        other.start == start &&
        other.end == end &&
        other.types == types;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, start.hashCode);
    hash = _SystemHash.combine(hash, end.hashCode);
    hash = _SystemHash.combine(hash, types.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin BrowsingHistoryRef on AutoDisposeFutureProviderRef<List<VisitInfo>> {
  /// The parameter `start` of this provider.
  DateTime get start;

  /// The parameter `end` of this provider.
  DateTime get end;

  /// The parameter `types` of this provider.
  Set<VisitType> get types;
}

class _BrowsingHistoryProviderElement
    extends AutoDisposeFutureProviderElement<List<VisitInfo>>
    with BrowsingHistoryRef {
  _BrowsingHistoryProviderElement(super.provider);

  @override
  DateTime get start => (origin as BrowsingHistoryProvider).start;
  @override
  DateTime get end => (origin as BrowsingHistoryProvider).end;
  @override
  Set<VisitType> get types => (origin as BrowsingHistoryProvider).types;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
