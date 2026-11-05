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
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:weblibre/domain/feature_policy/feature_policy.dart';
import 'package:weblibre/features/geckoview/features/search/domain/providers/search_modules_view.dart';
import 'package:weblibre/features/user/data/models/engine_settings.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';

/// How a feature's initial value ([FeaturePolicy.initial]) reaches the app.
///
/// The values come from the feature policy; this table only says *where*
/// each one is written. Every feature whose value for some preset is not
/// [PolicyToken.unchangedAppDefault] must have a binding —
/// `setup_policy_test.dart` fails otherwise, so a new value can never be
/// silently ignored.
sealed class PresetBinding {
  const PresetBinding();
}

/// Written into the general settings.
final class GeneralPresetBinding extends PresetBinding {
  const GeneralPresetBinding(this.apply);

  /// Applies [PolicyToken] to the settings. Throws [UnsupportedError] for a
  /// token this binding cannot express.
  final GeneralSettings Function(GeneralSettings settings, PolicyToken token)
  apply;
}

/// Written into the engine settings.
final class EnginePresetBinding extends PresetBinding {
  const EnginePresetBinding(this.apply);

  final EngineSettings Function(EngineSettings settings, PolicyToken token)
  apply;
}

/// The code default already is the policy value, so the commit writes
/// nothing. [matchesCodeDefault] lets the test prove it.
final class CodeDefaultPresetBinding extends PresetBinding {
  const CodeDefaultPresetBinding(this.matchesCodeDefault);

  final bool Function(PolicyToken token) matchesCodeDefault;
}

/// Has no setting of its own: always active, a safeguard, or decided at
/// runtime. [reason] says which.
final class NoSettingPresetBinding extends PresetBinding {
  const NoSettingPresetBinding(this.reason);

  final String reason;
}

/// Handled by a dedicated part of the onboarding draft: an answer, the
/// hardening baseline, an external step, a module layout or a visibility
/// switch.
final class DraftPresetBinding extends PresetBinding {
  const DraftPresetBinding(this.part);

  final DraftPart part;
}

enum DraftPart {
  /// Asked in the onboarding's Search and Layout steps (`user_choice`).
  answers,

  /// The engine hardening preference groups.
  hardeningBaseline,

  /// Installing uBlock Origin, after the settings writes.
  ublockInstall,

  /// uBlock Origin's optimized filter lists, after the install.
  ublockFilters,

  /// A module layout (`calm_new_tab`).
  moduleLayout,

  /// Shown or hidden by a visibility switch; the switch row carries the value.
  visibilitySwitch,
}

Never _unsupported(FeatureId feature, PolicyToken token) =>
    throw UnsupportedError('${feature.id}: no binding for ${token.name}');

bool _enabled(FeatureId feature, PolicyToken token) => switch (token) {
  PolicyToken.enabled => true,
  PolicyToken.disabled => false,
  _ => _unsupported(feature, token),
};

