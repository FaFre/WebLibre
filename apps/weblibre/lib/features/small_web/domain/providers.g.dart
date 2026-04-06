// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(kagiSourceService)
final kagiSourceServiceProvider = KagiSourceServiceProvider._();

final class KagiSourceServiceProvider
    extends
        $FunctionalProvider<
          AsyncValue<KagiSourceService>,
          KagiSourceService,
          FutureOr<KagiSourceService>
        >
    with
        $FutureModifier<KagiSourceService>,
        $FutureProvider<KagiSourceService> {
  KagiSourceServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'kagiSourceServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$kagiSourceServiceHash();

  @$internal
  @override
  $FutureProviderElement<KagiSourceService> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<KagiSourceService> create(Ref ref) {
    return kagiSourceService(ref);
  }
}

String _$kagiSourceServiceHash() => r'7f0cca556d22cc65356660f3e59c976a35d40d37';

@ProviderFor(wanderSourceService)
final wanderSourceServiceProvider = WanderSourceServiceProvider._();

final class WanderSourceServiceProvider
    extends
        $FunctionalProvider<
          WanderSourceService,
          WanderSourceService,
          WanderSourceService
        >
    with $Provider<WanderSourceService> {
  WanderSourceServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'wanderSourceServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$wanderSourceServiceHash();

  @$internal
  @override
  $ProviderElement<WanderSourceService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  WanderSourceService create(Ref ref) {
    return wanderSourceService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WanderSourceService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WanderSourceService>(value),
    );
  }
}

String _$wanderSourceServiceHash() =>
    r'80574ea0c51f56325940edb0fa7e849784ba7421';

@ProviderFor(smallWebDiscoverService)
final smallWebDiscoverServiceProvider = SmallWebDiscoverServiceProvider._();

final class SmallWebDiscoverServiceProvider
    extends
        $FunctionalProvider<
          AsyncValue<SmallWebDiscoverService>,
          SmallWebDiscoverService,
          FutureOr<SmallWebDiscoverService>
        >
    with
        $FutureModifier<SmallWebDiscoverService>,
        $FutureProvider<SmallWebDiscoverService> {
  SmallWebDiscoverServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'smallWebDiscoverServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$smallWebDiscoverServiceHash();

  @$internal
  @override
  $FutureProviderElement<SmallWebDiscoverService> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<SmallWebDiscoverService> create(Ref ref) {
    return smallWebDiscoverService(ref);
  }
}

String _$smallWebDiscoverServiceHash() =>
    r'14fba9eb1c2aa51fa1fac2c2c764ea400603e8ca';

@ProviderFor(smallWebRecentVisits)
final smallWebRecentVisitsProvider = SmallWebRecentVisitsFamily._();

