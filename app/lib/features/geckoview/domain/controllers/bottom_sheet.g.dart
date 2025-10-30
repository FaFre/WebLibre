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
        isAutoDispose: false,
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
    r'47234d4bd06187c6f0b85013ffc50ebdd065c90b';

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