/// Where each feature's initial value goes. See [PresetBinding].
final Map<FeatureId, PresetBinding> presetBindings = {
  FeatureId.coreBrowsing: const NoSettingPresetBinding('always active'),
  FeatureId.coreTabs: const NoSettingPresetBinding('always active'),
  FeatureId.searchDefaultProvider: const DraftPresetBinding(DraftPart.answers),
  FeatureId.searchLocalResults: CodeDefaultPresetBinding(
    (token) =>
        GeneralSettings.withDefaults().enableLocalSearchIndex ==
        _enabled(FeatureId.searchLocalResults, token),
  ),
  FeatureId.libraryBookmarkOpenBehavior: GeneralPresetBinding(
    (settings, token) => switch (token) {
      PolicyToken.regularTab => settings.copyWith(
        bookmarkOpenSetting: BookmarkOpenSetting.regular,
      ),
      _ => _unsupported(FeatureId.libraryBookmarkOpenBehavior, token),
    },
  ),
  FeatureId.homeLayoutNewTab: const DraftPresetBinding(DraftPart.moduleLayout),
  FeatureId.layoutBasic: const DraftPresetBinding(DraftPart.answers),
  FeatureId.inputKeyboardShortcuts: CodeDefaultPresetBinding(
    // KeyboardShortcutSettings.enabled defaults to true; checked by the test
    // against the model, which lives in another feature.
    (token) => token == PolicyToken.enabled,
  ),
  FeatureId.privacyEtp: CodeDefaultPresetBinding(
    (token) =>
        _enabled(FeatureId.privacyEtp, token) &&
        EngineSettings.withDefaults().trackingProtectionPolicy ==
            TrackingProtectionPolicy.strict,
  ),
  FeatureId.privacyDoh: CodeDefaultPresetBinding(
    (token) =>
        _enabled(FeatureId.privacyDoh, token) &&
        EngineSettings.withDefaults().dohSettingsMode ==
            DohSettingsMode.increased,
  ),
  FeatureId.privacyHttpsOnly: CodeDefaultPresetBinding(
    (token) =>
        _enabled(FeatureId.privacyHttpsOnly, token) &&
        EngineSettings.withDefaults().httpsOnlyMode == HttpsOnlyMode.enabled,
  ),
  FeatureId.privacyGpc: CodeDefaultPresetBinding(
    (token) =>
        EngineSettings.withDefaults().globalPrivacyControlEnabled ==
        _enabled(FeatureId.privacyGpc, token),
  ),
  FeatureId.privacyQueryStripping: CodeDefaultPresetBinding(
    (token) =>
        _enabled(FeatureId.privacyQueryStripping, token) &&
        EngineSettings.withDefaults().queryParameterStripping ==
            QueryParameterStripping.enabled,
  ),
  FeatureId.privacyBounceTracking: CodeDefaultPresetBinding(
    (token) =>
        _enabled(FeatureId.privacyBounceTracking, token) &&
        EngineSettings.withDefaults().bounceTrackingProtectionMode ==
            BounceTrackingProtectionMode.enabled,
  ),
  // dom.security.framebusting_intervention.enabled, in the Privacy hardening
  // group.
  FeatureId.privacyThirdPartyRedirectBlocking: const DraftPresetBinding(
    DraftPart.hardeningBaseline,
  ),
  FeatureId.privacySafeBrowsing: CodeDefaultPresetBinding((token) {
    final defaults = EngineSettings.withDefaults();
    final expected = _enabled(FeatureId.privacySafeBrowsing, token);
    return defaults.safeBrowsingMalwareEnabled == expected &&
        defaults.safeBrowsingPhishingEnabled == expected;
  }),
  FeatureId.privacySiteIsolation: CodeDefaultPresetBinding(
    (token) =>
        EngineSettings.withDefaults().fissionEnabled ==
        _enabled(FeatureId.privacySiteIsolation, token),
  ),
  FeatureId.privacyLocalNetworkProtection: EnginePresetBinding((
    settings,
    token,
  ) {
    final on = _enabled(FeatureId.privacyLocalNetworkProtection, token);
    return settings.copyWith(lnaEnabled: on, lnaBlocking: on);
  }),
  FeatureId.privacyEngineHardeningBaseline: const DraftPresetBinding(
    DraftPart.hardeningBaseline,
  ),
  // Follows the two baselines above: the switches show them, they write
  // nothing of their own.
  FeatureId.privacyCompleteHardeningSwitch: const DraftPresetBinding(
    DraftPart.hardeningBaseline,
  ),
  FeatureId.privacyLocalNetworkBlockingSwitch: EnginePresetBinding(
    (settings, token) => settings.copyWith(
      lnaBlocking: _enabled(FeatureId.privacyLocalNetworkBlockingSwitch, token),
    ),
  ),
  FeatureId.urlCleanerCleaning: GeneralPresetBinding(
    (settings, token) => switch (token) {
      PolicyToken.autoApply => settings.copyWith(
        urlCleanerEnabled: true,
        urlCleanerAutoApply: true,
      ),
      // Cleans after asking: the review prompt.
      PolicyToken.ask => settings.copyWith(
        urlCleanerEnabled: true,
        urlCleanerAutoApply: false,
      ),
      _ => _unsupported(FeatureId.urlCleanerCleaning, token),
    },
  ),
  FeatureId.linksUnshortener: CodeDefaultPresetBinding(
    (token) =>
        GeneralSettings.withDefaults().unshortenerEnabled ==
        _enabled(FeatureId.linksUnshortener, token),
  ),
  FeatureId.extensionsUblockStarter: const DraftPresetBinding(
    DraftPart.ublockInstall,
  ),
  FeatureId.extensionsUblockOptimizedFilters: const DraftPresetBinding(
    DraftPart.ublockFilters,
  ),
  FeatureId.extensionsAllowUnsigned: const NoSettingPresetBinding(
    'xpinstall.signatures.required stays at the engine default; never written',
  ),
  FeatureId.linksIncomingDefault: GeneralPresetBinding(
    (settings, token) => switch (token) {
      PolicyToken.regularTab => settings.copyWith(
        tabIntentOpenSetting: TabIntentOpenSetting.regular,
      ),
      _ => _unsupported(FeatureId.linksIncomingDefault, token),
    },
  ),
  FeatureId.linksOutgoingAppHandoff: CodeDefaultPresetBinding(
    (token) =>
        token == PolicyToken.ask &&
        GeneralSettings.withDefaults().appLinksMode == AppLinksMode.ask,
  ),
  FeatureId.linksSensitiveContextConfirmation: const NoSettingPresetBinding(
    'safeguard: applies in every preset and is never remembered',
  ),
  FeatureId.linksCustomTabs: CodeDefaultPresetBinding(
    (token) =>
        GeneralSettings.withDefaults().customTabsEnabled ==
        _enabled(FeatureId.linksCustomTabs, token),
  ),
  FeatureId.securityScreenshotProtection: CodeDefaultPresetBinding(
    (token) =>
        GeneralSettings.withDefaults().screenshotProtectionEnabled ==
        _enabled(FeatureId.securityScreenshotProtection, token),
  ),
  FeatureId.dataHistoryRetention: CodeDefaultPresetBinding(
    (token) =>
        token == PolicyToken.days90 &&
        GeneralSettings.withDefaults().historyAutoCleanInterval ==
            const Duration(days: 90),
  ),
  FeatureId.dataAutoDelete: CodeDefaultPresetBinding(
    (token) =>
        token == PolicyToken.disabled &&
        GeneralSettings.withDefaults().autoDeleteBrowsingData == null,
  ),
  FeatureId.dataAutoClearUnassignedTabs: CodeDefaultPresetBinding(
    (token) =>
        token == PolicyToken.disabled &&
        GeneralSettings.withDefaults().unassignedTabsAutoCleanInterval ==
            Duration.zero,
  ),
  FeatureId.contentReaderMode: CodeDefaultPresetBinding(
    (token) =>
        GeneralSettings.withDefaults().enableReadability ==
        _enabled(FeatureId.contentReaderMode, token),
  ),
  FeatureId.contentEnforceReaderMode: CodeDefaultPresetBinding(
    (token) =>
        GeneralSettings.withDefaults().enforceReadability ==
        _enabled(FeatureId.contentEnforceReaderMode, token),
  ),
  FeatureId.downloadsExternalManager: CodeDefaultPresetBinding(
    (token) =>
        GeneralSettings.withDefaults().useExternalDownloadManager ==
        _enabled(FeatureId.downloadsExternalManager, token),
  ),
  FeatureId.storageIsolatedContext: const NoSettingPresetBinding(
    'runtime capability with no user control',
  ),
  FeatureId.webappsStoragePicker: const DraftPresetBinding(
    DraftPart.visibilitySwitch,
  ),
  FeatureId.containerCore: const DraftPresetBinding(DraftPart.visibilitySwitch),
  FeatureId.tabsIsolatedUi: const DraftPresetBinding(
    DraftPart.visibilitySwitch,
  ),
  FeatureId.tabsTreeRelationships: const NoSettingPresetBinding(
    'always recorded; Tab Groups and Tree view read it',
  ),
  FeatureId.tabsChildTabCreation: CodeDefaultPresetBinding(
    (token) =>
        GeneralSettings.withDefaults().createChildTabsOption ==
        _enabled(FeatureId.tabsChildTabCreation, token),
  ),
  FeatureId.layoutStackingSimple: GeneralPresetBinding(
    (settings, token) => switch (token) {
      PolicyToken.recentlyUsedTabs => settings.copyWith(
        tabBarStackingMode: TabBarStackingMode.lastUsedTabs,
      ),
      _ => _unsupported(FeatureId.layoutStackingSimple, token),
    },
  ),
  FeatureId.inputDrawnGestures: CodeDefaultPresetBinding(
    // GestureSettings.enabled defaults to false; checked by the test against
    // the model, which lives in another feature.
    (token) => token == PolicyToken.disabled,
  ),
  FeatureId.connectionsFailClosed: const NoSettingPresetBinding(
    'safeguard: a tab that needs a stopped connection is always blocked',
  ),
  FeatureId.aiLocalAi: GeneralPresetBinding(
    (settings, token) => settings.copyWith(
      enableLocalAiFeatures: _enabled(FeatureId.aiLocalAi, token),
    ),
  ),
  // Follows `ai.local_ai`, which has no separate switch today.
  FeatureId.aiContainerSuggestions: GeneralPresetBinding(
    (settings, token) => settings.copyWith(
      enableLocalAiFeatures: _enabled(FeatureId.aiContainerSuggestions, token),
    ),
  ),
  FeatureId.advancedJavascriptControl: CodeDefaultPresetBinding(
    (token) =>
        EngineSettings.withDefaults().javascriptEnabled ==
        _enabled(FeatureId.advancedJavascriptControl, token),
  ),
  FeatureId.advancedThirdPartyCa: CodeDefaultPresetBinding(
    (token) =>
        EngineSettings.withDefaults().enterpriseRootsEnabled ==
        _enabled(FeatureId.advancedThirdPartyCa, token),
  ),
  FeatureId.advancedExperimentalProcess: CodeDefaultPresetBinding(
    (token) =>
        EngineSettings.withDefaults().appZygoteProcessEnabled ==
        _enabled(FeatureId.advancedExperimentalProcess, token),
  ),
  FeatureId.advancedUnmountEngineOffscreen: const NoSettingPresetBinding(
    'always applied on Android 12 and lower; optional (default off) on 13+',
  ),
  for (final visibilitySwitch in VisibilitySwitch.values)
    visibilitySwitch.featureId: const DraftPresetBinding(
      DraftPart.visibilitySwitch,
    ),
};

