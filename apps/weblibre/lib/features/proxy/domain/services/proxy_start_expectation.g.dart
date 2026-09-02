// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'proxy_start_expectation.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The live [ProxyStartExpectation], assembled from what each backend reports.
///
/// Watched by [containerRoutingSnapshot], so a start that settles — succeeds,
/// fails, or is abandoned — recomputes the snapshot and pushes it. That push is
/// what ends the extension's wait: without it a request held for a start would
/// sit out the whole budget before failing.

@ProviderFor(proxyStartExpectation)
final proxyStartExpectationProvider = ProxyStartExpectationProvider._();

/// The live [ProxyStartExpectation], assembled from what each backend reports.
///
/// Watched by [containerRoutingSnapshot], so a start that settles — succeeds,
/// fails, or is abandoned — recomputes the snapshot and pushes it. That push is
/// what ends the extension's wait: without it a request held for a start would
/// sit out the whole budget before failing.

final class ProxyStartExpectationProvider
    extends
        $FunctionalProvider<
          ProxyStartExpectation,
          ProxyStartExpectation,
          ProxyStartExpectation
        >
    with $Provider<ProxyStartExpectation> {
  /// The live [ProxyStartExpectation], assembled from what each backend reports.
  ///
  /// Watched by [containerRoutingSnapshot], so a start that settles — succeeds,
  /// fails, or is abandoned — recomputes the snapshot and pushes it. That push is
  /// what ends the extension's wait: without it a request held for a start would
  /// sit out the whole budget before failing.
  ProxyStartExpectationProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'proxyStartExpectationProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$proxyStartExpectationHash();

  @$internal
  @override
  $ProviderElement<ProxyStartExpectation> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ProxyStartExpectation create(Ref ref) {
    return proxyStartExpectation(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProxyStartExpectation value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProxyStartExpectation>(value),
    );
  }
}

String _$proxyStartExpectationHash() =>
    r'78b92da5a2569d8d93597140ae9bbd3efa525ff0';
