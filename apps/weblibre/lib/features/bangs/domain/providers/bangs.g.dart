// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bangs.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(defaultSearchBangData)
final defaultSearchBangDataProvider = DefaultSearchBangDataProvider._();

final class DefaultSearchBangDataProvider
    extends
        $FunctionalProvider<AsyncValue<BangData?>, BangData?, Stream<BangData?>>
    with $FutureModifier<BangData?>, $StreamProvider<BangData?> {
  DefaultSearchBangDataProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'defaultSearchBangDataProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$defaultSearchBangDataHash();

  @$internal
  @override
  $StreamProviderElement<BangData?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<BangData?> create(Ref ref) {
    return defaultSearchBangData(ref);
  }
}

String _$defaultSearchBangDataHash() =>
    r'5f43b8989219cf3cb2f5ca65df351b6cb100427f';

/// [defaultSearchBangData] for the displayed layer
/// (`displayedGeneralSettings`): in the onboarding the draft's search
/// provider.

@ProviderFor(displayedDefaultSearchBangData)
final displayedDefaultSearchBangDataProvider =
    DisplayedDefaultSearchBangDataProvider._();

/// [defaultSearchBangData] for the displayed layer
/// (`displayedGeneralSettings`): in the onboarding the draft's search
/// provider.

final class DisplayedDefaultSearchBangDataProvider
    extends
        $FunctionalProvider<AsyncValue<BangData?>, BangData?, Stream<BangData?>>
    with $FutureModifier<BangData?>, $StreamProvider<BangData?> {
  /// [defaultSearchBangData] for the displayed layer
  /// (`displayedGeneralSettings`): in the onboarding the draft's search
  /// provider.
  DisplayedDefaultSearchBangDataProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'displayedDefaultSearchBangDataProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$displayedDefaultSearchBangDataHash();

  @$internal
  @override
  $StreamProviderElement<BangData?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<BangData?> create(Ref ref) {
    return displayedDefaultSearchBangData(ref);
  }
}

String _$displayedDefaultSearchBangDataHash() =>
    r'd0436b98c24bceccfa3134b38294688b5bdb4d97';

@ProviderFor(defaultSearchBang)
final defaultSearchBangProvider = DefaultSearchBangProvider._();

final class DefaultSearchBangProvider
    extends
        $FunctionalProvider<
          AsyncValue<BangData?>,
          BangData?,
          FutureOr<BangData?>
        >
    with $FutureModifier<BangData?>, $FutureProvider<BangData?> {
  DefaultSearchBangProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'defaultSearchBangProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$defaultSearchBangHash();

  @$internal
  @override
  $FutureProviderElement<BangData?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<BangData?> create(Ref ref) {
    return defaultSearchBang(ref);
  }
}

String _$defaultSearchBangHash() => r'2da8ec4ccd0da74a7242a83ef4efe53850293116';

@ProviderFor(bangData)
final bangDataProvider = BangDataFamily._();