/// [preset]'s initial general settings on top of [settings]: every
/// [GeneralPresetBinding] with a value other than
/// [PolicyToken.unchangedAppDefault],
/// and every visibility switch.
GeneralSettings applyGeneralPreset(
  GeneralSettings settings,
  SetupPreset preset,
) {
  final updated = _applyBindings(
    settings,
    preset,
    (binding) => binding is GeneralPresetBinding ? binding.apply : null,
  );

  // Written directly rather than through withVisibilitySwitch: these are the
  // preset's own values, so nothing is turned on that the preset left off and
  // the legacy settings keep their defaults.
  return updated.copyWith(
    visibilitySwitches: {
      ...updated.visibilitySwitches,
      for (final visibilitySwitch in VisibilitySwitch.values)
        visibilitySwitch: presetSwitchValue(visibilitySwitch, preset),
    },
  );
}

/// [preset]'s initial engine settings on top of [settings].
EngineSettings applyEnginePreset(EngineSettings settings, SetupPreset preset) =>
    _applyBindings(
      settings,
      preset,
      (binding) => binding is EnginePresetBinding ? binding.apply : null,
    );

/// [settings] with [preset]'s value written by every binding [applierOf]
/// gives an applier for, in [presetBindings] order. Features that keep the
/// app default are skipped.
S _applyBindings<S>(
  S settings,
  SetupPreset preset,
  S Function(S settings, PolicyToken token)? Function(PresetBinding binding)
  applierOf,
) {
  var updated = settings;
  for (final MapEntry(key: feature, value: binding) in presetBindings.entries) {
    final apply = applierOf(binding);
    if (apply == null) continue;
    final token = feature.policy.resolvedValue(preset);
    if (token == PolicyToken.unchangedAppDefault) continue;
    updated = apply(updated, token);
  }
  return updated;
}

