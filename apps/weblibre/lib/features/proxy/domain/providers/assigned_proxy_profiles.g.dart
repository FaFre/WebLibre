// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assigned_proxy_profiles.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Returns sing-box proxy profiles that have at least one routing assignment:
/// global regular-tab routing, private-tab routing, or any container.

@ProviderFor(assignedSingboxProxyProfiles)
final assignedSingboxProxyProfilesProvider =
    AssignedSingboxProxyProfilesProvider._();

/// Returns sing-box proxy profiles that have at least one routing assignment:
/// global regular-tab routing, private-tab routing, or any container.

final class AssignedSingboxProxyProfilesProvider
    extends
        $FunctionalProvider<
          List<ProxyProfile>,
          List<ProxyProfile>,
          List<ProxyProfile>
        >
    with $Provider<List<ProxyProfile>> {
  /// Returns sing-box proxy profiles that have at least one routing assignment:
  /// global regular-tab routing, private-tab routing, or any container.
  AssignedSingboxProxyProfilesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'assignedSingboxProxyProfilesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$assignedSingboxProxyProfilesHash();

  @$internal
  @override
  $ProviderElement<List<ProxyProfile>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  List<ProxyProfile> create(Ref ref) {
    return assignedSingboxProxyProfiles(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<ProxyProfile> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<ProxyProfile>>(value),
    );
  }
}

String _$assignedSingboxProxyProfilesHash() =>
    r'dbc5c429a3b5e4bff902023d363e568c2f955fc4';
