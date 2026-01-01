// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'selected_container.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SelectedContainer)
final selectedContainerProvider = SelectedContainerProvider._();

final class SelectedContainerProvider
    extends $NotifierProvider<SelectedContainer, String?> {
  SelectedContainerProvider._()
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

String _$selectedContainerHash() => r'e1d20f0c2e7764e82937ba486de52c92184c0e4a';

abstract class _$SelectedContainer extends $Notifier<String?> {
  String? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<String?, String?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String?, String?>,
              String?,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(selectedContainerData)
final selectedContainerDataProvider = SelectedContainerDataProvider._();

final class SelectedContainerDataProvider
    extends
        $FunctionalProvider<
          AsyncValue<ContainerData?>,
          ContainerData?,
          Stream<ContainerData?>
        >
    with $FutureModifier<ContainerData?>, $StreamProvider<ContainerData?> {
  SelectedContainerDataProvider._()
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
final selectedContainerTabCountProvider = SelectedContainerTabCountProvider._();

final class SelectedContainerTabCountProvider
    extends $FunctionalProvider<AsyncValue<int>, int, FutureOr<int>>
    with $FutureModifier<int>, $FutureProvider<int> {
  SelectedContainerTabCountProvider._()
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
  $FutureProviderElement<int> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<int> create(Ref ref) {
    return selectedContainerTabCount(ref);
  }
}

String _$selectedContainerTabCountHash() =>
    r'b763f949210ac9106d4a9240c0e65bdfae2d18ec';
