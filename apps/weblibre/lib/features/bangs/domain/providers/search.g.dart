// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Tracks the bang written into the address bar as the user types.
///
/// Kept as a notifier rather than a `.family` on the text so that a keystroke
/// updates one provider instead of creating and disposing one per input value.

@ProviderFor(InlineBang)
final inlineBangProvider = InlineBangProvider._();

/// Tracks the bang written into the address bar as the user types.
///
/// Kept as a notifier rather than a `.family` on the text so that a keystroke
/// updates one provider instead of creating and disposing one per input value.
final class InlineBangProvider
    extends $NotifierProvider<InlineBang, InlineBangMatch?> {
  /// Tracks the bang written into the address bar as the user types.
  ///
  /// Kept as a notifier rather than a `.family` on the text so that a keystroke
  /// updates one provider instead of creating and disposing one per input value.
  InlineBangProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'inlineBangProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$inlineBangHash();

  @$internal
  @override
  InlineBang create() => InlineBang();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(InlineBangMatch? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<InlineBangMatch?>(value),
    );
  }
}

String _$inlineBangHash() => r'ae16a7860c45d54ed9f23f13c3c51f21175b6ef0';

/// Tracks the bang written into the address bar as the user types.
///
/// Kept as a notifier rather than a `.family` on the text so that a keystroke
/// updates one provider instead of creating and disposing one per input value.

abstract class _$InlineBang extends $Notifier<InlineBangMatch?> {
  InlineBangMatch? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<InlineBangMatch?, InlineBangMatch?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<InlineBangMatch?, InlineBangMatch?>,
              InlineBangMatch?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(BangSearch)
final bangSearchProvider = BangSearchProvider._();

final class BangSearchProvider
    extends $StreamNotifierProvider<BangSearch, List<BangData>> {
  BangSearchProvider._()
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

String _$bangSearchHash() => r'666cb6aa392fcca8b371cf5688fe1d20bf8fa8d0';

abstract class _$BangSearch extends $StreamNotifier<List<BangData>> {
  Stream<List<BangData>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<BangData>>, List<BangData>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<BangData>>, List<BangData>>,
              AsyncValue<List<BangData>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(SeamlessBang)
final seamlessBangProvider = SeamlessBangProvider._();

final class SeamlessBangProvider
    extends $NotifierProvider<SeamlessBang, AsyncValue<List<BangData>>> {
  SeamlessBangProvider._()
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

String _$seamlessBangHash() => r'1a3e12a782c7117ab5e508cfb0a59346a67e6b78';

abstract class _$SeamlessBang extends $Notifier<AsyncValue<List<BangData>>> {
  AsyncValue<List<BangData>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
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
    return element.handleCreate(ref, build);
  }
}
