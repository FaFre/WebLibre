// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'toolbar_visibility.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ToolbarVisibilityController)
final toolbarVisibilityControllerProvider =
    ToolbarVisibilityControllerFamily._();

final class ToolbarVisibilityControllerProvider
    extends $NotifierProvider<ToolbarVisibilityController, ToolbarVisibility> {
  ToolbarVisibilityControllerProvider._({
    required ToolbarVisibilityControllerFamily super.from,
    required String? super.argument,
  }) : super(
         retry: null,
         name: r'toolbarVisibilityControllerProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$toolbarVisibilityControllerHash();

  @override
  String toString() {
    return r'toolbarVisibilityControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ToolbarVisibilityController create() => ToolbarVisibilityController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ToolbarVisibility value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ToolbarVisibility>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ToolbarVisibilityControllerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$toolbarVisibilityControllerHash() =>
    r'242449893afd6780d977544659e83d4641c8a0ad';

final class ToolbarVisibilityControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          ToolbarVisibilityController,
          ToolbarVisibility,
          ToolbarVisibility,
          ToolbarVisibility,
          String?
        > {
  ToolbarVisibilityControllerFamily._()
    : super(
        retry: null,
        name: r'toolbarVisibilityControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  ToolbarVisibilityControllerProvider call(String? tabId) =>
      ToolbarVisibilityControllerProvider._(argument: tabId, from: this);

  @override
  String toString() => r'toolbarVisibilityControllerProvider';
}

abstract class _$ToolbarVisibilityController
    extends $Notifier<ToolbarVisibility> {
  late final _$args = ref.$arg as String?;
  String? get tabId => _$args;

  ToolbarVisibility build(String? tabId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<ToolbarVisibility, ToolbarVisibility>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ToolbarVisibility, ToolbarVisibility>,
              ToolbarVisibility,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
