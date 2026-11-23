// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'web_notification_click.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Delivers a tap on a web notification to Gecko (E12).
///
/// A tap starts in native (`NotificationActivity`), which decides whether the
/// process serves the notification's profile, parks the tap and brings
/// WebLibre to the front. This picks it up once the engine is up and whenever
/// WebLibre comes back to the front (the process may have been running, so no
/// start announces it), and hands it to Gecko only when the routing is ready
/// for the storage it came from: the click wakes the site's service worker in
/// that storage, whose network traffic must take that container's route and
/// never a direct one. Gecko then runs the site's `notificationclick`
/// handler, whose `clients.openWindow()` opens a tab in the same storage
/// through native's service worker delegate.
///
/// A storage a freeze restricts is asked about first ("Resume {container} and
/// open?", [ContainerFreezeService.resumeStorageToOpen]). Like a tab the user
/// opens, a tap waits for the startup cleanup of browsing data
/// ([StartupBrowsingDataCleanup]). A tap that is not delivered is released to
/// native, which keeps its notification showing, except for one whose
/// storage's data is being deleted or whose container was deleted; the user
/// is told why it did not open ([ContainerFreezeNotices]), and a tap that
/// fails is released all the same.
///
/// keepAlive and started from main.dart: a tap has to be answered whatever
/// screen is up.

@ProviderFor(WebNotificationClickService)
final webNotificationClickServiceProvider =
    WebNotificationClickServiceProvider._();

/// Delivers a tap on a web notification to Gecko (E12).
///
/// A tap starts in native (`NotificationActivity`), which decides whether the
/// process serves the notification's profile, parks the tap and brings
/// WebLibre to the front. This picks it up once the engine is up and whenever
/// WebLibre comes back to the front (the process may have been running, so no
/// start announces it), and hands it to Gecko only when the routing is ready
/// for the storage it came from: the click wakes the site's service worker in
/// that storage, whose network traffic must take that container's route and
/// never a direct one. Gecko then runs the site's `notificationclick`
/// handler, whose `clients.openWindow()` opens a tab in the same storage
/// through native's service worker delegate.
///
/// A storage a freeze restricts is asked about first ("Resume {container} and
/// open?", [ContainerFreezeService.resumeStorageToOpen]). Like a tab the user
/// opens, a tap waits for the startup cleanup of browsing data
/// ([StartupBrowsingDataCleanup]). A tap that is not delivered is released to
/// native, which keeps its notification showing, except for one whose
/// storage's data is being deleted or whose container was deleted; the user
/// is told why it did not open ([ContainerFreezeNotices]), and a tap that
/// fails is released all the same.
///
/// keepAlive and started from main.dart: a tap has to be answered whatever
/// screen is up.
final class WebNotificationClickServiceProvider
    extends $NotifierProvider<WebNotificationClickService, void> {
  /// Delivers a tap on a web notification to Gecko (E12).
  ///
  /// A tap starts in native (`NotificationActivity`), which decides whether the
  /// process serves the notification's profile, parks the tap and brings
  /// WebLibre to the front. This picks it up once the engine is up and whenever
  /// WebLibre comes back to the front (the process may have been running, so no
  /// start announces it), and hands it to Gecko only when the routing is ready
  /// for the storage it came from: the click wakes the site's service worker in
  /// that storage, whose network traffic must take that container's route and
  /// never a direct one. Gecko then runs the site's `notificationclick`
  /// handler, whose `clients.openWindow()` opens a tab in the same storage
  /// through native's service worker delegate.
  ///
  /// A storage a freeze restricts is asked about first ("Resume {container} and
  /// open?", [ContainerFreezeService.resumeStorageToOpen]). Like a tab the user
  /// opens, a tap waits for the startup cleanup of browsing data
  /// ([StartupBrowsingDataCleanup]). A tap that is not delivered is released to
  /// native, which keeps its notification showing, except for one whose
  /// storage's data is being deleted or whose container was deleted; the user
  /// is told why it did not open ([ContainerFreezeNotices]), and a tap that
  /// fails is released all the same.
  ///
  /// keepAlive and started from main.dart: a tap has to be answered whatever
  /// screen is up.
  WebNotificationClickServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'webNotificationClickServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$webNotificationClickServiceHash();

  @$internal
  @override
  WebNotificationClickService create() => WebNotificationClickService();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$webNotificationClickServiceHash() =>
    r'd4a8fd9ae5ca379605714df02125eccc2d1a3d5d';

/// Delivers a tap on a web notification to Gecko (E12).
///
/// A tap starts in native (`NotificationActivity`), which decides whether the
/// process serves the notification's profile, parks the tap and brings
/// WebLibre to the front. This picks it up once the engine is up and whenever
/// WebLibre comes back to the front (the process may have been running, so no
/// start announces it), and hands it to Gecko only when the routing is ready
/// for the storage it came from: the click wakes the site's service worker in
/// that storage, whose network traffic must take that container's route and
/// never a direct one. Gecko then runs the site's `notificationclick`
/// handler, whose `clients.openWindow()` opens a tab in the same storage
/// through native's service worker delegate.
///
/// A storage a freeze restricts is asked about first ("Resume {container} and
/// open?", [ContainerFreezeService.resumeStorageToOpen]). Like a tab the user
/// opens, a tap waits for the startup cleanup of browsing data
/// ([StartupBrowsingDataCleanup]). A tap that is not delivered is released to
/// native, which keeps its notification showing, except for one whose
/// storage's data is being deleted or whose container was deleted; the user
/// is told why it did not open ([ContainerFreezeNotices]), and a tap that
/// fails is released all the same.
///
/// keepAlive and started from main.dart: a tap has to be answered whatever
/// screen is up.

abstract class _$WebNotificationClickService extends $Notifier<void> {
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
