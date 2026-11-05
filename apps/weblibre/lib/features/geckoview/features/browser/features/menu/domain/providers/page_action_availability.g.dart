// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'page_action_availability.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Whether the Translate and Add to home screen rows apply.
///
/// Only the rows in the layout are checked ([translateInLayout],
/// [addToHomeScreenInLayout]): a row the user removed watches nothing, so
/// translation and install state changes do not rebuild the menu.

@ProviderFor(pageActionAvailability)
final pageActionAvailabilityProvider = PageActionAvailabilityFamily._();

/// Whether the Translate and Add to home screen rows apply.
///
/// Only the rows in the layout are checked ([translateInLayout],
/// [addToHomeScreenInLayout]): a row the user removed watches nothing, so
/// translation and install state changes do not rebuild the menu.

final class PageActionAvailabilityProvider
    extends
        $FunctionalProvider<
          PageActionAvailability,
          PageActionAvailability,
          PageActionAvailability
        >
    with $Provider<PageActionAvailability> {
  /// Whether the Translate and Add to home screen rows apply.
  ///
  /// Only the rows in the layout are checked ([translateInLayout],
  /// [addToHomeScreenInLayout]): a row the user removed watches nothing, so
  /// translation and install state changes do not rebuild the menu.
  PageActionAvailabilityProvider._({
    required PageActionAvailabilityFamily super.from,
    required (String, {bool translateInLayout, bool addToHomeScreenInLayout})
    super.argument,
  }) : super(
         retry: null,
         name: r'pageActionAvailabilityProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$pageActionAvailabilityHash();

  @override
  String toString() {
    return r'pageActionAvailabilityProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $ProviderElement<PageActionAvailability> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PageActionAvailability create(Ref ref) {
    final argument =
        this.argument
            as (String, {bool translateInLayout, bool addToHomeScreenInLayout});
    return pageActionAvailability(
      ref,
      argument.$1,
      translateInLayout: argument.translateInLayout,
      addToHomeScreenInLayout: argument.addToHomeScreenInLayout,
    );
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PageActionAvailability value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PageActionAvailability>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is PageActionAvailabilityProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$pageActionAvailabilityHash() =>
    r'fe78543ad665732f17e0df2124fbe3c2addc4a98';

/// Whether the Translate and Add to home screen rows apply.
///
/// Only the rows in the layout are checked ([translateInLayout],
/// [addToHomeScreenInLayout]): a row the user removed watches nothing, so
/// translation and install state changes do not rebuild the menu.

final class PageActionAvailabilityFamily extends $Family
    with
        $FunctionalFamilyOverride<
          PageActionAvailability,
          (String, {bool translateInLayout, bool addToHomeScreenInLayout})
        > {
  PageActionAvailabilityFamily._()
    : super(
        retry: null,
        name: r'pageActionAvailabilityProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Whether the Translate and Add to home screen rows apply.
  ///
  /// Only the rows in the layout are checked ([translateInLayout],
  /// [addToHomeScreenInLayout]): a row the user removed watches nothing, so
  /// translation and install state changes do not rebuild the menu.

  PageActionAvailabilityProvider call(
    String selectedTabId, {
    required bool translateInLayout,
    required bool addToHomeScreenInLayout,
  }) => PageActionAvailabilityProvider._(
    argument: (
      selectedTabId,
      translateInLayout: translateInLayout,
      addToHomeScreenInLayout: addToHomeScreenInLayout,
    ),
    from: this,
  );

  @override
  String toString() => r'pageActionAvailabilityProvider';
}
