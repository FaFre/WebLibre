// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'proxy_pref_baseline.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Keeps the fail-closed proxy prefs in sync with whether routing needs them.

@ProviderFor(ProxyPrefBaseline)
final proxyPrefBaselineProvider = ProxyPrefBaselineProvider._();

/// Keeps the fail-closed proxy prefs in sync with whether routing needs them.
final class ProxyPrefBaselineProvider
    extends $NotifierProvider<ProxyPrefBaseline, void> {
  /// Keeps the fail-closed proxy prefs in sync with whether routing needs them.
  ProxyPrefBaselineProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'proxyPrefBaselineProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$proxyPrefBaselineHash();

  @$internal
  @override
  ProxyPrefBaseline create() => ProxyPrefBaseline();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$proxyPrefBaselineHash() => r'4ef527c07ff6a07f8ba2b651acfe2ced839cf668';

/// Keeps the fail-closed proxy prefs in sync with whether routing needs them.

abstract class _$ProxyPrefBaseline extends $Notifier<void> {
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
