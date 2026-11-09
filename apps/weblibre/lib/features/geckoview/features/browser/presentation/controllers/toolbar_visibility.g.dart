// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'toolbar_visibility.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Per tab, except that the two tabs of a shown split pair share one state:
/// the bars belong to the pair, so focus moving between the panes must not
/// move them and resize both pages. Dismissing applies to the pair. Scroll
/// auto-hide is off while both pages are shown: it would resize both, and
/// could flip the layout between side by side and stacked. With "Show only
/// this page" chosen it works as for a single tab.

@ProviderFor(ToolbarVisibilityController)
final toolbarVisibilityControllerProvider =
    ToolbarVisibilityControllerFamily._();

/// Per tab, except that the two tabs of a shown split pair share one state:
/// the bars belong to the pair, so focus moving between the panes must not
/// move them and resize both pages. Dismissing applies to the pair. Scroll
/// auto-hide is off while both pages are shown: it would resize both, and
/// could flip the layout between side by side and stacked. With "Show only
/// this page" chosen it works as for a single tab.
final class ToolbarVisibilityControllerProvider
    extends $NotifierProvider<ToolbarVisibilityController, ToolbarVisibility> {
  /// Per tab, except that the two tabs of a shown split pair share one state:
  /// the bars belong to the pair, so focus moving between the panes must not
  /// move them and resize both pages. Dismissing applies to the pair. Scroll
  /// auto-hide is off while both pages are shown: it would resize both, and
  /// could flip the layout between side by side and stacked. With "Show only
  /// this page" chosen it works as for a single tab.
  ToolbarVisibilityControllerProvider._({
    required ToolbarVisibilityControllerFamily super.from,
    required String? super.argument,
  }) : super(
         retry: null,
         name: r'toolbarVisibilityControllerProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$toolbarVisibilityControllerHash();

  @override
  String toString() {
    return r'toolbarVisibilityControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ToolbarVisibilityController create() => ToolbarVisibilityController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ToolbarVisibility value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ToolbarVisibility>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ToolbarVisibilityControllerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$toolbarVisibilityControllerHash() =>
    r'64e8043a2994ddb5636c9ea5285d2bdcfd6d93f2';

/// Per tab, except that the two tabs of a shown split pair share one state:
/// the bars belong to the pair, so focus moving between the panes must not
/// move them and resize both pages. Dismissing applies to the pair. Scroll
/// auto-hide is off while both pages are shown: it would resize both, and
/// could flip the layout between side by side and stacked. With "Show only
/// this page" chosen it works as for a single tab.

final class ToolbarVisibilityControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          ToolbarVisibilityController,
          ToolbarVisibility,
          ToolbarVisibility,
          ToolbarVisibility,
          String?
        > {
  ToolbarVisibilityControllerFamily._()
    : super(
        retry: null,
        name: r'toolbarVisibilityControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  /// Per tab, except that the two tabs of a shown split pair share one state:
  /// the bars belong to the pair, so focus moving between the panes must not
  /// move them and resize both pages. Dismissing applies to the pair. Scroll
  /// auto-hide is off while both pages are shown: it would resize both, and
  /// could flip the layout between side by side and stacked. With "Show only
  /// this page" chosen it works as for a single tab.

  ToolbarVisibilityControllerProvider call(String? tabId) =>
      ToolbarVisibilityControllerProvider._(argument: tabId, from: this);

  @override
  String toString() => r'toolbarVisibilityControllerProvider';
}

/// Per tab, except that the two tabs of a shown split pair share one state:
/// the bars belong to the pair, so focus moving between the panes must not
/// move them and resize both pages. Dismissing applies to the pair. Scroll
/// auto-hide is off while both pages are shown: it would resize both, and
/// could flip the layout between side by side and stacked. With "Show only
/// this page" chosen it works as for a single tab.

abstract class _$ToolbarVisibilityController
    extends $Notifier<ToolbarVisibility> {
  late final _$args = ref.$arg as String?;
  String? get tabId => _$args;

  ToolbarVisibility build(String? tabId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<ToolbarVisibility, ToolbarVisibility>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ToolbarVisibility, ToolbarVisibility>,
              ToolbarVisibility,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
