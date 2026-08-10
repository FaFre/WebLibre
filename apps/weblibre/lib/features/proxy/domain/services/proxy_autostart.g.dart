// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'proxy_autostart.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Starts the proxy connections the user flagged for autostart as part of app
/// startup, so tabs bound to them are usable without the "start this proxy?"
/// prompt.
///
/// While a start is in flight [pendingStartFor] hands the caller the running
/// future instead of a "not running" snapshot — the connection is on its way
/// up, so prompting the user for it would be wrong.

@ProviderFor(ProxyAutostartService)
final proxyAutostartServiceProvider = ProxyAutostartServiceProvider._();

/// Starts the proxy connections the user flagged for autostart as part of app
/// startup, so tabs bound to them are usable without the "start this proxy?"
/// prompt.
///
/// While a start is in flight [pendingStartFor] hands the caller the running
/// future instead of a "not running" snapshot — the connection is on its way
/// up, so prompting the user for it would be wrong.
final class ProxyAutostartServiceProvider
    extends $NotifierProvider<ProxyAutostartService, void> {
  /// Starts the proxy connections the user flagged for autostart as part of app
  /// startup, so tabs bound to them are usable without the "start this proxy?"
  /// prompt.
  ///
  /// While a start is in flight [pendingStartFor] hands the caller the running
  /// future instead of a "not running" snapshot — the connection is on its way
  /// up, so prompting the user for it would be wrong.
  ProxyAutostartServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'proxyAutostartServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$proxyAutostartServiceHash();

  @$internal
  @override
  ProxyAutostartService create() => ProxyAutostartService();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$proxyAutostartServiceHash() =>
    r'9ca8b8b56b3edf36fec5860138bb0f77ec7c343c';

/// Starts the proxy connections the user flagged for autostart as part of app
/// startup, so tabs bound to them are usable without the "start this proxy?"
/// prompt.
///
/// While a start is in flight [pendingStartFor] hands the caller the running
/// future instead of a "not running" snapshot — the connection is on its way
/// up, so prompting the user for it would be wrong.

abstract class _$ProxyAutostartService extends $Notifier<void> {
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
