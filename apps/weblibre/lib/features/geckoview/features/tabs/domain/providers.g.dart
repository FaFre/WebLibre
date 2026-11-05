// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(watchContainersWithCount)
final watchContainersWithCountProvider = WatchContainersWithCountProvider._();

final class WatchContainersWithCountProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ContainerDataWithCount>>,
          List<ContainerDataWithCount>,
          Stream<List<ContainerDataWithCount>>
        >
    with
        $FutureModifier<List<ContainerDataWithCount>>,
        $StreamProvider<List<ContainerDataWithCount>> {
  WatchContainersWithCountProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'watchContainersWithCountProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$watchContainersWithCountHash();

  @$internal
  @override
  $StreamProviderElement<List<ContainerDataWithCount>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<ContainerDataWithCount>> create(Ref ref) {
    return watchContainersWithCount(ref);
  }
}

String _$watchContainersWithCountHash() =>
    r'2d66528392ba8b153b490a2c5533d89167a25822';

/// The containers without their tab counts. Unlike [watchContainersWithCount],
/// its query does not re-run on every write to a tab, so it suits work too
/// costly to repeat that often.

@ProviderFor(watchContainers)
final watchContainersProvider = WatchContainersProvider._();

/// The containers without their tab counts. Unlike [watchContainersWithCount],
/// its query does not re-run on every write to a tab, so it suits work too
/// costly to repeat that often.

final class WatchContainersProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ContainerData>>,
          List<ContainerData>,
          Stream<List<ContainerData>>
        >
    with
        $FutureModifier<List<ContainerData>>,
        $StreamProvider<List<ContainerData>> {
  /// The containers without their tab counts. Unlike [watchContainersWithCount],
  /// its query does not re-run on every write to a tab, so it suits work too
  /// costly to repeat that often.
  WatchContainersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'watchContainersProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$watchContainersHash();

  @$internal
  @override
  $StreamProviderElement<List<ContainerData>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<ContainerData>> create(Ref ref) {
    return watchContainers(ref);
  }
}

String _$watchContainersHash() => r'006574bcc5a030163beb9556111f9e2da4c5c452';

/// When each container was last used, keyed by container id. See
/// `ContainerDao.getContainerLastUsed`.
///
/// Kept alive like [watchContainersWithCount]: the accordion leaves the tree
/// whenever a sheet hides the switcher, and an auto-disposed stream would
/// leave it without an order for a frame each time it comes back.

@ProviderFor(watchContainerLastUsed)
final watchContainerLastUsedProvider = WatchContainerLastUsedProvider._();

/// When each container was last used, keyed by container id. See
/// `ContainerDao.getContainerLastUsed`.
///
/// Kept alive like [watchContainersWithCount]: the accordion leaves the tree
/// whenever a sheet hides the switcher, and an auto-disposed stream would
/// leave it without an order for a frame each time it comes back.

final class WatchContainerLastUsedProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<String, DateTime>>,
          Map<String, DateTime>,
          Stream<Map<String, DateTime>>
        >
    with
        $FutureModifier<Map<String, DateTime>>,
        $StreamProvider<Map<String, DateTime>> {
  /// When each container was last used, keyed by container id. See
  /// `ContainerDao.getContainerLastUsed`.
  ///
  /// Kept alive like [watchContainersWithCount]: the accordion leaves the tree
  /// whenever a sheet hides the switcher, and an auto-disposed stream would
  /// leave it without an order for a frame each time it comes back.
  WatchContainerLastUsedProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'watchContainerLastUsedProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$watchContainerLastUsedHash();

  @$internal
  @override
  $StreamProviderElement<Map<String, DateTime>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<Map<String, DateTime>> create(Ref ref) {
    return watchContainerLastUsed(ref);
  }
}

String _$watchContainerLastUsedHash() =>
    r'a79eeeec9a6ca8f5aef049dc6be38a5a9f41f12e';

/// Which container each closed tab ran in, for the recently closed list.

@ProviderFor(watchClosedTabContainers)
final watchClosedTabContainersProvider = WatchClosedTabContainersProvider._();

/// Which container each closed tab ran in, for the recently closed list.

final class WatchClosedTabContainersProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ClosedTabContainerData>>,
          List<ClosedTabContainerData>,
          Stream<List<ClosedTabContainerData>>
        >
    with
        $FutureModifier<List<ClosedTabContainerData>>,
        $StreamProvider<List<ClosedTabContainerData>> {
  /// Which container each closed tab ran in, for the recently closed list.
  WatchClosedTabContainersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'watchClosedTabContainersProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$watchClosedTabContainersHash();

  @$internal
  @override
  $StreamProviderElement<List<ClosedTabContainerData>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<ClosedTabContainerData>> create(Ref ref) {
    return watchClosedTabContainers(ref);
  }
}

String _$watchClosedTabContainersHash() =>
    r'93b2698fe05151e90e1e771438fa57603066d0b6';

/// The destinations a container-cycling gesture steps through, in the order
/// the container chips render them: the unassigned pseudo-container (`null`)
/// first, then the containers themselves.
///
/// Synced tabs and the group-suggestions chip are deliberately left out — they
/// are not containers, and landing on them mid-swipe would be a dead end.

@ProviderFor(containerCycleOrder)
final containerCycleOrderProvider = ContainerCycleOrderProvider._();

/// The destinations a container-cycling gesture steps through, in the order
/// the container chips render them: the unassigned pseudo-container (`null`)
/// first, then the containers themselves.
///
/// Synced tabs and the group-suggestions chip are deliberately left out — they
/// are not containers, and landing on them mid-swipe would be a dead end.

