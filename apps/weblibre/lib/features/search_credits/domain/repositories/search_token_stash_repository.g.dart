// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_token_stash_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Read-only-shaped stash for the search session: only reserve / commit /
/// release / count / take / clear are safe to call. The issuance controller
/// constructs its own stash with the freshly-fetched `key.version` before
/// calling `stash.add` so token rows are tagged with the exact key the
/// issuer signed against — see [searchTokenIssuanceControllerProvider].

@ProviderFor(searchTokenStash)
final searchTokenStashProvider = SearchTokenStashProvider._();

/// Read-only-shaped stash for the search session: only reserve / commit /
/// release / count / take / clear are safe to call. The issuance controller
/// constructs its own stash with the freshly-fetched `key.version` before
/// calling `stash.add` so token rows are tagged with the exact key the
/// issuer signed against — see [searchTokenIssuanceControllerProvider].

final class SearchTokenStashProvider
    extends
        $FunctionalProvider<DriftTokenStash, DriftTokenStash, DriftTokenStash>
    with $Provider<DriftTokenStash> {
  /// Read-only-shaped stash for the search session: only reserve / commit /
  /// release / count / take / clear are safe to call. The issuance controller
  /// constructs its own stash with the freshly-fetched `key.version` before
  /// calling `stash.add` so token rows are tagged with the exact key the
  /// issuer signed against — see [searchTokenIssuanceControllerProvider].
  SearchTokenStashProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'searchTokenStashProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$searchTokenStashHash();

  @$internal
  @override
  $ProviderElement<DriftTokenStash> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DriftTokenStash create(Ref ref) {
    return searchTokenStash(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DriftTokenStash value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DriftTokenStash>(value),
    );
  }
}

String _$searchTokenStashHash() => r'e761b254b778f7c4cc7475e0034aa7bec8e126de';

@ProviderFor(searchTokenStashCount)
final searchTokenStashCountProvider = SearchTokenStashCountProvider._();

final class SearchTokenStashCountProvider
    extends $FunctionalProvider<AsyncValue<int>, int, Stream<int>>
    with $FutureModifier<int>, $StreamProvider<int> {
  SearchTokenStashCountProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'searchTokenStashCountProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$searchTokenStashCountHash();

  @$internal
  @override
  $StreamProviderElement<int> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<int> create(Ref ref) {
    return searchTokenStashCount(ref);
  }
}

String _$searchTokenStashCountHash() =>
    r'0cef046aad0dc7e0a6e0f717fe1896f8f546d852';
