// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'general_settings.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(GeneralSettingsRepository)
final generalSettingsRepositoryProvider = GeneralSettingsRepositoryProvider._();

final class GeneralSettingsRepositoryProvider
    extends
        $StreamNotifierProvider<GeneralSettingsRepository, GeneralSettings> {
  GeneralSettingsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'generalSettingsRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$generalSettingsRepositoryHash();

  @$internal
  @override
  GeneralSettingsRepository create() => GeneralSettingsRepository();
}

String _$generalSettingsRepositoryHash() =>
    r'fbbe340abe9a7f5132ac44e4d4da182bd042ad69';

abstract class _$GeneralSettingsRepository
    extends $StreamNotifier<GeneralSettings> {
  Stream<GeneralSettings> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<GeneralSettings>, GeneralSettings>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<GeneralSettings>, GeneralSettings>,
              AsyncValue<GeneralSettings>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// The general settings of the profile as stored, hidden features included.
/// Never the onboarding draft.
///
/// The profile layer: what [generalSettingsWithDefaults] applies, and what the
/// onboarding's commit writes over. Screens that edit settings read
/// [storedGeneralSettings] instead.

@ProviderFor(profileGeneralSettings)
final profileGeneralSettingsProvider = ProfileGeneralSettingsProvider._();

/// The general settings of the profile as stored, hidden features included.
/// Never the onboarding draft.
///
/// The profile layer: what [generalSettingsWithDefaults] applies, and what the
/// onboarding's commit writes over. Screens that edit settings read
/// [storedGeneralSettings] instead.

final class ProfileGeneralSettingsProvider
    extends
        $FunctionalProvider<GeneralSettings, GeneralSettings, GeneralSettings>
    with $Provider<GeneralSettings> {
  /// The general settings of the profile as stored, hidden features included.
  /// Never the onboarding draft.
  ///
  /// The profile layer: what [generalSettingsWithDefaults] applies, and what the
  /// onboarding's commit writes over. Screens that edit settings read
  /// [storedGeneralSettings] instead.
  ProfileGeneralSettingsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'profileGeneralSettingsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$profileGeneralSettingsHash();

  @$internal
  @override
  $ProviderElement<GeneralSettings> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GeneralSettings create(Ref ref) {
    return profileGeneralSettings(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GeneralSettings value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GeneralSettings>(value),
    );
  }
}

String _$profileGeneralSettingsHash() =>
    r'cb9c58b6368358b136001c02d9808845ce9c9928';

/// The general settings as stored, hidden features included, for the screens
/// that show and edit them: in the onboarding the draft's
/// (`draftGeneralSettings`), otherwise the profile's
/// ([profileGeneralSettings]).
///
/// The edit layer. Behavior reads [generalSettingsWithDefaults].

@ProviderFor(storedGeneralSettings)
final storedGeneralSettingsProvider = StoredGeneralSettingsProvider._();

/// The general settings as stored, hidden features included, for the screens
/// that show and edit them: in the onboarding the draft's
/// (`draftGeneralSettings`), otherwise the profile's
/// ([profileGeneralSettings]).
///
/// The edit layer. Behavior reads [generalSettingsWithDefaults].

final class StoredGeneralSettingsProvider
    extends
        $FunctionalProvider<GeneralSettings, GeneralSettings, GeneralSettings>
    with $Provider<GeneralSettings> {
  /// The general settings as stored, hidden features included, for the screens
  /// that show and edit them: in the onboarding the draft's
  /// (`draftGeneralSettings`), otherwise the profile's
  /// ([profileGeneralSettings]).
  ///
  /// The edit layer. Behavior reads [generalSettingsWithDefaults].
  StoredGeneralSettingsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'storedGeneralSettingsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$storedGeneralSettingsHash();

  @$internal
  @override
  $ProviderElement<GeneralSettings> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GeneralSettings create(Ref ref) {
    return storedGeneralSettings(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GeneralSettings value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GeneralSettings>(value),
    );
  }
}

String _$storedGeneralSettingsHash() =>
    r'cd8abfab5673d2dcbca97dc16b6a3d690c6c18ce';

/// The general settings as they apply: the profile's settings with those of
/// hidden features at their hidden values ([GeneralSettings.effective]).
///
/// The live layer, which services and the browser behave by. It follows the
/// profile, never the onboarding draft.

@ProviderFor(generalSettingsWithDefaults)
final generalSettingsWithDefaultsProvider =
    GeneralSettingsWithDefaultsProvider._();

/// The general settings as they apply: the profile's settings with those of
/// hidden features at their hidden values ([GeneralSettings.effective]).
///
/// The live layer, which services and the browser behave by. It follows the
/// profile, never the onboarding draft.

final class GeneralSettingsWithDefaultsProvider
    extends
        $FunctionalProvider<GeneralSettings, GeneralSettings, GeneralSettings>
    with $Provider<GeneralSettings> {
  /// The general settings as they apply: the profile's settings with those of
  /// hidden features at their hidden values ([GeneralSettings.effective]).
  ///
  /// The live layer, which services and the browser behave by. It follows the
  /// profile, never the onboarding draft.
  GeneralSettingsWithDefaultsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'generalSettingsWithDefaultsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$generalSettingsWithDefaultsHash();

  @$internal
  @override
  $ProviderElement<GeneralSettings> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GeneralSettings create(Ref ref) {
    return generalSettingsWithDefaults(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GeneralSettings value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GeneralSettings>(value),
    );
  }
}

String _$generalSettingsWithDefaultsHash() =>
    r'481ba69247a8d82fd79df630156f8f28d118b092';

/// The features shown with the current visibility switches.
///
/// For widgets that check many features at once (a list of actions, a set of
/// modules): one watch, and a rebuild only when the set changes rather than
/// on every settings write. The live layer: widgets that render settings read
/// [DisplayedShownFeatures].

@ProviderFor(ShownFeatures)
final shownFeaturesProvider = ShownFeaturesProvider._();

/// The features shown with the current visibility switches.
///
/// For widgets that check many features at once (a list of actions, a set of
/// modules): one watch, and a rebuild only when the set changes rather than
/// on every settings write. The live layer: widgets that render settings read
/// [DisplayedShownFeatures].
final class ShownFeaturesProvider
    extends $NotifierProvider<ShownFeatures, Set<FeatureId>> {
  /// The features shown with the current visibility switches.
  ///
  /// For widgets that check many features at once (a list of actions, a set of
  /// modules): one watch, and a rebuild only when the set changes rather than
  /// on every settings write. The live layer: widgets that render settings read
  /// [DisplayedShownFeatures].
  ShownFeaturesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'shownFeaturesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$shownFeaturesHash();

  @$internal
  @override
  ShownFeatures create() => ShownFeatures();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Set<FeatureId> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Set<FeatureId>>(value),
    );
  }
}

