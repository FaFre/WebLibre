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
    r'50d8e9b39cb589b0b5f50d79cbe20b8d10d7a504';

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
    r'25f73fe16fad7ec0121b2bee99ecbd8b6bf47791';

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
          AsyncValue<List<TabData>>,
          List<TabData>,
          Stream<List<TabData>>
        >
    with $FutureModifier<List<TabData>>, $StreamProvider<List<TabData>> {
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
  $StreamProviderElement<List<TabData>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<TabData>> create(Ref ref) {
    return watchTabsFifo(ref);
  }
}

String _$watchTabsFifoHash() => r'9bb8729fd0c3e31b36c11ca31d6264eefd357bd9';

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
final watchTabTreesProvider = WatchTabTreesProvider._();

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
  WatchTabTreesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'watchTabTreesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$watchTabTreesHash();

  @$internal
  @override
  $StreamProviderElement<List<TabTreesResult>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<TabTreesResult>> create(Ref ref) {
    return watchTabTrees(ref);
  }
}

String _$watchTabTreesHash() => r'a2be591acb6818ea8675a12d90e6c4684a0448a8';

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
    r'8b20353888a851191d835784e24d7d4a6e898b72';

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
          AsyncValue<List<TabData>>,
          List<TabData>,
          Stream<List<TabData>>
        >
    with $FutureModifier<List<TabData>>, $StreamProvider<List<TabData>> {
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
  $StreamProviderElement<List<TabData>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<TabData>> create(Ref ref) {
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
    r'4edbb3029f4ffb6181396d81d8076e0395ec2481';

final class WatchContainerTabsDataFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<TabData>>, String?> {
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
    r'b8f107e462f417b128221240242167a0754f040f';

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
    r'ffdebb10f7118cdff93695c821ef5fbb0d434de1';

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
        isAutoDispose: true,
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
    r'd755451be0ad7e03db36ba39c64f6f0b5c1d9ba3';

@ProviderFor(watchIsCurrentSiteAssignedToContainer)
final watchIsCurrentSiteAssignedToContainerProvider =
    WatchIsCurrentSiteAssignedToContainerProvider._();

final class WatchIsCurrentSiteAssignedToContainerProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, Stream<bool>>
    with $FutureModifier<bool>, $StreamProvider<bool> {
  WatchIsCurrentSiteAssignedToContainerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'watchIsCurrentSiteAssignedToContainerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() =>
      _$watchIsCurrentSiteAssignedToContainerHash();

  @$internal
  @override
  $StreamProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<bool> create(Ref ref) {
    return watchIsCurrentSiteAssignedToContainer(ref);
  }
}

String _$watchIsCurrentSiteAssignedToContainerHash() =>
    r'2942672c75b671fbe84489606e5341f0290502c3';
