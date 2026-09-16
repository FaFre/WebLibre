// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'browser_action_dispatcher.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Carries out [BrowserAction]s against the currently selected tab.
///
/// The single meaning of every action: gestures and keyboard shortcuts only
/// resolve their trigger to an action and hand it here, so an action cannot
/// behave differently depending on how it was invoked.

@ProviderFor(BrowserActionDispatcher)
final browserActionDispatcherProvider = BrowserActionDispatcherProvider._();

/// Carries out [BrowserAction]s against the currently selected tab.
///
/// The single meaning of every action: gestures and keyboard shortcuts only
/// resolve their trigger to an action and hand it here, so an action cannot
/// behave differently depending on how it was invoked.
final class BrowserActionDispatcherProvider
    extends $NotifierProvider<BrowserActionDispatcher, void> {
  /// Carries out [BrowserAction]s against the currently selected tab.
  ///
  /// The single meaning of every action: gestures and keyboard shortcuts only
  /// resolve their trigger to an action and hand it here, so an action cannot
  /// behave differently depending on how it was invoked.
  BrowserActionDispatcherProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'browserActionDispatcherProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$browserActionDispatcherHash();

  @$internal
  @override
  BrowserActionDispatcher create() => BrowserActionDispatcher();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$browserActionDispatcherHash() =>
    r'2b4eb0cfeb6129ee5b4df8edc37dfc70e7972010';

/// Carries out [BrowserAction]s against the currently selected tab.
///
/// The single meaning of every action: gestures and keyboard shortcuts only
/// resolve their trigger to an action and hand it here, so an action cannot
/// behave differently depending on how it was invoked.

abstract class _$BrowserActionDispatcher extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<void, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<void, void>,
              void,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
