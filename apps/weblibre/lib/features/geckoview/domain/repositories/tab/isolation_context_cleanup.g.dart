// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'isolation_context_cleanup.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Deleting the data of isolation contexts no tab uses any more, for the tab
/// repository: an isolated tab's context is cleared once its group's last
/// tab is gone, through native's release procedure while the context is
/// restricted (D32 of `plans/TAB_LOCK_AND_FREEZE_IMPLEMENTATION_PLAN.md`).
///
/// Contexts are queued ([add]) as their tabs close or their rows go, and
/// cleaned up by [drain] once the rows are gone. One whose cleanup has to
/// wait stays queued for the next [drain].
///
/// The state is the queue, kept across restarts: a context that has to wait
/// (a web app window still uses its storage, or its container is frozen) has
/// no tab row left that would queue it again, and lost with the process, its
/// cookies and site data would stay for good.

@ProviderFor(IsolationContextCleanup)
final isolationContextCleanupProvider = IsolationContextCleanupProvider._();

/// Deleting the data of isolation contexts no tab uses any more, for the tab
/// repository: an isolated tab's context is cleared once its group's last
/// tab is gone, through native's release procedure while the context is
/// restricted (D32 of `plans/TAB_LOCK_AND_FREEZE_IMPLEMENTATION_PLAN.md`).
///
/// Contexts are queued ([add]) as their tabs close or their rows go, and
/// cleaned up by [drain] once the rows are gone. One whose cleanup has to
/// wait stays queued for the next [drain].
///
/// The state is the queue, kept across restarts: a context that has to wait
/// (a web app window still uses its storage, or its container is frozen) has
/// no tab row left that would queue it again, and lost with the process, its
/// cookies and site data would stay for good.
final class IsolationContextCleanupProvider
    extends $NotifierProvider<IsolationContextCleanup, List<String>> {
  /// Deleting the data of isolation contexts no tab uses any more, for the tab
  /// repository: an isolated tab's context is cleared once its group's last
  /// tab is gone, through native's release procedure while the context is
  /// restricted (D32 of `plans/TAB_LOCK_AND_FREEZE_IMPLEMENTATION_PLAN.md`).
  ///
  /// Contexts are queued ([add]) as their tabs close or their rows go, and
  /// cleaned up by [drain] once the rows are gone. One whose cleanup has to
  /// wait stays queued for the next [drain].
  ///
  /// The state is the queue, kept across restarts: a context that has to wait
  /// (a web app window still uses its storage, or its container is frozen) has
  /// no tab row left that would queue it again, and lost with the process, its
  /// cookies and site data would stay for good.
  IsolationContextCleanupProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'isolationContextCleanupProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$isolationContextCleanupHash();

  @$internal
  @override
  IsolationContextCleanup create() => IsolationContextCleanup();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<String>>(value),
    );
  }
}

String _$isolationContextCleanupHash() =>
    r'0eb1543120c68d2b453e0e280bef08594c367a58';

/// Deleting the data of isolation contexts no tab uses any more, for the tab
/// repository: an isolated tab's context is cleared once its group's last
/// tab is gone, through native's release procedure while the context is
/// restricted (D32 of `plans/TAB_LOCK_AND_FREEZE_IMPLEMENTATION_PLAN.md`).
///
/// Contexts are queued ([add]) as their tabs close or their rows go, and
/// cleaned up by [drain] once the rows are gone. One whose cleanup has to
/// wait stays queued for the next [drain].
///
/// The state is the queue, kept across restarts: a context that has to wait
/// (a web app window still uses its storage, or its container is frozen) has
/// no tab row left that would queue it again, and lost with the process, its
/// cookies and site data would stay for good.

abstract class _$IsolationContextCleanup extends $Notifier<List<String>> {
  List<String> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<List<String>, List<String>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<String>, List<String>>,
              List<String>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
