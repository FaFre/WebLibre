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
    r'2f00342d0b7584afe6f77d8e48ab49691c88c990';

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

@ProviderFor(generalSettingsWithDefaults)
final generalSettingsWithDefaultsProvider =
    GeneralSettingsWithDefaultsProvider._();

final class GeneralSettingsWithDefaultsProvider
    extends
        $FunctionalProvider<GeneralSettings, GeneralSettings, GeneralSettings>
    with $Provider<GeneralSettings> {
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
    r'9da4a00a3500286fbf515ee319fa911bfacab40e';

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
/// window.
///
/// Watching this rather than resolving at each call site also narrows
/// rebuilds: it fires when the *resolved* mode changes, not whenever any
/// setting or the window class does.

@ProviderFor(effectiveTabBarStackingMode)
final effectiveTabBarStackingModeProvider =
    EffectiveTabBarStackingModeProvider._();

/// [GeneralSettings.effectiveTabBarStackingMode] resolved against the current
/// window.
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
  /// window.
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
    r'5edf9bb20ad74e0133423f4864b9f54d9f7cef64';

/// The app UI locale to pass to `MaterialApp.locale`, resolved from
/// [GeneralSettings.appLocale].
///
/// Null means "let Flutter resolve the system locale" — both when the user
/// has not picked one, and defensively when a previously-picked tag is no
/// longer supported (e.g. a translation was dropped).

@ProviderFor(effectiveAppLocale)
final effectiveAppLocaleProvider = EffectiveAppLocaleProvider._();

/// The app UI locale to pass to `MaterialApp.locale`, resolved from
/// [GeneralSettings.appLocale].
///
/// Null means "let Flutter resolve the system locale" — both when the user
/// has not picked one, and defensively when a previously-picked tag is no
/// longer supported (e.g. a translation was dropped).

final class EffectiveAppLocaleProvider
    extends $FunctionalProvider<Locale?, Locale?, Locale?>
    with $Provider<Locale?> {
  /// The app UI locale to pass to `MaterialApp.locale`, resolved from
  /// [GeneralSettings.appLocale].
  ///
  /// Null means "let Flutter resolve the system locale" — both when the user
  /// has not picked one, and defensively when a previously-picked tag is no
  /// longer supported (e.g. a translation was dropped).
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
    r'df378dcfc9fae60e588e1955f8c1689b8bd4d7b8';

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