String _$shownFeaturesHash() => r'e57f691a36ff2d283e21cd26dfbdcb2a862c5c04';

/// The features shown with the current visibility switches.
///
/// For widgets that check many features at once (a list of actions, a set of
/// modules): one watch, and a rebuild only when the set changes rather than
/// on every settings write. The live layer: widgets that render settings read
/// [DisplayedShownFeatures].

abstract class _$ShownFeatures extends $Notifier<Set<FeatureId>> {
  Set<FeatureId> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<Set<FeatureId>, Set<FeatureId>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Set<FeatureId>, Set<FeatureId>>,
              Set<FeatureId>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// The tab bar edge to actually render on, with
/// [TabBarPositionSetting.auto] already resolved against the current window.
///
/// Lives beside [generalSettingsWithDefaults] rather than in the browser
/// feature because three features need it — the browser shell, the settings
/// preview and the home wallpaper — and none of them should have to know how
/// the resolution works or remember to perform it.
///
/// Watch this instead of `settings.tabBarPosition` anywhere the value drives
/// layout. The raw setting is only for the settings screen that writes it.

@ProviderFor(effectiveTabBarPosition)
final effectiveTabBarPositionProvider = EffectiveTabBarPositionProvider._();

/// The tab bar edge to actually render on, with
/// [TabBarPositionSetting.auto] already resolved against the current window.
///
/// Lives beside [generalSettingsWithDefaults] rather than in the browser
/// feature because three features need it — the browser shell, the settings
/// preview and the home wallpaper — and none of them should have to know how
/// the resolution works or remember to perform it.
///
/// Watch this instead of `settings.tabBarPosition` anywhere the value drives
/// layout. The raw setting is only for the settings screen that writes it.

final class EffectiveTabBarPositionProvider
    extends $FunctionalProvider<TabBarPosition, TabBarPosition, TabBarPosition>
    with $Provider<TabBarPosition> {
  /// The tab bar edge to actually render on, with
  /// [TabBarPositionSetting.auto] already resolved against the current window.
  ///
  /// Lives beside [generalSettingsWithDefaults] rather than in the browser
  /// feature because three features need it — the browser shell, the settings
  /// preview and the home wallpaper — and none of them should have to know how
  /// the resolution works or remember to perform it.
  ///
  /// Watch this instead of `settings.tabBarPosition` anywhere the value drives
  /// layout. The raw setting is only for the settings screen that writes it.
  EffectiveTabBarPositionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'effectiveTabBarPositionProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$effectiveTabBarPositionHash();

  @$internal
  @override
  $ProviderElement<TabBarPosition> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  TabBarPosition create(Ref ref) {
    return effectiveTabBarPosition(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TabBarPosition value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TabBarPosition>(value),
    );
  }
}

String _$effectiveTabBarPositionHash() =>
    r'074a9d960c58345eb08015acd3a5b04d95d6d366';

/// [GeneralSettings.effectiveTabBarStackingMode] resolved against the current
/// window and the width the side panel is drawn at, including a resize in
/// progress.
///
/// Watching this rather than resolving at each call site also narrows
/// rebuilds: it fires when the *resolved* mode changes, not whenever any
/// setting or the window class does.

@ProviderFor(effectiveTabBarStackingMode)
final effectiveTabBarStackingModeProvider =
    EffectiveTabBarStackingModeProvider._();

/// [GeneralSettings.effectiveTabBarStackingMode] resolved against the current
/// window and the width the side panel is drawn at, including a resize in
/// progress.
///
/// Watching this rather than resolving at each call site also narrows
/// rebuilds: it fires when the *resolved* mode changes, not whenever any
/// setting or the window class does.

final class EffectiveTabBarStackingModeProvider
    extends
        $FunctionalProvider<
          TabBarStackingMode,
          TabBarStackingMode,
          TabBarStackingMode
        >
    with $Provider<TabBarStackingMode> {
  /// [GeneralSettings.effectiveTabBarStackingMode] resolved against the current
  /// window and the width the side panel is drawn at, including a resize in
  /// progress.
  ///
  /// Watching this rather than resolving at each call site also narrows
  /// rebuilds: it fires when the *resolved* mode changes, not whenever any
  /// setting or the window class does.
  EffectiveTabBarStackingModeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'effectiveTabBarStackingModeProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$effectiveTabBarStackingModeHash();

  @$internal
  @override
  $ProviderElement<TabBarStackingMode> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  TabBarStackingMode create(Ref ref) {
    return effectiveTabBarStackingMode(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TabBarStackingMode value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TabBarStackingMode>(value),
    );
  }
}

String _$effectiveTabBarStackingModeHash() =>
    r'33890cd07523bca7f4807edf44249ae29a2cd5c9';

/// The width the side panel is being resized to, or null when the saved
/// [GeneralSettings.sideRailWidth] is the whole truth.
///
/// Kept past the end of a drag until the saved setting reports the released
/// width. Clearing it on release would put the panel back at its old width for
/// the frames the save takes, and every one of those frames resizes the page.
/// Lives with the settings rather than the rail because the effective
/// stacking mode depends on it: a panel dragged down to the icon rail has no
/// room for two lists.

@ProviderFor(SideRailDragWidth)
final sideRailDragWidthProvider = SideRailDragWidthProvider._();

/// The width the side panel is being resized to, or null when the saved
/// [GeneralSettings.sideRailWidth] is the whole truth.
///
/// Kept past the end of a drag until the saved setting reports the released
/// width. Clearing it on release would put the panel back at its old width for
/// the frames the save takes, and every one of those frames resizes the page.
/// Lives with the settings rather than the rail because the effective
/// stacking mode depends on it: a panel dragged down to the icon rail has no
/// room for two lists.
final class SideRailDragWidthProvider
    extends $NotifierProvider<SideRailDragWidth, double?> {
  /// The width the side panel is being resized to, or null when the saved
  /// [GeneralSettings.sideRailWidth] is the whole truth.
  ///
  /// Kept past the end of a drag until the saved setting reports the released
  /// width. Clearing it on release would put the panel back at its old width for
  /// the frames the save takes, and every one of those frames resizes the page.
  /// Lives with the settings rather than the rail because the effective
  /// stacking mode depends on it: a panel dragged down to the icon rail has no
  /// room for two lists.
  SideRailDragWidthProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sideRailDragWidthProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sideRailDragWidthHash();

  @$internal
  @override
  SideRailDragWidth create() => SideRailDragWidth();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(double? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<double?>(value),
    );
  }
}

