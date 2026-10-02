// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'startup_browsing_data_cleanup.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Deletes [GeneralSettings.autoDeleteBrowsingData] when the browser starts.
///
/// This is also what completes a Quit that died half way through its own
/// deletion, so a start must never skip it.
///
/// - **After the session restore.** Restore runs natively on its own schedule;
///   deleting tabs before it lands deletes nothing, and the restored tabs stay.
/// - **Before any new tab.** Tab creation waits on [waitUntilDone], so a link the
///   app was launched with, or the home page tab, is never caught by a deletion
///   meant for the previous session.
/// - **Retried after a failure.** Only a success counts as this process's run,
///   so the next [start] — a remount of the browser — tries again.

@ProviderFor(StartupBrowsingDataCleanup)
final startupBrowsingDataCleanupProvider =
    StartupBrowsingDataCleanupProvider._();

/// Deletes [GeneralSettings.autoDeleteBrowsingData] when the browser starts.
///
/// This is also what completes a Quit that died half way through its own
/// deletion, so a start must never skip it.
///
/// - **After the session restore.** Restore runs natively on its own schedule;
///   deleting tabs before it lands deletes nothing, and the restored tabs stay.
/// - **Before any new tab.** Tab creation waits on [waitUntilDone], so a link the
///   app was launched with, or the home page tab, is never caught by a deletion
///   meant for the previous session.
/// - **Retried after a failure.** Only a success counts as this process's run,
///   so the next [start] — a remount of the browser — tries again.
final class StartupBrowsingDataCleanupProvider
    extends $NotifierProvider<StartupBrowsingDataCleanup, void> {
  /// Deletes [GeneralSettings.autoDeleteBrowsingData] when the browser starts.
  ///
  /// This is also what completes a Quit that died half way through its own
  /// deletion, so a start must never skip it.
  ///
  /// - **After the session restore.** Restore runs natively on its own schedule;
  ///   deleting tabs before it lands deletes nothing, and the restored tabs stay.
  /// - **Before any new tab.** Tab creation waits on [waitUntilDone], so a link the
  ///   app was launched with, or the home page tab, is never caught by a deletion
  ///   meant for the previous session.
  /// - **Retried after a failure.** Only a success counts as this process's run,
  ///   so the next [start] — a remount of the browser — tries again.
  StartupBrowsingDataCleanupProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'startupBrowsingDataCleanupProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$startupBrowsingDataCleanupHash();

  @$internal
  @override
  StartupBrowsingDataCleanup create() => StartupBrowsingDataCleanup();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$startupBrowsingDataCleanupHash() =>
    r'9a8e2634c7377266e5189cd690daec17ee31c8ee';

/// Deletes [GeneralSettings.autoDeleteBrowsingData] when the browser starts.
///
/// This is also what completes a Quit that died half way through its own
/// deletion, so a start must never skip it.
///
/// - **After the session restore.** Restore runs natively on its own schedule;
///   deleting tabs before it lands deletes nothing, and the restored tabs stay.
/// - **Before any new tab.** Tab creation waits on [waitUntilDone], so a link the
///   app was launched with, or the home page tab, is never caught by a deletion
///   meant for the previous session.
/// - **Retried after a failure.** Only a success counts as this process's run,
///   so the next [start] — a remount of the browser — tries again.

abstract class _$StartupBrowsingDataCleanup extends $Notifier<void> {
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
