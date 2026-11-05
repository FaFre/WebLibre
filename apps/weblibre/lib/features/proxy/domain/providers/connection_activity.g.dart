// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'connection_activity.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Whether any connection is up or on its way up: Tor, or a sing-box
/// profile.
///
/// A running connection keeps its status and its stop control on screen
/// whatever the Connections switch says, and whichever tab is selected.

@ProviderFor(anyConnectionActive)
final anyConnectionActiveProvider = AnyConnectionActiveProvider._();

/// Whether any connection is up or on its way up: Tor, or a sing-box
/// profile.
///
/// A running connection keeps its status and its stop control on screen
/// whatever the Connections switch says, and whichever tab is selected.

final class AnyConnectionActiveProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Whether any connection is up or on its way up: Tor, or a sing-box
  /// profile.
  ///
  /// A running connection keeps its status and its stop control on screen
  /// whatever the Connections switch says, and whichever tab is selected.
  AnyConnectionActiveProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'anyConnectionActiveProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$anyConnectionActiveHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return anyConnectionActive(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$anyConnectionActiveHash() =>
    r'626ae1ede96652b4c5a3312f9e79509854bfe309';

/// Whether Tor is part of the user's setup, so its status and controls stay
/// on screen while Connections is hidden (P5): running or on its way up, set
/// to start automatically — which may have failed, leaving it stopped —
/// configured away from the defaults, or named by any route (global, private
/// tabs, a container, an isolated group).
///
/// One rule for every place that lists Tor: the browser menu's Connection
/// section, the connection list, and whether Settings keeps its Proxy
/// category.

@ProviderFor(torInUse)
final torInUseProvider = TorInUseProvider._();

/// Whether Tor is part of the user's setup, so its status and controls stay
/// on screen while Connections is hidden (P5): running or on its way up, set
/// to start automatically — which may have failed, leaving it stopped —
/// configured away from the defaults, or named by any route (global, private
/// tabs, a container, an isolated group).
///
/// One rule for every place that lists Tor: the browser menu's Connection
/// section, the connection list, and whether Settings keeps its Proxy
/// category.

final class TorInUseProvider extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Whether Tor is part of the user's setup, so its status and controls stay
  /// on screen while Connections is hidden (P5): running or on its way up, set
  /// to start automatically — which may have failed, leaving it stopped —
  /// configured away from the defaults, or named by any route (global, private
  /// tabs, a container, an isolated group).
  ///
  /// One rule for every place that lists Tor: the browser menu's Connection
  /// section, the connection list, and whether Settings keeps its Proxy
  /// category.
  TorInUseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'torInUseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$torInUseHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return torInUse(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$torInUseHash() => r'0c9c00596a8f515b780981778f3f8399680dd91a';
