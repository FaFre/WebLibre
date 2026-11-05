// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'proxy_health.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ProxyTrafficEvidenceCWProxy {
  ProxyTrafficEvidence failedLoads(List<ProxyFailedLoad> failedLoads);

  ProxyTrafficEvidence testFailed(bool testFailed);

  ProxyTrafficEvidence peerUnanswered(bool peerUnanswered);

  /// Creates a new instance with the provided field values.
  /// Omitted fields keep their values; explicit `null` clears nullable fields.
  /// The public API rejects `null` for non-nullable fields. To update a single field use `ProxyTrafficEvidence(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// ProxyTrafficEvidence(...).copyWith(id: 12, name: "My name")
  /// ```
  ProxyTrafficEvidence call({
    List<ProxyFailedLoad> failedLoads,
    bool testFailed,
    bool peerUnanswered,
  });
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfProxyTrafficEvidence.copyWith(...)` or call `instanceOfProxyTrafficEvidence.copyWith.fieldName(value)` for a single field.
class _$ProxyTrafficEvidenceCWProxyImpl
    implements _$ProxyTrafficEvidenceCWProxy {
  const _$ProxyTrafficEvidenceCWProxyImpl(this._value);

  final ProxyTrafficEvidence _value;

  @override
  ProxyTrafficEvidence failedLoads(List<ProxyFailedLoad> failedLoads) =>
      call(failedLoads: failedLoads);

  @override
  ProxyTrafficEvidence testFailed(bool testFailed) =>
      call(testFailed: testFailed);

  @override
  ProxyTrafficEvidence peerUnanswered(bool peerUnanswered) =>
      call(peerUnanswered: peerUnanswered);

  /// Creates a new instance with the provided field values.
  /// Omitted fields keep their values; explicit `null` clears nullable fields.
  /// The public API rejects `null` for non-nullable fields. To update a single field use `ProxyTrafficEvidence(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// ProxyTrafficEvidence(...).copyWith(id: 12, name: "My name")
  /// ```
  @override
  ProxyTrafficEvidence call({
    Object? failedLoads = const $CopyWithPlaceholder(),
    Object? testFailed = const $CopyWithPlaceholder(),
    Object? peerUnanswered = const $CopyWithPlaceholder(),
  }) {
    return ProxyTrafficEvidence(
      failedLoads:
          failedLoads == const $CopyWithPlaceholder() || failedLoads == null
          ? _value.failedLoads
          // ignore: cast_nullable_to_non_nullable
          : failedLoads as List<ProxyFailedLoad>,
      testFailed:
          testFailed == const $CopyWithPlaceholder() || testFailed == null
          ? _value.testFailed
          // ignore: cast_nullable_to_non_nullable
          : testFailed as bool,
      peerUnanswered:
          peerUnanswered == const $CopyWithPlaceholder() ||
              peerUnanswered == null
          ? _value.peerUnanswered
          // ignore: cast_nullable_to_non_nullable
          : peerUnanswered as bool,
    );
  }
}

extension $ProxyTrafficEvidenceCopyWith on ProxyTrafficEvidence {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfProxyTrafficEvidence.copyWith(...)` or `instanceOfProxyTrafficEvidence.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ProxyTrafficEvidenceCWProxy get copyWith =>
      _$ProxyTrafficEvidenceCWProxyImpl(this);
}

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Evidence that a proxy which is up is not carrying traffic, keyed by encoded
/// connection id.
///
/// A proxy used to read as connected for as long as its runtime ran, because
/// "running" was all anything knew: a WireGuard tunnel whose peer never
/// answers starts just as successfully as one that works (issue #669). What
/// actually shows a tunnel is down is traffic through it failing, so failed
/// page loads and failed connection tests are collected here — passively, from
/// traffic the user sent anyway, with no probing of its own. So is what the
/// runtime reports of a WireGuard tunnel's handshakes, which go unanswered
/// before any load has had the time to fail (issue #693).
///
/// Evidence is about one run of a tunnel. It is dropped when a (re)start of
/// the proxy begins and again when it ends, when traffic through it gets
/// through — a connection test, or a page load — and as it ages past
/// [proxyFailedLoadWindow]. What the runtime says of handshakes is the
/// runtime's alone to change: it mirrors the runtime's latest
/// [SingboxProxyTunnelState].

@ProviderFor(ProxyTrafficHealth)
final proxyTrafficHealthProvider = ProxyTrafficHealthProvider._();

