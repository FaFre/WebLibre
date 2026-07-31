// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'singbox_proxy_logs.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Snapshot of buffered log entries. Most-recent-last (chronological).
///
/// This notifier is `keepAlive` and subscribed from app start (see
/// `main.dart`) so startup messages are retained even before any UI mounts.
/// Appending and *publishing* are therefore deliberately decoupled: lines
/// always land in [_buffer], but a new immutable snapshot is only produced
/// while the log screen is on screen ([setLivePublishing]) and at most once
/// per [_publishInterval].

@ProviderFor(SingboxProxyLogs)
final singboxProxyLogsProvider = SingboxProxyLogsProvider._();

/// Snapshot of buffered log entries. Most-recent-last (chronological).
///
/// This notifier is `keepAlive` and subscribed from app start (see
/// `main.dart`) so startup messages are retained even before any UI mounts.
/// Appending and *publishing* are therefore deliberately decoupled: lines
/// always land in [_buffer], but a new immutable snapshot is only produced
/// while the log screen is on screen ([setLivePublishing]) and at most once
/// per [_publishInterval].
final class SingboxProxyLogsProvider
    extends $NotifierProvider<SingboxProxyLogs, List<ProxyLogMessage>> {
  /// Snapshot of buffered log entries. Most-recent-last (chronological).
  ///
  /// This notifier is `keepAlive` and subscribed from app start (see
  /// `main.dart`) so startup messages are retained even before any UI mounts.
  /// Appending and *publishing* are therefore deliberately decoupled: lines
  /// always land in [_buffer], but a new immutable snapshot is only produced
  /// while the log screen is on screen ([setLivePublishing]) and at most once
  /// per [_publishInterval].
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
  Override overrideWithValue(List<ProxyLogMessage> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<ProxyLogMessage>>(value),
    );
  }
}

String _$singboxProxyLogsHash() => r'9ce114b70829de5b7b1c05f359c13d1d52d8e4ad';

/// Snapshot of buffered log entries. Most-recent-last (chronological).
///
/// This notifier is `keepAlive` and subscribed from app start (see
/// `main.dart`) so startup messages are retained even before any UI mounts.
/// Appending and *publishing* are therefore deliberately decoupled: lines
/// always land in [_buffer], but a new immutable snapshot is only produced
/// while the log screen is on screen ([setLivePublishing]) and at most once
/// per [_publishInterval].

abstract class _$SingboxProxyLogs extends $Notifier<List<ProxyLogMessage>> {
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
