// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(searchBackendEndpoints)
final searchBackendEndpointsProvider = SearchBackendEndpointsProvider._();

final class SearchBackendEndpointsProvider
    extends
        $FunctionalProvider<
          BackendEndpoints,
          BackendEndpoints,
          BackendEndpoints
        >
    with $Provider<BackendEndpoints> {
  SearchBackendEndpointsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'searchBackendEndpointsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$searchBackendEndpointsHash();

  @$internal
  @override
  $ProviderElement<BackendEndpoints> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  BackendEndpoints create(Ref ref) {
    return searchBackendEndpoints(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BackendEndpoints value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BackendEndpoints>(value),
    );
  }
}

String _$searchBackendEndpointsHash() =>
    r'e2f367530cac69a2833b75520d1ac66605822f80';

@ProviderFor(searchClientLogger)
final searchClientLoggerProvider = SearchClientLoggerProvider._();

final class SearchClientLoggerProvider
    extends $FunctionalProvider<Logger, Logger, Logger>
    with $Provider<Logger> {
  SearchClientLoggerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'searchClientLoggerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$searchClientLoggerHash();

  @$internal
  @override
  $ProviderElement<Logger> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Logger create(Ref ref) {
    return searchClientLogger(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Logger value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Logger>(value),
    );
  }
}

String _$searchClientLoggerHash() =>
    r'58d85a104431de5005a3fd7521afbbbd7a8672f2';

@ProviderFor(issuanceClient)
final issuanceClientProvider = IssuanceClientProvider._();

final class IssuanceClientProvider
    extends $FunctionalProvider<IssuanceClient, IssuanceClient, IssuanceClient>
    with $Provider<IssuanceClient> {
  IssuanceClientProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'issuanceClientProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$issuanceClientHash();

  @$internal
  @override
  $ProviderElement<IssuanceClient> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  IssuanceClient create(Ref ref) {
    return issuanceClient(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(IssuanceClient value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<IssuanceClient>(value),
    );
  }
}

String _$issuanceClientHash() => r'4ef1f8f5a062ffa0f0f0fa3ebfa70c09efac778f';
