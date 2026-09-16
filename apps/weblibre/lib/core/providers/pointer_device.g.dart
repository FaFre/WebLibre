// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pointer_device.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Whether the cursor is the input the user is currently driving the app with.
///
/// Set by any mouse or trackpad event, cleared by a touch or stylus press.
///
/// Deliberately not "is a mouse connected right now". Android reports the
/// cursor leaving the window as its pointer being removed, so connection flips
/// each time the cursor crosses the window edge, and a layout keyed on it would
/// jump with it. A press is a deliberate change of input and happens far less
/// often.
///
/// It has to clear at all because cursor-only affordances hang off it. The
/// auto-hiding side rail is revealed only by the cursor reaching the window
/// edge, so were this sticky for the process, a disconnected mouse or leaving
/// DeX would put the rail out of touch's reach until the app restarted.
///
/// Observed through a global pointer route, which sees every event the
/// framework dispatches — including hovers over the web page, which the
/// native pointer router replays into Flutter.

@ProviderFor(CursorInUse)
final cursorInUseProvider = CursorInUseProvider._();

/// Whether the cursor is the input the user is currently driving the app with.
///
/// Set by any mouse or trackpad event, cleared by a touch or stylus press.
///
/// Deliberately not "is a mouse connected right now". Android reports the
/// cursor leaving the window as its pointer being removed, so connection flips
/// each time the cursor crosses the window edge, and a layout keyed on it would
/// jump with it. A press is a deliberate change of input and happens far less
/// often.
///
/// It has to clear at all because cursor-only affordances hang off it. The
/// auto-hiding side rail is revealed only by the cursor reaching the window
/// edge, so were this sticky for the process, a disconnected mouse or leaving
/// DeX would put the rail out of touch's reach until the app restarted.
///
/// Observed through a global pointer route, which sees every event the
/// framework dispatches — including hovers over the web page, which the
/// native pointer router replays into Flutter.
final class CursorInUseProvider extends $NotifierProvider<CursorInUse, bool> {
  /// Whether the cursor is the input the user is currently driving the app with.
  ///
  /// Set by any mouse or trackpad event, cleared by a touch or stylus press.
  ///
  /// Deliberately not "is a mouse connected right now". Android reports the
  /// cursor leaving the window as its pointer being removed, so connection flips
  /// each time the cursor crosses the window edge, and a layout keyed on it would
  /// jump with it. A press is a deliberate change of input and happens far less
  /// often.
  ///
  /// It has to clear at all because cursor-only affordances hang off it. The
  /// auto-hiding side rail is revealed only by the cursor reaching the window
  /// edge, so were this sticky for the process, a disconnected mouse or leaving
  /// DeX would put the rail out of touch's reach until the app restarted.
  ///
  /// Observed through a global pointer route, which sees every event the
  /// framework dispatches — including hovers over the web page, which the
  /// native pointer router replays into Flutter.
  CursorInUseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cursorInUseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cursorInUseHash();

  @$internal
  @override
  CursorInUse create() => CursorInUse();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$cursorInUseHash() => r'9b1e7360759ab8f94b5364ab22b07e56b4ea9c87';

/// Whether the cursor is the input the user is currently driving the app with.
///
/// Set by any mouse or trackpad event, cleared by a touch or stylus press.
///
/// Deliberately not "is a mouse connected right now". Android reports the
/// cursor leaving the window as its pointer being removed, so connection flips
/// each time the cursor crosses the window edge, and a layout keyed on it would
/// jump with it. A press is a deliberate change of input and happens far less
/// often.
///
/// It has to clear at all because cursor-only affordances hang off it. The
/// auto-hiding side rail is revealed only by the cursor reaching the window
/// edge, so were this sticky for the process, a disconnected mouse or leaving
/// DeX would put the rail out of touch's reach until the app restarted.
///
/// Observed through a global pointer route, which sees every event the
/// framework dispatches — including hovers over the web page, which the
/// native pointer router replays into Flutter.

abstract class _$CursorInUse extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