String _$sideRailDragWidthHash() => r'eb4c2ed888c9f9fae47355d6acd748f969818e06';

/// The width the side panel is being resized to, or null when the saved
/// [GeneralSettings.sideRailWidth] is the whole truth.
///
/// Kept past the end of a drag until the saved setting reports the released
/// width. Clearing it on release would put the panel back at its old width for
/// the frames the save takes, and every one of those frames resizes the page.
/// Lives with the settings rather than the rail because the effective
/// stacking mode depends on it: a panel dragged down to the icon rail has no
/// room for two lists.

abstract class _$SideRailDragWidth extends $Notifier<double?> {
  double? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<double?, double?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<double?, double?>,
              double?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// The app UI locale to pass to `MaterialApp.locale`, resolved from
/// [GeneralSettings.appLocale], or [defaultAppLocale] when the user has not
/// picked one.
///
/// Null means "let Flutter resolve the system locale" — both when the user
/// chose [appLocaleSystem], and defensively when a previously-picked tag is
/// no longer supported (e.g. a translation was dropped).

@ProviderFor(effectiveAppLocale)
final effectiveAppLocaleProvider = EffectiveAppLocaleProvider._();

/// The app UI locale to pass to `MaterialApp.locale`, resolved from
/// [GeneralSettings.appLocale], or [defaultAppLocale] when the user has not
/// picked one.
///
/// Null means "let Flutter resolve the system locale" — both when the user
/// chose [appLocaleSystem], and defensively when a previously-picked tag is
/// no longer supported (e.g. a translation was dropped).

final class EffectiveAppLocaleProvider
    extends $FunctionalProvider<Locale?, Locale?, Locale?>
    with $Provider<Locale?> {
  /// The app UI locale to pass to `MaterialApp.locale`, resolved from
  /// [GeneralSettings.appLocale], or [defaultAppLocale] when the user has not
  /// picked one.
  ///
  /// Null means "let Flutter resolve the system locale" — both when the user
  /// chose [appLocaleSystem], and defensively when a previously-picked tag is
  /// no longer supported (e.g. a translation was dropped).
  EffectiveAppLocaleProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'effectiveAppLocaleProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$effectiveAppLocaleHash();

  @$internal
  @override
  $ProviderElement<Locale?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Locale? create(Ref ref) {
    return effectiveAppLocale(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Locale? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Locale?>(value),
    );
  }
}

String _$effectiveAppLocaleHash() =>
    r'ab79e794177a3521e25451dd865a6a919dd37778';

/// [GeneralSettings.effectiveSearchFieldPlacement] resolved against the
/// current window.

@ProviderFor(effectiveSearchFieldPlacement)
final effectiveSearchFieldPlacementProvider =
    EffectiveSearchFieldPlacementProvider._();

/// [GeneralSettings.effectiveSearchFieldPlacement] resolved against the
/// current window.

final class EffectiveSearchFieldPlacementProvider
    extends
        $FunctionalProvider<
          SearchFieldPlacement,
          SearchFieldPlacement,
          SearchFieldPlacement
        >
    with $Provider<SearchFieldPlacement> {
  /// [GeneralSettings.effectiveSearchFieldPlacement] resolved against the
  /// current window.
  EffectiveSearchFieldPlacementProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'effectiveSearchFieldPlacementProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$effectiveSearchFieldPlacementHash();

  @$internal
  @override
  $ProviderElement<SearchFieldPlacement> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SearchFieldPlacement create(Ref ref) {
    return effectiveSearchFieldPlacement(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SearchFieldPlacement value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SearchFieldPlacement>(value),
    );
  }
}

String _$effectiveSearchFieldPlacementHash() =>
    r'045ab5e28bd7e421645e64dfd3fb282b1483f1a1';

/// [GeneralSettings.effectiveHomeSearchBarPlacement] resolved against the
/// current window.

@ProviderFor(effectiveHomeSearchBarPlacement)
final effectiveHomeSearchBarPlacementProvider =
    EffectiveHomeSearchBarPlacementProvider._();

/// [GeneralSettings.effectiveHomeSearchBarPlacement] resolved against the
/// current window.

final class EffectiveHomeSearchBarPlacementProvider
    extends
        $FunctionalProvider<
          HomeSearchBarPlacement,
          HomeSearchBarPlacement,
          HomeSearchBarPlacement
        >
    with $Provider<HomeSearchBarPlacement> {
  /// [GeneralSettings.effectiveHomeSearchBarPlacement] resolved against the
  /// current window.
  EffectiveHomeSearchBarPlacementProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'effectiveHomeSearchBarPlacementProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$effectiveHomeSearchBarPlacementHash();

  @$internal
  @override
  $ProviderElement<HomeSearchBarPlacement> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  HomeSearchBarPlacement create(Ref ref) {
    return effectiveHomeSearchBarPlacement(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HomeSearchBarPlacement value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HomeSearchBarPlacement>(value),
    );
  }
}

String _$effectiveHomeSearchBarPlacementHash() =>
    r'73f1d11f26d6fb322f109470bd71828677181ab9';

/// The general settings as the widgets that render settings draw them: in
/// the onboarding the draft's as they would apply, otherwise the live ones
/// ([generalSettingsWithDefaults]).
///
/// The displayed layer, for the layout preview, `HiddenFeatureGate`, the
/// module and menu views and the onboarding's pages. Never for behavior:
/// services read [generalSettingsWithDefaults].

@ProviderFor(displayedGeneralSettings)
final displayedGeneralSettingsProvider = DisplayedGeneralSettingsProvider._();

/// The general settings as the widgets that render settings draw them: in
/// the onboarding the draft's as they would apply, otherwise the live ones
/// ([generalSettingsWithDefaults]).
///
/// The displayed layer, for the layout preview, `HiddenFeatureGate`, the
/// module and menu views and the onboarding's pages. Never for behavior:
/// services read [generalSettingsWithDefaults].

final class DisplayedGeneralSettingsProvider
    extends
        $FunctionalProvider<GeneralSettings, GeneralSettings, GeneralSettings>
    with $Provider<GeneralSettings> {
  /// The general settings as the widgets that render settings draw them: in
  /// the onboarding the draft's as they would apply, otherwise the live ones
  /// ([generalSettingsWithDefaults]).
  ///
  /// The displayed layer, for the layout preview, `HiddenFeatureGate`, the
  /// module and menu views and the onboarding's pages. Never for behavior:
  /// services read [generalSettingsWithDefaults].
  DisplayedGeneralSettingsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'displayedGeneralSettingsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$displayedGeneralSettingsHash();

  @$internal
  @override
  $ProviderElement<GeneralSettings> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GeneralSettings create(Ref ref) {
    return displayedGeneralSettings(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GeneralSettings value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GeneralSettings>(value),
    );
  }
}

String _$displayedGeneralSettingsHash() =>
    r'75222d1286e1ee9b999b85315f208a3483c7b432';

/// [ShownFeatures] for the displayed layer ([displayedGeneralSettings]).

@ProviderFor(DisplayedShownFeatures)
final displayedShownFeaturesProvider = DisplayedShownFeaturesProvider._();

/// [ShownFeatures] for the displayed layer ([displayedGeneralSettings]).
final class DisplayedShownFeaturesProvider
    extends $NotifierProvider<DisplayedShownFeatures, Set<FeatureId>> {
  /// [ShownFeatures] for the displayed layer ([displayedGeneralSettings]).
  DisplayedShownFeaturesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'displayedShownFeaturesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$displayedShownFeaturesHash();

  @$internal
  @override
  DisplayedShownFeatures create() => DisplayedShownFeatures();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Set<FeatureId> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Set<FeatureId>>(value),
    );
  }
}

