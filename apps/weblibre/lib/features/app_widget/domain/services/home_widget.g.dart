// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_widget.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(widgetPinnable)
final widgetPinnableProvider = WidgetPinnableProvider._();

final class WidgetPinnableProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  WidgetPinnableProvider._()
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

/// Every widget launch, whoever delivered it.
///
/// ## Who delivers a widget launch
///
/// The `home_widget` plugin reads the launch intent itself, so §7.1's question is
/// real: broker, plugin, or both with deduplication. The answer here is
/// **whichever one has it, and never both** — which holds by construction rather
/// than by filtering:
///
/// - **Cold start.** `MainActivity.onCreate` does not queue, so the launch intent
///   is untouched and `initiallyLaunchedFromHomeWidget()` reads it as always.
/// - **Warm, profile committed.** The broker declines the intent, `super` runs,
///   and the plugin's `widgetClicked` fires.
/// - **Warm, nothing committed** — the picker, maintenance, restart teardown.
///   The broker takes the intent and `MainActivity` returns without `super`, so
///   the plugin never sees it and cannot double-deliver. Before this, the plugin
///   sent it to a Dart side with no listeners and the tap did nothing at all.
///
/// The two paths are mutually exclusive on the *same* condition the broker uses
/// to take an intent, so a deduplication step would have nothing to deduplicate.
/// The merge below is a union of disjoint sources, not a race.
///
/// Subscribed as soon as it is built, and buffered, unlike the plugin's own
/// streams: a launch the broker replays is delivered once, at startup, while the
/// widget that reads this only exists once the browser has mounted. See
/// [bufferedIntentStream].

@ProviderFor(appWidgetLaunchStream)
final appWidgetLaunchStreamProvider = AppWidgetLaunchStreamProvider._();

/// Every widget launch, whoever delivered it.
///
/// ## Who delivers a widget launch
///
/// The `home_widget` plugin reads the launch intent itself, so §7.1's question is
/// real: broker, plugin, or both with deduplication. The answer here is
/// **whichever one has it, and never both** — which holds by construction rather
/// than by filtering:
///
/// - **Cold start.** `MainActivity.onCreate` does not queue, so the launch intent
///   is untouched and `initiallyLaunchedFromHomeWidget()` reads it as always.
/// - **Warm, profile committed.** The broker declines the intent, `super` runs,
///   and the plugin's `widgetClicked` fires.
/// - **Warm, nothing committed** — the picker, maintenance, restart teardown.
///   The broker takes the intent and `MainActivity` returns without `super`, so
///   the plugin never sees it and cannot double-deliver. Before this, the plugin
///   sent it to a Dart side with no listeners and the tap did nothing at all.
///
/// The two paths are mutually exclusive on the *same* condition the broker uses
/// to take an intent, so a deduplication step would have nothing to deduplicate.
/// The merge below is a union of disjoint sources, not a race.
///
/// Subscribed as soon as it is built, and buffered, unlike the plugin's own
/// streams: a launch the broker replays is delivered once, at startup, while the
/// widget that reads this only exists once the browser has mounted. See
/// [bufferedIntentStream].

final class AppWidgetLaunchStreamProvider
    extends
        $FunctionalProvider<
          Raw<Stream<ReceivedIntentParameter>>,
          Raw<Stream<ReceivedIntentParameter>>,
          Raw<Stream<ReceivedIntentParameter>>
        >
    with $Provider<Raw<Stream<ReceivedIntentParameter>>> {
  /// Every widget launch, whoever delivered it.
  ///
  /// ## Who delivers a widget launch
  ///
  /// The `home_widget` plugin reads the launch intent itself, so §7.1's question is
  /// real: broker, plugin, or both with deduplication. The answer here is
  /// **whichever one has it, and never both** — which holds by construction rather
  /// than by filtering:
  ///
  /// - **Cold start.** `MainActivity.onCreate` does not queue, so the launch intent
  ///   is untouched and `initiallyLaunchedFromHomeWidget()` reads it as always.
  /// - **Warm, profile committed.** The broker declines the intent, `super` runs,
  ///   and the plugin's `widgetClicked` fires.
  /// - **Warm, nothing committed** — the picker, maintenance, restart teardown.
  ///   The broker takes the intent and `MainActivity` returns without `super`, so
  ///   the plugin never sees it and cannot double-deliver. Before this, the plugin
  ///   sent it to a Dart side with no listeners and the tap did nothing at all.
  ///
  /// The two paths are mutually exclusive on the *same* condition the broker uses
  /// to take an intent, so a deduplication step would have nothing to deduplicate.
  /// The merge below is a union of disjoint sources, not a race.
  ///
  /// Subscribed as soon as it is built, and buffered, unlike the plugin's own
  /// streams: a launch the broker replays is delivered once, at startup, while the
  /// widget that reads this only exists once the browser has mounted. See
  /// [bufferedIntentStream].
  AppWidgetLaunchStreamProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appWidgetLaunchStreamProvider',
        isAutoDispose: false,
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
    r'5515bfa8f97e0238622e94b9f8c565b6b95e4ccd';