/// Evidence that a proxy which is up is not carrying traffic, keyed by encoded
/// connection id.
///
/// A proxy used to read as connected for as long as its runtime ran, because
/// "running" was all anything knew: a WireGuard tunnel whose peer never
/// answers starts just as successfully as one that works (issue #669). What
/// actually shows a tunnel is down is traffic through it failing, so failed
/// page loads and failed connection tests are collected here — passively, from
/// traffic the user sent anyway, with no probing of its own. So is what the
/// runtime reports of a WireGuard tunnel's handshakes, which go unanswered
/// before any load has had the time to fail (issue #693).
///
/// Evidence is about one run of a tunnel. It is dropped when a (re)start of
/// the proxy begins and again when it ends, when traffic through it gets
/// through — a connection test, or a page load — and as it ages past
/// [proxyFailedLoadWindow]. What the runtime says of handshakes is the
/// runtime's alone to change: it mirrors the runtime's latest
/// [SingboxProxyTunnelState].
final class ProxyTrafficHealthProvider
    extends
        $NotifierProvider<
          ProxyTrafficHealth,
          Map<String, ProxyTrafficEvidence>
        > {
  /// Evidence that a proxy which is up is not carrying traffic, keyed by encoded
  /// connection id.
  ///
  /// A proxy used to read as connected for as long as its runtime ran, because
  /// "running" was all anything knew: a WireGuard tunnel whose peer never
  /// answers starts just as successfully as one that works (issue #669). What
  /// actually shows a tunnel is down is traffic through it failing, so failed
  /// page loads and failed connection tests are collected here — passively, from
  /// traffic the user sent anyway, with no probing of its own. So is what the
  /// runtime reports of a WireGuard tunnel's handshakes, which go unanswered
  /// before any load has had the time to fail (issue #693).
  ///
  /// Evidence is about one run of a tunnel. It is dropped when a (re)start of
  /// the proxy begins and again when it ends, when traffic through it gets
  /// through — a connection test, or a page load — and as it ages past
  /// [proxyFailedLoadWindow]. What the runtime says of handshakes is the
  /// runtime's alone to change: it mirrors the runtime's latest
  /// [SingboxProxyTunnelState].
  ProxyTrafficHealthProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'proxyTrafficHealthProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$proxyTrafficHealthHash();

  @$internal
  @override
  ProxyTrafficHealth create() => ProxyTrafficHealth();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<String, ProxyTrafficEvidence> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<String, ProxyTrafficEvidence>>(
        value,
      ),
    );
  }
}

String _$proxyTrafficHealthHash() =>
    r'f8dc1c86db02eeb6295e5e3d6f7edeb30b89a94e';

/// Evidence that a proxy which is up is not carrying traffic, keyed by encoded
/// connection id.
///
/// A proxy used to read as connected for as long as its runtime ran, because
/// "running" was all anything knew: a WireGuard tunnel whose peer never
/// answers starts just as successfully as one that works (issue #669). What
/// actually shows a tunnel is down is traffic through it failing, so failed
/// page loads and failed connection tests are collected here — passively, from
/// traffic the user sent anyway, with no probing of its own. So is what the
/// runtime reports of a WireGuard tunnel's handshakes, which go unanswered
/// before any load has had the time to fail (issue #693).
///
/// Evidence is about one run of a tunnel. It is dropped when a (re)start of
/// the proxy begins and again when it ends, when traffic through it gets
/// through — a connection test, or a page load — and as it ages past
/// [proxyFailedLoadWindow]. What the runtime says of handshakes is the
/// runtime's alone to change: it mirrors the runtime's latest
/// [SingboxProxyTunnelState].

abstract class _$ProxyTrafficHealth
    extends $Notifier<Map<String, ProxyTrafficEvidence>> {
  Map<String, ProxyTrafficEvidence> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<
              Map<String, ProxyTrafficEvidence>,
              Map<String, ProxyTrafficEvidence>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                Map<String, ProxyTrafficEvidence>,
                Map<String, ProxyTrafficEvidence>
              >,
              Map<String, ProxyTrafficEvidence>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// The [ProxyConnectionCondition] for [connectionId], or null when there is
/// nothing to say beyond on or off.

@ProviderFor(proxyConnectionCondition)
final proxyConnectionConditionProvider = ProxyConnectionConditionFamily._();

/// The [ProxyConnectionCondition] for [connectionId], or null when there is
/// nothing to say beyond on or off.

final class ProxyConnectionConditionProvider
    extends
        $FunctionalProvider<
          ProxyConnectionCondition?,
          ProxyConnectionCondition?,
          ProxyConnectionCondition?
        >
    with $Provider<ProxyConnectionCondition?> {
  /// The [ProxyConnectionCondition] for [connectionId], or null when there is
  /// nothing to say beyond on or off.
  ProxyConnectionConditionProvider._({
    required ProxyConnectionConditionFamily super.from,
    required ProxyConnectionId super.argument,
  }) : super(
         retry: null,
         name: r'proxyConnectionConditionProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$proxyConnectionConditionHash();

  @override
  String toString() {
    return r'proxyConnectionConditionProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<ProxyConnectionCondition?> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ProxyConnectionCondition? create(Ref ref) {
    final argument = this.argument as ProxyConnectionId;
    return proxyConnectionCondition(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProxyConnectionCondition? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProxyConnectionCondition?>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ProxyConnectionConditionProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$proxyConnectionConditionHash() =>
    r'dd2a311b82e41a1389a49da49e326e394cdc485d';

/// The [ProxyConnectionCondition] for [connectionId], or null when there is
/// nothing to say beyond on or off.

final class ProxyConnectionConditionFamily extends $Family
    with
        $FunctionalFamilyOverride<
          ProxyConnectionCondition?,
          ProxyConnectionId
        > {
  ProxyConnectionConditionFamily._()
    : super(
        retry: null,
        name: r'proxyConnectionConditionProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The [ProxyConnectionCondition] for [connectionId], or null when there is
  /// nothing to say beyond on or off.

  ProxyConnectionConditionProvider call(ProxyConnectionId connectionId) =>
      ProxyConnectionConditionProvider._(argument: connectionId, from: this);

  @override
  String toString() => r'proxyConnectionConditionProvider';
}
