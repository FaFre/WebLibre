// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tab_view_controllers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(TabSuggestionsController)
final tabSuggestionsControllerProvider = TabSuggestionsControllerProvider._();

final class TabSuggestionsControllerProvider
    extends $NotifierProvider<TabSuggestionsController, bool> {
  TabSuggestionsControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tabSuggestionsControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tabSuggestionsControllerHash();

  @$internal
  @override
  TabSuggestionsController create() => TabSuggestionsController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$tabSuggestionsControllerHash() =>
    r'27a22674f9e4efb01e70120338202e95acef4791';

abstract class _$TabSuggestionsController extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(TabsViewModeController)
final tabsViewModeControllerProvider = TabsViewModeControllerProvider._();

final class TabsViewModeControllerProvider
    extends $NotifierProvider<TabsViewModeController, TabsViewMode> {
  TabsViewModeControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tabsViewModeControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tabsViewModeControllerHash();

  @$internal
  @override
  TabsViewModeController create() => TabsViewModeController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TabsViewMode value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TabsViewMode>(value),
    );
  }
}

String _$tabsViewModeControllerHash() =>
    r'e013b174218fcad81981f7d939cf161c3b002adc';

abstract class _$TabsViewModeController extends $Notifier<TabsViewMode> {
  TabsViewMode build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<TabsViewMode, TabsViewMode>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<TabsViewMode, TabsViewMode>,
              TabsViewMode,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(TabsReorderableController)
final tabsReorderableControllerProvider = TabsReorderableControllerProvider._();

final class TabsReorderableControllerProvider
    extends $NotifierProvider<TabsReorderableController, bool> {
  TabsReorderableControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tabsReorderableControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tabsReorderableControllerHash();

  @$internal
  @override
  TabsReorderableController create() => TabsReorderableController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$tabsReorderableControllerHash() =>
    r'f169e9dc04055ef611f17ebe121f0f51f6a294cb';

abstract class _$TabsReorderableController extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
