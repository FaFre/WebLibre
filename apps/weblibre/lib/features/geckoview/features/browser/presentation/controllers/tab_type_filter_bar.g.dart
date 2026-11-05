// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tab_type_filter_bar.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The kinds of tab open right now, as the filters that would list them.

@ProviderFor(openTabTypes)
final openTabTypesProvider = OpenTabTypesProvider._();

/// The kinds of tab open right now, as the filters that would list them.

final class OpenTabTypesProvider
    extends
        $FunctionalProvider<
          EquatableValue<Set<TabTypeFilter>>,
          EquatableValue<Set<TabTypeFilter>>,
          EquatableValue<Set<TabTypeFilter>>
        >
    with $Provider<EquatableValue<Set<TabTypeFilter>>> {
  /// The kinds of tab open right now, as the filters that would list them.
  OpenTabTypesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'openTabTypesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$openTabTypesHash();

  @$internal
  @override
  $ProviderElement<EquatableValue<Set<TabTypeFilter>>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  EquatableValue<Set<TabTypeFilter>> create(Ref ref) {
    return openTabTypes(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(EquatableValue<Set<TabTypeFilter>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<EquatableValue<Set<TabTypeFilter>>>(
        value,
      ),
    );
  }
}

String _$openTabTypesHash() => r'bbc2639f8363c8266172a8070168bdd4b4b2f9ba';

/// Whether the tray's header shows the tab type filter bar.
///
/// Only once there is a choice to make: while tabs of more than one kind are
/// open, or while the filter is set — the filter persists, and must never hide
/// tabs out of sight. Not in the tree view, which ignores the filter, nor for
/// synced tabs, which have no kind.

@ProviderFor(tabTypeFilterBarVisible)
final tabTypeFilterBarVisibleProvider = TabTypeFilterBarVisibleFamily._();

/// Whether the tray's header shows the tab type filter bar.
///
/// Only once there is a choice to make: while tabs of more than one kind are
/// open, or while the filter is set — the filter persists, and must never hide
/// tabs out of sight. Not in the tree view, which ignores the filter, nor for
/// synced tabs, which have no kind.

final class TabTypeFilterBarVisibleProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Whether the tray's header shows the tab type filter bar.
  ///
  /// Only once there is a choice to make: while tabs of more than one kind are
  /// open, or while the filter is set — the filter persists, and must never hide
  /// tabs out of sight. Not in the tree view, which ignores the filter, nor for
  /// synced tabs, which have no kind.
  TabTypeFilterBarVisibleProvider._({
    required TabTypeFilterBarVisibleFamily super.from,
    required TabsViewMode super.argument,
  }) : super(
         retry: null,
         name: r'tabTypeFilterBarVisibleProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$tabTypeFilterBarVisibleHash();

  @override
  String toString() {
    return r'tabTypeFilterBarVisibleProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    final argument = this.argument as TabsViewMode;
    return tabTypeFilterBarVisible(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is TabTypeFilterBarVisibleProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$tabTypeFilterBarVisibleHash() =>
    r'9e0d1d123a6c671648b43c32598d7bf7e1099d70';

/// Whether the tray's header shows the tab type filter bar.
///
/// Only once there is a choice to make: while tabs of more than one kind are
/// open, or while the filter is set — the filter persists, and must never hide
/// tabs out of sight. Not in the tree view, which ignores the filter, nor for
/// synced tabs, which have no kind.

final class TabTypeFilterBarVisibleFamily extends $Family
    with $FunctionalFamilyOverride<bool, TabsViewMode> {
  TabTypeFilterBarVisibleFamily._()
    : super(
        retry: null,
        name: r'tabTypeFilterBarVisibleProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Whether the tray's header shows the tab type filter bar.
  ///
  /// Only once there is a choice to make: while tabs of more than one kind are
  /// open, or while the filter is set — the filter persists, and must never hide
  /// tabs out of sight. Not in the tree view, which ignores the filter, nor for
  /// synced tabs, which have no kind.

  TabTypeFilterBarVisibleProvider call(TabsViewMode tabsViewMode) =>
      TabTypeFilterBarVisibleProvider._(argument: tabsViewMode, from: this);

  @override
  String toString() => r'tabTypeFilterBarVisibleProvider';
}
