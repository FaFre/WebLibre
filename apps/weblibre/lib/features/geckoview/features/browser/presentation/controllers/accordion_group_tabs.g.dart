// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'accordion_group_tabs.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The tabs of every accordion group shown open, by container id: several
/// groups while [multiple], one otherwise ([AccordionExpansion.displayed]).
/// Depths are only worked out [withDepths]. Collapsed groups subscribe to
/// nothing.

@ProviderFor(accordionGroupTabs)
final accordionGroupTabsProvider = AccordionGroupTabsFamily._();

/// The tabs of every accordion group shown open, by container id: several
/// groups while [multiple], one otherwise ([AccordionExpansion.displayed]).
/// Depths are only worked out [withDepths]. Collapsed groups subscribe to
/// nothing.

final class AccordionGroupTabsProvider
    extends
        $FunctionalProvider<
          Map<String?, AccordionGroupTabs>,
          Map<String?, AccordionGroupTabs>,
          Map<String?, AccordionGroupTabs>
        >
    with $Provider<Map<String?, AccordionGroupTabs>> {
  /// The tabs of every accordion group shown open, by container id: several
  /// groups while [multiple], one otherwise ([AccordionExpansion.displayed]).
  /// Depths are only worked out [withDepths]. Collapsed groups subscribe to
  /// nothing.
  AccordionGroupTabsProvider._({
    required AccordionGroupTabsFamily super.from,
    required ({bool multiple, bool withDepths}) super.argument,
  }) : super(
         retry: null,
         name: r'accordionGroupTabsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$accordionGroupTabsHash();

  @override
  String toString() {
    return r'accordionGroupTabsProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $ProviderElement<Map<String?, AccordionGroupTabs>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  Map<String?, AccordionGroupTabs> create(Ref ref) {
    final argument = this.argument as ({bool multiple, bool withDepths});
    return accordionGroupTabs(
      ref,
      multiple: argument.multiple,
      withDepths: argument.withDepths,
    );
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<String?, AccordionGroupTabs> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<String?, AccordionGroupTabs>>(
        value,
      ),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is AccordionGroupTabsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$accordionGroupTabsHash() =>
    r'4d18f5291473ad5eafb96a7577c459eeb0e52183';

/// The tabs of every accordion group shown open, by container id: several
/// groups while [multiple], one otherwise ([AccordionExpansion.displayed]).
/// Depths are only worked out [withDepths]. Collapsed groups subscribe to
/// nothing.

final class AccordionGroupTabsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          Map<String?, AccordionGroupTabs>,
          ({bool multiple, bool withDepths})
        > {
  AccordionGroupTabsFamily._()
    : super(
        retry: null,
        name: r'accordionGroupTabsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The tabs of every accordion group shown open, by container id: several
  /// groups while [multiple], one otherwise ([AccordionExpansion.displayed]).
  /// Depths are only worked out [withDepths]. Collapsed groups subscribe to
  /// nothing.

  AccordionGroupTabsProvider call({
    required bool multiple,
    required bool withDepths,
  }) => AccordionGroupTabsProvider._(
    argument: (multiple: multiple, withDepths: withDepths),
    from: this,
  );

  @override
  String toString() => r'accordionGroupTabsProvider';
}
