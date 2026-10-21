// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'intent.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Whether an external launch is on its way to a tab.
///
/// Held from the moment the launch is delivered — synchronously, before the
/// engine-readiness wait — until its tab exists, so that startup logic which
/// would otherwise conclude the browser has nothing to show waits for it
/// instead. On a cold start [StartupLaunchCover] holds one from earlier still,
/// before the router mounts, covering the stretch before the launch reaches the
/// consumer.
///
/// The two are far apart on a cold start. Opening the launch means waiting for
/// the engine, resolving a container and writing the tab DB, while
/// `HomeTargetController` asks the native store for a selection as soon as
/// restore completes, and finding none, latches the home surface (or resumes
/// some other tab) over whatever the launch opens next. The launch then loaded
/// behind the home screen, looking like it had been dropped (#623). "Ask" never
/// showed it, because the dialog defers the tab to a tap that lands long after
/// startup has settled.

@ProviderFor(IntentLaunchClaim)
final intentLaunchClaimProvider = IntentLaunchClaimProvider._();

/// Whether an external launch is on its way to a tab.
///
/// Held from the moment the launch is delivered — synchronously, before the
/// engine-readiness wait — until its tab exists, so that startup logic which
/// would otherwise conclude the browser has nothing to show waits for it
/// instead. On a cold start [StartupLaunchCover] holds one from earlier still,
/// before the router mounts, covering the stretch before the launch reaches the
/// consumer.
///
/// The two are far apart on a cold start. Opening the launch means waiting for
/// the engine, resolving a container and writing the tab DB, while
/// `HomeTargetController` asks the native store for a selection as soon as
/// restore completes, and finding none, latches the home surface (or resumes
/// some other tab) over whatever the launch opens next. The launch then loaded
/// behind the home screen, looking like it had been dropped (#623). "Ask" never
/// showed it, because the dialog defers the tab to a tap that lands long after
/// startup has settled.
final class IntentLaunchClaimProvider
    extends $NotifierProvider<IntentLaunchClaim, bool> {
  /// Whether an external launch is on its way to a tab.
  ///
  /// Held from the moment the launch is delivered — synchronously, before the
  /// engine-readiness wait — until its tab exists, so that startup logic which
  /// would otherwise conclude the browser has nothing to show waits for it
  /// instead. On a cold start [StartupLaunchCover] holds one from earlier still,
  /// before the router mounts, covering the stretch before the launch reaches the
  /// consumer.
  ///
  /// The two are far apart on a cold start. Opening the launch means waiting for
  /// the engine, resolving a container and writing the tab DB, while
  /// `HomeTargetController` asks the native store for a selection as soon as
  /// restore completes, and finding none, latches the home surface (or resumes
  /// some other tab) over whatever the launch opens next. The launch then loaded
  /// behind the home screen, looking like it had been dropped (#623). "Ask" never
  /// showed it, because the dialog defers the tab to a tap that lands long after
  /// startup has settled.
  IntentLaunchClaimProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'intentLaunchClaimProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$intentLaunchClaimHash();

  @$internal
  @override
  IntentLaunchClaim create() => IntentLaunchClaim();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$intentLaunchClaimHash() => r'8e6b5ad99d1c451b3b7e8a0379703e96ad1b6ad4';

/// Whether an external launch is on its way to a tab.
///
/// Held from the moment the launch is delivered — synchronously, before the
/// engine-readiness wait — until its tab exists, so that startup logic which
/// would otherwise conclude the browser has nothing to show waits for it
/// instead. On a cold start [StartupLaunchCover] holds one from earlier still,
/// before the router mounts, covering the stretch before the launch reaches the
/// consumer.
///
/// The two are far apart on a cold start. Opening the launch means waiting for
/// the engine, resolving a container and writing the tab DB, while
/// `HomeTargetController` asks the native store for a selection as soon as
/// restore completes, and finding none, latches the home surface (or resumes
/// some other tab) over whatever the launch opens next. The launch then loaded
/// behind the home screen, looking like it had been dropped (#623). "Ask" never
/// showed it, because the dialog defers the tab to a tap that lands long after
/// startup has settled.

abstract class _$IntentLaunchClaim extends $Notifier<bool> {
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

/// Keeps the browser behind the startup spinner while a cold start is still
/// opening the launch the app was started for.
///
/// The router mounts as soon as initialization finishes, and the restored
/// session has no selection yet, so the home surface painted for a quarter of a
/// second before the launch's tab replaced it (#612).
///
/// Raised by startup, before the router mounts, from the receiver's backlog.
/// While up it holds an [IntentLaunchClaim]: the consumer takes its own only
/// once the launch has crossed the gatekeeper and reached the browser view, and
/// a startup home target that ran in between found no claim, no selection, and
/// latched home over the launch anyway.
///
/// Lowered by whichever comes first:
/// - the launch is on screen: a tab the consumer opened for it
///   ([launchTabOpened]), or whatever was selected after the engine created
///   it ([launchTabCreated]);
/// - the launch tab is selected but stays under home, because `addTab` could
///   not move the selected container over to it;
/// - the sharing pipeline let go of every awaited launch without opening it;
/// - the consumer gave up, or is showing a route rather than a tab ([lower]);
/// - [_maxCover], so a launch lost on the way never strands the spinner.
///
/// Not on just any selection. The restored session's own can land after the
/// cover went up, and the launch tab's lands before `addTab` has moved the
/// selected container over to it; lowering on either showed the restored page,
/// or home, for the frames before the launch took over.
///
/// Nor only on the launch's own tab, though. The engine reports the selection
/// debounced, keeping only the last of each 50ms, and a launch tab can be
/// replaced inside that window: a first navigation the container extension
/// cancels is reopened in a new tab in the site's assigned container, and the
/// launch tab is closed. Dart then never sees it selected, and waiting for it
/// kept the spinner over the replacement until [_maxCover] (12s). Anything
/// selected after the engine created the launch tab is past that tab's own
/// selection, which happened in the same step, so it is that tab or what took
/// its place. That is also why the selection to hide is taken there and not
/// once `addTab` has returned: the replacement can be selected while `addTab`
/// is still moving the selected container, and was then itself hidden.

@ProviderFor(StartupLaunchCover)
final startupLaunchCoverProvider = StartupLaunchCoverProvider._();

/// Keeps the browser behind the startup spinner while a cold start is still
/// opening the launch the app was started for.
///
/// The router mounts as soon as initialization finishes, and the restored
/// session has no selection yet, so the home surface painted for a quarter of a
/// second before the launch's tab replaced it (#612).
///
/// Raised by startup, before the router mounts, from the receiver's backlog.
/// While up it holds an [IntentLaunchClaim]: the consumer takes its own only
/// once the launch has crossed the gatekeeper and reached the browser view, and
/// a startup home target that ran in between found no claim, no selection, and
/// latched home over the launch anyway.
///
/// Lowered by whichever comes first:
/// - the launch is on screen: a tab the consumer opened for it
///   ([launchTabOpened]), or whatever was selected after the engine created
///   it ([launchTabCreated]);
/// - the launch tab is selected but stays under home, because `addTab` could
///   not move the selected container over to it;
/// - the sharing pipeline let go of every awaited launch without opening it;
/// - the consumer gave up, or is showing a route rather than a tab ([lower]);
/// - [_maxCover], so a launch lost on the way never strands the spinner.
///
/// Not on just any selection. The restored session's own can land after the
/// cover went up, and the launch tab's lands before `addTab` has moved the
/// selected container over to it; lowering on either showed the restored page,
/// or home, for the frames before the launch took over.
///
/// Nor only on the launch's own tab, though. The engine reports the selection
/// debounced, keeping only the last of each 50ms, and a launch tab can be
/// replaced inside that window: a first navigation the container extension
/// cancels is reopened in a new tab in the site's assigned container, and the
/// launch tab is closed. Dart then never sees it selected, and waiting for it
/// kept the spinner over the replacement until [_maxCover] (12s). Anything
/// selected after the engine created the launch tab is past that tab's own
/// selection, which happened in the same step, so it is that tab or what took
/// its place. That is also why the selection to hide is taken there and not
/// once `addTab` has returned: the replacement can be selected while `addTab`
/// is still moving the selected container, and was then itself hidden.
final class StartupLaunchCoverProvider
    extends $NotifierProvider<StartupLaunchCover, bool> {
  /// Keeps the browser behind the startup spinner while a cold start is still
  /// opening the launch the app was started for.
  ///
  /// The router mounts as soon as initialization finishes, and the restored
  /// session has no selection yet, so the home surface painted for a quarter of a
  /// second before the launch's tab replaced it (#612).
  ///
  /// Raised by startup, before the router mounts, from the receiver's backlog.
  /// While up it holds an [IntentLaunchClaim]: the consumer takes its own only
  /// once the launch has crossed the gatekeeper and reached the browser view, and
  /// a startup home target that ran in between found no claim, no selection, and
  /// latched home over the launch anyway.
  ///
  /// Lowered by whichever comes first:
  /// - the launch is on screen: a tab the consumer opened for it
  ///   ([launchTabOpened]), or whatever was selected after the engine created
  ///   it ([launchTabCreated]);
  /// - the launch tab is selected but stays under home, because `addTab` could
  ///   not move the selected container over to it;
  /// - the sharing pipeline let go of every awaited launch without opening it;
  /// - the consumer gave up, or is showing a route rather than a tab ([lower]);
  /// - [_maxCover], so a launch lost on the way never strands the spinner.
  ///
  /// Not on just any selection. The restored session's own can land after the
  /// cover went up, and the launch tab's lands before `addTab` has moved the
  /// selected container over to it; lowering on either showed the restored page,
  /// or home, for the frames before the launch took over.
  ///
  /// Nor only on the launch's own tab, though. The engine reports the selection
  /// debounced, keeping only the last of each 50ms, and a launch tab can be
  /// replaced inside that window: a first navigation the container extension
  /// cancels is reopened in a new tab in the site's assigned container, and the
  /// launch tab is closed. Dart then never sees it selected, and waiting for it
  /// kept the spinner over the replacement until [_maxCover] (12s). Anything
  /// selected after the engine created the launch tab is past that tab's own
  /// selection, which happened in the same step, so it is that tab or what took
  /// its place. That is also why the selection to hide is taken there and not
  /// once `addTab` has returned: the replacement can be selected while `addTab`
  /// is still moving the selected container, and was then itself hidden.
  StartupLaunchCoverProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'startupLaunchCoverProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$startupLaunchCoverHash();

  @$internal
  @override
  StartupLaunchCover create() => StartupLaunchCover();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$startupLaunchCoverHash() =>
    r'b9308aad167bf163fa929989d4e25386b0d1a35c';

/// Keeps the browser behind the startup spinner while a cold start is still
/// opening the launch the app was started for.
///
/// The router mounts as soon as initialization finishes, and the restored
/// session has no selection yet, so the home surface painted for a quarter of a
/// second before the launch's tab replaced it (#612).
///
/// Raised by startup, before the router mounts, from the receiver's backlog.
/// While up it holds an [IntentLaunchClaim]: the consumer takes its own only
/// once the launch has crossed the gatekeeper and reached the browser view, and
/// a startup home target that ran in between found no claim, no selection, and
/// latched home over the launch anyway.
///
/// Lowered by whichever comes first:
/// - the launch is on screen: a tab the consumer opened for it
///   ([launchTabOpened]), or whatever was selected after the engine created
///   it ([launchTabCreated]);
/// - the launch tab is selected but stays under home, because `addTab` could
///   not move the selected container over to it;
/// - the sharing pipeline let go of every awaited launch without opening it;
/// - the consumer gave up, or is showing a route rather than a tab ([lower]);
/// - [_maxCover], so a launch lost on the way never strands the spinner.
///
/// Not on just any selection. The restored session's own can land after the
/// cover went up, and the launch tab's lands before `addTab` has moved the
/// selected container over to it; lowering on either showed the restored page,
/// or home, for the frames before the launch took over.
///
/// Nor only on the launch's own tab, though. The engine reports the selection
/// debounced, keeping only the last of each 50ms, and a launch tab can be
/// replaced inside that window: a first navigation the container extension
/// cancels is reopened in a new tab in the site's assigned container, and the
/// launch tab is closed. Dart then never sees it selected, and waiting for it
/// kept the spinner over the replacement until [_maxCover] (12s). Anything
/// selected after the engine created the launch tab is past that tab's own
/// selection, which happened in the same step, so it is that tab or what took
/// its place. That is also why the selection to hide is taken there and not
/// once `addTab` has returned: the replacement can be selected while `addTab`
/// is still moving the selected container, and was then itself hidden.

abstract class _$StartupLaunchCover extends $Notifier<bool> {
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

@ProviderFor(EngineBoundIntentStream)
final engineBoundIntentStreamProvider = EngineBoundIntentStreamProvider._();

final class EngineBoundIntentStreamProvider
    extends $StreamNotifierProvider<EngineBoundIntentStream, SharedContent> {
  EngineBoundIntentStreamProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'engineBoundIntentStreamProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$engineBoundIntentStreamHash();

  @$internal
  @override
  EngineBoundIntentStream create() => EngineBoundIntentStream();
}

String _$engineBoundIntentStreamHash() =>
    r'8170f28c2ce69813066780a65205426182a26863';

abstract class _$EngineBoundIntentStream
    extends $StreamNotifier<SharedContent> {
  Stream<SharedContent> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<SharedContent>, SharedContent>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<SharedContent>, SharedContent>,
              AsyncValue<SharedContent>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
