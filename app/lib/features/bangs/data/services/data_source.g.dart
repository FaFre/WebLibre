// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'data_source.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(BangDataSourceService)
const bangDataSourceServiceProvider = BangDataSourceServiceProvider._();

final class BangDataSourceServiceProvider
    extends $NotifierProvider<BangDataSourceService, void> {
  const BangDataSourceServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'bangDataSourceServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$bangDataSourceServiceHash();

  @$internal
  @override
  BangDataSourceService create() => BangDataSourceService();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$bangDataSourceServiceHash() =>
    r'2ff811ece417ae498dacc04a2fa963cffb34c8a9';

abstract class _$BangDataSourceService extends $Notifier<void> {
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
