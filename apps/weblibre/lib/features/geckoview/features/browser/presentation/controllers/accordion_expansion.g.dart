// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'accordion_expansion.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The selected tab paired with its own container, or null while either is
/// unknown.
///
/// One value rather than the selected tab and `selectedTabContainerIdProvider`
/// read side by side. Read from inside a selected-tab listener, the container
/// provider had not caught up yet and still answered for the *previous* tab, so
/// selecting a tab in container A opened the group of the tab before it — in
/// the single row that closed A, the group the user had just picked the tab
/// from. Pairing the two here makes a stale container impossible to attribute
/// to a new tab.

@ProviderFor(_selectedTabWithContainer)
final _selectedTabWithContainerProvider = _SelectedTabWithContainerProvider._();

/// The selected tab paired with its own container, or null while either is
/// unknown.
///
/// One value rather than the selected tab and `selectedTabContainerIdProvider`
/// read side by side. Read from inside a selected-tab listener, the container
/// provider had not caught up yet and still answered for the *previous* tab, so
/// selecting a tab in container A opened the group of the tab before it — in
/// the single row that closed A, the group the user had just picked the tab
/// from. Pairing the two here makes a stale container impossible to attribute
/// to a new tab.

final class _SelectedTabWithContainerProvider
    extends
        $FunctionalProvider<
          SelectedTabContainer?,
          SelectedTabContainer?,
          SelectedTabContainer?
        >
    with $Provider<SelectedTabContainer?> {
  /// The selected tab paired with its own container, or null while either is
  /// unknown.
  ///
  /// One value rather than the selected tab and `selectedTabContainerIdProvider`
  /// read side by side. Read from inside a selected-tab listener, the container
  /// provider had not caught up yet and still answered for the *previous* tab, so
  /// selecting a tab in container A opened the group of the tab before it — in
  /// the single row that closed A, the group the user had just picked the tab
  /// from. Pairing the two here makes a stale container impossible to attribute
  /// to a new tab.
  _SelectedTabWithContainerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'_selectedTabWithContainerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$_selectedTabWithContainerHash();

  @$internal
  @override
  $ProviderElement<SelectedTabContainer?> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SelectedTabContainer? create(Ref ref) {
    return _selectedTabWithContainer(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SelectedTabContainer? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SelectedTabContainer?>(value),
    );
  }
}

String _$_selectedTabWithContainerHash() =>
    r'd20a9586cc60b5a9a99588b62a99a4712f738160';

/// The accordion's expanded groups, which follow the selected tab.
///
/// Whenever a different tab gets selected — from the switcher, a gesture, a
/// shortcut or a link — its group is expanded so the active tab stays in view,
/// and so is the new group of a selected tab moved to another container.
/// Groups the user collapsed stay collapsed until then.

@ProviderFor(AccordionExpansionController)
final accordionExpansionControllerProvider =
    AccordionExpansionControllerProvider._();

/// The accordion's expanded groups, which follow the selected tab.
///
/// Whenever a different tab gets selected — from the switcher, a gesture, a
/// shortcut or a link — its group is expanded so the active tab stays in view,
/// and so is the new group of a selected tab moved to another container.
/// Groups the user collapsed stay collapsed until then.
final class AccordionExpansionControllerProvider
    extends
        $NotifierProvider<AccordionExpansionController, AccordionExpansion> {
  /// The accordion's expanded groups, which follow the selected tab.
  ///
  /// Whenever a different tab gets selected — from the switcher, a gesture, a
  /// shortcut or a link — its group is expanded so the active tab stays in view,
  /// and so is the new group of a selected tab moved to another container.
  /// Groups the user collapsed stay collapsed until then.
  AccordionExpansionControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'accordionExpansionControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$accordionExpansionControllerHash();

  @$internal
  @override
  AccordionExpansionController create() => AccordionExpansionController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AccordionExpansion value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AccordionExpansion>(value),
    );
  }
}

String _$accordionExpansionControllerHash() =>
    r'25815f225ffaa12e3da1156afd5d9a6fd9d76ec4';

/// The accordion's expanded groups, which follow the selected tab.
///
/// Whenever a different tab gets selected — from the switcher, a gesture, a
/// shortcut or a link — its group is expanded so the active tab stays in view,
/// and so is the new group of a selected tab moved to another container.
/// Groups the user collapsed stay collapsed until then.

abstract class _$AccordionExpansionController
    extends $Notifier<AccordionExpansion> {
  AccordionExpansion build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AccordionExpansion, AccordionExpansion>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AccordionExpansion, AccordionExpansion>,
              AccordionExpansion,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
