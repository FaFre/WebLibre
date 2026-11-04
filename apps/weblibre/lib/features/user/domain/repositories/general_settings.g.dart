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

/// The general settings as stored, hidden features included.
///
/// For the screens that show and edit settings, the onboarding draft and
/// Feature Control. Behavior reads [generalSettingsWithDefaults].

@ProviderFor(storedGeneralSettings)
final storedGeneralSettingsProvider = StoredGeneralSettingsProvider._();

/// The general settings as stored, hidden features included.
///
/// For the screens that show and edit settings, the onboarding draft and
/// Feature Control. Behavior reads [generalSettingsWithDefaults].

final class StoredGeneralSettingsProvider
    extends
        $FunctionalProvider<GeneralSettings, GeneralSettings, GeneralSettings>
    with $Provider<GeneralSettings> {
  /// The general settings as stored, hidden features included.
  ///
  /// For the screens that show and edit settings, the onboarding draft and
  /// Feature Control. Behavior reads [generalSettingsWithDefaults].
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
    r'555fbb61d3ebce799f295e284a8dff663b5c8a72';

/// The general settings as they apply: the settings of hidden features at
/// their hidden values ([GeneralSettings.effective]).

@ProviderFor(generalSettingsWithDefaults)
final generalSettingsWithDefaultsProvider =
    GeneralSettingsWithDefaultsProvider._();

/// The general settings as they apply: the settings of hidden features at
/// their hidden values ([GeneralSettings.effective]).

final class GeneralSettingsWithDefaultsProvider
    extends
        $FunctionalProvider<GeneralSettings, GeneralSettings, GeneralSettings>
    with $Provider<GeneralSettings> {
  /// The general settings as they apply: the settings of hidden features at
  /// their hidden values ([GeneralSettings.effective]).
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
    r'2c307a04c985c4d9b8857b8f509de2d99decfc24';

/// The features shown with the current visibility switches.
///
/// For widgets that check many features at once (a list of actions, a set of
/// modules): one watch, and a rebuild only when the set changes rather than
/// on every settings write. `SetupDraftScope` overrides it, so below the
/// scope it follows the draft.

@ProviderFor(ShownFeatures)
final shownFeaturesProvider = ShownFeaturesProvider._();

/// The features shown with the current visibility switches.
///
/// For widgets that check many features at once (a list of actions, a set of
/// modules): one watch, and a rebuild only when the set changes rather than
/// on every settings write. `SetupDraftScope` overrides it, so below the
/// scope it follows the draft.
final class ShownFeaturesProvider
    extends $NotifierProvider<ShownFeatures, Set<FeatureId>> {
  /// The features shown with the current visibility switches.
  ///
  /// For widgets that check many features at once (a list of actions, a set of
  /// modules): one watch, and a rebuild only when the set changes rather than
  /// on every settings write. `SetupDraftScope` overrides it, so below the
  /// scope it follows the draft.
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
/// on every settings write. `SetupDraftScope` overrides it, so below the
/// scope it follows the draft.

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
