// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pending_writes.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(pendingWrites)
final pendingWritesProvider = PendingWritesProvider._();

final class PendingWritesProvider
    extends $FunctionalProvider<PendingWrites, PendingWrites, PendingWrites>
    with $Provider<PendingWrites> {
  PendingWritesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pendingWritesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pendingWritesHash();

  @$internal
  @override
  $ProviderElement<PendingWrites> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  PendingWrites create(Ref ref) {
    return pendingWrites(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PendingWrites value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PendingWrites>(value),
    );
  }
}

String _$pendingWritesHash() => r'0a220631fc14222345d50d3243929197f56c92ec';
