// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tab_bar_dismissable.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(TabBarDismissableController)
final tabBarDismissableControllerProvider =
    TabBarDismissableControllerProvider._();

final class TabBarDismissableControllerProvider
    extends $NotifierProvider<TabBarDismissableController, bool> {
  TabBarDismissableControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tabBarDismissableControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tabBarDismissableControllerHash();

  @$internal
  @override
  TabBarDismissableController create() => TabBarDismissableController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$tabBarDismissableControllerHash() =>
    r'e0c2f700ccebc35bc8029370cdebd63e98bf95e1';

abstract class _$TabBarDismissableController extends $Notifier<bool> {
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
