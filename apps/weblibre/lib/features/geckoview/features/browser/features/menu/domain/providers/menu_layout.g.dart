// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'menu_layout.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The user's arrangement of the browser menu sheet: which sections appear, in
/// what order, how the rows inside each one are ordered, and how the rows an
/// expanding row reveals are ordered.
///
/// One persisted list rather than one per section, so a reorder and the
/// visibility toggle next to it are a single atomic write, and so the whole
/// layout can be reconciled against the shipped defaults in one pass on read.

@ProviderFor(MenuLayout)
final menuLayoutProvider = MenuLayoutProvider._();

/// The user's arrangement of the browser menu sheet: which sections appear, in
/// what order, how the rows inside each one are ordered, and how the rows an
/// expanding row reveals are ordered.
///
/// One persisted list rather than one per section, so a reorder and the
/// visibility toggle next to it are a single atomic write, and so the whole
/// layout can be reconciled against the shipped defaults in one pass on read.
final class MenuLayoutProvider
    extends $NotifierProvider<MenuLayout, List<MenuSectionEntry>> {
  /// The user's arrangement of the browser menu sheet: which sections appear, in
  /// what order, how the rows inside each one are ordered, and how the rows an
  /// expanding row reveals are ordered.
  ///
  /// One persisted list rather than one per section, so a reorder and the
  /// visibility toggle next to it are a single atomic write, and so the whole
  /// layout can be reconciled against the shipped defaults in one pass on read.
  MenuLayoutProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'menuLayoutProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$menuLayoutHash();

  @$internal
  @override
  MenuLayout create() => MenuLayout();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<MenuSectionEntry> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<MenuSectionEntry>>(value),
    );
  }
}

String _$menuLayoutHash() => r'9018173260f99c101631e26d7db0f87873b2a9bf';

/// The user's arrangement of the browser menu sheet: which sections appear, in
/// what order, how the rows inside each one are ordered, and how the rows an
/// expanding row reveals are ordered.
///
/// One persisted list rather than one per section, so a reorder and the
/// visibility toggle next to it are a single atomic write, and so the whole
/// layout can be reconciled against the shipped defaults in one pass on read.

abstract class _$MenuLayout extends $Notifier<List<MenuSectionEntry>> {
  List<MenuSectionEntry> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<List<MenuSectionEntry>, List<MenuSectionEntry>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<MenuSectionEntry>, List<MenuSectionEntry>>,
              List<MenuSectionEntry>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// The menu as drawn: the user's arrangement ([MenuLayout]), or the shipped
/// one while menu customization is hidden (`layout.menu_customization`). The
/// arrangement is kept and comes back with the feature.

@ProviderFor(effectiveMenuLayout)
final effectiveMenuLayoutProvider = EffectiveMenuLayoutProvider._();

/// The menu as drawn: the user's arrangement ([MenuLayout]), or the shipped
/// one while menu customization is hidden (`layout.menu_customization`). The
/// arrangement is kept and comes back with the feature.

final class EffectiveMenuLayoutProvider
    extends
        $FunctionalProvider<
          List<MenuSectionEntry>,
          List<MenuSectionEntry>,
          List<MenuSectionEntry>
        >
    with $Provider<List<MenuSectionEntry>> {
  /// The menu as drawn: the user's arrangement ([MenuLayout]), or the shipped
  /// one while menu customization is hidden (`layout.menu_customization`). The
  /// arrangement is kept and comes back with the feature.
  EffectiveMenuLayoutProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'effectiveMenuLayoutProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$effectiveMenuLayoutHash();

  @$internal
  @override
  $ProviderElement<List<MenuSectionEntry>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  List<MenuSectionEntry> create(Ref ref) {
    return effectiveMenuLayout(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<MenuSectionEntry> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<MenuSectionEntry>>(value),
    );
  }
}

String _$effectiveMenuLayoutHash() =>
    r'de3f97245e77bf4cf6a0a42a29ed0a07b20b4ab8';

/// Whether the sheet is currently showing its arrangement UI instead of the
/// menu.
///
/// Auto-disposed and therefore scoped to one presentation of the sheet: leaving
/// the menu while arranging and opening it again returns to the menu, which is
/// what a modal that is dismissed by tapping outside has to do.

@ProviderFor(MenuReorderMode)
final menuReorderModeProvider = MenuReorderModeProvider._();

/// Whether the sheet is currently showing its arrangement UI instead of the
/// menu.
///
/// Auto-disposed and therefore scoped to one presentation of the sheet: leaving
/// the menu while arranging and opening it again returns to the menu, which is
/// what a modal that is dismissed by tapping outside has to do.
final class MenuReorderModeProvider
    extends $NotifierProvider<MenuReorderMode, MenuReorderState> {
  /// Whether the sheet is currently showing its arrangement UI instead of the
  /// menu.
  ///
  /// Auto-disposed and therefore scoped to one presentation of the sheet: leaving
  /// the menu while arranging and opening it again returns to the menu, which is
  /// what a modal that is dismissed by tapping outside has to do.
  MenuReorderModeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'menuReorderModeProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$menuReorderModeHash();

  @$internal
  @override
  MenuReorderMode create() => MenuReorderMode();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MenuReorderState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MenuReorderState>(value),
    );
  }
}

String _$menuReorderModeHash() => r'fc7652fcd1123b6023336bfccd386cf9b08701ee';

/// Whether the sheet is currently showing its arrangement UI instead of the
/// menu.
///
/// Auto-disposed and therefore scoped to one presentation of the sheet: leaving
/// the menu while arranging and opening it again returns to the menu, which is
/// what a modal that is dismissed by tapping outside has to do.

abstract class _$MenuReorderMode extends $Notifier<MenuReorderState> {
  MenuReorderState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<MenuReorderState, MenuReorderState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<MenuReorderState, MenuReorderState>,
              MenuReorderState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
