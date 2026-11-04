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
import 'package:flutter/widgets.dart';
import 'package:weblibre/features/settings/domain/hidden_settings.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';

extension HiddenSettingL10n on HiddenSetting {
  /// The setting's own title, as its Settings row shows it.
  String label(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return switch (this) {
      HiddenSetting.httpsOnly => l10n.settings_httpsOnlyModeTitle,
      HiddenSetting.globalPrivacyControl =>
        l10n.settings_globalPrivacyControlTitle,
      HiddenSetting.queryParameterStripping =>
        l10n.settings_queryParameterStrippingTitle,
      HiddenSetting.bounceTrackingProtection =>
        l10n.settings_bounceTrackingProtectionTitle,
      HiddenSetting.trackingProtection =>
        l10n.settings_enhancedTrackingProtectionTitle,
      HiddenSetting.safeBrowsingMalware =>
        l10n.settings_safeBrowsingMalwareTitle,
      HiddenSetting.safeBrowsingPhishing =>
        l10n.settings_safeBrowsingPhishingTitle,
      HiddenSetting.browserLanguages => l10n.settings_browserLanguagesTitle,
      HiddenSetting.localNetworkProtection => l10n.settings_lnaEnabledTitle,
      HiddenSetting.localNetworkBlocking => l10n.settings_lnaBlockingTitle,
      HiddenSetting.localNetworkTrackers => l10n.settings_lnaBlockTrackersTitle,
      HiddenSetting.fingerprintingOverrides =>
        l10n.settings_indexAdvancedFingerprintingProtectionTitle,
      HiddenSetting.siteIsolation => l10n.settings_fissionEnabledTitle,
      HiddenSetting.urlCleanerAutoApply =>
        l10n.visibilitySwitch_hiddenSettingUrlCleanerAutoApply,
      HiddenSetting.urlCleanerReferral => l10n.openLinkTools_allowReferralTitle,
      HiddenSetting.urlCleanerRules =>
        l10n.visibilitySwitch_hiddenSettingUrlCleanerRules,
      HiddenSetting.unshortener => l10n.settings_unshortenerTitle,
      HiddenSetting.newTabDefault => l10n.settings_newTabDefaultTitle,
      HiddenSetting.smallWebTabDefault => l10n.settings_smallWebTabDefaultTitle,
      HiddenSetting.externalLinks => l10n.settings_externalLinkHandlingTitle,
      HiddenSetting.bookmarkOpenBehavior =>
        l10n.settings_bookmarkOpenBehaviorTitle,
      HiddenSetting.sequentialTabNavigation =>
        l10n.settings_sequentialTabNavigationTitle,
      HiddenSetting.strictMode => l10n.tabs_strictMode,
      HiddenSetting.containerAppLinks => l10n.tabs_isolatedAppLinkSettings,
      HiddenSetting.childTabs => l10n.settings_createChildTabsTitle,
      HiddenSetting.hierarchyGlyphs => l10n.settings_hierarchyDepthTitle,
      HiddenSetting.childTabPlacement => l10n.settings_childTabPlacementTitle,
      HiddenSetting.tabStacking => l10n.settings_tabStackingTitle,
      HiddenSetting.toolbarButtons =>
        l10n.visibilitySwitch_hiddenSettingToolbarButtons,
      HiddenSetting.menuLayout => l10n.settings_customizeMenu,
      HiddenSetting.drawnGestures => l10n.gestures_drawnGesturesTitle,
      HiddenSetting.tabSwipes => l10n.settings_tabBarSwipesTitle,
      HiddenSetting.keyboardShortcuts =>
        l10n.visibilitySwitch_keyboardCustomizationLabel,
      HiddenSetting.localAi => l10n.settings_onDeviceAiTitle,
      HiddenSetting.javascript => l10n.settings_javascriptTitle,
      HiddenSetting.userAgent => l10n.settings_userAgentLabel,
      HiddenSetting.thirdPartyCertificates =>
        l10n.settings_enterpriseRootsTitle,
      HiddenSetting.isolatedProcess =>
        l10n.settings_isolatedContentProcessTitle,
      HiddenSetting.appZygoteProcess => l10n.settings_appZygoteProcessTitle,
      HiddenSetting.unmountEngine => l10n.settings_unmountGeckoViewTitle,
      HiddenSetting.addonCollection => l10n.settings_addonCollectionTitle,
      HiddenSetting.proxyLogLevel => l10n.proxy_logLevelSheetTitle,
    };
  }
}
