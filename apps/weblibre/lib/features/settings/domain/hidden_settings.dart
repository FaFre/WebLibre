/*
 * Copyright (c) 2024-2026 Fabian Freund.
 *
 * This file is part of WebLibre
 * (see https://weblibre.eu).
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */
import 'package:collection/collection.dart';
import 'package:weblibre/domain/feature_policy/feature_policy.dart';
import 'package:weblibre/features/geckoview/features/browser/features/contextual_toolbar/data/providers/toolbar_button_configs.dart';
import 'package:weblibre/features/geckoview/features/browser/features/contextual_toolbar/domain/entities/toolbar_config_location.dart';
import 'package:weblibre/features/geckoview/features/browser/features/menu/domain/entities/menu_layout.dart';
import 'package:weblibre/features/geckoview/features/browser/features/menu/domain/providers/menu_layout.dart';
import 'package:weblibre/features/gestures/data/models/gesture_settings.dart';
import 'package:weblibre/features/keyboard_shortcuts/data/models/keyboard_shortcut_settings.dart';
import 'package:weblibre/features/user/data/database/definitions.drift.dart'
    show ToolbarButtonConfig;
import 'package:weblibre/features/user/data/models/engine_settings.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';
import 'package:weblibre/features/user/data/models/proxy_diagnostics_settings.dart';

/// Everything a visibility switch can stop from applying, as stored: the
/// settings partitions, the toolbar and menu arrangements, and whether any
/// container uses strict mode or its own app link settings.
///
/// [applied] is the same as it applies with [general]'s visibility switches,
/// the way the effective providers project it. Comparing the two says which
/// changes are not applied while their feature is hidden ([HiddenSetting]).
class SettingsSnapshot {
  SettingsSnapshot({
    required this.general,
    required this.engine,
    required this.gestures,
    required this.keyboardShortcuts,
    required this.proxyDiagnostics,
    required this.toolbars,
    required this.menu,
    required this.strictContainers,
    required this.appLinkContainers,
  });

  final GeneralSettings general;
  final EngineSettings engine;
  final GestureSettings gestures;
  final KeyboardShortcutSettings keyboardShortcuts;
  final ProxyDiagnosticsSettings proxyDiagnostics;
  final Map<ToolbarConfigLocation, List<ToolbarButtonConfig>> toolbars;
  final List<MenuSectionEntry> menu;

  /// Whether any container has strict mode on.
  final bool strictContainers;

  /// Whether any container has its own app link settings on.
  final bool appLinkContainers;

  /// This snapshot with [general] in place of its general settings: what
  /// changing the visibility switches to [general]'s would make of it. With
  /// [engine], the engine settings too: what a change of both (an onboarding
  /// preset change) would make of it.
  SettingsSnapshot withGeneral(
    GeneralSettings general, {
    EngineSettings? engine,
  }) => SettingsSnapshot(
    general: general,
    engine: engine ?? this.engine,
    gestures: gestures,
    keyboardShortcuts: keyboardShortcuts,
    proxyDiagnostics: proxyDiagnostics,
    toolbars: toolbars,
    menu: menu,
    strictContainers: strictContainers,
    appLinkContainers: appLinkContainers,
  );

  /// The snapshot as it applies with [general]'s visibility switches.
  SettingsSnapshot applied() {
    final isShown = general.isFeatureShown;
    final toolbarAdvancedShown = isShown(
      FeatureId.layoutContextualToolbarAdvanced,
    );

    return SettingsSnapshot(
      general: general.effective(),
      engine: engine.effective(isShown),
      gestures: gestures.effective(isShown),
      keyboardShortcuts: keyboardShortcuts.effective(isShown),
      proxyDiagnostics: proxyDiagnostics.effective(isShown),
      toolbars: {
        for (final MapEntry(key: location, value: configs) in toolbars.entries)
          location: toolbarButtonConfigsAsApplied(
            configs,
            location,
            advancedShown: toolbarAdvancedShown,
          ),
      },
      menu: isShown(FeatureId.layoutMenuCustomization)
          ? menu
          : defaultMenuLayout,
      strictContainers:
          strictContainers && isShown(FeatureId.containerStrictMode),
      appLinkContainers:
          appLinkContainers && isShown(FeatureId.containerAppLinks),
    );
  }

