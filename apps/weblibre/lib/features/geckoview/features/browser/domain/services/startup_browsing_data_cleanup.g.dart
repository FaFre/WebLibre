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
/// deletion, so a start must never skip it. Nothing it does may reach a tab
/// opened in this session, however late it runs:
///
/// - **Tabs are scoped to the previous session.** Native removes only the tabs
///   the session restore brought back, after that restore completed — never a
///   launch link or home page tab, even when this runs late or is retried.
/// - **Everything else runs only while new tabs are held back.** Cookie, cache
///   and the other deletions are global: one that runs after browsing began
///   would take this session's logins with it. So they are dispatched only
///   while [waitUntilDone] still holds new tabs — during the first run, and
///   never after a wait on it timed out. What did not get done is left for the
///   next start, which deletes it anyway.
/// - **Progress is kept per data type.** A retry (a remount of the browser after
///   a failure) repeats only the previous-session tab deletion, if that is what
///   failed, against the selection taken on the first run.

@ProviderFor(StartupBrowsingDataCleanup)
final startupBrowsingDataCleanupProvider =
    StartupBrowsingDataCleanupProvider._();

/// Deletes [GeneralSettings.autoDeleteBrowsingData] when the browser starts.
///
/// This is also what completes a Quit that died half way through its own
/// deletion, so a start must never skip it. Nothing it does may reach a tab
/// opened in this session, however late it runs:
///
/// - **Tabs are scoped to the previous session.** Native removes only the tabs
///   the session restore brought back, after that restore completed — never a
///   launch link or home page tab, even when this runs late or is retried.
/// - **Everything else runs only while new tabs are held back.** Cookie, cache
///   and the other deletions are global: one that runs after browsing began
///   would take this session's logins with it. So they are dispatched only
///   while [waitUntilDone] still holds new tabs — during the first run, and
///   never after a wait on it timed out. What did not get done is left for the
///   next start, which deletes it anyway.
/// - **Progress is kept per data type.** A retry (a remount of the browser after
///   a failure) repeats only the previous-session tab deletion, if that is what
///   failed, against the selection taken on the first run.
final class StartupBrowsingDataCleanupProvider
    extends $NotifierProvider<StartupBrowsingDataCleanup, void> {
  /// Deletes [GeneralSettings.autoDeleteBrowsingData] when the browser starts.
  ///
  /// This is also what completes a Quit that died half way through its own
  /// deletion, so a start must never skip it. Nothing it does may reach a tab
  /// opened in this session, however late it runs:
  ///
  /// - **Tabs are scoped to the previous session.** Native removes only the tabs
  ///   the session restore brought back, after that restore completed — never a
  ///   launch link or home page tab, even when this runs late or is retried.
  /// - **Everything else runs only while new tabs are held back.** Cookie, cache
  ///   and the other deletions are global: one that runs after browsing began
  ///   would take this session's logins with it. So they are dispatched only
  ///   while [waitUntilDone] still holds new tabs — during the first run, and
  ///   never after a wait on it timed out. What did not get done is left for the
  ///   next start, which deletes it anyway.
  /// - **Progress is kept per data type.** A retry (a remount of the browser after
  ///   a failure) repeats only the previous-session tab deletion, if that is what
  ///   failed, against the selection taken on the first run.
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
    r'f084d64e5817c76c5eb8214871ff113d7e261459';

/// Deletes [GeneralSettings.autoDeleteBrowsingData] when the browser starts.
///
/// This is also what completes a Quit that died half way through its own
/// deletion, so a start must never skip it. Nothing it does may reach a tab
/// opened in this session, however late it runs:
///
/// - **Tabs are scoped to the previous session.** Native removes only the tabs
///   the session restore brought back, after that restore completed — never a
///   launch link or home page tab, even when this runs late or is retried.
/// - **Everything else runs only while new tabs are held back.** Cookie, cache
///   and the other deletions are global: one that runs after browsing began
///   would take this session's logins with it. So they are dispatched only
///   while [waitUntilDone] still holds new tabs — during the first run, and
///   never after a wait on it timed out. What did not get done is left for the
///   next start, which deletes it anyway.
/// - **Progress is kept per data type.** A retry (a remount of the browser after
///   a failure) repeats only the previous-session tab deletion, if that is what
///   failed, against the selection taken on the first run.

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
