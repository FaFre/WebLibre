// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(HistoryFilter)
const historyFilterProvider = HistoryFilterProvider._();

final class HistoryFilterProvider
    extends $NotifierProvider<HistoryFilter, HistoryFilterOptions> {
  const HistoryFilterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'historyFilterProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$historyFilterHash();

  @$internal
  @override
  HistoryFilter create() => HistoryFilter();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HistoryFilterOptions value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HistoryFilterOptions>(value),
    );
  }
}

String _$historyFilterHash() => r'68a604fe857476f7c15be89352a7b10bc456c3d6';

abstract class _$HistoryFilter extends $Notifier<HistoryFilterOptions> {
  HistoryFilterOptions build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<HistoryFilterOptions, HistoryFilterOptions>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<HistoryFilterOptions, HistoryFilterOptions>,
              HistoryFilterOptions,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(browsingHistory)
const browsingHistoryProvider = BrowsingHistoryProvider._();

final class BrowsingHistoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<VisitInfo>>,
          List<VisitInfo>,
          FutureOr<List<VisitInfo>>
        >
    with $FutureModifier<List<VisitInfo>>, $FutureProvider<List<VisitInfo>> {
  const BrowsingHistoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'browsingHistoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$browsingHistoryHash();

  @$internal
  @override
  $FutureProviderElement<List<VisitInfo>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<VisitInfo>> create(Ref ref) {
    return browsingHistory(ref);
  }
}

String _$browsingHistoryHash() => r'6447fd4d8209c3befb07f2d82fa41a24bd3accb1';