final class BangDataProvider
    extends
        $FunctionalProvider<AsyncValue<BangData?>, BangData?, Stream<BangData?>>
    with $FutureModifier<BangData?>, $StreamProvider<BangData?> {
  BangDataProvider._({
    required BangDataFamily super.from,
    required BangKey super.argument,
  }) : super(
         retry: null,
         name: r'bangDataProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$bangDataHash();

  @override
  String toString() {
    return r'bangDataProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<BangData?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<BangData?> create(Ref ref) {
    final argument = this.argument as BangKey;
    return bangData(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is BangDataProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$bangDataHash() => r'bd9f5ec8b29aab74620a9b5a4246cb7e3b2fd377';

final class BangDataFamily extends $Family
    with $FunctionalFamilyOverride<Stream<BangData?>, BangKey> {
  BangDataFamily._()
    : super(
        retry: null,
        name: r'bangDataProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  BangDataProvider call(BangKey key) =>
      BangDataProvider._(argument: key, from: this);

  @override
  String toString() => r'bangDataProvider';
}

@ProviderFor(bangCategories)
final bangCategoriesProvider = BangCategoriesProvider._();

final class BangCategoriesProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<String, List<String>>>,
          Map<String, List<String>>,
          Stream<Map<String, List<String>>>
        >
    with
        $FutureModifier<Map<String, List<String>>>,
        $StreamProvider<Map<String, List<String>>> {
  BangCategoriesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'bangCategoriesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$bangCategoriesHash();

  @$internal
  @override
  $StreamProviderElement<Map<String, List<String>>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<Map<String, List<String>>> create(Ref ref) {
    return bangCategories(ref);
  }
}

String _$bangCategoriesHash() => r'947fcfd2dffcc7f585c6ed7379d319f4fe72293a';

@ProviderFor(bangList)
final bangListProvider = BangListFamily._();

final class BangListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<BangData>>,
          List<BangData>,
          Stream<List<BangData>>
        >
    with $FutureModifier<List<BangData>>, $StreamProvider<List<BangData>> {
  BangListProvider._({
    required BangListFamily super.from,
    required ({
      List<String>? triggers,
      List<BangGroup>? groups,
      String? domain,
      ({String category, String? subCategory})? categoryFilter,
      bool? orderMostFrequentFirst,
    })
    super.argument,
  }) : super(
         retry: null,
         name: r'bangListProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$bangListHash();

  @override
  String toString() {
    return r'bangListProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $StreamProviderElement<List<BangData>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<BangData>> create(Ref ref) {
    final argument =
        this.argument
            as ({
              List<String>? triggers,
              List<BangGroup>? groups,
              String? domain,
              ({String category, String? subCategory})? categoryFilter,
              bool? orderMostFrequentFirst,
            });
    return bangList(
      ref,
      triggers: argument.triggers,
      groups: argument.groups,
      domain: argument.domain,
      categoryFilter: argument.categoryFilter,
      orderMostFrequentFirst: argument.orderMostFrequentFirst,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is BangListProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$bangListHash() => r'd1e0bb9fa4f523ce516e075c0d149bf7803ebb2b';

final class BangListFamily extends $Family
    with
        $FunctionalFamilyOverride<
          Stream<List<BangData>>,
          ({
            List<String>? triggers,
            List<BangGroup>? groups,
            String? domain,
            ({String category, String? subCategory})? categoryFilter,
            bool? orderMostFrequentFirst,
          })
        > {
  BangListFamily._()
    : super(
        retry: null,
        name: r'bangListProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  BangListProvider call({
    List<String>? triggers,
    List<BangGroup>? groups,
    String? domain,
    ({String category, String? subCategory})? categoryFilter,
    bool? orderMostFrequentFirst,
  }) => BangListProvider._(
    argument: (
      triggers: triggers,
      groups: groups,
      domain: domain,
      categoryFilter: categoryFilter,
      orderMostFrequentFirst: orderMostFrequentFirst,
    ),
    from: this,
  );

  @override
  String toString() => r'bangListProvider';
}

@ProviderFor(frequentBangList)
final frequentBangListProvider = FrequentBangListProvider._();

final class FrequentBangListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<BangData>>,
          List<BangData>,
          Stream<List<BangData>>
        >
    with $FutureModifier<List<BangData>>, $StreamProvider<List<BangData>> {
  FrequentBangListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'frequentBangListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$frequentBangListHash();

  @$internal
  @override
  $StreamProviderElement<List<BangData>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<BangData>> create(Ref ref) {
    return frequentBangList(ref);
  }
}

String _$frequentBangListHash() => r'2c1ecb7e9416772fc1c32d01d767e1eb4f865975';

/// The bangs the user pinned, in the order they pinned them.
///
/// Pins that no longer resolve to a bang are skipped rather than rendered as
/// gaps — a repository resync or a deleted user bang can strand a key.

@ProviderFor(pinnedBangList)
final pinnedBangListProvider = PinnedBangListProvider._();

/// The bangs the user pinned, in the order they pinned them.
///
/// Pins that no longer resolve to a bang are skipped rather than rendered as
/// gaps — a repository resync or a deleted user bang can strand a key.

final class PinnedBangListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<BangData>>,
          List<BangData>,
          Stream<List<BangData>>
        >
    with $FutureModifier<List<BangData>>, $StreamProvider<List<BangData>> {
  /// The bangs the user pinned, in the order they pinned them.
  ///
  /// Pins that no longer resolve to a bang are skipped rather than rendered as
  /// gaps — a repository resync or a deleted user bang can strand a key.
  PinnedBangListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pinnedBangListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pinnedBangListHash();

  @$internal
  @override
  $StreamProviderElement<List<BangData>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<BangData>> create(Ref ref) {
    return pinnedBangList(ref);
  }
}

String _$pinnedBangListHash() => r'0e4a53d668a3a971390c2394257e9d14ec1e553d';

/// Adds and removes pins. Pinning is idempotent, so a chip and a details screen
/// can both drive it without having to agree on the current state first.

@ProviderFor(PinnedBangs)
final pinnedBangsProvider = PinnedBangsProvider._();

/// Adds and removes pins. Pinning is idempotent, so a chip and a details screen
/// can both drive it without having to agree on the current state first.
final class PinnedBangsProvider extends $NotifierProvider<PinnedBangs, void> {
  /// Adds and removes pins. Pinning is idempotent, so a chip and a details screen
  /// can both drive it without having to agree on the current state first.
  PinnedBangsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pinnedBangsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pinnedBangsHash();

  @$internal
  @override
  PinnedBangs create() => PinnedBangs();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$pinnedBangsHash() => r'18e48df24ef08277eae1636d950f43cbb02e65c3';

/// Adds and removes pins. Pinning is idempotent, so a chip and a details screen
/// can both drive it without having to agree on the current state first.

abstract class _$PinnedBangs extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<void, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<void, void>,
              void,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(searchHistory)
final searchHistoryProvider = SearchHistoryProvider._();

final class SearchHistoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<SearchHistoryEntry>>,
          List<SearchHistoryEntry>,
          Stream<List<SearchHistoryEntry>>
        >
    with
        $FutureModifier<List<SearchHistoryEntry>>,
        $StreamProvider<List<SearchHistoryEntry>> {
  SearchHistoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'searchHistoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$searchHistoryHash();

  @$internal
  @override
  $StreamProviderElement<List<SearchHistoryEntry>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<SearchHistoryEntry>> create(Ref ref) {
    return searchHistory(ref);
  }
}

String _$searchHistoryHash() => r'5f9508a6b286bfcd1b641bd429de46ad052a3dfe';

@ProviderFor(lastSyncOfGroup)
final lastSyncOfGroupProvider = LastSyncOfGroupFamily._();

final class LastSyncOfGroupProvider
    extends
        $FunctionalProvider<AsyncValue<DateTime?>, DateTime?, Stream<DateTime?>>
    with $FutureModifier<DateTime?>, $StreamProvider<DateTime?> {
  LastSyncOfGroupProvider._({
    required LastSyncOfGroupFamily super.from,
    required BangGroup super.argument,
  }) : super(
         retry: null,
         name: r'lastSyncOfGroupProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$lastSyncOfGroupHash();

  @override
  String toString() {
    return r'lastSyncOfGroupProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<DateTime?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<DateTime?> create(Ref ref) {
    final argument = this.argument as BangGroup;
    return lastSyncOfGroup(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is LastSyncOfGroupProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$lastSyncOfGroupHash() => r'23d07f3132ba9bb35a31f74e3a69698d31d4c569';

final class LastSyncOfGroupFamily extends $Family
    with $FunctionalFamilyOverride<Stream<DateTime?>, BangGroup> {
  LastSyncOfGroupFamily._()
    : super(
        retry: null,
        name: r'lastSyncOfGroupProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  LastSyncOfGroupProvider call(BangGroup group) =>
      LastSyncOfGroupProvider._(argument: group, from: this);

  @override
  String toString() => r'lastSyncOfGroupProvider';
}

@ProviderFor(bangCountOfGroup)
final bangCountOfGroupProvider = BangCountOfGroupFamily._();

final class BangCountOfGroupProvider
    extends $FunctionalProvider<AsyncValue<int>, int, Stream<int>>
    with $FutureModifier<int>, $StreamProvider<int> {
  BangCountOfGroupProvider._({
    required BangCountOfGroupFamily super.from,
    required BangGroup super.argument,
  }) : super(
         retry: null,
         name: r'bangCountOfGroupProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$bangCountOfGroupHash();

  @override
  String toString() {
    return r'bangCountOfGroupProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<int> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<int> create(Ref ref) {
    final argument = this.argument as BangGroup;
    return bangCountOfGroup(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is BangCountOfGroupProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$bangCountOfGroupHash() => r'211ffcd7f49b637a7953f913dc5eafda344423f3';

final class BangCountOfGroupFamily extends $Family
    with $FunctionalFamilyOverride<Stream<int>, BangGroup> {
  BangCountOfGroupFamily._()
    : super(
        retry: null,
        name: r'bangCountOfGroupProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  BangCountOfGroupProvider call(BangGroup group) =>
      BangCountOfGroupProvider._(argument: group, from: this);

  @override
  String toString() => r'bangCountOfGroupProvider';
}

/// The bangs for [domain], most frequent first; none without a domain, rather
/// than every bang.

@ProviderFor(siteBangs)
final siteBangsProvider = SiteBangsFamily._();

/// The bangs for [domain], most frequent first; none without a domain, rather
/// than every bang.

final class SiteBangsProvider
    extends $FunctionalProvider<List<BangData>, List<BangData>, List<BangData>>
    with $Provider<List<BangData>> {
  /// The bangs for [domain], most frequent first; none without a domain, rather
  /// than every bang.
  SiteBangsProvider._({
    required SiteBangsFamily super.from,
    required String? super.argument,
  }) : super(
         retry: null,
         name: r'siteBangsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$siteBangsHash();

  @override
  String toString() {
    return r'siteBangsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<List<BangData>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<BangData> create(Ref ref) {
    final argument = this.argument as String?;
    return siteBangs(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<BangData> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<BangData>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is SiteBangsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$siteBangsHash() => r'1b475c46a7850f5a38209ba2bc9143574a834508';

/// The bangs for [domain], most frequent first; none without a domain, rather
/// than every bang.

final class SiteBangsFamily extends $Family
    with $FunctionalFamilyOverride<List<BangData>, String?> {
  SiteBangsFamily._()
    : super(
        retry: null,
        name: r'siteBangsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The bangs for [domain], most frequent first; none without a domain, rather
  /// than every bang.

  SiteBangsProvider call(String? domain) =>
      SiteBangsProvider._(argument: domain, from: this);

  @override
  String toString() => r'siteBangsProvider';
}
