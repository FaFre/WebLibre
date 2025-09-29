// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(bangDatabase)
const bangDatabaseProvider = BangDatabaseProvider._();

final class BangDatabaseProvider
    extends $FunctionalProvider<BangDatabase, BangDatabase, BangDatabase>
    with $Provider<BangDatabase> {
  const BangDatabaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'bangDatabaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$bangDatabaseHash();

  @$internal
  @override
  $ProviderElement<BangDatabase> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  BangDatabase create(Ref ref) {
    return bangDatabase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BangDatabase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BangDatabase>(value),
    );
  }
}

String _$bangDatabaseHash() => r'35142ef6c747e7c65c3417a2b6fc1c6f41d0411b';