String _$displayedShownFeaturesHash() =>
    r'514287f5dabe0d84a1ae5b5031ac36861321d486';

/// [ShownFeatures] for the displayed layer ([displayedGeneralSettings]).

abstract class _$DisplayedShownFeatures extends $Notifier<Set<FeatureId>> {
  Set<FeatureId> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<Set<FeatureId>, Set<FeatureId>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Set<FeatureId>, Set<FeatureId>>,
              Set<FeatureId>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// [effectiveTabBarPosition] for the displayed layer.

@ProviderFor(displayedTabBarPosition)
final displayedTabBarPositionProvider = DisplayedTabBarPositionProvider._();

/// [effectiveTabBarPosition] for the displayed layer.

final class DisplayedTabBarPositionProvider
    extends $FunctionalProvider<TabBarPosition, TabBarPosition, TabBarPosition>
    with $Provider<TabBarPosition> {
  /// [effectiveTabBarPosition] for the displayed layer.
  DisplayedTabBarPositionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'displayedTabBarPositionProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$displayedTabBarPositionHash();

  @$internal
  @override
  $ProviderElement<TabBarPosition> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  TabBarPosition create(Ref ref) {
    return displayedTabBarPosition(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TabBarPosition value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TabBarPosition>(value),
    );
  }
}

String _$displayedTabBarPositionHash() =>
    r'16147c6acb7e6c74c8292ca53d21ee16c62736ef';

/// [effectiveTabBarStackingMode] for the displayed layer.

@ProviderFor(displayedTabBarStackingMode)
final displayedTabBarStackingModeProvider =
    DisplayedTabBarStackingModeProvider._();

/// [effectiveTabBarStackingMode] for the displayed layer.

final class DisplayedTabBarStackingModeProvider
    extends
        $FunctionalProvider<
          TabBarStackingMode,
          TabBarStackingMode,
          TabBarStackingMode
        >
    with $Provider<TabBarStackingMode> {
  /// [effectiveTabBarStackingMode] for the displayed layer.
  DisplayedTabBarStackingModeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'displayedTabBarStackingModeProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$displayedTabBarStackingModeHash();

  @$internal
  @override
  $ProviderElement<TabBarStackingMode> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  TabBarStackingMode create(Ref ref) {
    return displayedTabBarStackingMode(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TabBarStackingMode value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TabBarStackingMode>(value),
    );
  }
}

String _$displayedTabBarStackingModeHash() =>
    r'c1bbfbb4dfd8cc0a41ee14199bb8d3a7a504e6f2';

/// [effectiveSearchFieldPlacement] for the displayed layer.

@ProviderFor(displayedSearchFieldPlacement)
final displayedSearchFieldPlacementProvider =
    DisplayedSearchFieldPlacementProvider._();

/// [effectiveSearchFieldPlacement] for the displayed layer.

final class DisplayedSearchFieldPlacementProvider
    extends
        $FunctionalProvider<
          SearchFieldPlacement,
          SearchFieldPlacement,
          SearchFieldPlacement
        >
    with $Provider<SearchFieldPlacement> {
  /// [effectiveSearchFieldPlacement] for the displayed layer.
  DisplayedSearchFieldPlacementProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'displayedSearchFieldPlacementProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$displayedSearchFieldPlacementHash();

  @$internal
  @override
  $ProviderElement<SearchFieldPlacement> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SearchFieldPlacement create(Ref ref) {
    return displayedSearchFieldPlacement(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SearchFieldPlacement value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SearchFieldPlacement>(value),
    );
  }
}

String _$displayedSearchFieldPlacementHash() =>
    r'e36c24ca3ec209d38912cd8dc27d6999386098b7';

/// [effectiveHomeSearchBarPlacement] for the displayed layer.

@ProviderFor(displayedHomeSearchBarPlacement)
final displayedHomeSearchBarPlacementProvider =
    DisplayedHomeSearchBarPlacementProvider._();

/// [effectiveHomeSearchBarPlacement] for the displayed layer.

final class DisplayedHomeSearchBarPlacementProvider
    extends
        $FunctionalProvider<
          HomeSearchBarPlacement,
          HomeSearchBarPlacement,
          HomeSearchBarPlacement
        >
    with $Provider<HomeSearchBarPlacement> {
  /// [effectiveHomeSearchBarPlacement] for the displayed layer.
  DisplayedHomeSearchBarPlacementProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'displayedHomeSearchBarPlacementProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$displayedHomeSearchBarPlacementHash();

  @$internal
  @override
  $ProviderElement<HomeSearchBarPlacement> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  HomeSearchBarPlacement create(Ref ref) {
    return displayedHomeSearchBarPlacement(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HomeSearchBarPlacement value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HomeSearchBarPlacement>(value),
    );
  }
}

String _$displayedHomeSearchBarPlacementHash() =>
    r'3870cb2623c5f2c4b9f0b09b1f4825e16f0045c7';
