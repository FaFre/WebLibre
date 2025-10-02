// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_widget.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(widgetPinnable)
const widgetPinnableProvider = WidgetPinnableProvider._();

final class WidgetPinnableProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  const WidgetPinnableProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'widgetPinnableProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$widgetPinnableHash();

  @$internal
  @override
  $FutureProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<bool> create(Ref ref) {
    return widgetPinnable(ref);
  }
}

String _$widgetPinnableHash() => r'3181e5e3e69e7e796e6429ca7507bbbc239f6c21';

@ProviderFor(appWidgetLaunchStream)
const appWidgetLaunchStreamProvider = AppWidgetLaunchStreamProvider._();

final class AppWidgetLaunchStreamProvider
    extends
        $FunctionalProvider<
          Raw<Stream<ReceivedIntentParameter>>,
          Raw<Stream<ReceivedIntentParameter>>,
          Raw<Stream<ReceivedIntentParameter>>
        >
    with $Provider<Raw<Stream<ReceivedIntentParameter>>> {
  const AppWidgetLaunchStreamProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appWidgetLaunchStreamProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appWidgetLaunchStreamHash();

  @$internal
  @override
  $ProviderElement<Raw<Stream<ReceivedIntentParameter>>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  Raw<Stream<ReceivedIntentParameter>> create(Ref ref) {
    return appWidgetLaunchStream(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Raw<Stream<ReceivedIntentParameter>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride:
          $SyncValueProvider<Raw<Stream<ReceivedIntentParameter>>>(value),
    );
  }
}

String _$appWidgetLaunchStreamHash() =>
    r'ed042d1391ae3dbc26f806d6fa2e9a4a2464ae44';
