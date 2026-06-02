// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'proxy_latency_tester.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Per-profile latency results, keyed by profile id. Holds the latest result
/// only; we don't keep history because the test is user-triggered and the user
/// is looking at the chip we render from it.

@ProviderFor(ProxyLatencyResults)
final proxyLatencyResultsProvider = ProxyLatencyResultsProvider._();

/// Per-profile latency results, keyed by profile id. Holds the latest result
/// only; we don't keep history because the test is user-triggered and the user
/// is looking at the chip we render from it.
final class ProxyLatencyResultsProvider
    extends
        $NotifierProvider<
          ProxyLatencyResults,
          Map<ProxyConnectionId, AsyncValue<ProxyLatencyData>>
        > {
  /// Per-profile latency results, keyed by profile id. Holds the latest result
  /// only; we don't keep history because the test is user-triggered and the user
  /// is looking at the chip we render from it.
  ProxyLatencyResultsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'proxyLatencyResultsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$proxyLatencyResultsHash();

  @$internal
  @override
  ProxyLatencyResults create() => ProxyLatencyResults();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(
    Map<ProxyConnectionId, AsyncValue<ProxyLatencyData>> value,
  ) {
    return $ProviderOverride(
      origin: this,
      providerOverride:
          $SyncValueProvider<
            Map<ProxyConnectionId, AsyncValue<ProxyLatencyData>>
          >(value),
    );
  }
}

String _$proxyLatencyResultsHash() =>
    r'85dec80ca28c86cf0cb62c6548d82986de79f61d';

/// Per-profile latency results, keyed by profile id. Holds the latest result
/// only; we don't keep history because the test is user-triggered and the user
/// is looking at the chip we render from it.

abstract class _$ProxyLatencyResults
    extends $Notifier<Map<ProxyConnectionId, AsyncValue<ProxyLatencyData>>> {
  Map<ProxyConnectionId, AsyncValue<ProxyLatencyData>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<
              Map<ProxyConnectionId, AsyncValue<ProxyLatencyData>>,
              Map<ProxyConnectionId, AsyncValue<ProxyLatencyData>>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                Map<ProxyConnectionId, AsyncValue<ProxyLatencyData>>,
                Map<ProxyConnectionId, AsyncValue<ProxyLatencyData>>
              >,
              Map<ProxyConnectionId, AsyncValue<ProxyLatencyData>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
