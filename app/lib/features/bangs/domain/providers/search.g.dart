// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(BangSearch)
const bangSearchProvider = BangSearchProvider._();

final class BangSearchProvider
    extends $StreamNotifierProvider<BangSearch, List<BangData>> {
  const BangSearchProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'bangSearchProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$bangSearchHash();

  @$internal
  @override
  BangSearch create() => BangSearch();
}

String _$bangSearchHash() => r'66080335f1677e6a4636c41dd5619de3828375e6';

abstract class _$BangSearch extends $StreamNotifier<List<BangData>> {
  Stream<List<BangData>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<List<BangData>>, List<BangData>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<BangData>>, List<BangData>>,
              AsyncValue<List<BangData>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(SeamlessBang)
const seamlessBangProvider = SeamlessBangProvider._();

final class SeamlessBangProvider
    extends $NotifierProvider<SeamlessBang, AsyncValue<List<BangData>>> {
  const SeamlessBangProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'seamlessBangProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$seamlessBangHash();

  @$internal
  @override
  SeamlessBang create() => SeamlessBang();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<List<BangData>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<List<BangData>>>(value),
    );
  }
}

String _$seamlessBangHash() => r'8bd7a2cbe4c302ae08f85167290666a7437f8b9b';

abstract class _$SeamlessBang extends $Notifier<AsyncValue<List<BangData>>> {
  AsyncValue<List<BangData>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref
            as $Ref<AsyncValue<List<BangData>>, AsyncValue<List<BangData>>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<BangData>>,
                AsyncValue<List<BangData>>
              >,
              AsyncValue<List<BangData>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
