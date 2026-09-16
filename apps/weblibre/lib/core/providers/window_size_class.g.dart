// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'window_size_class.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The current window's [WindowSizeClass].
///
/// This is a provider rather than an `InheritedWidget` because both halves of
/// the app need it and only one of them has a `BuildContext`: the settings
/// resolvers are read from widgets (`browser.dart`) *and* from plain providers
/// that take only a `Ref` — `quickTabSwitcherRowCount` is the blocking
/// example. One mechanism keeps those two from drifting apart.
///
/// It observes the platform view directly instead of being fed from the widget
/// tree. That is not just convenience:
///
///  * Writing a provider from a widget's build (including from `useEffect`,
///    which still runs inside the build phase) trips Riverpod's
///    modify-during-build guard. Deferring the write to a post-frame callback
///    would work but would paint one frame of the wrong layout on every
///    change.
///  * The window size is a platform-global fact, not a property of any
///    subtree. The app's only `MediaQuery` override
///    (`applyAppMediaQueryOverrides`) touches `textScaler` and
///    `disableAnimations` and never `size`, so reading the view is equivalent
///    to reading `MediaQuery` and is honest about what it means.
///
/// The state is the discrete enum pair, never a size, so it notifies only when
/// a breakpoint is actually crossed. Dragging a freeform window from 400dp to
/// 1600dp produces two notifications, not one per frame — which is what keeps
/// the browser shell from re-laying out the GeckoView platform view mid-drag.

@ProviderFor(WindowSizeClassController)
final windowSizeClassControllerProvider = WindowSizeClassControllerProvider._();

/// The current window's [WindowSizeClass].
///
/// This is a provider rather than an `InheritedWidget` because both halves of
/// the app need it and only one of them has a `BuildContext`: the settings
/// resolvers are read from widgets (`browser.dart`) *and* from plain providers
/// that take only a `Ref` — `quickTabSwitcherRowCount` is the blocking
/// example. One mechanism keeps those two from drifting apart.
///
/// It observes the platform view directly instead of being fed from the widget
/// tree. That is not just convenience:
///
///  * Writing a provider from a widget's build (including from `useEffect`,
///    which still runs inside the build phase) trips Riverpod's
///    modify-during-build guard. Deferring the write to a post-frame callback
///    would work but would paint one frame of the wrong layout on every
///    change.
///  * The window size is a platform-global fact, not a property of any
///    subtree. The app's only `MediaQuery` override
///    (`applyAppMediaQueryOverrides`) touches `textScaler` and
///    `disableAnimations` and never `size`, so reading the view is equivalent
///    to reading `MediaQuery` and is honest about what it means.
///
/// The state is the discrete enum pair, never a size, so it notifies only when
/// a breakpoint is actually crossed. Dragging a freeform window from 400dp to
/// 1600dp produces two notifications, not one per frame — which is what keeps
/// the browser shell from re-laying out the GeckoView platform view mid-drag.
final class WindowSizeClassControllerProvider
    extends $NotifierProvider<WindowSizeClassController, WindowSizeClass> {
  /// The current window's [WindowSizeClass].
  ///
  /// This is a provider rather than an `InheritedWidget` because both halves of
  /// the app need it and only one of them has a `BuildContext`: the settings
  /// resolvers are read from widgets (`browser.dart`) *and* from plain providers
  /// that take only a `Ref` — `quickTabSwitcherRowCount` is the blocking
  /// example. One mechanism keeps those two from drifting apart.
  ///
  /// It observes the platform view directly instead of being fed from the widget
  /// tree. That is not just convenience:
  ///
  ///  * Writing a provider from a widget's build (including from `useEffect`,
  ///    which still runs inside the build phase) trips Riverpod's
  ///    modify-during-build guard. Deferring the write to a post-frame callback
  ///    would work but would paint one frame of the wrong layout on every
  ///    change.
  ///  * The window size is a platform-global fact, not a property of any
  ///    subtree. The app's only `MediaQuery` override
  ///    (`applyAppMediaQueryOverrides`) touches `textScaler` and
  ///    `disableAnimations` and never `size`, so reading the view is equivalent
  ///    to reading `MediaQuery` and is honest about what it means.
  ///
  /// The state is the discrete enum pair, never a size, so it notifies only when
  /// a breakpoint is actually crossed. Dragging a freeform window from 400dp to
  /// 1600dp produces two notifications, not one per frame — which is what keeps
  /// the browser shell from re-laying out the GeckoView platform view mid-drag.
  WindowSizeClassControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'windowSizeClassControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$windowSizeClassControllerHash();

  @$internal
  @override
  WindowSizeClassController create() => WindowSizeClassController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WindowSizeClass value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WindowSizeClass>(value),
    );
  }
}

String _$windowSizeClassControllerHash() =>
    r'9ce795a0c6508d545915c5475c98a535f8e75001';

/// The current window's [WindowSizeClass].
///
/// This is a provider rather than an `InheritedWidget` because both halves of
/// the app need it and only one of them has a `BuildContext`: the settings
/// resolvers are read from widgets (`browser.dart`) *and* from plain providers
/// that take only a `Ref` — `quickTabSwitcherRowCount` is the blocking
/// example. One mechanism keeps those two from drifting apart.
///
/// It observes the platform view directly instead of being fed from the widget
/// tree. That is not just convenience:
///
///  * Writing a provider from a widget's build (including from `useEffect`,
///    which still runs inside the build phase) trips Riverpod's
///    modify-during-build guard. Deferring the write to a post-frame callback
///    would work but would paint one frame of the wrong layout on every
///    change.
///  * The window size is a platform-global fact, not a property of any
///    subtree. The app's only `MediaQuery` override
///    (`applyAppMediaQueryOverrides`) touches `textScaler` and
///    `disableAnimations` and never `size`, so reading the view is equivalent
///    to reading `MediaQuery` and is honest about what it means.
///
/// The state is the discrete enum pair, never a size, so it notifies only when
/// a breakpoint is actually crossed. Dragging a freeform window from 400dp to
/// 1600dp produces two notifications, not one per frame — which is what keeps
/// the browser shell from re-laying out the GeckoView platform view mid-drag.

abstract class _$WindowSizeClassController extends $Notifier<WindowSizeClass> {
  WindowSizeClass build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<WindowSizeClass, WindowSizeClass>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<WindowSizeClass, WindowSizeClass>,
              WindowSizeClass,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
