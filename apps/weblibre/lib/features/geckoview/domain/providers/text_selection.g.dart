// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'text_selection.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Whether native text selection is currently on screen, mirroring the engine's
/// selection action mode (the floating copy/paste toolbar).
///
/// Exists so the touch-driven chrome can tell a selection-handle drag apart from
/// a swipe. Handles are drawn by the compositor rather than as Android views, so
/// dragging one produces an ordinary pointer stream that the toolbar auto-hide
/// accumulator would otherwise read as a scroll and re-show the toolbar.
///
/// Read this at pointer-down and hold the decision for the rest of the stream.
/// Sampling it mid-drag does not work: the engine tears the selection toolbar
/// down while a handle is being dragged, so it reports false during exactly the
/// interaction it is meant to describe. The native side compensates with a short
/// grace window after the toolbar disappears and again after a selection drag
/// ends, covering a quick re-grab of a handle.
///
/// See https://github.com/FaFre/WebLibre/issues/578.

@ProviderFor(TextSelectionActive)
final textSelectionActiveProvider = TextSelectionActiveProvider._();

/// Whether native text selection is currently on screen, mirroring the engine's
/// selection action mode (the floating copy/paste toolbar).
///
/// Exists so the touch-driven chrome can tell a selection-handle drag apart from
/// a swipe. Handles are drawn by the compositor rather than as Android views, so
/// dragging one produces an ordinary pointer stream that the toolbar auto-hide
/// accumulator would otherwise read as a scroll and re-show the toolbar.
///
/// Read this at pointer-down and hold the decision for the rest of the stream.
/// Sampling it mid-drag does not work: the engine tears the selection toolbar
/// down while a handle is being dragged, so it reports false during exactly the
/// interaction it is meant to describe. The native side compensates with a short
/// grace window after the toolbar disappears and again after a selection drag
/// ends, covering a quick re-grab of a handle.
///
/// See https://github.com/FaFre/WebLibre/issues/578.
final class TextSelectionActiveProvider
    extends $NotifierProvider<TextSelectionActive, bool> {
  /// Whether native text selection is currently on screen, mirroring the engine's
  /// selection action mode (the floating copy/paste toolbar).
  ///
  /// Exists so the touch-driven chrome can tell a selection-handle drag apart from
  /// a swipe. Handles are drawn by the compositor rather than as Android views, so
  /// dragging one produces an ordinary pointer stream that the toolbar auto-hide
  /// accumulator would otherwise read as a scroll and re-show the toolbar.
  ///
  /// Read this at pointer-down and hold the decision for the rest of the stream.
  /// Sampling it mid-drag does not work: the engine tears the selection toolbar
  /// down while a handle is being dragged, so it reports false during exactly the
  /// interaction it is meant to describe. The native side compensates with a short
  /// grace window after the toolbar disappears and again after a selection drag
  /// ends, covering a quick re-grab of a handle.
  ///
  /// See https://github.com/FaFre/WebLibre/issues/578.
  TextSelectionActiveProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'textSelectionActiveProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$textSelectionActiveHash();

  @$internal
  @override
  TextSelectionActive create() => TextSelectionActive();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$textSelectionActiveHash() =>
    r'94bf9d19a615a8424a5b57950cd0cc2c69a69c90';

/// Whether native text selection is currently on screen, mirroring the engine's
/// selection action mode (the floating copy/paste toolbar).
///
/// Exists so the touch-driven chrome can tell a selection-handle drag apart from
/// a swipe. Handles are drawn by the compositor rather than as Android views, so
/// dragging one produces an ordinary pointer stream that the toolbar auto-hide
/// accumulator would otherwise read as a scroll and re-show the toolbar.
///
/// Read this at pointer-down and hold the decision for the rest of the stream.
/// Sampling it mid-drag does not work: the engine tears the selection toolbar
/// down while a handle is being dragged, so it reports false during exactly the
/// interaction it is meant to describe. The native side compensates with a short
/// grace window after the toolbar disappears and again after a selection drag
/// ends, covering a quick re-grab of a handle.
///
/// See https://github.com/FaFre/WebLibre/issues/578.

abstract class _$TextSelectionActive extends $Notifier<bool> {
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
