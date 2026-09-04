// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'singbox_proxy_logs.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Ring buffer of proxy/Tor log lines.
///
/// This notifier is `keepAlive` and subscribed from app start (see
/// `main.dart`) so startup messages are retained even before any UI mounts.
/// It holds no provider state of its own: appending to a buffer thousands of
/// times a minute must not notify anybody, and materializing a snapshot is
/// [ProxyLogFeed]'s job, which only exists while something displays the logs.

@ProviderFor(SingboxProxyLogs)
final singboxProxyLogsProvider = SingboxProxyLogsProvider._();

/// Ring buffer of proxy/Tor log lines.
///
/// This notifier is `keepAlive` and subscribed from app start (see
/// `main.dart`) so startup messages are retained even before any UI mounts.
/// It holds no provider state of its own: appending to a buffer thousands of
/// times a minute must not notify anybody, and materializing a snapshot is
/// [ProxyLogFeed]'s job, which only exists while something displays the logs.
final class SingboxProxyLogsProvider
    extends $NotifierProvider<SingboxProxyLogs, void> {
  /// Ring buffer of proxy/Tor log lines.
  ///
  /// This notifier is `keepAlive` and subscribed from app start (see
  /// `main.dart`) so startup messages are retained even before any UI mounts.
  /// It holds no provider state of its own: appending to a buffer thousands of
  /// times a minute must not notify anybody, and materializing a snapshot is
  /// [ProxyLogFeed]'s job, which only exists while something displays the logs.
  SingboxProxyLogsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'singboxProxyLogsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$singboxProxyLogsHash();

  @$internal
  @override
  SingboxProxyLogs create() => SingboxProxyLogs();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$singboxProxyLogsHash() => r'e82b73c50b8f9c295bc6286fcaf0a998be075977';

/// Ring buffer of proxy/Tor log lines.
///
/// This notifier is `keepAlive` and subscribed from app start (see
/// `main.dart`) so startup messages are retained even before any UI mounts.
/// It holds no provider state of its own: appending to a buffer thousands of
/// times a minute must not notify anybody, and materializing a snapshot is
/// [ProxyLogFeed]'s job, which only exists while something displays the logs.

abstract class _$SingboxProxyLogs extends $Notifier<void> {
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

/// Throttled snapshots of [SingboxProxyLogs]' ring buffer, most-recent-last.
///
/// Auto-disposed, and that is the whole point: copying up to
/// [_ringBufferCapacity] entries is only worth doing while something is
/// actually showing them, and tying that to the provider's own lifetime keeps
/// it out of a widget life-cycle. Publishing from `useEffect` — whose body runs
/// during build — wrote provider state mid-frame, which Riverpod refuses.

@ProviderFor(ProxyLogFeed)
final proxyLogFeedProvider = ProxyLogFeedProvider._();

/// Throttled snapshots of [SingboxProxyLogs]' ring buffer, most-recent-last.
///
/// Auto-disposed, and that is the whole point: copying up to
/// [_ringBufferCapacity] entries is only worth doing while something is
/// actually showing them, and tying that to the provider's own lifetime keeps
/// it out of a widget life-cycle. Publishing from `useEffect` — whose body runs
/// during build — wrote provider state mid-frame, which Riverpod refuses.
final class ProxyLogFeedProvider
    extends $NotifierProvider<ProxyLogFeed, List<ProxyLogMessage>> {
  /// Throttled snapshots of [SingboxProxyLogs]' ring buffer, most-recent-last.
  ///
  /// Auto-disposed, and that is the whole point: copying up to
  /// [_ringBufferCapacity] entries is only worth doing while something is
  /// actually showing them, and tying that to the provider's own lifetime keeps
  /// it out of a widget life-cycle. Publishing from `useEffect` — whose body runs
  /// during build — wrote provider state mid-frame, which Riverpod refuses.
  ProxyLogFeedProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'proxyLogFeedProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$proxyLogFeedHash();

  @$internal
  @override
  ProxyLogFeed create() => ProxyLogFeed();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<ProxyLogMessage> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<ProxyLogMessage>>(value),
    );
  }
}

String _$proxyLogFeedHash() => r'63f6697dd631df39f0648d7f722e06c22dda05d6';

/// Throttled snapshots of [SingboxProxyLogs]' ring buffer, most-recent-last.
///
/// Auto-disposed, and that is the whole point: copying up to
/// [_ringBufferCapacity] entries is only worth doing while something is
/// actually showing them, and tying that to the provider's own lifetime keeps
/// it out of a widget life-cycle. Publishing from `useEffect` — whose body runs
/// during build — wrote provider state mid-frame, which Riverpod refuses.

abstract class _$ProxyLogFeed extends $Notifier<List<ProxyLogMessage>> {
  List<ProxyLogMessage> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<List<ProxyLogMessage>, List<ProxyLogMessage>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<ProxyLogMessage>, List<ProxyLogMessage>>,
              List<ProxyLogMessage>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
