// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'proxy_settings.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Whether there are connections to come back to: a saved profile, a global
/// route, one running, or Tor set up in any way ([torInUse] — autostart that
/// failed and container or isolated-group routes included). The Proxy
/// category then stays in Settings even while connections are hidden, so the
/// existing ones keep their status, repair and stop controls (P5); the list
/// itself hides adding new ones.

@ProviderFor(connectionsInUse)
final connectionsInUseProvider = ConnectionsInUseProvider._();

/// Whether there are connections to come back to: a saved profile, a global
/// route, one running, or Tor set up in any way ([torInUse] — autostart that
/// failed and container or isolated-group routes included). The Proxy
/// category then stays in Settings even while connections are hidden, so the
/// existing ones keep their status, repair and stop controls (P5); the list
/// itself hides adding new ones.

final class ConnectionsInUseProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Whether there are connections to come back to: a saved profile, a global
  /// route, one running, or Tor set up in any way ([torInUse] — autostart that
  /// failed and container or isolated-group routes included). The Proxy
  /// category then stays in Settings even while connections are hidden, so the
  /// existing ones keep their status, repair and stop controls (P5); the list
  /// itself hides adding new ones.
  ConnectionsInUseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'connectionsInUseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$connectionsInUseHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return connectionsInUse(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$connectionsInUseHash() => r'8eae1c78d8113af39b2253c17a4796c11b426f14';