  /// The changes in this snapshot that do not apply while their feature is
  /// hidden, in [HiddenSetting] order: stored other than the default, and
  /// applied other than stored.
  ///
  /// A value at its default is no change, even where the hidden value is not
  /// the default: the default tab stacking (Accordion) is itself a container
  /// mode, drawn as the simple row while containers are hidden.
  Set<HiddenSetting> get suspended {
    final applied = this.applied();
    final defaults = _defaults();
    return {
      for (final setting in HiddenSetting.values)
        if (!setting._sameIn(this, applied) && !setting._sameIn(this, defaults))
          setting,
    };
  }

  /// Every store at its defaults, with the same visibility switches.
  SettingsSnapshot _defaults() => SettingsSnapshot(
    general: GeneralSettings.withDefaults(
      visibilitySwitches: general.visibilitySwitches,
      showContainerUi: general.showContainerUi,
      showIsolatedTabUi: general.showIsolatedTabUi,
    ),
    engine: EngineSettings.withDefaults(),
    gestures: GestureSettings.withDefaults(),
    keyboardShortcuts: KeyboardShortcutSettings.withDefaults(),
    proxyDiagnostics: ProxyDiagnosticsSettings.withDefaults(),
    toolbars: {
      for (final location in toolbars.keys)
        location: defaultToolbarButtonConfigsFor(location).value,
    },
    menu: defaultMenuLayout,
    strictContainers: false,
    appLinkContainers: false,
  );
}

/// The changes that stop applying when the general settings go from this
/// snapshot's to [next]: suspended afterwards, not before. Hiding a second
/// guard of a change already suspended lists nothing for it.
List<HiddenSetting> settingsStoppingToApply(
  SettingsSnapshot stored,
  GeneralSettings next,
) => settingsStoppingBetween(stored, stored.withGeneral(next));

/// The changes suspended in [next] that are not in [stored], in
/// [HiddenSetting] order: [settingsStoppingToApply] for a change of more
/// than the general settings.
List<HiddenSetting> settingsStoppingBetween(
  SettingsSnapshot stored,
  SettingsSnapshot next,
) {
  final before = stored.suspended;
  final after = next.suspended;
  return [
    for (final setting in HiddenSetting.values)
      if (after.contains(setting) && !before.contains(setting)) setting,
  ];
}

/// The changes that apply again when the general settings go from this
/// snapshot's to [next]: the other way round from [settingsStoppingToApply].
List<HiddenSetting> settingsApplyingAgain(
  SettingsSnapshot stored,
  GeneralSettings next,
) {
  final before = stored.suspended;
  final after = stored.withGeneral(next).suspended;
  return [
    for (final setting in HiddenSetting.values)
      if (before.contains(setting) && !after.contains(setting)) setting,
  ];
}

/// [general] with every switch in [switches] turned on, the way showing a
/// hidden feature does ([GeneralSettings.withVisibilitySwitch]).
GeneralSettings withSwitchesShown(
  GeneralSettings general,
  Iterable<VisibilitySwitch> switches,
) => switches.fold(
  general,
  (settings, visibilitySwitch) =>
      settings.withVisibilitySwitch(visibilitySwitch, enabled: true),
);

/// The changes that apply again once [switches] are shown: of [suspended],
/// the ones [settingsApplyingAgain] lists. What the reveal dialog lists
/// before "Show", and what a restart is offered for afterwards.
///
/// Computed for every suspended change, not only the ones read at engine
/// start: a JavaScript setting coming back matters as much as a restart.
/// [stored] is read only when something is suspended, so the onboarding
/// draft, where nothing is, never reaches outside it.
List<HiddenSetting> changesApplyingAgainOnShow({
  required Set<HiddenSetting> suspended,
  required SettingsSnapshot Function() stored,
  required Iterable<VisibilitySwitch> switches,
}) {
  if (suspended.isEmpty) return const [];
  final snapshot = stored();
  return settingsApplyingAgain(
    snapshot,
    withSwitchesShown(snapshot.general, switches),
  ).where(suspended.contains).toList();
}

