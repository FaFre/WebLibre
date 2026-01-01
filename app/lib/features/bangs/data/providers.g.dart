// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(bangDatabase)
final bangDatabaseProvider = BangDatabaseProvider._();

final class BangDatabaseProvider
    extends $FunctionalProvider<BangDatabase, BangDatabase, BangDatabase>
    with $Provider<BangDatabase> {
  BangDatabaseProvider._()
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

String _$bangDatabaseHash() => r'86fed6bcc4a1e8a0621869c2886b1b80d353f14f';
