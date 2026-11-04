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
import 'package:flutter_test/flutter_test.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/domain/feature_policy/feature_policy.dart';
import 'package:weblibre/features/browser_actions/data/models/browser_action.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/entities/child_tab_placement.dart';
import 'package:weblibre/features/gestures/data/models/built_in_gesture.dart';
import 'package:weblibre/features/gestures/data/models/gesture_settings.dart';
import 'package:weblibre/features/keyboard_shortcuts/data/models/key_chord.dart';
import 'package:weblibre/features/keyboard_shortcuts/data/models/keyboard_shortcut_settings.dart';
import 'package:weblibre/features/user/data/models/engine_settings.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';
import 'package:weblibre/features/user/data/models/proxy_diagnostics_settings.dart';
import 'package:weblibre/features/user/domain/entities/fingerprint_overrides.dart';

/// General settings with every visibility switch at [on].
GeneralSettings _switches({required bool on}) => GeneralSettings.withDefaults(
  visibilitySwitches: {for (final s in VisibilitySwitch.values) s: on},
);

/// General settings with only [off] switched off.
GeneralSettings _without(VisibilitySwitch off) => _switches(on: true).copyWith(
  visibilitySwitches: {for (final s in VisibilitySwitch.values) s: s != off},
);

/// Every setting the table resets, changed from its fallback.
GeneralSettings _changedGeneral(GeneralSettings switches) => switches.copyWith(
  urlCleanerAutoApply: false,
  urlCleanerAllowReferralMarketing: true,
  urlCleanerCatalogUrl: 'https://example.org/rules.json',
  urlCleanerHashUrl: 'https://example.org/rules.hash',
  urlCleanerAutoUpdate: true,
  unshortenerEnabled: true,
  unshortenerToken: 'token',
  enableLocalAiFeatures: true,
  quickTabSwitcherHierarchyGlyphs: 3,
  createChildTabsOption: true,
  childTabPlacement: ChildTabPlacement.endOfList,
  storedDefaultCreateTabType: TabType.isolated,
  smallWebTabType: TabType.isolated,
  tabIntentOpenSetting: TabIntentOpenSetting.isolated,
  bookmarkOpenSetting: BookmarkOpenSetting.isolated,
  sequentialTabNavigationCrossContainers: false,
  tabBarStackingMode: TabBarStackingMode.tabGroups,
  tabBarSwipeAction: TabBarSwipeAction.navigateOrderedTabs,
  unmountGeckoViewOffRoute: true,
  syncServerOverride: 'https://sync.example.org',
);