/// One change a hidden feature stops from applying, as the user knows it:
/// one setting, or a few that are set together. The label is the setting's
/// own title (`hidden_settings_l10n.dart`).
///
/// Exempt settings (where data goes, what the user created, settings stored
/// only in Gecko) have no entry: they keep applying.
enum HiddenSetting {
  httpsOnly(FeatureId.privacyBasicSwitches, _httpsOnly),
  globalPrivacyControl(FeatureId.privacyBasicSwitches, _gpc),
  queryParameterStripping(FeatureId.privacyBasicSwitches, _queryStripping),
  bounceTrackingProtection(FeatureId.privacyBasicSwitches, _bounceTracking),
  trackingProtection(
    FeatureId.privacyTrackingProtectionLevel,
    _trackingProtection,
  ),
  safeBrowsingMalware(FeatureId.privacySafeBrowsingSwitches, _sbMalware),
  safeBrowsingPhishing(FeatureId.privacySafeBrowsingSwitches, _sbPhishing),
  browserLanguages(FeatureId.privacyBrowserLanguages, _locales),
  localNetworkProtection(
    FeatureId.privacyLocalNetworkBlockingSwitch,
    _lnaEnabled,
  ),
  localNetworkBlocking(FeatureId.privacyLocalNetworkBlockingSwitch, _lnaBlock),
  localNetworkTrackers(
    FeatureId.privacyLocalNetworkBlockingSwitch,
    _lnaTrackers,
  ),
  fingerprintingOverrides(FeatureId.privacyFpOverrides, _fpOverrides),
  siteIsolation(FeatureId.privacySiteIsolationSwitch, _fission),
  urlCleanerAutoApply(FeatureId.urlCleanerReviewAndReferral, _autoApply),
  urlCleanerReferral(FeatureId.urlCleanerReviewAndReferral, _referral),
  urlCleanerRules(FeatureId.urlCleanerReviewAndReferral, _cleanerRules),
  unshortener(FeatureId.linksUnshortener, _unshortener),
  newTabDefault(FeatureId.tabsIsolatedUi, _newTabDefault),
  smallWebTabDefault(FeatureId.tabsIsolatedUi, _smallWebTabDefault),
  externalLinks(FeatureId.tabsIsolatedUi, _externalLinks),
  bookmarkOpenBehavior(FeatureId.tabsIsolatedUi, _bookmarkOpen),
  sequentialTabNavigation(FeatureId.containerCore, _sequential),
  strictMode(FeatureId.containerStrictMode, _strict),
  containerAppLinks(FeatureId.containerAppLinks, _containerAppLinks),
  childTabs(FeatureId.tabsChildTabCreation, _childTabs),
  hierarchyGlyphs(FeatureId.tabsHierarchyDisplay, _hierarchyGlyphs),
  childTabPlacement(FeatureId.tabsChildTabCreation, _childTabPlacement),
  tabStacking(FeatureId.layoutStackingTabGroups, _stacking),
  toolbarButtons(FeatureId.layoutContextualToolbarAdvanced, _toolbars),
  menuLayout(FeatureId.layoutMenuCustomization, _menu),
  drawnGestures(FeatureId.inputDrawnGestures, _drawnGestures),
  tabSwipes(FeatureId.inputTabSwipeRemap, _tabSwipes),
  keyboardShortcuts(FeatureId.inputKeyboardShortcutCustomization, _shortcuts),
  localAi(FeatureId.aiLocalAi, _localAi),
  javascript(FeatureId.advancedJavascriptControl, _javascript),
  userAgent(FeatureId.advancedCustomUserAgent, _userAgent),
  thirdPartyCertificates(FeatureId.advancedThirdPartyCa, _enterpriseRoots),
  isolatedProcess(FeatureId.advancedExperimentalProcess, _isolatedProcess),
  appZygoteProcess(FeatureId.advancedExperimentalProcess, _appZygote),
  unmountEngine(FeatureId.advancedUnmountEngineOffscreen, _unmount),
  addonCollection(FeatureId.extensionsCustomCollection, _addonCollection),
  proxyLogLevel(FeatureId.diagnosticsVerboseLogs, _logLevel);

  const HiddenSetting(this.feature, this._read);

  /// The feature whose settings this is part of. Which switches suspend it
  /// is decided by the effective functions, not by this.
  final FeatureId feature;

  final Object? Function(SettingsSnapshot snapshot) _read;

  /// Whether the engine reads this only when it starts: a change, a feature
  /// hidden or shown included, applies after a restart.
  bool get appliesOnRestart => switch (this) {
    // Query parameter stripping is not here: the engine settings push it to
    // the running engine with the rest of content blocking.
    bounceTrackingProtection ||
    siteIsolation ||
    isolatedProcess ||
    appZygoteProcess ||
    addonCollection => true,
    // The engine-wide override changes at once, but tabs already open keep
    // the one they started with until a restart.
    userAgent => true,
    _ => false,
  };

  bool _sameIn(SettingsSnapshot a, SettingsSnapshot b) =>
      const DeepCollectionEquality().equals(_read(a), _read(b));
}