/// [visibilitySwitch]'s initial value for [preset].
bool presetSwitchValue(VisibilitySwitch visibilitySwitch, SetupPreset preset) =>
    switch (visibilitySwitch.policy.resolvedValue(preset)) {
      PolicyToken.enabled => true,
      PolicyToken.disabled => false,
      final token => _unsupported(visibilitySwitch.featureId, token),
    };

/// Whether [feature]'s value for [preset] is the given [token].
bool presetValueIs(FeatureId feature, SetupPreset preset, PolicyToken token) =>
    feature.policy.resolvedValue(preset) == token;

/// The new-tab layout for [preset], in display order, or null when the
/// preset keeps the code default.
List<({SearchModuleType type, bool visible})>? presetNewTabLayout(
  SetupPreset preset,
) => switch (FeatureId.homeLayoutNewTab.policy.resolvedValue(preset)) {
  PolicyToken.unchangedAppDefault => null,
  PolicyToken.calmNewTab => calmNewTabLayout,
  final token => _unsupported(FeatureId.homeLayoutNewTab, token),
};

/// [PolicyToken.calmNewTab]: the essentials up front, the busier modules
/// hidden until the user turns them on. Lists every new-tab module.
const calmNewTabLayout = <({SearchModuleType type, bool visible})>[
  (type: SearchModuleType.topSites, visible: true),
  (type: SearchModuleType.recentSearches, visible: true),
  (type: SearchModuleType.frequentBangs, visible: true),
  (type: SearchModuleType.recentTabs, visible: true),
  (type: SearchModuleType.recentHistory, visible: true),
  (type: SearchModuleType.recentArticles, visible: true),
  (type: SearchModuleType.historyHighlights, visible: false),
  (type: SearchModuleType.containers, visible: false),
  (type: SearchModuleType.actions, visible: false),
  (type: SearchModuleType.quote, visible: false),
];