final class ContainerCycleOrderProvider
    extends
        $FunctionalProvider<
          List<ContainerData?>,
          List<ContainerData?>,
          List<ContainerData?>
        >
    with $Provider<List<ContainerData?>> {
  /// The destinations a container-cycling gesture steps through, in the order
  /// the container chips render them: the unassigned pseudo-container (`null`)
  /// first, then the containers themselves.
  ///
  /// Synced tabs and the group-suggestions chip are deliberately left out — they
  /// are not containers, and landing on them mid-swipe would be a dead end.
  ContainerCycleOrderProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'containerCycleOrderProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$containerCycleOrderHash();

  @$internal
  @override
  $ProviderElement<List<ContainerData?>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  List<ContainerData?> create(Ref ref) {
    return containerCycleOrder(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<ContainerData?> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<ContainerData?>>(value),
    );
  }
}

String _$containerCycleOrderHash() =>
    r'dd732a8717b1ebe7055776d2b7800e587f552438';

@ProviderFor(matchSortedContainersWithCount)
final matchSortedContainersWithCountProvider =
    MatchSortedContainersWithCountFamily._();

final class MatchSortedContainersWithCountProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ContainerDataWithCount>>,
          AsyncValue<List<ContainerDataWithCount>>,
          AsyncValue<List<ContainerDataWithCount>>
        >
    with $Provider<AsyncValue<List<ContainerDataWithCount>>> {
  MatchSortedContainersWithCountProvider._({
    required MatchSortedContainersWithCountFamily super.from,
    required String? super.argument,
  }) : super(
         retry: null,
         name: r'matchSortedContainersWithCountProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$matchSortedContainersWithCountHash();

  @override
  String toString() {
    return r'matchSortedContainersWithCountProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<AsyncValue<List<ContainerDataWithCount>>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AsyncValue<List<ContainerDataWithCount>> create(Ref ref) {
    final argument = this.argument as String?;
    return matchSortedContainersWithCount(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<List<ContainerDataWithCount>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride:
          $SyncValueProvider<AsyncValue<List<ContainerDataWithCount>>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is MatchSortedContainersWithCountProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$matchSortedContainersWithCountHash() =>
    r'e66ca1d96a735155f582975ae05a90503e615882';

final class MatchSortedContainersWithCountFamily extends $Family
    with
        $FunctionalFamilyOverride<
          AsyncValue<List<ContainerDataWithCount>>,
          String?
        > {
  MatchSortedContainersWithCountFamily._()
    : super(
        retry: null,
        name: r'matchSortedContainersWithCountProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  MatchSortedContainersWithCountProvider call(String? searchText) =>
      MatchSortedContainersWithCountProvider._(
        argument: searchText,
        from: this,
      );

  @override
  String toString() => r'matchSortedContainersWithCountProvider';
}

@ProviderFor(watchContainerTabIds)
final watchContainerTabIdsProvider = WatchContainerTabIdsFamily._();

final class WatchContainerTabIdsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<String>>,
          List<String>,
          Stream<List<String>>
        >
    with $FutureModifier<List<String>>, $StreamProvider<List<String>> {
  WatchContainerTabIdsProvider._({
    required WatchContainerTabIdsFamily super.from,
    required ContainerFilter super.argument,
  }) : super(
         retry: null,
         name: r'watchContainerTabIdsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$watchContainerTabIdsHash();

  @override
  String toString() {
    return r'watchContainerTabIdsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<String>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<String>> create(Ref ref) {
    final argument = this.argument as ContainerFilter;
    return watchContainerTabIds(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is WatchContainerTabIdsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$watchContainerTabIdsHash() =>
    r'0b416bb68a05ea74e9f7878fc97e6e96516ffd92';

final class WatchContainerTabIdsFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<String>>, ContainerFilter> {
  WatchContainerTabIdsFamily._()
    : super(
        retry: null,
        name: r'watchContainerTabIdsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  WatchContainerTabIdsProvider call(ContainerFilter containerFilter) =>
      WatchContainerTabIdsProvider._(argument: containerFilter, from: this);

  @override
  String toString() => r'watchContainerTabIdsProvider';
}

@ProviderFor(watchTabsFifo)
final watchTabsFifoProvider = WatchTabsFifoProvider._();

final class WatchTabsFifoProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<TabSummary>>,
          List<TabSummary>,
          Stream<List<TabSummary>>
        >
    with $FutureModifier<List<TabSummary>>, $StreamProvider<List<TabSummary>> {
  WatchTabsFifoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'watchTabsFifoProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$watchTabsFifoHash();

  @$internal
  @override
  $StreamProviderElement<List<TabSummary>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<TabSummary>> create(Ref ref) {
    return watchTabsFifo(ref);
  }
}

String _$watchTabsFifoHash() => r'6c4b6098b4436d66eb4b1136373e27f41dc43574';

@ProviderFor(containerTabCount)
final containerTabCountProvider = ContainerTabCountFamily._();

final class ContainerTabCountProvider
    extends $FunctionalProvider<AsyncValue<int>, int, FutureOr<int>>
    with $FutureModifier<int>, $FutureProvider<int> {
  ContainerTabCountProvider._({
    required ContainerTabCountFamily super.from,
    required ContainerFilter super.argument,
  }) : super(
         retry: null,
         name: r'containerTabCountProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$containerTabCountHash();

  @override
  String toString() {
    return r'containerTabCountProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<int> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<int> create(Ref ref) {
    final argument = this.argument as ContainerFilter;
    return containerTabCount(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ContainerTabCountProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$containerTabCountHash() => r'df4008a9c589936c8a0699b082ab23087ae9b85f';

final class ContainerTabCountFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<int>, ContainerFilter> {
  ContainerTabCountFamily._()
    : super(
        retry: null,
        name: r'containerTabCountProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ContainerTabCountProvider call(ContainerFilter containerFilter) =>
      ContainerTabCountProvider._(argument: containerFilter, from: this);

  @override
  String toString() => r'containerTabCountProvider';
}

@ProviderFor(watchTabTrees)
final watchTabTreesProvider = WatchTabTreesFamily._();

final class WatchTabTreesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<TabTreesResult>>,
          List<TabTreesResult>,
          Stream<List<TabTreesResult>>
        >
    with
        $FutureModifier<List<TabTreesResult>>,
        $StreamProvider<List<TabTreesResult>> {
  WatchTabTreesProvider._({
    required WatchTabTreesFamily super.from,
    required ContainerFilter super.argument,
  }) : super(
         retry: null,
         name: r'watchTabTreesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$watchTabTreesHash();

  @override
  String toString() {
    return r'watchTabTreesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<TabTreesResult>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<TabTreesResult>> create(Ref ref) {
    final argument = this.argument as ContainerFilter;
    return watchTabTrees(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is WatchTabTreesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$watchTabTreesHash() => r'27addd602aa6af9f5aa408c41311d88c3c9c4063';

final class WatchTabTreesFamily extends $Family
    with
        $FunctionalFamilyOverride<
          Stream<List<TabTreesResult>>,
          ContainerFilter
        > {
  WatchTabTreesFamily._()
    : super(
        retry: null,
        name: r'watchTabTreesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  WatchTabTreesProvider call(ContainerFilter containerFilter) =>
      WatchTabTreesProvider._(argument: containerFilter, from: this);

  @override
  String toString() => r'watchTabTreesProvider';
}

@ProviderFor(watchTabsWithRootAndDepth)
final watchTabsWithRootAndDepthProvider = WatchTabsWithRootAndDepthFamily._();

final class WatchTabsWithRootAndDepthProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<TabsWithRootAndDepthResult>>,
          List<TabsWithRootAndDepthResult>,
          Stream<List<TabsWithRootAndDepthResult>>
        >
    with
        $FutureModifier<List<TabsWithRootAndDepthResult>>,
        $StreamProvider<List<TabsWithRootAndDepthResult>> {
  WatchTabsWithRootAndDepthProvider._({
    required WatchTabsWithRootAndDepthFamily super.from,
    required String? super.argument,
  }) : super(
         retry: null,
         name: r'watchTabsWithRootAndDepthProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$watchTabsWithRootAndDepthHash();

  @override
  String toString() {
    return r'watchTabsWithRootAndDepthProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<TabsWithRootAndDepthResult>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<TabsWithRootAndDepthResult>> create(Ref ref) {
    final argument = this.argument as String?;
    return watchTabsWithRootAndDepth(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is WatchTabsWithRootAndDepthProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$watchTabsWithRootAndDepthHash() =>
    r'c888c290a5d35094df59c982e56d524af04b88ef';

final class WatchTabsWithRootAndDepthFamily extends $Family
    with
        $FunctionalFamilyOverride<
          Stream<List<TabsWithRootAndDepthResult>>,
          String?
        > {
  WatchTabsWithRootAndDepthFamily._()
    : super(
        retry: null,
        name: r'watchTabsWithRootAndDepthProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  WatchTabsWithRootAndDepthProvider call(String? containerId) =>
      WatchTabsWithRootAndDepthProvider._(argument: containerId, from: this);

  @override
  String toString() => r'watchTabsWithRootAndDepthProvider';
}

/// One tab's row, watched — without its page text.
///
/// A [TabSummary]: this is a `.watch()`, so it re-runs on every write to `tab`
/// for as long as the tab menu or the parent picker is open, and both consumers
/// read only `parentId` and `containerId`. The wide row would drag that tab's
/// stored content (and the `content_hash` UDF) through on every tick.

@ProviderFor(watchTabDbData)
final watchTabDbDataProvider = WatchTabDbDataFamily._();

/// One tab's row, watched — without its page text.
///
/// A [TabSummary]: this is a `.watch()`, so it re-runs on every write to `tab`
/// for as long as the tab menu or the parent picker is open, and both consumers
/// read only `parentId` and `containerId`. The wide row would drag that tab's
/// stored content (and the `content_hash` UDF) through on every tick.

final class WatchTabDbDataProvider
    extends
        $FunctionalProvider<
          AsyncValue<TabSummary?>,
          TabSummary?,
          Stream<TabSummary?>
        >
    with $FutureModifier<TabSummary?>, $StreamProvider<TabSummary?> {
  /// One tab's row, watched — without its page text.
  ///
  /// A [TabSummary]: this is a `.watch()`, so it re-runs on every write to `tab`
  /// for as long as the tab menu or the parent picker is open, and both consumers
  /// read only `parentId` and `containerId`. The wide row would drag that tab's
  /// stored content (and the `content_hash` UDF) through on every tick.
  WatchTabDbDataProvider._({
    required WatchTabDbDataFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'watchTabDbDataProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$watchTabDbDataHash();

  @override
  String toString() {
    return r'watchTabDbDataProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<TabSummary?> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<TabSummary?> create(Ref ref) {
    final argument = this.argument as String;
    return watchTabDbData(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is WatchTabDbDataProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$watchTabDbDataHash() => r'3e3c7221b4ef73616f995c362f823128e88984e2';

/// One tab's row, watched — without its page text.
///
/// A [TabSummary]: this is a `.watch()`, so it re-runs on every write to `tab`
/// for as long as the tab menu or the parent picker is open, and both consumers
/// read only `parentId` and `containerId`. The wide row would drag that tab's
/// stored content (and the `content_hash` UDF) through on every tick.

final class WatchTabDbDataFamily extends $Family
    with $FunctionalFamilyOverride<Stream<TabSummary?>, String> {
  WatchTabDbDataFamily._()
    : super(
        retry: null,
        name: r'watchTabDbDataProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// One tab's row, watched — without its page text.
  ///
  /// A [TabSummary]: this is a `.watch()`, so it re-runs on every write to `tab`
  /// for as long as the tab menu or the parent picker is open, and both consumers
  /// read only `parentId` and `containerId`. The wide row would drag that tab's
  /// stored content (and the `content_hash` UDF) through on every tick.

  WatchTabDbDataProvider call(String tabId) =>
      WatchTabDbDataProvider._(argument: tabId, from: this);

  @override
  String toString() => r'watchTabDbDataProvider';
}

@ProviderFor(watchTabDescendants)
final watchTabDescendantsProvider = WatchTabDescendantsFamily._();

final class WatchTabDescendantsProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<String, String?>>,
          Map<String, String?>,
          Stream<Map<String, String?>>
        >
    with
        $FutureModifier<Map<String, String?>>,
        $StreamProvider<Map<String, String?>> {
  WatchTabDescendantsProvider._({
    required WatchTabDescendantsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'watchTabDescendantsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$watchTabDescendantsHash();

  @override
  String toString() {
    return r'watchTabDescendantsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<Map<String, String?>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<Map<String, String?>> create(Ref ref) {
    final argument = this.argument as String;
    return watchTabDescendants(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is WatchTabDescendantsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$watchTabDescendantsHash() =>
    r'604515de406baa5f32894be442ecee4528d87102';

final class WatchTabDescendantsFamily extends $Family
    with $FunctionalFamilyOverride<Stream<Map<String, String?>>, String> {
  WatchTabDescendantsFamily._()
    : super(
        retry: null,
        name: r'watchTabDescendantsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  WatchTabDescendantsProvider call(String tabId) =>
      WatchTabDescendantsProvider._(argument: tabId, from: this);

  @override
  String toString() => r'watchTabDescendantsProvider';
}

@ProviderFor(watchContainerTabsData)
final watchContainerTabsDataProvider = WatchContainerTabsDataFamily._();

final class WatchContainerTabsDataProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<TabSummary>>,
          List<TabSummary>,
          Stream<List<TabSummary>>
        >
    with $FutureModifier<List<TabSummary>>, $StreamProvider<List<TabSummary>> {
  WatchContainerTabsDataProvider._({
    required WatchContainerTabsDataFamily super.from,
    required String? super.argument,
  }) : super(
         retry: null,
         name: r'watchContainerTabsDataProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$watchContainerTabsDataHash();

  @override
  String toString() {
    return r'watchContainerTabsDataProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<TabSummary>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<TabSummary>> create(Ref ref) {
    final argument = this.argument as String?;
    return watchContainerTabsData(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is WatchContainerTabsDataProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$watchContainerTabsDataHash() =>
    r'02299843b6345052ab9845c16d7f93066920134c';

final class WatchContainerTabsDataFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<TabSummary>>, String?> {
  WatchContainerTabsDataFamily._()
    : super(
        retry: null,
        name: r'watchContainerTabsDataProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  WatchContainerTabsDataProvider call(String? containerId) =>
      WatchContainerTabsDataProvider._(argument: containerId, from: this);

  @override
  String toString() => r'watchContainerTabsDataProvider';
}

/// Whether a container menu for [containerId] offers closing its isolated
/// tabs. Closing them is a way out, not creation: it stays while the scope
/// still holds isolated tabs, even with isolated tabs hidden (P5).
///
/// The tab stream is watched only while isolated tabs are hidden: a container
/// menu is built for every container chip, and the stream is only needed then.

@ProviderFor(closeIsolatedTabsShown)
final closeIsolatedTabsShownProvider = CloseIsolatedTabsShownFamily._();

/// Whether a container menu for [containerId] offers closing its isolated
/// tabs. Closing them is a way out, not creation: it stays while the scope
/// still holds isolated tabs, even with isolated tabs hidden (P5).
///
/// The tab stream is watched only while isolated tabs are hidden: a container
/// menu is built for every container chip, and the stream is only needed then.

final class CloseIsolatedTabsShownProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Whether a container menu for [containerId] offers closing its isolated
  /// tabs. Closing them is a way out, not creation: it stays while the scope
  /// still holds isolated tabs, even with isolated tabs hidden (P5).
  ///
  /// The tab stream is watched only while isolated tabs are hidden: a container
  /// menu is built for every container chip, and the stream is only needed then.
  CloseIsolatedTabsShownProvider._({
    required CloseIsolatedTabsShownFamily super.from,
    required String? super.argument,
  }) : super(
         retry: null,
         name: r'closeIsolatedTabsShownProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$closeIsolatedTabsShownHash();

  @override
  String toString() {
    return r'closeIsolatedTabsShownProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    final argument = this.argument as String?;
    return closeIsolatedTabsShown(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is CloseIsolatedTabsShownProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$closeIsolatedTabsShownHash() =>
    r'c1c65716286d8c6fb7fbac35f19fde9288198e59';

/// Whether a container menu for [containerId] offers closing its isolated
/// tabs. Closing them is a way out, not creation: it stays while the scope
/// still holds isolated tabs, even with isolated tabs hidden (P5).
///
/// The tab stream is watched only while isolated tabs are hidden: a container
/// menu is built for every container chip, and the stream is only needed then.

final class CloseIsolatedTabsShownFamily extends $Family
    with $FunctionalFamilyOverride<bool, String?> {
  CloseIsolatedTabsShownFamily._()
    : super(
        retry: null,
        name: r'closeIsolatedTabsShownProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Whether a container menu for [containerId] offers closing its isolated
  /// tabs. Closing them is a way out, not creation: it stays while the scope
  /// still holds isolated tabs, even with isolated tabs hidden (P5).
  ///
  /// The tab stream is watched only while isolated tabs are hidden: a container
  /// menu is built for every container chip, and the stream is only needed then.

  CloseIsolatedTabsShownProvider call(String? containerId) =>
      CloseIsolatedTabsShownProvider._(argument: containerId, from: this);

  @override
  String toString() => r'closeIsolatedTabsShownProvider';
}

/// What a tab's menu needs to keep the ways out of a container while
/// containers are hidden (P5): whether [tabId] is in a container, and whether
/// its site is assigned to one. Neither applies while containers are shown,
/// or for a menu without container rows ([enabled]): every tab's menu would
/// otherwise hold two database streams open for nothing.

@ProviderFor(hiddenContainerWayOut)
final hiddenContainerWayOutProvider = HiddenContainerWayOutFamily._();

/// What a tab's menu needs to keep the ways out of a container while
/// containers are hidden (P5): whether [tabId] is in a container, and whether
/// its site is assigned to one. Neither applies while containers are shown,
/// or for a menu without container rows ([enabled]): every tab's menu would
/// otherwise hold two database streams open for nothing.

final class HiddenContainerWayOutProvider
    extends
        $FunctionalProvider<
          ({bool inContainer, bool siteAssigned}),
          ({bool inContainer, bool siteAssigned}),
          ({bool inContainer, bool siteAssigned})
        >
    with $Provider<({bool inContainer, bool siteAssigned})> {
  /// What a tab's menu needs to keep the ways out of a container while
  /// containers are hidden (P5): whether [tabId] is in a container, and whether
  /// its site is assigned to one. Neither applies while containers are shown,
  /// or for a menu without container rows ([enabled]): every tab's menu would
  /// otherwise hold two database streams open for nothing.
  HiddenContainerWayOutProvider._({
    required HiddenContainerWayOutFamily super.from,
    required (String, {bool enabled}) super.argument,
  }) : super(
         retry: null,
         name: r'hiddenContainerWayOutProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$hiddenContainerWayOutHash();

  @override
  String toString() {
    return r'hiddenContainerWayOutProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $ProviderElement<({bool inContainer, bool siteAssigned})> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ({bool inContainer, bool siteAssigned}) create(Ref ref) {
    final argument = this.argument as (String, {bool enabled});
    return hiddenContainerWayOut(ref, argument.$1, enabled: argument.enabled);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(({bool inContainer, bool siteAssigned}) value) {
    return $ProviderOverride(
      origin: this,
      providerOverride:
          $SyncValueProvider<({bool inContainer, bool siteAssigned})>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is HiddenContainerWayOutProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$hiddenContainerWayOutHash() =>
    r'd4c23422921f4b643616dc4abd1addaa8b334e3b';

/// What a tab's menu needs to keep the ways out of a container while
/// containers are hidden (P5): whether [tabId] is in a container, and whether
/// its site is assigned to one. Neither applies while containers are shown,
/// or for a menu without container rows ([enabled]): every tab's menu would
/// otherwise hold two database streams open for nothing.

final class HiddenContainerWayOutFamily extends $Family
    with
        $FunctionalFamilyOverride<
          ({bool inContainer, bool siteAssigned}),
          (String, {bool enabled})
        > {
  HiddenContainerWayOutFamily._()
    : super(
        retry: null,
        name: r'hiddenContainerWayOutProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// What a tab's menu needs to keep the ways out of a container while
  /// containers are hidden (P5): whether [tabId] is in a container, and whether
  /// its site is assigned to one. Neither applies while containers are shown,
  /// or for a menu without container rows ([enabled]): every tab's menu would
  /// otherwise hold two database streams open for nothing.

  HiddenContainerWayOutProvider call(String tabId, {required bool enabled}) =>
      HiddenContainerWayOutProvider._(
        argument: (tabId, enabled: enabled),
        from: this,
      );

  @override
  String toString() => r'hiddenContainerWayOutProvider';
}

@ProviderFor(watchPinnedTabIds)
final watchPinnedTabIdsProvider = WatchPinnedTabIdsProvider._();

final class WatchPinnedTabIdsProvider
    extends
        $FunctionalProvider<
          AsyncValue<Set<String>>,
          Set<String>,
          Stream<Set<String>>
        >
    with $FutureModifier<Set<String>>, $StreamProvider<Set<String>> {
  WatchPinnedTabIdsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'watchPinnedTabIdsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$watchPinnedTabIdsHash();

  @$internal
  @override
  $StreamProviderElement<Set<String>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<Set<String>> create(Ref ref) {
    return watchPinnedTabIds(ref);
  }
}

String _$watchPinnedTabIdsHash() => r'3b041fac974914ebd4f99490ea4d380475bd7ab2';

@ProviderFor(watchTabTimestamps)
final watchTabTimestampsProvider = WatchTabTimestampsProvider._();

final class WatchTabTimestampsProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<String, DateTime>>,
          Map<String, DateTime>,
          Stream<Map<String, DateTime>>
        >
    with
        $FutureModifier<Map<String, DateTime>>,
        $StreamProvider<Map<String, DateTime>> {
  WatchTabTimestampsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'watchTabTimestampsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$watchTabTimestampsHash();

  @$internal
  @override
  $StreamProviderElement<Map<String, DateTime>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<Map<String, DateTime>> create(Ref ref) {
    return watchTabTimestamps(ref);
  }
}

String _$watchTabTimestampsHash() =>
    r'8e8788a36dcc0bea3a0b481fe4ee20d0b1f8197e';

@ProviderFor(watchTabOrderKeys)
final watchTabOrderKeysProvider = WatchTabOrderKeysProvider._();

final class WatchTabOrderKeysProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<String, String>>,
          Map<String, String>,
          Stream<Map<String, String>>
        >
    with
        $FutureModifier<Map<String, String>>,
        $StreamProvider<Map<String, String>> {
  WatchTabOrderKeysProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'watchTabOrderKeysProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$watchTabOrderKeysHash();

  @$internal
  @override
  $StreamProviderElement<Map<String, String>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<Map<String, String>> create(Ref ref) {
    return watchTabOrderKeys(ref);
  }
}

String _$watchTabOrderKeysHash() => r'ed4064c8159009cf0a43ac3b596c9865e165d0d4';

@ProviderFor(watchContainerData)
final watchContainerDataProvider = WatchContainerDataFamily._();

final class WatchContainerDataProvider
    extends
        $FunctionalProvider<
          AsyncValue<ContainerData?>,
          ContainerData?,
          Stream<ContainerData?>
        >
    with $FutureModifier<ContainerData?>, $StreamProvider<ContainerData?> {
  WatchContainerDataProvider._({
    required WatchContainerDataFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'watchContainerDataProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$watchContainerDataHash();

  @override
  String toString() {
    return r'watchContainerDataProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<ContainerData?> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<ContainerData?> create(Ref ref) {
    final argument = this.argument as String;
    return watchContainerData(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is WatchContainerDataProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$watchContainerDataHash() =>
    r'abd0e964a6444ed9be5da649a0f6a77bbbb54042';

final class WatchContainerDataFamily extends $Family
    with $FunctionalFamilyOverride<Stream<ContainerData?>, String> {
  WatchContainerDataFamily._()
    : super(
        retry: null,
        name: r'watchContainerDataProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  WatchContainerDataProvider call(String containerId) =>
      WatchContainerDataProvider._(argument: containerId, from: this);

  @override
  String toString() => r'watchContainerDataProvider';
}

@ProviderFor(watchContainerTabId)
final watchContainerTabIdProvider = WatchContainerTabIdFamily._();

final class WatchContainerTabIdProvider
    extends $FunctionalProvider<AsyncValue<String?>, String?, Stream<String?>>
    with $FutureModifier<String?>, $StreamProvider<String?> {
  WatchContainerTabIdProvider._({
    required WatchContainerTabIdFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'watchContainerTabIdProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$watchContainerTabIdHash();

  @override
  String toString() {
    return r'watchContainerTabIdProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<String?> create(Ref ref) {
    final argument = this.argument as String;
    return watchContainerTabId(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is WatchContainerTabIdProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$watchContainerTabIdHash() =>
    r'c2cb263d4633fae436e7b3b216ab46d93ef49d4f';

final class WatchContainerTabIdFamily extends $Family
    with $FunctionalFamilyOverride<Stream<String?>, String> {
  WatchContainerTabIdFamily._()
    : super(
        retry: null,
        name: r'watchContainerTabIdProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  WatchContainerTabIdProvider call(String tabId) =>
      WatchContainerTabIdProvider._(argument: tabId, from: this);

  @override
  String toString() => r'watchContainerTabIdProvider';
}

@ProviderFor(watchTabContainerData)
final watchTabContainerDataProvider = WatchTabContainerDataFamily._();

final class WatchTabContainerDataProvider
    extends
        $FunctionalProvider<
          AsyncValue<ContainerData?>,
          ContainerData?,
          Stream<ContainerData?>
        >
    with $FutureModifier<ContainerData?>, $StreamProvider<ContainerData?> {
  WatchTabContainerDataProvider._({
    required WatchTabContainerDataFamily super.from,
    required String? super.argument,
  }) : super(
         retry: null,
         name: r'watchTabContainerDataProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$watchTabContainerDataHash();

  @override
  String toString() {
    return r'watchTabContainerDataProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<ContainerData?> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<ContainerData?> create(Ref ref) {
    final argument = this.argument as String?;
    return watchTabContainerData(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is WatchTabContainerDataProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$watchTabContainerDataHash() =>
    r'7fe7d139555f6bbf3165ac67a3641bec9b1af966';

final class WatchTabContainerDataFamily extends $Family
    with $FunctionalFamilyOverride<Stream<ContainerData?>, String?> {
  WatchTabContainerDataFamily._()
    : super(
        retry: null,
        name: r'watchTabContainerDataProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  WatchTabContainerDataProvider call(String? tabId) =>
      WatchTabContainerDataProvider._(argument: tabId, from: this);

  @override
  String toString() => r'watchTabContainerDataProvider';
}

@ProviderFor(watchTabsContainerId)
final watchTabsContainerIdProvider = WatchTabsContainerIdFamily._();

final class WatchTabsContainerIdProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<String, String?>>,
          Map<String, String?>,
          Stream<Map<String, String?>>
        >
    with
        $FutureModifier<Map<String, String?>>,
        $StreamProvider<Map<String, String?>> {
  WatchTabsContainerIdProvider._({
    required WatchTabsContainerIdFamily super.from,
    required EquatableValue<List<String>> super.argument,
  }) : super(
         retry: null,
         name: r'watchTabsContainerIdProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$watchTabsContainerIdHash();

  @override
  String toString() {
    return r'watchTabsContainerIdProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<Map<String, String?>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<Map<String, String?>> create(Ref ref) {
    final argument = this.argument as EquatableValue<List<String>>;
    return watchTabsContainerId(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is WatchTabsContainerIdProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$watchTabsContainerIdHash() =>
    r'5cef762ad23ba489181a75b33242c5deef5a7cae';

final class WatchTabsContainerIdFamily extends $Family
    with
        $FunctionalFamilyOverride<
          Stream<Map<String, String?>>,
          EquatableValue<List<String>>
        > {
  WatchTabsContainerIdFamily._()
    : super(
        retry: null,
        name: r'watchTabsContainerIdProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  WatchTabsContainerIdProvider call(EquatableValue<List<String>> tabIds) =>
      WatchTabsContainerIdProvider._(argument: tabIds, from: this);

  @override
  String toString() => r'watchTabsContainerIdProvider';
}

@ProviderFor(watchAllAssignedSites)
final watchAllAssignedSitesProvider = WatchAllAssignedSitesProvider._();

final class WatchAllAssignedSitesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<SiteAssignment>>,
          List<SiteAssignment>,
          Stream<List<SiteAssignment>>
        >
    with
        $FutureModifier<List<SiteAssignment>>,
        $StreamProvider<List<SiteAssignment>> {
  WatchAllAssignedSitesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'watchAllAssignedSitesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$watchAllAssignedSitesHash();

  @$internal
  @override
  $StreamProviderElement<List<SiteAssignment>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<SiteAssignment>> create(Ref ref) {
    return watchAllAssignedSites(ref);
  }
}

String _$watchAllAssignedSitesHash() =>
    r'9b142741b89af3f442dc5d7938c9d3fb18eaedeb';

/// Strict-mode enforcement map: each Gecko cookie-store context that must be
/// enforced (a strict container's base context, plus the isolation contexts of
/// its isolated tabs) mapped to the base contextualIdentities its site
/// assignments are keyed on. Replicated to the container-proxy extension by
/// ProxySettingsReplication.
///
/// Empty while strict mode is hidden (`container.strict_mode`): the
/// containers keep the option, and it applies again once shown. Watching the
/// switch re-sends the policies whenever it changes.

@ProviderFor(watchStrictContextAssignments)
final watchStrictContextAssignmentsProvider =
    WatchStrictContextAssignmentsProvider._();

/// Strict-mode enforcement map: each Gecko cookie-store context that must be
/// enforced (a strict container's base context, plus the isolation contexts of
/// its isolated tabs) mapped to the base contextualIdentities its site
/// assignments are keyed on. Replicated to the container-proxy extension by
/// ProxySettingsReplication.
///
/// Empty while strict mode is hidden (`container.strict_mode`): the
/// containers keep the option, and it applies again once shown. Watching the
/// switch re-sends the policies whenever it changes.

final class WatchStrictContextAssignmentsProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<String, List<String>>>,
          Map<String, List<String>>,
          Stream<Map<String, List<String>>>
        >
    with
        $FutureModifier<Map<String, List<String>>>,
        $StreamProvider<Map<String, List<String>>> {
  /// Strict-mode enforcement map: each Gecko cookie-store context that must be
  /// enforced (a strict container's base context, plus the isolation contexts of
  /// its isolated tabs) mapped to the base contextualIdentities its site
  /// assignments are keyed on. Replicated to the container-proxy extension by
  /// ProxySettingsReplication.
  ///
  /// Empty while strict mode is hidden (`container.strict_mode`): the
  /// containers keep the option, and it applies again once shown. Watching the
  /// switch re-sends the policies whenever it changes.
  WatchStrictContextAssignmentsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'watchStrictContextAssignmentsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$watchStrictContextAssignmentsHash();

  @$internal
  @override
  $StreamProviderElement<Map<String, List<String>>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<Map<String, List<String>>> create(Ref ref) {
    return watchStrictContextAssignments(ref);
  }
}

String _$watchStrictContextAssignmentsHash() =>
    r'8c14fe9f3497f55df63fa8e71c176baeb1e2d3cf';

/// Watches distinct (isolationContextId, containerId) pairs for isolated tabs
/// assigned to containers. Used by ProxySettingsReplication to manage proxy
/// aliases for isolated contexts.
///
/// Returns a map from isolation context ID to the set of container IDs it
/// appears in. An isolation context needs an explicit routing alias if any
/// associated container has a proxy connection or bypasses global routing.

@ProviderFor(watchIsolatedContextContainerMap)
final watchIsolatedContextContainerMapProvider =
    WatchIsolatedContextContainerMapProvider._();

/// Watches distinct (isolationContextId, containerId) pairs for isolated tabs
/// assigned to containers. Used by ProxySettingsReplication to manage proxy
/// aliases for isolated contexts.
///
/// Returns a map from isolation context ID to the set of container IDs it
/// appears in. An isolation context needs an explicit routing alias if any
/// associated container has a proxy connection or bypasses global routing.

final class WatchIsolatedContextContainerMapProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<String, Set<String>>>,
          Map<String, Set<String>>,
          Stream<Map<String, Set<String>>>
        >
    with
        $FutureModifier<Map<String, Set<String>>>,
        $StreamProvider<Map<String, Set<String>>> {
  /// Watches distinct (isolationContextId, containerId) pairs for isolated tabs
  /// assigned to containers. Used by ProxySettingsReplication to manage proxy
  /// aliases for isolated contexts.
  ///
  /// Returns a map from isolation context ID to the set of container IDs it
  /// appears in. An isolation context needs an explicit routing alias if any
  /// associated container has a proxy connection or bypasses global routing.
  WatchIsolatedContextContainerMapProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'watchIsolatedContextContainerMapProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$watchIsolatedContextContainerMapHash();

  @$internal
  @override
  $StreamProviderElement<Map<String, Set<String>>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<Map<String, Set<String>>> create(Ref ref) {
    return watchIsolatedContextContainerMap(ref);
  }
}

String _$watchIsolatedContextContainerMapHash() =>
    r'9ceb254fc38999071a92e1446d7e2aec434205df';

/// Whether the site [tabId] shows is assigned to a container. Keyed by tab, so
/// a menu opened for a tab other than the selected one asks about its own.

@ProviderFor(watchIsSiteAssignedToContainer)
final watchIsSiteAssignedToContainerProvider =
    WatchIsSiteAssignedToContainerFamily._();

/// Whether the site [tabId] shows is assigned to a container. Keyed by tab, so
/// a menu opened for a tab other than the selected one asks about its own.

final class WatchIsSiteAssignedToContainerProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, Stream<bool>>
    with $FutureModifier<bool>, $StreamProvider<bool> {
  /// Whether the site [tabId] shows is assigned to a container. Keyed by tab, so
  /// a menu opened for a tab other than the selected one asks about its own.
  WatchIsSiteAssignedToContainerProvider._({
    required WatchIsSiteAssignedToContainerFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'watchIsSiteAssignedToContainerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$watchIsSiteAssignedToContainerHash();

  @override
  String toString() {
    return r'watchIsSiteAssignedToContainerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<bool> create(Ref ref) {
    final argument = this.argument as String;
    return watchIsSiteAssignedToContainer(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is WatchIsSiteAssignedToContainerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$watchIsSiteAssignedToContainerHash() =>
    r'0b4bf8245341fcc1a9ea444d8232ce787ae51f48';

/// Whether the site [tabId] shows is assigned to a container. Keyed by tab, so
/// a menu opened for a tab other than the selected one asks about its own.

final class WatchIsSiteAssignedToContainerFamily extends $Family
    with $FunctionalFamilyOverride<Stream<bool>, String> {
  WatchIsSiteAssignedToContainerFamily._()
    : super(
        retry: null,
        name: r'watchIsSiteAssignedToContainerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Whether the site [tabId] shows is assigned to a container. Keyed by tab, so
  /// a menu opened for a tab other than the selected one asks about its own.

  WatchIsSiteAssignedToContainerProvider call(String tabId) =>
      WatchIsSiteAssignedToContainerProvider._(argument: tabId, from: this);

  @override
  String toString() => r'watchIsSiteAssignedToContainerProvider';
}

/// The tabs of the container [tabId] is in. Loading until [tabId] itself is
/// read, so they are never those of another container.

@ProviderFor(watchTabContainerTabsData)
final watchTabContainerTabsDataProvider = WatchTabContainerTabsDataFamily._();

/// The tabs of the container [tabId] is in. Loading until [tabId] itself is
/// read, so they are never those of another container.

final class WatchTabContainerTabsDataProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<TabSummary>>,
          AsyncValue<List<TabSummary>>,
          AsyncValue<List<TabSummary>>
        >
    with $Provider<AsyncValue<List<TabSummary>>> {
  /// The tabs of the container [tabId] is in. Loading until [tabId] itself is
  /// read, so they are never those of another container.
  WatchTabContainerTabsDataProvider._({
    required WatchTabContainerTabsDataFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'watchTabContainerTabsDataProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$watchTabContainerTabsDataHash();

  @override
  String toString() {
    return r'watchTabContainerTabsDataProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<AsyncValue<List<TabSummary>>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AsyncValue<List<TabSummary>> create(Ref ref) {
    final argument = this.argument as String;
    return watchTabContainerTabsData(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<List<TabSummary>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<List<TabSummary>>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is WatchTabContainerTabsDataProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$watchTabContainerTabsDataHash() =>
    r'5344366a77f37d201e19520c67c81841cd383688';

/// The tabs of the container [tabId] is in. Loading until [tabId] itself is
/// read, so they are never those of another container.

final class WatchTabContainerTabsDataFamily extends $Family
    with $FunctionalFamilyOverride<AsyncValue<List<TabSummary>>, String> {
  WatchTabContainerTabsDataFamily._()
    : super(
        retry: null,
        name: r'watchTabContainerTabsDataProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The tabs of the container [tabId] is in. Loading until [tabId] itself is
  /// read, so they are never those of another container.

  WatchTabContainerTabsDataProvider call(String tabId) =>
      WatchTabContainerTabsDataProvider._(argument: tabId, from: this);

  @override
  String toString() => r'watchTabContainerTabsDataProvider';
}

/// Whether a tab preview draws the pin badge on [tabId]: where it shows one
/// at all ([enabled]) and the tab is pinned. Previews without the badge do
/// not follow the pinned tabs.

@ProviderFor(tabPinBadgeShown)
final tabPinBadgeShownProvider = TabPinBadgeShownFamily._();

/// Whether a tab preview draws the pin badge on [tabId]: where it shows one
/// at all ([enabled]) and the tab is pinned. Previews without the badge do
/// not follow the pinned tabs.

final class TabPinBadgeShownProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Whether a tab preview draws the pin badge on [tabId]: where it shows one
  /// at all ([enabled]) and the tab is pinned. Previews without the badge do
  /// not follow the pinned tabs.
  TabPinBadgeShownProvider._({
    required TabPinBadgeShownFamily super.from,
    required (String, {bool enabled}) super.argument,
  }) : super(
         retry: null,
         name: r'tabPinBadgeShownProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$tabPinBadgeShownHash();

  @override
  String toString() {
    return r'tabPinBadgeShownProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    final argument = this.argument as (String, {bool enabled});
    return tabPinBadgeShown(ref, argument.$1, enabled: argument.enabled);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is TabPinBadgeShownProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$tabPinBadgeShownHash() => r'ae8256bb02311eaa4326ea433374f80eeb317ff9';

/// Whether a tab preview draws the pin badge on [tabId]: where it shows one
/// at all ([enabled]) and the tab is pinned. Previews without the badge do
/// not follow the pinned tabs.

final class TabPinBadgeShownFamily extends $Family
    with $FunctionalFamilyOverride<bool, (String, {bool enabled})> {
  TabPinBadgeShownFamily._()
    : super(
        retry: null,
        name: r'tabPinBadgeShownProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Whether a tab preview draws the pin badge on [tabId]: where it shows one
  /// at all ([enabled]) and the tab is pinned. Previews without the badge do
  /// not follow the pinned tabs.

  TabPinBadgeShownProvider call(String tabId, {required bool enabled}) =>
      TabPinBadgeShownProvider._(
        argument: (tabId, enabled: enabled),
        from: this,
      );

  @override
  String toString() => r'tabPinBadgeShownProvider';
}

/// How many tabs are in no container, for a chip that counts them itself
/// ([enabled]); 0 without reading them for one given its count.

@ProviderFor(unassignedTabCount)
final unassignedTabCountProvider = UnassignedTabCountFamily._();

/// How many tabs are in no container, for a chip that counts them itself
/// ([enabled]); 0 without reading them for one given its count.

final class UnassignedTabCountProvider
    extends $FunctionalProvider<int, int, int>
    with $Provider<int> {
  /// How many tabs are in no container, for a chip that counts them itself
  /// ([enabled]); 0 without reading them for one given its count.
  UnassignedTabCountProvider._({
    required UnassignedTabCountFamily super.from,
    required bool super.argument,
  }) : super(
         retry: null,
         name: r'unassignedTabCountProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$unassignedTabCountHash();

  @override
  String toString() {
    return r'unassignedTabCountProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<int> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  int create(Ref ref) {
    final argument = this.argument as bool;
    return unassignedTabCount(ref, enabled: argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is UnassignedTabCountProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$unassignedTabCountHash() =>
    r'814322bc474e1ad0108ad33bbd04b76242f27288';

/// How many tabs are in no container, for a chip that counts them itself
/// ([enabled]); 0 without reading them for one given its count.

final class UnassignedTabCountFamily extends $Family
    with $FunctionalFamilyOverride<int, bool> {
  UnassignedTabCountFamily._()
    : super(
        retry: null,
        name: r'unassignedTabCountProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// How many tabs are in no container, for a chip that counts them itself
  /// ([enabled]); 0 without reading them for one given its count.

  UnassignedTabCountProvider call({required bool enabled}) =>
      UnassignedTabCountProvider._(argument: enabled, from: this);

  @override
  String toString() => r'unassignedTabCountProvider';
}
