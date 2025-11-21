// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'data.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(BangDataRepository)
const bangDataRepositoryProvider = BangDataRepositoryProvider._();

final class BangDataRepositoryProvider
    extends $NotifierProvider<BangDataRepository, void> {
  const BangDataRepositoryProvider._()
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
    r'0001f3e21fc1bff4fc942e6e468fb580cf2afe4b';

abstract class _$BangDataRepository extends $Notifier<void> {
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
