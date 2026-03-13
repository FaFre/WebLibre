// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'browser_viewport_toolbar_insets.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$BrowserViewportToolbarInsetsStateCWProxy {
  BrowserViewportToolbarInsetsState dynamicToolbarMaxHeightPx(
    int dynamicToolbarMaxHeightPx,
  );

  BrowserViewportToolbarInsetsState verticalClippingPx(int verticalClippingPx);

  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `BrowserViewportToolbarInsetsState(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// BrowserViewportToolbarInsetsState(...).copyWith(id: 12, name: "My name")
  /// ```
  BrowserViewportToolbarInsetsState call({
    int dynamicToolbarMaxHeightPx,
    int verticalClippingPx,
  });
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfBrowserViewportToolbarInsetsState.copyWith(...)` or call `instanceOfBrowserViewportToolbarInsetsState.copyWith.fieldName(value)` for a single field.
class _$BrowserViewportToolbarInsetsStateCWProxyImpl
    implements _$BrowserViewportToolbarInsetsStateCWProxy {
  const _$BrowserViewportToolbarInsetsStateCWProxyImpl(this._value);

  final BrowserViewportToolbarInsetsState _value;

  @override
  BrowserViewportToolbarInsetsState dynamicToolbarMaxHeightPx(
    int dynamicToolbarMaxHeightPx,
  ) => call(dynamicToolbarMaxHeightPx: dynamicToolbarMaxHeightPx);

  @override
  BrowserViewportToolbarInsetsState verticalClippingPx(
    int verticalClippingPx,
  ) => call(verticalClippingPx: verticalClippingPx);

  @override
  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `BrowserViewportToolbarInsetsState(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// BrowserViewportToolbarInsetsState(...).copyWith(id: 12, name: "My name")
  /// ```
  BrowserViewportToolbarInsetsState call({
    Object? dynamicToolbarMaxHeightPx = const $CopyWithPlaceholder(),
    Object? verticalClippingPx = const $CopyWithPlaceholder(),
  }) {
    return BrowserViewportToolbarInsetsState(
      dynamicToolbarMaxHeightPx:
          dynamicToolbarMaxHeightPx == const $CopyWithPlaceholder() ||
              dynamicToolbarMaxHeightPx == null
          ? _value.dynamicToolbarMaxHeightPx
          // ignore: cast_nullable_to_non_nullable
          : dynamicToolbarMaxHeightPx as int,
      verticalClippingPx:
          verticalClippingPx == const $CopyWithPlaceholder() ||
              verticalClippingPx == null
          ? _value.verticalClippingPx
          // ignore: cast_nullable_to_non_nullable
          : verticalClippingPx as int,
    );
  }
}

extension $BrowserViewportToolbarInsetsStateCopyWith
    on BrowserViewportToolbarInsetsState {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfBrowserViewportToolbarInsetsState.copyWith(...)` or `instanceOfBrowserViewportToolbarInsetsState.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$BrowserViewportToolbarInsetsStateCWProxy get copyWith =>
      _$BrowserViewportToolbarInsetsStateCWProxyImpl(this);
}

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(BrowserViewportToolbarInsetsController)
final browserViewportToolbarInsetsControllerProvider =
    BrowserViewportToolbarInsetsControllerProvider._();

final class BrowserViewportToolbarInsetsControllerProvider
    extends
        $NotifierProvider<
          BrowserViewportToolbarInsetsController,
          BrowserViewportToolbarInsetsState
        > {
  BrowserViewportToolbarInsetsControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'browserViewportToolbarInsetsControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() =>
      _$browserViewportToolbarInsetsControllerHash();

  @$internal
  @override
  BrowserViewportToolbarInsetsController create() =>
      BrowserViewportToolbarInsetsController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BrowserViewportToolbarInsetsState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BrowserViewportToolbarInsetsState>(
        value,
      ),
    );
  }
}

String _$browserViewportToolbarInsetsControllerHash() =>
    r'ae6444dc84383bef7d957e3bbd1c48d9ebba15ec';

abstract class _$BrowserViewportToolbarInsetsController
    extends $Notifier<BrowserViewportToolbarInsetsState> {
  BrowserViewportToolbarInsetsState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<
              BrowserViewportToolbarInsetsState,
              BrowserViewportToolbarInsetsState
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                BrowserViewportToolbarInsetsState,
                BrowserViewportToolbarInsetsState
              >,
              BrowserViewportToolbarInsetsState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
