// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'small_web_mode_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SmallWebModeController)
final smallWebModeControllerProvider = SmallWebModeControllerProvider._();

final class SmallWebModeControllerProvider
    extends $NotifierProvider<SmallWebModeController, String?> {
  SmallWebModeControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'smallWebModeControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$smallWebModeControllerHash();

  @$internal
  @override
  SmallWebModeController create() => SmallWebModeController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$smallWebModeControllerHash() =>
    r'a012c3735309e0ace448369e2bf41e2671b7d9b9';

abstract class _$SmallWebModeController extends $Notifier<String?> {
  String? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<String?, String?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String?, String?>,
              String?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
