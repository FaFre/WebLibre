// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'singbox_proxy_logs.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Snapshot of buffered log entries. Most-recent-last (chronological).

@ProviderFor(SingboxProxyLogs)
final singboxProxyLogsProvider = SingboxProxyLogsProvider._();

/// Snapshot of buffered log entries. Most-recent-last (chronological).
final class SingboxProxyLogsProvider
    extends $NotifierProvider<SingboxProxyLogs, List<ProxyLogMessage>> {
  /// Snapshot of buffered log entries. Most-recent-last (chronological).
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

String _$singboxProxyLogsHash() => r'9fa30201ed4c128335142227226d937022f79d47';

/// Snapshot of buffered log entries. Most-recent-last (chronological).

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
