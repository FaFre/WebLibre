// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'overlay.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(OverlayController)
final overlayControllerProvider = OverlayControllerProvider._();

final class OverlayControllerProvider
    extends $NotifierProvider<OverlayController, WidgetBuilder?> {
  OverlayControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'overlayControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$overlayControllerHash();

  @$internal
  @override
  OverlayController create() => OverlayController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WidgetBuilder? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WidgetBuilder?>(value),
    );
  }
}

String _$overlayControllerHash() => r'd0cd7c4cf867397f10f801ec2f7733be56520fb3';

abstract class _$OverlayController extends $Notifier<WidgetBuilder?> {
  WidgetBuilder? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<WidgetBuilder?, WidgetBuilder?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<WidgetBuilder?, WidgetBuilder?>,
              WidgetBuilder?,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
