// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(BangSyncRepository)
const bangSyncRepositoryProvider = BangSyncRepositoryProvider._();

final class BangSyncRepositoryProvider
    extends $NotifierProvider<BangSyncRepository, void> {
  const BangSyncRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'bangSyncRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$bangSyncRepositoryHash();

  @$internal
  @override
  BangSyncRepository create() => BangSyncRepository();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$bangSyncRepositoryHash() =>
    r'bb977652087d2ff2cb75b093adcfc45dafa21d2a';

abstract class _$BangSyncRepository extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  void runBuild() {
    build();
    final ref = this.ref as $Ref<void, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<void, void>,
              void,
              Object?,
              Object?
            >;
    element.handleValue(ref, null);
  }
}
