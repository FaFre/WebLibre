// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'proxy_log_level_applier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Restarts the sing-box runtime when the diagnostic log level changes.
///
/// sing-box takes `log.level` from the config document it is started with, so
/// there is nothing to toggle on a live runtime — the level a user picks while
/// a proxy is up would otherwise apply only after they stopped and started it
/// by hand, which is exactly the moment they are least likely to think of.
///
/// Only a *change* restarts. The first value this sees is whatever was already
/// persisted, and the runtime — if it is even up yet — was started from that
/// same value, so acting on it would be a restart that changes nothing.

@ProviderFor(ProxyLogLevelApplier)
final proxyLogLevelApplierProvider = ProxyLogLevelApplierProvider._();

/// Restarts the sing-box runtime when the diagnostic log level changes.
///
/// sing-box takes `log.level` from the config document it is started with, so
/// there is nothing to toggle on a live runtime — the level a user picks while
/// a proxy is up would otherwise apply only after they stopped and started it
/// by hand, which is exactly the moment they are least likely to think of.
///
/// Only a *change* restarts. The first value this sees is whatever was already
/// persisted, and the runtime — if it is even up yet — was started from that
/// same value, so acting on it would be a restart that changes nothing.
final class ProxyLogLevelApplierProvider
    extends $NotifierProvider<ProxyLogLevelApplier, void> {
  /// Restarts the sing-box runtime when the diagnostic log level changes.
  ///
  /// sing-box takes `log.level` from the config document it is started with, so
  /// there is nothing to toggle on a live runtime — the level a user picks while
  /// a proxy is up would otherwise apply only after they stopped and started it
  /// by hand, which is exactly the moment they are least likely to think of.
  ///
  /// Only a *change* restarts. The first value this sees is whatever was already
  /// persisted, and the runtime — if it is even up yet — was started from that
  /// same value, so acting on it would be a restart that changes nothing.
  ProxyLogLevelApplierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'proxyLogLevelApplierProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$proxyLogLevelApplierHash();

  @$internal
  @override
  ProxyLogLevelApplier create() => ProxyLogLevelApplier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$proxyLogLevelApplierHash() =>
    r'd5113086f6d8980662b90b2ecb7d0bdf602df181';

/// Restarts the sing-box runtime when the diagnostic log level changes.
///
/// sing-box takes `log.level` from the config document it is started with, so
/// there is nothing to toggle on a live runtime — the level a user picks while
/// a proxy is up would otherwise apply only after they stopped and started it
/// by hand, which is exactly the moment they are least likely to think of.
///
/// Only a *change* restarts. The first value this sees is whatever was already
/// persisted, and the runtime — if it is even up yet — was started from that
/// same value, so acting on it would be a restart that changes nothing.

abstract class _$ProxyLogLevelApplier extends $Notifier<void> {
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
