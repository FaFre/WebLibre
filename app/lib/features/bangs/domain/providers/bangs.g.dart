// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bangs.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$bangDataHash() => r'057a002de9789ab74c8f3b337a43faa26b788d8d';

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

/// See also [bangData].
@ProviderFor(bangData)
const bangDataProvider = BangDataFamily();

/// See also [bangData].
class BangDataFamily extends Family<AsyncValue<BangData?>> {
  /// See also [bangData].
  const BangDataFamily();

  /// See also [bangData].
  BangDataProvider call(String? trigger) {
    return BangDataProvider(trigger);
  }

  @override
  BangDataProvider getProviderOverride(covariant BangDataProvider provider) {
    return call(provider.trigger);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'bangDataProvider';
}

/// See also [bangData].
class BangDataProvider extends AutoDisposeStreamProvider<BangData?> {
  /// See also [bangData].
  BangDataProvider(String? trigger)
    : this._internal(
        (ref) => bangData(ref as BangDataRef, trigger),
        from: bangDataProvider,
        name: r'bangDataProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$bangDataHash,
        dependencies: BangDataFamily._dependencies,
        allTransitiveDependencies: BangDataFamily._allTransitiveDependencies,
        trigger: trigger,
      );

  BangDataProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.trigger,
  }) : super.internal();

  final String? trigger;

  @override
  Override overrideWith(
    Stream<BangData?> Function(BangDataRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: BangDataProvider._internal(
        (ref) => create(ref as BangDataRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        trigger: trigger,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<BangData?> createElement() {
    return _BangDataProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is BangDataProvider && other.trigger == trigger;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, trigger.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin BangDataRef on AutoDisposeStreamProviderRef<BangData?> {
  /// The parameter `trigger` of this provider.
  String? get trigger;
}

class _BangDataProviderElement
    extends AutoDisposeStreamProviderElement<BangData?>
    with BangDataRef {
  _BangDataProviderElement(super.provider);

  @override
  String? get trigger => (origin as BangDataProvider).trigger;
}

String _$defaultSearchBangDataHash() =>
    r'c93026fe7b1650fe8a39bb2a8850af3ee416c306';

/// See also [defaultSearchBangData].
@ProviderFor(defaultSearchBangData)
final defaultSearchBangDataProvider = StreamProvider<BangData?>.internal(
  defaultSearchBangData,
  name: r'defaultSearchBangDataProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$defaultSearchBangDataHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DefaultSearchBangDataRef = StreamProviderRef<BangData?>;
String _$bangCategoriesHash() => r'947fcfd2dffcc7f585c6ed7379d319f4fe72293a';

/// See also [bangCategories].
@ProviderFor(bangCategories)
final bangCategoriesProvider =
    AutoDisposeStreamProvider<Map<String, List<String>>>.internal(
      bangCategories,
      name: r'bangCategoriesProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$bangCategoriesHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef BangCategoriesRef =
    AutoDisposeStreamProviderRef<Map<String, List<String>>>;
String _$bangDataListHash() => r'cd034fdf046b156ac452edd0857ac054ab477917';

/// See also [bangDataList].
@ProviderFor(bangDataList)
const bangDataListProvider = BangDataListFamily();

/// See also [bangDataList].
class BangDataListFamily extends Family<AsyncValue<List<BangData>>> {
  /// See also [bangDataList].
  const BangDataListFamily();

  /// See also [bangDataList].
  BangDataListProvider call({
    ({
      ({String category, String? subCategory})? categoryFilter,
      String? domain,
      Iterable<BangGroup>? groups,
      bool? orderMostFrequentFirst,
    })?
    filter,
  }) {
    return BangDataListProvider(filter: filter);
  }

  @override
  BangDataListProvider getProviderOverride(
    covariant BangDataListProvider provider,
  ) {
    return call(filter: provider.filter);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'bangDataListProvider';
}

/// See also [bangDataList].
class BangDataListProvider extends AutoDisposeStreamProvider<List<BangData>> {
  /// See also [bangDataList].
  BangDataListProvider({
    ({
      ({String category, String? subCategory})? categoryFilter,
      String? domain,
      Iterable<BangGroup>? groups,
      bool? orderMostFrequentFirst,
    })?
    filter,
  }) : this._internal(
         (ref) => bangDataList(ref as BangDataListRef, filter: filter),
         from: bangDataListProvider,
         name: r'bangDataListProvider',
         debugGetCreateSourceHash:
             const bool.fromEnvironment('dart.vm.product')
                 ? null
                 : _$bangDataListHash,
         dependencies: BangDataListFamily._dependencies,
         allTransitiveDependencies:
             BangDataListFamily._allTransitiveDependencies,
         filter: filter,
       );

  BangDataListProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.filter,
  }) : super.internal();

  final ({
    ({String category, String? subCategory})? categoryFilter,
    String? domain,
    Iterable<BangGroup>? groups,
    bool? orderMostFrequentFirst,
  })?
  filter;

  @override
  Override overrideWith(
    Stream<List<BangData>> Function(BangDataListRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: BangDataListProvider._internal(
        (ref) => create(ref as BangDataListRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        filter: filter,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<BangData>> createElement() {
    return _BangDataListProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is BangDataListProvider && other.filter == filter;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, filter.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin BangDataListRef on AutoDisposeStreamProviderRef<List<BangData>> {
  /// The parameter `filter` of this provider.
  ({
    ({String category, String? subCategory})? categoryFilter,
    String? domain,
    Iterable<BangGroup>? groups,
    bool? orderMostFrequentFirst,
  })?
  get filter;
}

class _BangDataListProviderElement
    extends AutoDisposeStreamProviderElement<List<BangData>>
    with BangDataListRef {
  _BangDataListProviderElement(super.provider);

  @override
  ({
    ({String category, String? subCategory})? categoryFilter,
    String? domain,
    Iterable<BangGroup>? groups,
    bool? orderMostFrequentFirst,
  })?
  get filter => (origin as BangDataListProvider).filter;
}

String _$frequentBangDataListHash() =>
    r'27bc10ddf502266458af3910fff09bc8282a8e5c';

/// See also [frequentBangDataList].
@ProviderFor(frequentBangDataList)
final frequentBangDataListProvider =
    AutoDisposeStreamProvider<List<BangData>>.internal(
      frequentBangDataList,
      name: r'frequentBangDataListProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$frequentBangDataListHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FrequentBangDataListRef = AutoDisposeStreamProviderRef<List<BangData>>;
String _$searchHistoryHash() => r'7b97798729643de8e44fd8024cdc02f35124b08b';

/// See also [searchHistory].
@ProviderFor(searchHistory)
final searchHistoryProvider =
    AutoDisposeStreamProvider<List<SearchHistoryEntry>>.internal(
      searchHistory,
      name: r'searchHistoryProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$searchHistoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SearchHistoryRef =
    AutoDisposeStreamProviderRef<List<SearchHistoryEntry>>;
String _$lastSyncOfGroupHash() => r'23d07f3132ba9bb35a31f74e3a69698d31d4c569';

/// See also [lastSyncOfGroup].
@ProviderFor(lastSyncOfGroup)
const lastSyncOfGroupProvider = LastSyncOfGroupFamily();

/// See also [lastSyncOfGroup].
class LastSyncOfGroupFamily extends Family<AsyncValue<DateTime?>> {
  /// See also [lastSyncOfGroup].
  const LastSyncOfGroupFamily();

  /// See also [lastSyncOfGroup].
  LastSyncOfGroupProvider call(BangGroup group) {
    return LastSyncOfGroupProvider(group);
  }

  @override
  LastSyncOfGroupProvider getProviderOverride(
    covariant LastSyncOfGroupProvider provider,
  ) {
    return call(provider.group);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'lastSyncOfGroupProvider';
}

/// See also [lastSyncOfGroup].
class LastSyncOfGroupProvider extends AutoDisposeStreamProvider<DateTime?> {
  /// See also [lastSyncOfGroup].
  LastSyncOfGroupProvider(BangGroup group)
    : this._internal(
        (ref) => lastSyncOfGroup(ref as LastSyncOfGroupRef, group),
        from: lastSyncOfGroupProvider,
        name: r'lastSyncOfGroupProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$lastSyncOfGroupHash,
        dependencies: LastSyncOfGroupFamily._dependencies,
        allTransitiveDependencies:
            LastSyncOfGroupFamily._allTransitiveDependencies,
        group: group,
      );

  LastSyncOfGroupProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.group,
  }) : super.internal();

  final BangGroup group;

  @override
  Override overrideWith(
    Stream<DateTime?> Function(LastSyncOfGroupRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: LastSyncOfGroupProvider._internal(
        (ref) => create(ref as LastSyncOfGroupRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        group: group,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<DateTime?> createElement() {
    return _LastSyncOfGroupProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is LastSyncOfGroupProvider && other.group == group;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, group.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin LastSyncOfGroupRef on AutoDisposeStreamProviderRef<DateTime?> {
  /// The parameter `group` of this provider.
  BangGroup get group;
}

class _LastSyncOfGroupProviderElement
    extends AutoDisposeStreamProviderElement<DateTime?>
    with LastSyncOfGroupRef {
  _LastSyncOfGroupProviderElement(super.provider);

  @override
  BangGroup get group => (origin as LastSyncOfGroupProvider).group;
}

String _$bangCountOfGroupHash() => r'211ffcd7f49b637a7953f913dc5eafda344423f3';

/// See also [bangCountOfGroup].
@ProviderFor(bangCountOfGroup)
const bangCountOfGroupProvider = BangCountOfGroupFamily();

/// See also [bangCountOfGroup].
class BangCountOfGroupFamily extends Family<AsyncValue<int>> {
  /// See also [bangCountOfGroup].
  const BangCountOfGroupFamily();

  /// See also [bangCountOfGroup].
  BangCountOfGroupProvider call(BangGroup group) {
    return BangCountOfGroupProvider(group);
  }

  @override
  BangCountOfGroupProvider getProviderOverride(
    covariant BangCountOfGroupProvider provider,
  ) {
    return call(provider.group);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'bangCountOfGroupProvider';
}

/// See also [bangCountOfGroup].
class BangCountOfGroupProvider extends AutoDisposeStreamProvider<int> {
  /// See also [bangCountOfGroup].
  BangCountOfGroupProvider(BangGroup group)
    : this._internal(
        (ref) => bangCountOfGroup(ref as BangCountOfGroupRef, group),
        from: bangCountOfGroupProvider,
        name: r'bangCountOfGroupProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$bangCountOfGroupHash,
        dependencies: BangCountOfGroupFamily._dependencies,
        allTransitiveDependencies:
            BangCountOfGroupFamily._allTransitiveDependencies,
        group: group,
      );

  BangCountOfGroupProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.group,
  }) : super.internal();

  final BangGroup group;

  @override
  Override overrideWith(
    Stream<int> Function(BangCountOfGroupRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: BangCountOfGroupProvider._internal(
        (ref) => create(ref as BangCountOfGroupRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        group: group,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<int> createElement() {
    return _BangCountOfGroupProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is BangCountOfGroupProvider && other.group == group;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, group.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin BangCountOfGroupRef on AutoDisposeStreamProviderRef<int> {
  /// The parameter `group` of this provider.
  BangGroup get group;
}

class _BangCountOfGroupProviderElement
    extends AutoDisposeStreamProviderElement<int>
    with BangCountOfGroupRef {
  _BangCountOfGroupProviderElement(super.provider);

  @override
  BangGroup get group => (origin as BangCountOfGroupProvider).group;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
