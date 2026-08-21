// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_restart_request.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(restartProfileRequestStream)
final restartProfileRequestStreamProvider =
    RestartProfileRequestStreamProvider._();

final class RestartProfileRequestStreamProvider
    extends
        $FunctionalProvider<
          Raw<Stream<String>>,
          Raw<Stream<String>>,
          Raw<Stream<String>>
        >
    with $Provider<Raw<Stream<String>>> {
  RestartProfileRequestStreamProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'restartProfileRequestStreamProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$restartProfileRequestStreamHash();

  @$internal
  @override
  $ProviderElement<Raw<Stream<String>>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  Raw<Stream<String>> create(Ref ref) {
    return restartProfileRequestStream(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Raw<Stream<String>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Raw<Stream<String>>>(value),
    );
  }
}

String _$restartProfileRequestStreamHash() =>
    r'9ac65324d089abcb860a398e1742cfbea1e81c87';

/// Restarts the app onto the profile a mismatched shortcut belongs to.
///
/// The work happens here rather than in the activity that raised the dialog
/// because this isolate is the one holding the engine, the databases and the
/// Gecko runtime — it is the only place a clean shutdown can happen. The native
/// side has already recorded which launch to replay afterwards.
///
/// Must be watched during app initialization to be active.

@ProviderFor(profileRestartRequestHandler)
final profileRestartRequestHandlerProvider =
    ProfileRestartRequestHandlerProvider._();

/// Restarts the app onto the profile a mismatched shortcut belongs to.
///
/// The work happens here rather than in the activity that raised the dialog
/// because this isolate is the one holding the engine, the databases and the
/// Gecko runtime — it is the only place a clean shutdown can happen. The native
/// side has already recorded which launch to replay afterwards.
///
/// Must be watched during app initialization to be active.

final class ProfileRestartRequestHandlerProvider
    extends $FunctionalProvider<void, void, void>
    with $Provider<void> {
  /// Restarts the app onto the profile a mismatched shortcut belongs to.
  ///
  /// The work happens here rather than in the activity that raised the dialog
  /// because this isolate is the one holding the engine, the databases and the
  /// Gecko runtime — it is the only place a clean shutdown can happen. The native
  /// side has already recorded which launch to replay afterwards.
  ///
  /// Must be watched during app initialization to be active.
  ProfileRestartRequestHandlerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'profileRestartRequestHandlerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$profileRestartRequestHandlerHash();

  @$internal
  @override
  $ProviderElement<void> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  void create(Ref ref) {
    return profileRestartRequestHandler(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$profileRestartRequestHandlerHash() =>
    r'ac400a97bc5cae463e7fe0b308940cbaadf600e0';
