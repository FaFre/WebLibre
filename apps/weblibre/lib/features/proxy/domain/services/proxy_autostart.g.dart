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
///
/// The provider's own state answers the same question for everything that
/// cannot hold a future: the encoded ids startup is still going to bring up,
/// or null while the configuration that decides them has not been read yet.
/// [ProxyStartExpectation] reads it to tell a relation whose backend is still
/// coming up from one whose backend is simply not running, and startup
/// publishes routing long before [run] is even called — so "nothing is known
/// yet" has to be the initial answer, not "nothing is pending".
///
/// Deliberately a set rather than a "startup has finished" flag. The flag made
/// every connection look pending until the slowest start settled, so a
/// container routed through a sing-box profile nobody was starting sat out the
/// extension's whole budget behind an unrelated Tor bootstrap. What ends the
/// unknown state is the *lookups* landing; from then on the answer is per
/// connection.

@ProviderFor(ProxyAutostartService)
final proxyAutostartServiceProvider = ProxyAutostartServiceProvider._();

/// Starts the proxy connections the user flagged for autostart as part of app
/// startup, so tabs bound to them are usable without the "start this proxy?"
/// prompt.
///
/// While a start is in flight [pendingStartFor] hands the caller the running
/// future instead of a "not running" snapshot — the connection is on its way
/// up, so prompting the user for it would be wrong.
///
/// The provider's own state answers the same question for everything that
/// cannot hold a future: the encoded ids startup is still going to bring up,
/// or null while the configuration that decides them has not been read yet.
/// [ProxyStartExpectation] reads it to tell a relation whose backend is still
/// coming up from one whose backend is simply not running, and startup
/// publishes routing long before [run] is even called — so "nothing is known
/// yet" has to be the initial answer, not "nothing is pending".
///
/// Deliberately a set rather than a "startup has finished" flag. The flag made
/// every connection look pending until the slowest start settled, so a
/// container routed through a sing-box profile nobody was starting sat out the
/// extension's whole budget behind an unrelated Tor bootstrap. What ends the
/// unknown state is the *lookups* landing; from then on the answer is per
/// connection.
final class ProxyAutostartServiceProvider
    extends $NotifierProvider<ProxyAutostartService, Set<String>?> {
  /// Starts the proxy connections the user flagged for autostart as part of app
  /// startup, so tabs bound to them are usable without the "start this proxy?"
  /// prompt.
  ///
  /// While a start is in flight [pendingStartFor] hands the caller the running
  /// future instead of a "not running" snapshot — the connection is on its way
  /// up, so prompting the user for it would be wrong.
  ///
  /// The provider's own state answers the same question for everything that
  /// cannot hold a future: the encoded ids startup is still going to bring up,
  /// or null while the configuration that decides them has not been read yet.
  /// [ProxyStartExpectation] reads it to tell a relation whose backend is still
  /// coming up from one whose backend is simply not running, and startup
  /// publishes routing long before [run] is even called — so "nothing is known
  /// yet" has to be the initial answer, not "nothing is pending".
  ///
  /// Deliberately a set rather than a "startup has finished" flag. The flag made
  /// every connection look pending until the slowest start settled, so a
  /// container routed through a sing-box profile nobody was starting sat out the
  /// extension's whole budget behind an unrelated Tor bootstrap. What ends the
  /// unknown state is the *lookups* landing; from then on the answer is per
  /// connection.
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
  Override overrideWithValue(Set<String>? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Set<String>?>(value),
    );
  }
}

String _$proxyAutostartServiceHash() =>
    r'ded87b4c4fd6fc7db99a3ad33eed1c734cb4cef6';

/// Starts the proxy connections the user flagged for autostart as part of app
/// startup, so tabs bound to them are usable without the "start this proxy?"
/// prompt.
///
/// While a start is in flight [pendingStartFor] hands the caller the running
/// future instead of a "not running" snapshot — the connection is on its way
/// up, so prompting the user for it would be wrong.
///
/// The provider's own state answers the same question for everything that
/// cannot hold a future: the encoded ids startup is still going to bring up,
/// or null while the configuration that decides them has not been read yet.
/// [ProxyStartExpectation] reads it to tell a relation whose backend is still
/// coming up from one whose backend is simply not running, and startup
/// publishes routing long before [run] is even called — so "nothing is known
/// yet" has to be the initial answer, not "nothing is pending".
///
/// Deliberately a set rather than a "startup has finished" flag. The flag made
/// every connection look pending until the slowest start settled, so a
/// container routed through a sing-box profile nobody was starting sat out the
/// extension's whole budget behind an unrelated Tor bootstrap. What ends the
/// unknown state is the *lookups* landing; from then on the answer is per
/// connection.

abstract class _$ProxyAutostartService extends $Notifier<Set<String>?> {
  Set<String>? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<Set<String>?, Set<String>?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Set<String>?, Set<String>?>,
              Set<String>?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
