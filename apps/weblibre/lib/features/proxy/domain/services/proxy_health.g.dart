// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'proxy_health.dart';

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
/// traffic the user sent anyway, with no probing of its own.
///
/// Evidence is about one run of a tunnel. It is dropped when a (re)start of
/// the proxy begins and again when it ends, when traffic through it gets
/// through — a connection test, or a page load — and as it ages past
/// [proxyFailedLoadWindow].

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
/// traffic the user sent anyway, with no probing of its own.
///
/// Evidence is about one run of a tunnel. It is dropped when a (re)start of
/// the proxy begins and again when it ends, when traffic through it gets
/// through — a connection test, or a page load — and as it ages past
/// [proxyFailedLoadWindow].
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
  /// traffic the user sent anyway, with no probing of its own.
  ///
  /// Evidence is about one run of a tunnel. It is dropped when a (re)start of
  /// the proxy begins and again when it ends, when traffic through it gets
  /// through — a connection test, or a page load — and as it ages past
  /// [proxyFailedLoadWindow].
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
    r'28b42abf425c77d8c82efaf35b1b58ac1fbc405b';

/// Evidence that a proxy which is up is not carrying traffic, keyed by encoded
/// connection id.
///
/// A proxy used to read as connected for as long as its runtime ran, because
/// "running" was all anything knew: a WireGuard tunnel whose peer never
/// answers starts just as successfully as one that works (issue #669). What
/// actually shows a tunnel is down is traffic through it failing, so failed
/// page loads and failed connection tests are collected here — passively, from
/// traffic the user sent anyway, with no probing of its own.
///
/// Evidence is about one run of a tunnel. It is dropped when a (re)start of
/// the proxy begins and again when it ends, when traffic through it gets
/// through — a connection test, or a page load — and as it ages past
/// [proxyFailedLoadWindow].

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