EngineSettings _changedEngine() => EngineSettings.withDefaults(
  httpsOnlyMode: HttpsOnlyMode.disabled,
  globalPrivacyControlEnabled: false,
  queryParameterStripping: QueryParameterStripping.disabled,
  bounceTrackingProtectionMode: BounceTrackingProtectionMode.disabled,
  trackingProtectionPolicy: TrackingProtectionPolicy.custom,
  safeBrowsingMalwareEnabled: false,
  safeBrowsingPhishingEnabled: false,
  locales: const ['xx-XX'],
  lnaEnabled: false,
  lnaBlocking: false,
  lnaBlockTrackers: false,
  fingerprintingProtectionOverrides: '+AllTargets',
  fissionEnabled: false,
  javascriptEnabled: false,
  userAgent: 'Custom/1.0',
  enterpriseRootsEnabled: true,
  isolatedProcessEnabled: true,
  appZygoteProcessEnabled: true,
  dohSettingsMode: DohSettingsMode.max,
  dohProviderUrl: 'https://dns.example.org/dns-query',
  blockCookies: false,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final generalDefaults = GeneralSettings.withDefaults();
  final engineDefaults = EngineSettings.withDefaults();

  group('GeneralSettings.effective', () {
    test('everything shown: the stored values apply', () {
      final stored = _changedGeneral(_switches(on: true));
      expect(stored.effective(), stored);
    });

    test('Advanced privacy hidden: URL Cleaner review, referral and rules, '
        'and the unshortener, back at their fallbacks', () {
      final effective = _changedGeneral(
        _without(VisibilitySwitch.privacyAdvanced),
      ).effective();

      expect(
        effective.urlCleanerAutoApply,
        generalDefaults.urlCleanerAutoApply,
      );
      expect(effective.urlCleanerAutoApply, isTrue);
      expect(
        effective.urlCleanerAllowReferralMarketing,
        generalDefaults.urlCleanerAllowReferralMarketing,
      );
      expect(
        effective.urlCleanerCatalogUrl,
        generalDefaults.urlCleanerCatalogUrl,
      );
      expect(effective.urlCleanerHashUrl, generalDefaults.urlCleanerHashUrl);
      expect(
        effective.urlCleanerAutoUpdate,
        generalDefaults.urlCleanerAutoUpdate,
      );
      expect(effective.unshortenerEnabled, isFalse);
      // The token does nothing without the switch, and is kept.
      expect(effective.unshortenerToken, 'token');
    });

    test('AI hidden: on-device AI off', () {
      final effective = _changedGeneral(
        _without(VisibilitySwitch.ai),
      ).effective();
      expect(effective.enableLocalAiFeatures, isFalse);
    });

    test('tree tabs hidden: no hierarchy glyphs, no child tabs, child tabs '
        'placed after their opener', () {
      final effective = _changedGeneral(
        _without(VisibilitySwitch.treeTabs),
      ).effective();
      expect(effective.quickTabSwitcherHierarchyGlyphs, 0);
      expect(effective.createChildTabsOption, isFalse);
      expect(effective.childTabPlacement, ChildTabPlacement.afterParent);
    });

    test('isolated tabs hidden: each isolated choice becomes the nearest '
        'one without them', () {
      final effective = _changedGeneral(
        _without(VisibilitySwitch.isolatedTabs),
      ).effective();
      expect(effective.storedDefaultCreateTabType, TabType.regular);
      expect(effective.smallWebTabType, TabType.private);
      expect(effective.tabIntentOpenSetting, TabIntentOpenSetting.ask);
      expect(effective.bookmarkOpenSetting, BookmarkOpenSetting.ask);
    });

    test('isolated tabs hidden: a choice other than isolated is kept', () {
      final effective = _without(VisibilitySwitch.isolatedTabs)
          .copyWith(
            storedDefaultCreateTabType: TabType.private,
            tabIntentOpenSetting: TabIntentOpenSetting.private,
          )
          .effective();
      expect(effective.storedDefaultCreateTabType, TabType.private);
      expect(effective.tabIntentOpenSetting, TabIntentOpenSetting.private);
    });

    test('containers hidden: sequential navigation spans every container, '
        'container stacking modes draw the simple row', () {
      final effective = _changedGeneral(
        _without(VisibilitySwitch.containers),
      ).copyWith(tabBarStackingMode: TabBarStackingMode.twoLevel).effective();
      expect(effective.sequentialTabNavigationCrossContainers, isTrue);
      expect(effective.tabBarStackingMode, TabBarStackingMode.lastUsedTabs);
    });

    test('more layout options hidden: Tab Groups draw the simple row', () {
      final effective = _changedGeneral(
        _without(VisibilitySwitch.layoutAdvanced),
      ).effective();
      expect(effective.tabBarStackingMode, TabBarStackingMode.lastUsedTabs);
    });

    test('gestures hidden: tab bar swipes back at their fallback', () {
      final effective = _changedGeneral(
        _without(VisibilitySwitch.gestures),
      ).effective();
      expect(effective.tabBarSwipeAction, generalDefaults.tabBarSwipeAction);
    });

    test('expert details hidden: the engine stays mounted off-screen, the '
        'custom sync server (where data goes) is kept', () {
      final effective = _changedGeneral(
        _without(VisibilitySwitch.expertDetails),
      ).effective();
      expect(effective.unmountGeckoViewOffRoute, isFalse);
      expect(effective.syncServerOverride, 'https://sync.example.org');
    });

    test('the visibility switches themselves never change', () {
      final stored = _changedGeneral(_switches(on: false));
      expect(stored.effective().visibilitySwitches, stored.visibilitySwitches);
    });

    test('is idempotent', () {
      final once = _changedGeneral(_switches(on: false)).effective();
      expect(once.effective(), once);
    });

    test('per-container app links apply only while shown', () {
      expect(
        _switches(
          on: true,
        ).containerAppLinksApply(isolatedAppLinkSettings: true),
        isTrue,
      );
      expect(
        _without(
          VisibilitySwitch.expertDetails,
        ).containerAppLinksApply(isolatedAppLinkSettings: true),
        isFalse,
      );
      expect(
        _switches(
          on: true,
        ).containerAppLinksApply(isolatedAppLinkSettings: false),
        isFalse,
      );
    });
  });

  group('EngineSettings.effective', () {
    test('everything shown: the stored values apply', () {
      final stored = _changedEngine();
      expect(stored.effective(_switches(on: true).isFeatureShown), stored);
    });

    test('Advanced privacy hidden: basic switches, tracking protection, Safe '
        'Browsing, languages and local network blocking at their fallbacks; '
        'Secure DNS kept (where data goes)', () {
      final effective = _changedEngine().effective(
        _without(VisibilitySwitch.privacyAdvanced).isFeatureShown,
      );

      expect(effective.httpsOnlyMode, engineDefaults.httpsOnlyMode);
      expect(
        effective.globalPrivacyControlEnabled,
        engineDefaults.globalPrivacyControlEnabled,
      );
      expect(
        effective.queryParameterStripping,
        engineDefaults.queryParameterStripping,
      );
      expect(
        effective.bounceTrackingProtectionMode,
        engineDefaults.bounceTrackingProtectionMode,
      );
      expect(
        effective.trackingProtectionPolicy,
        TrackingProtectionPolicy.strict,
      );
      expect(effective.safeBrowsingMalwareEnabled, isTrue);
      expect(effective.safeBrowsingPhishingEnabled, isTrue);
      expect(effective.locales, engineDefaults.locales);
      expect(effective.lnaEnabled, isTrue);
      expect(effective.lnaBlocking, isTrue);
      expect(effective.lnaBlockTrackers, isTrue);
      // Guarded by Advanced privacy too.
      expect(
        effective.fingerprintingProtectionOverrides,
        engineDefaults.fingerprintingProtectionOverrides,
      );
      expect(effective.fissionEnabled, isTrue);

      expect(effective.dohSettingsMode, DohSettingsMode.max);
      expect(effective.dohProviderUrl, 'https://dns.example.org/dns-query');
    });

    test('expert details hidden: a custom tracking policy becomes Strict, '
        'its own fields kept; the level a user picked stays', () {
      final isShown = _without(VisibilitySwitch.expertDetails).isFeatureShown;

      final custom = _changedEngine().effective(isShown);
      expect(custom.trackingProtectionPolicy, TrackingProtectionPolicy.strict);
      expect(custom.blockCookies, isFalse);

      final standard = EngineSettings.withDefaults(
        trackingProtectionPolicy: TrackingProtectionPolicy.recommended,
      ).effective(isShown);
      expect(
        standard.trackingProtectionPolicy,
        TrackingProtectionPolicy.recommended,
      );
    });

    test('expert details hidden: JavaScript, user agent, third-party CAs, '
        'process options, add-on collection, fingerprinting overrides and '
        'site isolation at their fallbacks', () {
      final effective = _changedEngine().effective(
        _without(VisibilitySwitch.expertDetails).isFeatureShown,
      );

      expect(effective.javascriptEnabled, isTrue);
      expect(effective.userAgent, isNull);
      expect(effective.enterpriseRootsEnabled, isFalse);
      expect(effective.isolatedProcessEnabled, isFalse);
      expect(effective.appZygoteProcessEnabled, isFalse);
      expect(effective.addonCollection, isNull);
      expect(
        effective.fingerprintingProtectionOverrides,
        engineDefaults.fingerprintingProtectionOverrides,
      );
      expect(effective.fissionEnabled, isTrue);
      // Advanced privacy is still shown.
      expect(effective.httpsOnlyMode, HttpsOnlyMode.disabled);
      expect(effective.lnaBlocking, isFalse);
    });

    test('expert details hidden: the hardened fingerprinting preset, which '
        'Advanced privacy offers, keeps applying', () {
      final hardened = FingerprintOverrides.hardenedDefaults().toString();
      final stored = EngineSettings.withDefaults(
        fingerprintingProtectionOverrides: hardened,
      );

      expect(
        stored
            .effective(_without(VisibilitySwitch.expertDetails).isFeatureShown)
            .fingerprintingProtectionOverrides,
        hardened,
      );
      expect(
        stored
            .effective(
              _without(VisibilitySwitch.privacyAdvanced).isFeatureShown,
            )
            .fingerprintingProtectionOverrides,
        engineDefaults.fingerprintingProtectionOverrides,
        reason: 'the preset itself is hidden',
      );
    });

    test('is idempotent', () {
      final isShown = _switches(on: false).isFeatureShown;
      final once = _changedEngine().effective(isShown);
      expect(once.effective(isShown), once);
    });
  });

  group('other settings', () {
    test('gestures hidden: drawn gestures off, built-in swipes default', () {
      final stored = GestureSettings.withDefaults(
        enabled: true,
        builtInOverrides: {BuiltInGesture.values.first: BrowserAction.reload},
      );
      final hidden = stored.effective(
        _without(VisibilitySwitch.gestures).isFeatureShown,
      );
      expect(hidden.enabled, isFalse);
      expect(hidden.builtInOverrides, isEmpty);
      expect(stored.effective(_switches(on: true).isFeatureShown), stored);
    });

    test('custom keyboard shortcuts hidden: the defaults, master switch '
        'kept', () {
      final stored = KeyboardShortcutSettings.withDefaults(
        enabled: false,
        overrides: {
          BrowserAction.reload: [KeyChord(0x72, control: true, shift: true)],
        },
      );
      final hidden = stored.effective(
        _without(VisibilitySwitch.keyboardCustomization).isFeatureShown,
      );
      expect(hidden.overrides, isEmpty);
      expect(hidden.enabled, isFalse);
      expect(stored.effective(_switches(on: true).isFeatureShown), stored);
    });

    test('expert details hidden: proxy log level back at warnings', () {
      final stored = ProxyDiagnosticsSettings.withDefaults(
        logLevel: ProxyLogLevel.debug,
      );
      expect(
        stored
            .effective(_without(VisibilitySwitch.expertDetails).isFeatureShown)
            .logLevel,
        ProxyLogLevel.warn,
      );
      expect(stored.effective(_switches(on: true).isFeatureShown), stored);
    });
  });
}
