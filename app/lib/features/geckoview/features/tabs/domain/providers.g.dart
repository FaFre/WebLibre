// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(containersWithCount)
const containersWithCountProvider = ContainersWithCountProvider._();

final class ContainersWithCountProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ContainerDataWithCount>>,
          List<ContainerDataWithCount>,
          Stream<List<ContainerDataWithCount>>
        >
    with
        $FutureModifier<List<ContainerDataWithCount>>,
        $StreamProvider<List<ContainerDataWithCount>> {
  const ContainersWithCountProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'containersWithCountProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$containersWithCountHash();

  @$internal
  @override
  $StreamProviderElement<List<ContainerDataWithCount>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<ContainerDataWithCount>> create(Ref ref) {
    return containersWithCount(ref);
  }
}

String _$containersWithCountHash() =>
    r'757bb0102afedc07ef0f80a420b4c87cbdbed3e1';

@ProviderFor(matchSortedContainersWithCount)
const matchSortedContainersWithCountProvider =
    MatchSortedContainersWithCountFamily._();

final class MatchSortedContainersWithCountProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ContainerDataWithCount>>,
          AsyncValue<List<ContainerDataWithCount>>,
          AsyncValue<List<ContainerDataWithCount>>
        >
    with $Provider<AsyncValue<List<ContainerDataWithCount>>> {
  const MatchSortedContainersWithCountProvider._({
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
    r'bc2077602c3c1d86c5b916e4ad920053310993e4';

final class MatchSortedContainersWithCountFamily extends $Family
    with
        $FunctionalFamilyOverride<
          AsyncValue<List<ContainerDataWithCount>>,
          String?
        > {
  const MatchSortedContainersWithCountFamily._()
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

@ProviderFor(containerTabIds)
const containerTabIdsProvider = ContainerTabIdsFamily._();

final class ContainerTabIdsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<String>>,
          List<String>,
          Stream<List<String>>
        >
    with $FutureModifier<List<String>>, $StreamProvider<List<String>> {
  const ContainerTabIdsProvider._({
    required ContainerTabIdsFamily super.from,
    required ContainerFilter super.argument,
  }) : super(
         retry: null,
         name: r'containerTabIdsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$containerTabIdsHash();

  @override
  String toString() {
    return r'containerTabIdsProvider'
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
    return containerTabIds(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ContainerTabIdsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$containerTabIdsHash() => r'61716a2ae74ffa590c1498d259382e69e24ad7f1';

final class ContainerTabIdsFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<String>>, ContainerFilter> {
  const ContainerTabIdsFamily._()
    : super(
        retry: null,
        name: r'containerTabIdsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ContainerTabIdsProvider call(ContainerFilter containerFilter) =>
      ContainerTabIdsProvider._(argument: containerFilter, from: this);

  @override
  String toString() => r'containerTabIdsProvider';
}

@ProviderFor(containerTabCount)
const containerTabCountProvider = ContainerTabCountFamily._();

final class ContainerTabCountProvider
    extends $FunctionalProvider<AsyncValue<int>, int, FutureOr<int>>
    with $FutureModifier<int>, $FutureProvider<int> {
  const ContainerTabCountProvider._({
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

String _$containerTabCountHash() => r'586e83429b527b546d43232a58453635ab860d69';

final class ContainerTabCountFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<int>, ContainerFilter> {
  const ContainerTabCountFamily._()
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

@ProviderFor(tabTrees)
const tabTreesProvider = TabTreesProvider._();

final class TabTreesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<TabTreesResult>>,
          List<TabTreesResult>,
          Stream<List<TabTreesResult>>
        >
    with
        $FutureModifier<List<TabTreesResult>>,
        $StreamProvider<List<TabTreesResult>> {
  const TabTreesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tabTreesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tabTreesHash();

  @$internal
  @override
  $StreamProviderElement<List<TabTreesResult>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<TabTreesResult>> create(Ref ref) {
    return tabTrees(ref);
  }
}

String _$tabTreesHash() => r'd9256293a97d5451c2ab881a30ae99c9e2178999';

@ProviderFor(tabDescendants)
const tabDescendantsProvider = TabDescendantsFamily._();

final class TabDescendantsProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<String, String?>>,
          Map<String, String?>,
          Stream<Map<String, String?>>
        >
    with
        $FutureModifier<Map<String, String?>>,
        $StreamProvider<Map<String, String?>> {
  const TabDescendantsProvider._({
    required TabDescendantsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'tabDescendantsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$tabDescendantsHash();

  @override
  String toString() {
    return r'tabDescendantsProvider'
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
    return tabDescendants(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is TabDescendantsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$tabDescendantsHash() => r'c2c3fe18e9b47c64df9ae6c1cfde683f3231d53c';

final class TabDescendantsFamily extends $Family
    with $FunctionalFamilyOverride<Stream<Map<String, String?>>, String> {
  const TabDescendantsFamily._()
    : super(
        retry: null,
        name: r'tabDescendantsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  TabDescendantsProvider call(String tabId) =>
      TabDescendantsProvider._(argument: tabId, from: this);

  @override
  String toString() => r'tabDescendantsProvider';
}

@ProviderFor(containerTabsData)
const containerTabsDataProvider = ContainerTabsDataFamily._();

final class ContainerTabsDataProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<TabData>>,
          List<TabData>,
          Stream<List<TabData>>
        >
    with $FutureModifier<List<TabData>>, $StreamProvider<List<TabData>> {
  const ContainerTabsDataProvider._({
    required ContainerTabsDataFamily super.from,
    required String? super.argument,
  }) : super(
         retry: null,
         name: r'containerTabsDataProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$containerTabsDataHash();

  @override
  String toString() {
    return r'containerTabsDataProvider'
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
    return containerTabsData(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ContainerTabsDataProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$containerTabsDataHash() => r'2961c89fc9e16c8e6005342356ecf677fb2ff63c';

final class ContainerTabsDataFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<TabData>>, String?> {
  const ContainerTabsDataFamily._()
    : super(
        retry: null,
        name: r'containerTabsDataProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ContainerTabsDataProvider call(String? containerId) =>
      ContainerTabsDataProvider._(argument: containerId, from: this);

  @override
  String toString() => r'containerTabsDataProvider';
}

@ProviderFor(containerData)
const containerDataProvider = ContainerDataFamily._();

final class ContainerDataProvider
    extends
        $FunctionalProvider<
          AsyncValue<ContainerData?>,
          ContainerData?,
          Stream<ContainerData?>
        >
    with $FutureModifier<ContainerData?>, $StreamProvider<ContainerData?> {
  const ContainerDataProvider._({
    required ContainerDataFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'containerDataProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$containerDataHash();

  @override
  String toString() {
    return r'containerDataProvider'
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
    return containerData(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ContainerDataProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$containerDataHash() => r'6adbec128876069189954832af35109b0779148c';

final class ContainerDataFamily extends $Family
    with $FunctionalFamilyOverride<Stream<ContainerData?>, String> {
  const ContainerDataFamily._()
    : super(
        retry: null,
        name: r'containerDataProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ContainerDataProvider call(String containerId) =>
      ContainerDataProvider._(argument: containerId, from: this);

  @override
  String toString() => r'containerDataProvider';
}

@ProviderFor(watchContainerTabId)
const watchContainerTabIdProvider = WatchContainerTabIdFamily._();

final class WatchContainerTabIdProvider
    extends $FunctionalProvider<AsyncValue<String?>, String?, Stream<String?>>
    with $FutureModifier<String?>, $StreamProvider<String?> {
  const WatchContainerTabIdProvider._({
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
  const WatchContainerTabIdFamily._()
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