Object? _httpsOnly(SettingsSnapshot s) => s.engine.httpsOnlyMode;
Object? _gpc(SettingsSnapshot s) => s.engine.globalPrivacyControlEnabled;
Object? _queryStripping(SettingsSnapshot s) => s.engine.queryParameterStripping;
Object? _bounceTracking(SettingsSnapshot s) =>
    s.engine.bounceTrackingProtectionMode;
Object? _trackingProtection(SettingsSnapshot s) =>
    s.engine.trackingProtectionPolicy;
Object? _sbMalware(SettingsSnapshot s) => s.engine.safeBrowsingMalwareEnabled;
Object? _sbPhishing(SettingsSnapshot s) => s.engine.safeBrowsingPhishingEnabled;
Object? _locales(SettingsSnapshot s) => s.engine.locales;
Object? _lnaEnabled(SettingsSnapshot s) => s.engine.lnaEnabled;
Object? _lnaBlock(SettingsSnapshot s) => s.engine.lnaBlocking;
Object? _lnaTrackers(SettingsSnapshot s) => s.engine.lnaBlockTrackers;
Object? _fpOverrides(SettingsSnapshot s) =>
    s.engine.fingerprintingProtectionOverrides;
Object? _fission(SettingsSnapshot s) => s.engine.fissionEnabled;
Object? _autoApply(SettingsSnapshot s) => s.general.urlCleanerAutoApply;
Object? _referral(SettingsSnapshot s) =>
    s.general.urlCleanerAllowReferralMarketing;
Object? _cleanerRules(SettingsSnapshot s) => [
  s.general.urlCleanerCatalogUrl,
  s.general.urlCleanerHashUrl,
  s.general.urlCleanerAutoUpdate,
];
Object? _unshortener(SettingsSnapshot s) => s.general.unshortenerEnabled;
Object? _newTabDefault(SettingsSnapshot s) =>
    s.general.storedDefaultCreateTabType;
Object? _smallWebTabDefault(SettingsSnapshot s) => s.general.smallWebTabType;
Object? _externalLinks(SettingsSnapshot s) => s.general.tabIntentOpenSetting;
Object? _bookmarkOpen(SettingsSnapshot s) => s.general.bookmarkOpenSetting;
Object? _sequential(SettingsSnapshot s) =>
    s.general.sequentialTabNavigationCrossContainers;
Object? _strict(SettingsSnapshot s) => s.strictContainers;
Object? _containerAppLinks(SettingsSnapshot s) => s.appLinkContainers;
Object? _childTabs(SettingsSnapshot s) => s.general.createChildTabsOption;
Object? _hierarchyGlyphs(SettingsSnapshot s) =>
    s.general.quickTabSwitcherHierarchyGlyphs;
Object? _childTabPlacement(SettingsSnapshot s) => s.general.childTabPlacement;
Object? _stacking(SettingsSnapshot s) => s.general.tabBarStackingMode;
Object? _toolbars(SettingsSnapshot s) => [
  for (final location in ToolbarConfigLocation.values)
    for (final config in s.toolbars[location] ?? const <ToolbarButtonConfig>[])
      [config.buttonId, config.fallbackId, config.longPressAction],
];
Object? _menu(SettingsSnapshot s) => s.menu;
Object? _drawnGestures(SettingsSnapshot s) => s.gestures.enabled;
Object? _tabSwipes(SettingsSnapshot s) => [
  s.general.tabBarSwipeAction,
  s.gestures.builtInOverrides,
];
Object? _shortcuts(SettingsSnapshot s) => s.keyboardShortcuts.overrides;
Object? _localAi(SettingsSnapshot s) => s.general.enableLocalAiFeatures;
Object? _javascript(SettingsSnapshot s) => s.engine.javascriptEnabled;
Object? _userAgent(SettingsSnapshot s) => s.engine.userAgent;
Object? _enterpriseRoots(SettingsSnapshot s) => s.engine.enterpriseRootsEnabled;
Object? _isolatedProcess(SettingsSnapshot s) => s.engine.isolatedProcessEnabled;
Object? _appZygote(SettingsSnapshot s) => s.engine.appZygoteProcessEnabled;
Object? _unmount(SettingsSnapshot s) => s.general.unmountGeckoViewOffRoute;
Object? _addonCollection(SettingsSnapshot s) => s.engine.addonCollection;
Object? _logLevel(SettingsSnapshot s) => s.proxyDiagnostics.logLevel;
