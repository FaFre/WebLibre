// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tab_tray_rows.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Whether the tab tray is showing search results.

@ProviderFor(tabTraySearchActive)
final tabTraySearchActiveProvider = TabTraySearchActiveProvider._();

/// Whether the tab tray is showing search results.

final class TabTraySearchActiveProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Whether the tab tray is showing search results.
  TabTraySearchActiveProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tabTraySearchActiveProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tabTraySearchActiveHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return tabTraySearchActive(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$tabTraySearchActiveHash() =>
    r'5088d2eadd8c96bc609b804760f330870b844f5e';

/// The rows the tab tray's list and grid draw for [containerId]: the flat
/// search results while a search is active, otherwise the tray's grouped
/// tab list. Only the source in use is watched.

@ProviderFor(tabTrayRows)
final tabTrayRowsProvider = TabTrayRowsFamily._();

/// The rows the tab tray's list and grid draw for [containerId]: the flat
/// search results while a search is active, otherwise the tray's grouped
/// tab list. Only the source in use is watched.

final class TabTrayRowsProvider
    extends
        $FunctionalProvider<
          List<TabViewItem>,
          List<TabViewItem>,
          List<TabViewItem>
        >
    with $Provider<List<TabViewItem>> {
  /// The rows the tab tray's list and grid draw for [containerId]: the flat
  /// search results while a search is active, otherwise the tray's grouped
  /// tab list. Only the source in use is watched.
  TabTrayRowsProvider._({
    required TabTrayRowsFamily super.from,
    required String? super.argument,
  }) : super(
         retry: null,
         name: r'tabTrayRowsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$tabTrayRowsHash();

  @override
  String toString() {
    return r'tabTrayRowsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<List<TabViewItem>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  List<TabViewItem> create(Ref ref) {
    final argument = this.argument as String?;
    return tabTrayRows(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<TabViewItem> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<TabViewItem>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is TabTrayRowsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$tabTrayRowsHash() => r'8174849611e191b2f0b418f559322cc06079e7fe';

/// The rows the tab tray's list and grid draw for [containerId]: the flat
/// search results while a search is active, otherwise the tray's grouped
/// tab list. Only the source in use is watched.

final class TabTrayRowsFamily extends $Family
    with $FunctionalFamilyOverride<List<TabViewItem>, String?> {
  TabTrayRowsFamily._()
    : super(
        retry: null,
        name: r'tabTrayRowsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The rows the tab tray's list and grid draw for [containerId]: the flat
  /// search results while a search is active, otherwise the tray's grouped
  /// tab list. Only the source in use is watched.

  TabTrayRowsProvider call(String? containerId) =>
      TabTrayRowsProvider._(argument: containerId, from: this);

  @override
  String toString() => r'tabTrayRowsProvider';
}
