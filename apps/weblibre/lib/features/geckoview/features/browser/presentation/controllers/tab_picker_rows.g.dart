// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tab_picker_rows.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The tabs of [containerId] the tray offers while it picks one: the tray's
/// search results while it searches, otherwise every tab in the order of the
/// tab bar, which leaves nothing out (the tray's own filters, sort and folded
/// groups are its saved state and stay out of the picker). Only tabs that
/// [tabPickerOffers] are kept.

@ProviderFor(tabPickerRows)
final tabPickerRowsProvider = TabPickerRowsFamily._();

/// The tabs of [containerId] the tray offers while it picks one: the tray's
/// search results while it searches, otherwise every tab in the order of the
/// tab bar, which leaves nothing out (the tray's own filters, sort and folded
/// groups are its saved state and stay out of the picker). Only tabs that
/// [tabPickerOffers] are kept.

final class TabPickerRowsProvider
    extends
        $FunctionalProvider<
          EquatableValue<List<TabPickerRow>>,
          EquatableValue<List<TabPickerRow>>,
          EquatableValue<List<TabPickerRow>>
        >
    with $Provider<EquatableValue<List<TabPickerRow>>> {
  /// The tabs of [containerId] the tray offers while it picks one: the tray's
  /// search results while it searches, otherwise every tab in the order of the
  /// tab bar, which leaves nothing out (the tray's own filters, sort and folded
  /// groups are its saved state and stay out of the picker). Only tabs that
  /// [tabPickerOffers] are kept.
  TabPickerRowsProvider._({
    required TabPickerRowsFamily super.from,
    required ({String? containerId, bool privateTabs, TabTypeFilter typeFilter})
    super.argument,
  }) : super(
         retry: null,
         name: r'tabPickerRowsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$tabPickerRowsHash();

  @override
  String toString() {
    return r'tabPickerRowsProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $ProviderElement<EquatableValue<List<TabPickerRow>>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  EquatableValue<List<TabPickerRow>> create(Ref ref) {
    final argument =
        this.argument
            as ({
              String? containerId,
              bool privateTabs,
              TabTypeFilter typeFilter,
            });
    return tabPickerRows(
      ref,
      containerId: argument.containerId,
      privateTabs: argument.privateTabs,
      typeFilter: argument.typeFilter,
    );
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(EquatableValue<List<TabPickerRow>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<EquatableValue<List<TabPickerRow>>>(
        value,
      ),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is TabPickerRowsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$tabPickerRowsHash() => r'26eab4f35304290bf4309f9db49365e041be11de';

/// The tabs of [containerId] the tray offers while it picks one: the tray's
/// search results while it searches, otherwise every tab in the order of the
/// tab bar, which leaves nothing out (the tray's own filters, sort and folded
/// groups are its saved state and stay out of the picker). Only tabs that
/// [tabPickerOffers] are kept.

final class TabPickerRowsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          EquatableValue<List<TabPickerRow>>,
          ({String? containerId, bool privateTabs, TabTypeFilter typeFilter})
        > {
  TabPickerRowsFamily._()
    : super(
        retry: null,
        name: r'tabPickerRowsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The tabs of [containerId] the tray offers while it picks one: the tray's
  /// search results while it searches, otherwise every tab in the order of the
  /// tab bar, which leaves nothing out (the tray's own filters, sort and folded
  /// groups are its saved state and stay out of the picker). Only tabs that
  /// [tabPickerOffers] are kept.

  TabPickerRowsProvider call({
    required String? containerId,
    required bool privateTabs,
    required TabTypeFilter typeFilter,
  }) => TabPickerRowsProvider._(
    argument: (
      containerId: containerId,
      privateTabs: privateTabs,
      typeFilter: typeFilter,
    ),
    from: this,
  );

  @override
  String toString() => r'tabPickerRowsProvider';
}
