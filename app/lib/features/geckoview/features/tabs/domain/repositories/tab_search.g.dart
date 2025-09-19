// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tab_search.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(TabSearchRepository)
const tabSearchRepositoryProvider = TabSearchRepositoryFamily._();

final class TabSearchRepositoryProvider
    extends
        $AsyncNotifierProvider<
          TabSearchRepository,
          ({String query, List<TabQueryResult> results})?
        > {
  const TabSearchRepositoryProvider._({
    required TabSearchRepositoryFamily super.from,
    required TabSearchPartition super.argument,
  }) : super(
         retry: null,
         name: r'tabSearchRepositoryProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$tabSearchRepositoryHash();

  @override
  String toString() {
    return r'tabSearchRepositoryProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  TabSearchRepository create() => TabSearchRepository();

  @override
  bool operator ==(Object other) {
    return other is TabSearchRepositoryProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$tabSearchRepositoryHash() =>
    r'ac2381c692b9caf93f26f302d15e0160c098917a';

final class TabSearchRepositoryFamily extends $Family
    with
        $ClassFamilyOverride<
          TabSearchRepository,
          AsyncValue<({String query, List<TabQueryResult> results})?>,
          ({String query, List<TabQueryResult> results})?,
          FutureOr<({String query, List<TabQueryResult> results})?>,
          TabSearchPartition
        > {
  const TabSearchRepositoryFamily._()
    : super(
        retry: null,
        name: r'tabSearchRepositoryProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  TabSearchRepositoryProvider call(TabSearchPartition partition) =>
      TabSearchRepositoryProvider._(argument: partition, from: this);

  @override
  String toString() => r'tabSearchRepositoryProvider';
}

abstract class _$TabSearchRepository
    extends $AsyncNotifier<({String query, List<TabQueryResult> results})?> {
  late final _$args = ref.$arg as TabSearchPartition;
  TabSearchPartition get partition => _$args;

  FutureOr<({String query, List<TabQueryResult> results})?> build(
    TabSearchPartition partition,
  );
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args);
    final ref =
        this.ref
            as $Ref<
              AsyncValue<({String query, List<TabQueryResult> results})?>,
              ({String query, List<TabQueryResult> results})?
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<({String query, List<TabQueryResult> results})?>,
                ({String query, List<TabQueryResult> results})?
              >,
              AsyncValue<({String query, List<TabQueryResult> results})?>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
