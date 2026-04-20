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

String _$selectedContainerHash() => r'1f0828ce1d3f8b88fd2731a7aae2602a7323092c';

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

/// Whether the browser home screen should be displayed instead of the
/// active tab's content.
///
/// Returns `true` when any of the following hold:
/// 1. No tab is selected at all (app just started or all tabs closed).
/// 2. The selected tab belongs to a different container than the currently
///    selected container – this implies the user manually switched
///    containers after selecting a tab, because tab selection automatically
///    syncs the selected container to match the tab's container.
///
/// Condition (2) also implicitly covers the case where the selected
/// container has zero tabs: if the container has no tabs, the selected tab
/// (if any) necessarily belongs to a different container.

@ProviderFor(shouldShowBrowserHome)
final shouldShowBrowserHomeProvider = ShouldShowBrowserHomeProvider._();

/// Whether the browser home screen should be displayed instead of the
/// active tab's content.
///
/// Returns `true` when any of the following hold:
/// 1. No tab is selected at all (app just started or all tabs closed).
/// 2. The selected tab belongs to a different container than the currently
///    selected container – this implies the user manually switched
///    containers after selecting a tab, because tab selection automatically
///    syncs the selected container to match the tab's container.
///
/// Condition (2) also implicitly covers the case where the selected
/// container has zero tabs: if the container has no tabs, the selected tab
/// (if any) necessarily belongs to a different container.

final class ShouldShowBrowserHomeProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Whether the browser home screen should be displayed instead of the
  /// active tab's content.
  ///
  /// Returns `true` when any of the following hold:
  /// 1. No tab is selected at all (app just started or all tabs closed).
  /// 2. The selected tab belongs to a different container than the currently
  ///    selected container – this implies the user manually switched
  ///    containers after selecting a tab, because tab selection automatically
  ///    syncs the selected container to match the tab's container.
  ///
  /// Condition (2) also implicitly covers the case where the selected
  /// container has zero tabs: if the container has no tabs, the selected tab
  /// (if any) necessarily belongs to a different container.
  ShouldShowBrowserHomeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'shouldShowBrowserHomeProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$shouldShowBrowserHomeHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return shouldShowBrowserHome(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$shouldShowBrowserHomeHash() =>
    r'644344c9abe06e0273dad584e75a53dc417781ad';

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