final class SmallWebRecentVisitsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<GetRecentVisitsResult>>,
          List<GetRecentVisitsResult>,
          Stream<List<GetRecentVisitsResult>>
        >
    with
        $FutureModifier<List<GetRecentVisitsResult>>,
        $StreamProvider<List<GetRecentVisitsResult>> {
  SmallWebRecentVisitsProvider._({
    required SmallWebRecentVisitsFamily super.from,
    required (SmallWebSourceKind, KagiSmallWebMode?) super.argument,
  }) : super(
         retry: null,
         name: r'smallWebRecentVisitsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$smallWebRecentVisitsHash();

  @override
  String toString() {
    return r'smallWebRecentVisitsProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $StreamProviderElement<List<GetRecentVisitsResult>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<GetRecentVisitsResult>> create(Ref ref) {
    final argument = this.argument as (SmallWebSourceKind, KagiSmallWebMode?);
    return smallWebRecentVisits(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is SmallWebRecentVisitsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$smallWebRecentVisitsHash() =>
    r'ec7d837523b856a6e7e828c0f26a97913e2af34a';

final class SmallWebRecentVisitsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          Stream<List<GetRecentVisitsResult>>,
          (SmallWebSourceKind, KagiSmallWebMode?)
        > {
  SmallWebRecentVisitsFamily._()
    : super(
        retry: null,
        name: r'smallWebRecentVisitsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  SmallWebRecentVisitsProvider call(
    SmallWebSourceKind sourceKind,
    KagiSmallWebMode? mode,
  ) => SmallWebRecentVisitsProvider._(argument: (sourceKind, mode), from: this);

  @override
  String toString() => r'smallWebRecentVisitsProvider';
}

@ProviderFor(smallWebAllModeItemCounts)
final smallWebAllModeItemCountsProvider = SmallWebAllModeItemCountsProvider._();

final class SmallWebAllModeItemCountsProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<KagiSmallWebMode, int>>,
          Map<KagiSmallWebMode, int>,
          Stream<Map<KagiSmallWebMode, int>>
        >
    with
        $FutureModifier<Map<KagiSmallWebMode, int>>,
        $StreamProvider<Map<KagiSmallWebMode, int>> {
  SmallWebAllModeItemCountsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'smallWebAllModeItemCountsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$smallWebAllModeItemCountsHash();

  @$internal
  @override
  $StreamProviderElement<Map<KagiSmallWebMode, int>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<Map<KagiSmallWebMode, int>> create(Ref ref) {
    return smallWebAllModeItemCounts(ref);
  }
}

String _$smallWebAllModeItemCountsHash() =>
    r'64d50f9fe581003d6f1e7df61b859118a5ad31fa';

@ProviderFor(wanderConsoleStats)
final wanderConsoleStatsProvider = WanderConsoleStatsFamily._();

final class WanderConsoleStatsProvider
    extends
        $FunctionalProvider<
          AsyncValue<({int linkedConsoles, int pages})>,
          ({int linkedConsoles, int pages}),
          Stream<({int linkedConsoles, int pages})>
        >
    with
        $FutureModifier<({int linkedConsoles, int pages})>,
        $StreamProvider<({int linkedConsoles, int pages})> {
  WanderConsoleStatsProvider._({
    required WanderConsoleStatsFamily super.from,
    required Uri super.argument,
  }) : super(
         retry: null,
         name: r'wanderConsoleStatsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$wanderConsoleStatsHash();

  @override
  String toString() {
    return r'wanderConsoleStatsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<({int linkedConsoles, int pages})> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<({int linkedConsoles, int pages})> create(Ref ref) {
    final argument = this.argument as Uri;
    return wanderConsoleStats(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is WanderConsoleStatsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$wanderConsoleStatsHash() =>
    r'201d2b0669b878762c3d535f39f6d04e030b8112';

final class WanderConsoleStatsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          Stream<({int linkedConsoles, int pages})>,
          Uri
        > {
  WanderConsoleStatsFamily._()
    : super(
        retry: null,
        name: r'wanderConsoleStatsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  WanderConsoleStatsProvider call(Uri consoleUrl) =>
      WanderConsoleStatsProvider._(argument: consoleUrl, from: this);

  @override
  String toString() => r'wanderConsoleStatsProvider';
}

@ProviderFor(wanderNeighborConsoles)
final wanderNeighborConsolesProvider = WanderNeighborConsolesFamily._();

final class WanderNeighborConsolesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<GetNeighborConsolesWithPageCountsResult>>,
          List<GetNeighborConsolesWithPageCountsResult>,
          Stream<List<GetNeighborConsolesWithPageCountsResult>>
        >
    with
        $FutureModifier<List<GetNeighborConsolesWithPageCountsResult>>,
        $StreamProvider<List<GetNeighborConsolesWithPageCountsResult>> {
  WanderNeighborConsolesProvider._({
    required WanderNeighborConsolesFamily super.from,
    required Uri super.argument,
  }) : super(
         retry: null,
         name: r'wanderNeighborConsolesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$wanderNeighborConsolesHash();

  @override
  String toString() {
    return r'wanderNeighborConsolesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<GetNeighborConsolesWithPageCountsResult>>
  $createElement($ProviderPointer pointer) => $StreamProviderElement(pointer);

  @override
  Stream<List<GetNeighborConsolesWithPageCountsResult>> create(Ref ref) {
    final argument = this.argument as Uri;
    return wanderNeighborConsoles(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is WanderNeighborConsolesProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$wanderNeighborConsolesHash() =>
    r'08393800b649cb88e21281dad02a7ed6c745797e';

final class WanderNeighborConsolesFamily extends $Family
    with
        $FunctionalFamilyOverride<
          Stream<List<GetNeighborConsolesWithPageCountsResult>>,
          Uri
        > {
  WanderNeighborConsolesFamily._()
    : super(
        retry: null,
        name: r'wanderNeighborConsolesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  WanderNeighborConsolesProvider call(Uri consoleUrl) =>
      WanderNeighborConsolesProvider._(argument: consoleUrl, from: this);

  @override
  String toString() => r'wanderNeighborConsolesProvider';
}

@ProviderFor(wanderAllConsoles)
final wanderAllConsolesProvider = WanderAllConsolesFamily._();

final class WanderAllConsolesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<GetAllConsolesWithPageCountsResult>>,
          List<GetAllConsolesWithPageCountsResult>,
          Stream<List<GetAllConsolesWithPageCountsResult>>
        >
    with
        $FutureModifier<List<GetAllConsolesWithPageCountsResult>>,
        $StreamProvider<List<GetAllConsolesWithPageCountsResult>> {
  WanderAllConsolesProvider._({
    required WanderAllConsolesFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'wanderAllConsolesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$wanderAllConsolesHash();

  @override
  String toString() {
    return r'wanderAllConsolesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<GetAllConsolesWithPageCountsResult>>
  $createElement($ProviderPointer pointer) => $StreamProviderElement(pointer);

  @override
  Stream<List<GetAllConsolesWithPageCountsResult>> create(Ref ref) {
    final argument = this.argument as String;
    return wanderAllConsoles(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is WanderAllConsolesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$wanderAllConsolesHash() => r'27d87bbad8fb9e993de36c70649b324a98c8bf87';

final class WanderAllConsolesFamily extends $Family
    with
        $FunctionalFamilyOverride<
          Stream<List<GetAllConsolesWithPageCountsResult>>,
          String
        > {
  WanderAllConsolesFamily._()
    : super(
        retry: null,
        name: r'wanderAllConsolesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  WanderAllConsolesProvider call(String query) =>
      WanderAllConsolesProvider._(argument: query, from: this);

  @override
  String toString() => r'wanderAllConsolesProvider';
}
