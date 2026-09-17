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
/// instead.
///
/// The two are far apart on a cold start. Opening the launch means waiting for
/// the engine, resolving a container and writing the tab DB, while
/// `HomeTargetController` gives a restored selection ~300ms before it decides
/// the session is empty and latches the home surface (or resumes some other
/// tab) over whatever the launch opens next. The launch then loaded behind the
/// home screen, looking like it had been dropped (#623). "Ask" never showed it,
/// because the dialog defers the tab to a tap that lands long after startup has
/// settled.

@ProviderFor(IntentLaunchClaim)
final intentLaunchClaimProvider = IntentLaunchClaimProvider._();

/// Whether an external launch is on its way to a tab.
///
/// Held from the moment the launch is delivered — synchronously, before the
/// engine-readiness wait — until its tab exists, so that startup logic which
/// would otherwise conclude the browser has nothing to show waits for it
/// instead.
///
/// The two are far apart on a cold start. Opening the launch means waiting for
/// the engine, resolving a container and writing the tab DB, while
/// `HomeTargetController` gives a restored selection ~300ms before it decides
/// the session is empty and latches the home surface (or resumes some other
/// tab) over whatever the launch opens next. The launch then loaded behind the
/// home screen, looking like it had been dropped (#623). "Ask" never showed it,
/// because the dialog defers the tab to a tap that lands long after startup has
/// settled.
final class IntentLaunchClaimProvider
    extends $NotifierProvider<IntentLaunchClaim, bool> {
  /// Whether an external launch is on its way to a tab.
  ///
  /// Held from the moment the launch is delivered — synchronously, before the
  /// engine-readiness wait — until its tab exists, so that startup logic which
  /// would otherwise conclude the browser has nothing to show waits for it
  /// instead.
  ///
  /// The two are far apart on a cold start. Opening the launch means waiting for
  /// the engine, resolving a container and writing the tab DB, while
  /// `HomeTargetController` gives a restored selection ~300ms before it decides
  /// the session is empty and latches the home surface (or resumes some other
  /// tab) over whatever the launch opens next. The launch then loaded behind the
  /// home screen, looking like it had been dropped (#623). "Ask" never showed it,
  /// because the dialog defers the tab to a tap that lands long after startup has
  /// settled.
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
/// instead.
///
/// The two are far apart on a cold start. Opening the launch means waiting for
/// the engine, resolving a container and writing the tab DB, while
/// `HomeTargetController` gives a restored selection ~300ms before it decides
/// the session is empty and latches the home surface (or resumes some other
/// tab) over whatever the launch opens next. The launch then loaded behind the
/// home screen, looking like it had been dropped (#623). "Ask" never showed it,
/// because the dialog defers the tab to a tap that lands long after startup has
/// settled.

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
