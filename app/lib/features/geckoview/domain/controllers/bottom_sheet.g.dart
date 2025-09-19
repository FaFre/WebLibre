// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bottom_sheet.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(BottomSheetController)
const bottomSheetControllerProvider = BottomSheetControllerProvider._();

final class BottomSheetControllerProvider
    extends $NotifierProvider<BottomSheetController, Sheet?> {
  const BottomSheetControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'bottomSheetControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$bottomSheetControllerHash();

  @$internal
  @override
  BottomSheetController create() => BottomSheetController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Sheet? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Sheet?>(value),
    );
  }
}

String _$bottomSheetControllerHash() =>
    r'0b0ea53a96b80b8c1cba79b1d5913274b7127d5b';

abstract class _$BottomSheetController extends $Notifier<Sheet?> {
  Sheet? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<Sheet?, Sheet?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Sheet?, Sheet?>,
              Sheet?,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(BottomSheetExtend)
const bottomSheetExtendProvider = BottomSheetExtendProvider._();

final class BottomSheetExtendProvider
    extends $StreamNotifierProvider<BottomSheetExtend, double> {
  const BottomSheetExtendProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'bottomSheetExtendProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$bottomSheetExtendHash();

  @$internal
  @override
  BottomSheetExtend create() => BottomSheetExtend();
}

String _$bottomSheetExtendHash() => r'7e11b9047c15bdeb4dfcb488a8573daadb64e25c';

abstract class _$BottomSheetExtend extends $StreamNotifier<double> {
  Stream<double> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<double>, double>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<double>, double>,
              AsyncValue<double>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
