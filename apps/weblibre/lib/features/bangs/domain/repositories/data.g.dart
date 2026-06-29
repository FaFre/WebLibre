// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'data.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(BangDataRepository)
final bangDataRepositoryProvider = BangDataRepositoryProvider._();

final class BangDataRepositoryProvider
    extends $NotifierProvider<BangDataRepository, void> {
  BangDataRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'bangDataRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$bangDataRepositoryHash();

  @$internal
  @override
  BangDataRepository create() => BangDataRepository();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$bangDataRepositoryHash() =>
    r'2b964de957cb9474f29a3d4d1b05a29562700030';

abstract class _$BangDataRepository extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<void, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<void, void>,
              void,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
