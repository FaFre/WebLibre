// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tree_view.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(TreeViewController)
const treeViewControllerProvider = TreeViewControllerProvider._();

final class TreeViewControllerProvider
    extends $NotifierProvider<TreeViewController, bool> {
  const TreeViewControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'treeViewControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$treeViewControllerHash();

  @$internal
  @override
  TreeViewController create() => TreeViewController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$treeViewControllerHash() =>
    r'1fac2a133d369e3bd3f8f75cdd2d0c862a6ab942';

abstract class _$TreeViewController extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
