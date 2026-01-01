// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'container.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ContainerRepository)
final containerRepositoryProvider = ContainerRepositoryProvider._();

final class ContainerRepositoryProvider
    extends $NotifierProvider<ContainerRepository, void> {
  ContainerRepositoryProvider._()
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
    r'3154277f7a6029d6f5b9fcc62ba057e117248e0c';

abstract class _$ContainerRepository extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<void, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<void, void>,
              void,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
