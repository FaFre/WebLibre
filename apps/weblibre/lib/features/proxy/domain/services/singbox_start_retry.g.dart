// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'singbox_start_retry.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The pauses before each automatic attempt after a failed one; their count
/// is how many attempts are made.
///
/// Spread out because the failures worth retrying are the ones that clear up
/// on their own — a WireGuard peer that does not resolve while the device has
/// no usable network yet, a server that is briefly down — and the ones that do
/// not should not be hammered.

@ProviderFor(singboxStartRetryDelays)
final singboxStartRetryDelaysProvider = SingboxStartRetryDelaysProvider._();

/// The pauses before each automatic attempt after a failed one; their count
/// is how many attempts are made.
///
/// Spread out because the failures worth retrying are the ones that clear up
/// on their own — a WireGuard peer that does not resolve while the device has
/// no usable network yet, a server that is briefly down — and the ones that do
/// not should not be hammered.

final class SingboxStartRetryDelaysProvider
    extends $FunctionalProvider<List<Duration>, List<Duration>, List<Duration>>
    with $Provider<List<Duration>> {
  /// The pauses before each automatic attempt after a failed one; their count
  /// is how many attempts are made.
  ///
  /// Spread out because the failures worth retrying are the ones that clear up
  /// on their own — a WireGuard peer that does not resolve while the device has
  /// no usable network yet, a server that is briefly down — and the ones that do
  /// not should not be hammered.
  SingboxStartRetryDelaysProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'singboxStartRetryDelaysProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$singboxStartRetryDelaysHash();

  @$internal
  @override
  $ProviderElement<List<Duration>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<Duration> create(Ref ref) {
    return singboxStartRetryDelays(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<Duration> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<Duration>>(value),
    );
  }
}

String _$singboxStartRetryDelaysHash() =>
    r'fd657d917f60094010eacd2c242d259070ff5082';

/// Tries again to start sing-box profiles that failed to start when nobody
/// was there to retry them: those startup brings up, those a Custom Tab or PWA
/// launch asked for, and running ones a failed start took down.
///
/// sing-box resolves a WireGuard peer's hostname exactly once, while it
/// starts, and a start that fails is never attempted again — so a profile that
/// could not come up at a cold start, before the network was usable, stayed
/// down until the user noticed and started it by hand (issue #669). A start
/// the user asked for is not retried here: they are told it failed and decide.
///
/// The state is keyed by profile id and is what the UI shows as "could not
/// start". An entry goes away when its profile runs, however that happened,
/// or when the profile no longer exists.

@ProviderFor(SingboxStartRetries)
final singboxStartRetriesProvider = SingboxStartRetriesProvider._();

/// Tries again to start sing-box profiles that failed to start when nobody
/// was there to retry them: those startup brings up, those a Custom Tab or PWA
/// launch asked for, and running ones a failed start took down.
///
/// sing-box resolves a WireGuard peer's hostname exactly once, while it
/// starts, and a start that fails is never attempted again — so a profile that
/// could not come up at a cold start, before the network was usable, stayed
/// down until the user noticed and started it by hand (issue #669). A start
/// the user asked for is not retried here: they are told it failed and decide.
///
/// The state is keyed by profile id and is what the UI shows as "could not
/// start". An entry goes away when its profile runs, however that happened,
/// or when the profile no longer exists.
final class SingboxStartRetriesProvider
    extends
        $NotifierProvider<SingboxStartRetries, Map<String, SingboxStartRetry>> {
  /// Tries again to start sing-box profiles that failed to start when nobody
  /// was there to retry them: those startup brings up, those a Custom Tab or PWA
  /// launch asked for, and running ones a failed start took down.
  ///
  /// sing-box resolves a WireGuard peer's hostname exactly once, while it
  /// starts, and a start that fails is never attempted again — so a profile that
  /// could not come up at a cold start, before the network was usable, stayed
  /// down until the user noticed and started it by hand (issue #669). A start
  /// the user asked for is not retried here: they are told it failed and decide.
  ///
  /// The state is keyed by profile id and is what the UI shows as "could not
  /// start". An entry goes away when its profile runs, however that happened,
  /// or when the profile no longer exists.
  SingboxStartRetriesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'singboxStartRetriesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$singboxStartRetriesHash();

  @$internal
  @override
  SingboxStartRetries create() => SingboxStartRetries();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<String, SingboxStartRetry> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<String, SingboxStartRetry>>(
        value,
      ),
    );
  }
}

String _$singboxStartRetriesHash() =>
    r'461c28b0fe5e5553d3e3081b3494a6271a64c5de';

/// Tries again to start sing-box profiles that failed to start when nobody
/// was there to retry them: those startup brings up, those a Custom Tab or PWA
/// launch asked for, and running ones a failed start took down.
///
/// sing-box resolves a WireGuard peer's hostname exactly once, while it
/// starts, and a start that fails is never attempted again — so a profile that
/// could not come up at a cold start, before the network was usable, stayed
/// down until the user noticed and started it by hand (issue #669). A start
/// the user asked for is not retried here: they are told it failed and decide.
///
/// The state is keyed by profile id and is what the UI shows as "could not
/// start". An entry goes away when its profile runs, however that happened,
/// or when the profile no longer exists.

abstract class _$SingboxStartRetries
    extends $Notifier<Map<String, SingboxStartRetry>> {
  Map<String, SingboxStartRetry> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<
              Map<String, SingboxStartRetry>,
              Map<String, SingboxStartRetry>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                Map<String, SingboxStartRetry>,
                Map<String, SingboxStartRetry>
              >,
              Map<String, SingboxStartRetry>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
