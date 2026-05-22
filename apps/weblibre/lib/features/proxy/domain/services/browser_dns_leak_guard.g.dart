// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'browser_dns_leak_guard.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Watches the proxy runtime and **disables** GeckoView's TRR (sets
/// [DohSettingsMode.off]) while at least one profile is running.
///
/// Why "off" and not "max": TRR resolves URL hostnames over DoH directly via
/// the system network, *before* any SOCKS connection is established — so a
/// DoH lookup leaks the destination outside the proxy even when the data
/// itself goes through it. `max` (TRR-only) keeps that leak. `off` disables
/// TRR so GeckoView uses its native resolver, which — combined with
/// `proxyDNS: true` on our SOCKS proxy settings — sends hostnames through the
/// SOCKS inbound so sing-box can resolve them instead of GeckoView doing a
/// direct DoH lookup first.
///
/// The previous TRR mode is captured on engage and restored when all
/// profiles stop.
///
/// This is a side-effect-only provider: it must be `keepAlive: true` and is
/// explicitly listened-to from main.dart so the side effect runs without any
/// widget needing to depend on it.

@ProviderFor(BrowserDnsLeakGuard)
final browserDnsLeakGuardProvider = BrowserDnsLeakGuardProvider._();

/// Watches the proxy runtime and **disables** GeckoView's TRR (sets
/// [DohSettingsMode.off]) while at least one profile is running.
///
/// Why "off" and not "max": TRR resolves URL hostnames over DoH directly via
/// the system network, *before* any SOCKS connection is established — so a
/// DoH lookup leaks the destination outside the proxy even when the data
/// itself goes through it. `max` (TRR-only) keeps that leak. `off` disables
/// TRR so GeckoView uses its native resolver, which — combined with
/// `proxyDNS: true` on our SOCKS proxy settings — sends hostnames through the
/// SOCKS inbound so sing-box can resolve them instead of GeckoView doing a
/// direct DoH lookup first.
///
/// The previous TRR mode is captured on engage and restored when all
/// profiles stop.
///
/// This is a side-effect-only provider: it must be `keepAlive: true` and is
/// explicitly listened-to from main.dart so the side effect runs without any
/// widget needing to depend on it.
final class BrowserDnsLeakGuardProvider
    extends $AsyncNotifierProvider<BrowserDnsLeakGuard, void> {
  /// Watches the proxy runtime and **disables** GeckoView's TRR (sets
  /// [DohSettingsMode.off]) while at least one profile is running.
  ///
  /// Why "off" and not "max": TRR resolves URL hostnames over DoH directly via
  /// the system network, *before* any SOCKS connection is established — so a
  /// DoH lookup leaks the destination outside the proxy even when the data
  /// itself goes through it. `max` (TRR-only) keeps that leak. `off` disables
  /// TRR so GeckoView uses its native resolver, which — combined with
  /// `proxyDNS: true` on our SOCKS proxy settings — sends hostnames through the
  /// SOCKS inbound so sing-box can resolve them instead of GeckoView doing a
  /// direct DoH lookup first.
  ///
  /// The previous TRR mode is captured on engage and restored when all
  /// profiles stop.
  ///
  /// This is a side-effect-only provider: it must be `keepAlive: true` and is
  /// explicitly listened-to from main.dart so the side effect runs without any
  /// widget needing to depend on it.
  BrowserDnsLeakGuardProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'browserDnsLeakGuardProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$browserDnsLeakGuardHash();

  @$internal
  @override
  BrowserDnsLeakGuard create() => BrowserDnsLeakGuard();
}

String _$browserDnsLeakGuardHash() =>
    r'366aaa6ae8c163449dca50147be0451c766ba765';

/// Watches the proxy runtime and **disables** GeckoView's TRR (sets
/// [DohSettingsMode.off]) while at least one profile is running.
///
/// Why "off" and not "max": TRR resolves URL hostnames over DoH directly via
/// the system network, *before* any SOCKS connection is established — so a
/// DoH lookup leaks the destination outside the proxy even when the data
/// itself goes through it. `max` (TRR-only) keeps that leak. `off` disables
/// TRR so GeckoView uses its native resolver, which — combined with
/// `proxyDNS: true` on our SOCKS proxy settings — sends hostnames through the
/// SOCKS inbound so sing-box can resolve them instead of GeckoView doing a
/// direct DoH lookup first.
///
/// The previous TRR mode is captured on engage and restored when all
/// profiles stop.
///
/// This is a side-effect-only provider: it must be `keepAlive: true` and is
/// explicitly listened-to from main.dart so the side effect runs without any
/// widget needing to depend on it.

abstract class _$BrowserDnsLeakGuard extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
