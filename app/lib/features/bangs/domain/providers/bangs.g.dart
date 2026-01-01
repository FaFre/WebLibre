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

String _$searchHistoryHash() => r'7b97798729643de8e44fd8024cdc02f35124b08b';

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
