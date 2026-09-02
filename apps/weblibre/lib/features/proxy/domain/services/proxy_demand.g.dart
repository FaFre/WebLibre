// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'proxy_demand.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The native side of the demand handover.
///
/// A provider so tests can drive launches without a platform channel; nothing
/// in the app has a reason to override it.

@ProviderFor(geckoContainerProxyService)
final geckoContainerProxyServiceProvider =
    GeckoContainerProxyServiceProvider._();

/// The native side of the demand handover.
///
/// A provider so tests can drive launches without a platform channel; nothing
/// in the app has a reason to override it.

final class GeckoContainerProxyServiceProvider
    extends
        $FunctionalProvider<
          GeckoContainerProxyService,
          GeckoContainerProxyService,
          GeckoContainerProxyService
        >
    with $Provider<GeckoContainerProxyService> {
  /// The native side of the demand handover.
  ///
  /// A provider so tests can drive launches without a platform channel; nothing
  /// in the app has a reason to override it.
  GeckoContainerProxyServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'geckoContainerProxyServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$geckoContainerProxyServiceHash();

  @$internal
  @override
  $ProviderElement<GeckoContainerProxyService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GeckoContainerProxyService create(Ref ref) {
    return geckoContainerProxyService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GeckoContainerProxyService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GeckoContainerProxyService>(value),
    );
  }
}

String _$geckoContainerProxyServiceHash() =>
    r'eb80f5f54e4cced43915a736c2f76180aa77b05c';

/// Starts the proxy connections a Custom Tab or PWA launch is waiting on.
///
/// Those launches are decided natively, before the app half exists and often
/// without a window of ours on screen, and a launch into a container that
/// routes through a stopped proxy cannot be served: sing-box and Tor both run
/// inside this isolate. Until now that ended the launch at a dialog — the user
/// was sent to the browser to start the proxy by hand and to tap their shortcut
/// again. But a container the user pointed at a proxy is a standing instruction
/// to use it, so the launch's need is recorded natively and answered here.
///
/// Deliberately unprompted, unlike [ensureProxyStartedForConnection]: the
/// windows these launches wait in are native, there is no Flutter UI in them to
/// ask through, and the question would be about a connection the user already
/// configured for the container they just opened.
///
/// The provider's own state names the connections it is bringing up, in the
/// same shape and for the same reason as [ProxyAutostartService]: routing is
/// published continuously, and an endpoint-less relation must read as "still
/// coming up" rather than as a settled block for as long as that is true.
/// Null until the first read lands, because "nothing is demanded" is an answer
/// this has to *get* — assuming it before asking would publish a block over a
/// launch that is at that moment being served.

@ProviderFor(ProxyDemandService)
final proxyDemandServiceProvider = ProxyDemandServiceProvider._();

/// Starts the proxy connections a Custom Tab or PWA launch is waiting on.
///
/// Those launches are decided natively, before the app half exists and often
/// without a window of ours on screen, and a launch into a container that
/// routes through a stopped proxy cannot be served: sing-box and Tor both run
/// inside this isolate. Until now that ended the launch at a dialog — the user
/// was sent to the browser to start the proxy by hand and to tap their shortcut
/// again. But a container the user pointed at a proxy is a standing instruction
/// to use it, so the launch's need is recorded natively and answered here.
///
/// Deliberately unprompted, unlike [ensureProxyStartedForConnection]: the
/// windows these launches wait in are native, there is no Flutter UI in them to
/// ask through, and the question would be about a connection the user already
/// configured for the container they just opened.
///
/// The provider's own state names the connections it is bringing up, in the
/// same shape and for the same reason as [ProxyAutostartService]: routing is
/// published continuously, and an endpoint-less relation must read as "still
/// coming up" rather than as a settled block for as long as that is true.
/// Null until the first read lands, because "nothing is demanded" is an answer
/// this has to *get* — assuming it before asking would publish a block over a
/// launch that is at that moment being served.
final class ProxyDemandServiceProvider
    extends $NotifierProvider<ProxyDemandService, Set<String>?> {
  /// Starts the proxy connections a Custom Tab or PWA launch is waiting on.
  ///
  /// Those launches are decided natively, before the app half exists and often
  /// without a window of ours on screen, and a launch into a container that
  /// routes through a stopped proxy cannot be served: sing-box and Tor both run
  /// inside this isolate. Until now that ended the launch at a dialog — the user
  /// was sent to the browser to start the proxy by hand and to tap their shortcut
  /// again. But a container the user pointed at a proxy is a standing instruction
  /// to use it, so the launch's need is recorded natively and answered here.
  ///
  /// Deliberately unprompted, unlike [ensureProxyStartedForConnection]: the
  /// windows these launches wait in are native, there is no Flutter UI in them to
  /// ask through, and the question would be about a connection the user already
  /// configured for the container they just opened.
  ///
  /// The provider's own state names the connections it is bringing up, in the
  /// same shape and for the same reason as [ProxyAutostartService]: routing is
  /// published continuously, and an endpoint-less relation must read as "still
  /// coming up" rather than as a settled block for as long as that is true.
  /// Null until the first read lands, because "nothing is demanded" is an answer
  /// this has to *get* — assuming it before asking would publish a block over a
  /// launch that is at that moment being served.
  ProxyDemandServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'proxyDemandServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$proxyDemandServiceHash();

  @$internal
  @override
  ProxyDemandService create() => ProxyDemandService();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Set<String>? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Set<String>?>(value),
    );
  }
}

String _$proxyDemandServiceHash() =>
    r'b0240b6e9dfe9670c8c99e548baca9e8f5d67515';

/// Starts the proxy connections a Custom Tab or PWA launch is waiting on.
///
/// Those launches are decided natively, before the app half exists and often
/// without a window of ours on screen, and a launch into a container that
/// routes through a stopped proxy cannot be served: sing-box and Tor both run
/// inside this isolate. Until now that ended the launch at a dialog — the user
/// was sent to the browser to start the proxy by hand and to tap their shortcut
/// again. But a container the user pointed at a proxy is a standing instruction
/// to use it, so the launch's need is recorded natively and answered here.
///
/// Deliberately unprompted, unlike [ensureProxyStartedForConnection]: the
/// windows these launches wait in are native, there is no Flutter UI in them to
/// ask through, and the question would be about a connection the user already
/// configured for the container they just opened.
///
/// The provider's own state names the connections it is bringing up, in the
/// same shape and for the same reason as [ProxyAutostartService]: routing is
/// published continuously, and an endpoint-less relation must read as "still
/// coming up" rather than as a settled block for as long as that is true.
/// Null until the first read lands, because "nothing is demanded" is an answer
/// this has to *get* — assuming it before asking would publish a block over a
/// launch that is at that moment being served.

abstract class _$ProxyDemandService extends $Notifier<Set<String>?> {
  Set<String>? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<Set<String>?, Set<String>?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Set<String>?, Set<String>?>,
              Set<String>?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
