// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'container.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ContainerRepository)
const containerRepositoryProvider = ContainerRepositoryProvider._();

final class ContainerRepositoryProvider
    extends $NotifierProvider<ContainerRepository, void> {
  const ContainerRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'containerRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$containerRepositoryHash();

  @$internal
  @override
  ContainerRepository create() => ContainerRepository();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$containerRepositoryHash() =>
    r'6d84d672e24ac3d2cb376e93cbbe61fc223d89b3';

abstract class _$ContainerRepository extends $Notifier<void> {
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
