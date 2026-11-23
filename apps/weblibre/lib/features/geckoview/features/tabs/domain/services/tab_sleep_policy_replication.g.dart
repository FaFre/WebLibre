// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tab_sleep_policy_replication.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Builds native's automatic sleep policy (5.9 of the tab lock and freeze
/// plan) from the effective settings, the "Keep awake" tabs (D30) and the
/// containers that freeze automatically (phase C2), and sends it whenever one
/// of them changes. Native keeps it process-wide and evaluates it only while
/// WebLibre is in the foreground.
///
/// Activated from main.dart, at app scope, so it keeps sending while the
/// browser view is gone (the settings screen is where it changes).

@ProviderFor(tabSleepPolicyReplication)
final tabSleepPolicyReplicationProvider = TabSleepPolicyReplicationProvider._();

/// Builds native's automatic sleep policy (5.9 of the tab lock and freeze
/// plan) from the effective settings, the "Keep awake" tabs (D30) and the
/// containers that freeze automatically (phase C2), and sends it whenever one
/// of them changes. Native keeps it process-wide and evaluates it only while
/// WebLibre is in the foreground.
///
/// Activated from main.dart, at app scope, so it keeps sending while the
/// browser view is gone (the settings screen is where it changes).

final class TabSleepPolicyReplicationProvider
    extends $FunctionalProvider<AsyncValue<void>, void, FutureOr<void>>
    with $FutureModifier<void>, $FutureProvider<void> {
  /// Builds native's automatic sleep policy (5.9 of the tab lock and freeze
  /// plan) from the effective settings, the "Keep awake" tabs (D30) and the
  /// containers that freeze automatically (phase C2), and sends it whenever one
  /// of them changes. Native keeps it process-wide and evaluates it only while
  /// WebLibre is in the foreground.
  ///
  /// Activated from main.dart, at app scope, so it keeps sending while the
  /// browser view is gone (the settings screen is where it changes).
  TabSleepPolicyReplicationProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tabSleepPolicyReplicationProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tabSleepPolicyReplicationHash();

  @$internal
  @override
  $FutureProviderElement<void> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<void> create(Ref ref) {
    return tabSleepPolicyReplication(ref);
  }
}

String _$tabSleepPolicyReplicationHash() =>
    r'467e7db4b0b146174fd99b92a4a6020494d8a15f';
