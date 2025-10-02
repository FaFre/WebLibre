// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'selected_container.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SelectedContainer)
const selectedContainerProvider = SelectedContainerProvider._();

final class SelectedContainerProvider
    extends $NotifierProvider<SelectedContainer, String?> {
  const SelectedContainerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectedContainerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectedContainerHash();

  @$internal
  @override
  SelectedContainer create() => SelectedContainer();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$selectedContainerHash() => r'4754aa8ad9b43b022821a41771eb5af5e33b1cb6';

abstract class _$SelectedContainer extends $Notifier<String?> {
  String? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<String?, String?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String?, String?>,
              String?,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(selectedContainerData)
const selectedContainerDataProvider = SelectedContainerDataProvider._();

final class SelectedContainerDataProvider
    extends
        $FunctionalProvider<
          AsyncValue<ContainerData?>,
          ContainerData?,
          Stream<ContainerData?>
        >
    with $FutureModifier<ContainerData?>, $StreamProvider<ContainerData?> {
  const SelectedContainerDataProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectedContainerDataProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectedContainerDataHash();

  @$internal
  @override
  $StreamProviderElement<ContainerData?> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<ContainerData?> create(Ref ref) {
    return selectedContainerData(ref);
  }
}

String _$selectedContainerDataHash() =>
    r'1ec86a82e1fc4823a867285f05036c903633a165';

@ProviderFor(selectedContainerTabCount)
const selectedContainerTabCountProvider = SelectedContainerTabCountProvider._();

final class SelectedContainerTabCountProvider
    extends
        $FunctionalProvider<AsyncValue<int>, AsyncValue<int>, AsyncValue<int>>
    with $Provider<AsyncValue<int>> {
  const SelectedContainerTabCountProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectedContainerTabCountProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectedContainerTabCountHash();

  @$internal
  @override
  $ProviderElement<AsyncValue<int>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AsyncValue<int> create(Ref ref) {
    return selectedContainerTabCount(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<int> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<int>>(value),
    );
  }
}

String _$selectedContainerTabCountHash() =>
    r'0fd457793f7870050f81c54d2fbcc81aca60f394';
