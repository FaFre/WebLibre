// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'effective_tab_routing.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Whether the proxy extension currently holds an acknowledged routing
/// snapshot. While it does not, it blocks every request.
///
/// There is no push notification for this — readiness can be lost without any
/// app-side input changing (the extension's background script restarts and its
/// replay fails) — so the UI polls for as long as it is displaying the answer.

@ProviderFor(containerRoutingInstalled)
final containerRoutingInstalledProvider = ContainerRoutingInstalledProvider._();

/// Whether the proxy extension currently holds an acknowledged routing
/// snapshot. While it does not, it blocks every request.
///
/// There is no push notification for this — readiness can be lost without any
/// app-side input changing (the extension's background script restarts and its
/// replay fails) — so the UI polls for as long as it is displaying the answer.

final class ContainerRoutingInstalledProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, Stream<bool>>
    with $FutureModifier<bool>, $StreamProvider<bool> {
  /// Whether the proxy extension currently holds an acknowledged routing
  /// snapshot. While it does not, it blocks every request.
  ///
  /// There is no push notification for this — readiness can be lost without any
  /// app-side input changing (the extension's background script restarts and its
  /// replay fails) — so the UI polls for as long as it is displaying the answer.
  ContainerRoutingInstalledProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'containerRoutingInstalledProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$containerRoutingInstalledHash();

  @$internal
  @override
  $StreamProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<bool> create(Ref ref) {
    return containerRoutingInstalled(ref);
  }
}

String _$containerRoutingInstalledHash() =>
    r'10c73afd7bf17bc158ebb7a0e5921f469308563a';

/// How the tab identified by [tabId] is routed right now.
///
/// Reads back the snapshot the extension was given rather than re-deriving
/// routing from settings, so this cannot drift from what the engine actually
/// does. See [resolveTabRouting].

@ProviderFor(effectiveTabRouting)
final effectiveTabRoutingProvider = EffectiveTabRoutingFamily._();

/// How the tab identified by [tabId] is routed right now.
///
/// Reads back the snapshot the extension was given rather than re-deriving
/// routing from settings, so this cannot drift from what the engine actually
/// does. See [resolveTabRouting].

final class EffectiveTabRoutingProvider
    extends $FunctionalProvider<TabRouting, TabRouting, TabRouting>
    with $Provider<TabRouting> {
  /// How the tab identified by [tabId] is routed right now.
  ///
  /// Reads back the snapshot the extension was given rather than re-deriving
  /// routing from settings, so this cannot drift from what the engine actually
  /// does. See [resolveTabRouting].
  EffectiveTabRoutingProvider._({
    required EffectiveTabRoutingFamily super.from,
    required String? super.argument,
  }) : super(
         retry: null,
         name: r'effectiveTabRoutingProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$effectiveTabRoutingHash();

  @override
  String toString() {
    return r'effectiveTabRoutingProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<TabRouting> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  TabRouting create(Ref ref) {
    final argument = this.argument as String?;
    return effectiveTabRouting(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TabRouting value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TabRouting>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is EffectiveTabRoutingProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$effectiveTabRoutingHash() =>
    r'72bde56f573d04cdef5dfea6f4e1280743e047e3';

/// How the tab identified by [tabId] is routed right now.
///
/// Reads back the snapshot the extension was given rather than re-deriving
/// routing from settings, so this cannot drift from what the engine actually
/// does. See [resolveTabRouting].

final class EffectiveTabRoutingFamily extends $Family
    with $FunctionalFamilyOverride<TabRouting, String?> {
  EffectiveTabRoutingFamily._()
    : super(
        retry: null,
        name: r'effectiveTabRoutingProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// How the tab identified by [tabId] is routed right now.
  ///
  /// Reads back the snapshot the extension was given rather than re-deriving
  /// routing from settings, so this cannot drift from what the engine actually
  /// does. See [resolveTabRouting].

  EffectiveTabRoutingProvider call(String? tabId) =>
      EffectiveTabRoutingProvider._(argument: tabId, from: this);

  @override
  String toString() => r'effectiveTabRoutingProvider';
}
