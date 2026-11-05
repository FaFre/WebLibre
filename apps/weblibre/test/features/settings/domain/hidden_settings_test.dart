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
import 'package:weblibre/domain/feature_policy/feature_policy.dart';
import 'package:weblibre/features/geckoview/features/browser/features/contextual_toolbar/data/providers/toolbar_button_configs.dart';
import 'package:weblibre/features/geckoview/features/browser/features/contextual_toolbar/domain/entities/toolbar_config_location.dart';
import 'package:weblibre/features/geckoview/features/browser/features/menu/domain/providers/menu_layout.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/entities/child_tab_placement.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/models/container_data.dart';
import 'package:weblibre/features/gestures/data/models/gesture_settings.dart';
import 'package:weblibre/features/keyboard_shortcuts/data/models/keyboard_shortcut_settings.dart';
import 'package:weblibre/features/settings/domain/hidden_settings.dart';
import 'package:weblibre/features/settings/domain/services/legacy_container_options.dart';
import 'package:weblibre/features/user/data/models/engine_settings.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';
import 'package:weblibre/features/user/data/models/proxy_diagnostics_settings.dart';

SettingsSnapshot _snapshot({
  GeneralSettings? general,
  EngineSettings? engine,
  bool strictContainers = false,
  bool appLinkContainers = false,
}) => SettingsSnapshot(
  general: general ?? GeneralSettings.withDefaults(),
  engine: engine ?? EngineSettings.withDefaults(),
  gestures: GestureSettings.withDefaults(),
  keyboardShortcuts: KeyboardShortcutSettings.withDefaults(),
  proxyDiagnostics: ProxyDiagnosticsSettings.withDefaults(),
  toolbars: {
    for (final location in ToolbarConfigLocation.values)
      location: defaultToolbarButtonConfigsFor(location).value,
  },
  menu: defaultMenuLayout,
  strictContainers: strictContainers,
  appLinkContainers: appLinkContainers,
);

GeneralSettings _hide(GeneralSettings settings, VisibilitySwitch s) =>
    settings.withVisibilitySwitch(s, enabled: false);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('suspended', () {
    test('nothing changed: nothing suspended, whatever is hidden', () {
      var general = GeneralSettings.withDefaults();
      for (final s in VisibilitySwitch.values) {
        general = _hide(general, s);
      }
      expect(_snapshot(general: general).suspended, isEmpty);
    });

    test('a change of a shown feature applies', () {
      final snapshot = _snapshot(
        engine: EngineSettings.withDefaults(javascriptEnabled: false),
      );
      expect(snapshot.suspended, isEmpty);
    });

    test('a change of a hidden feature is suspended', () {
      final snapshot = _snapshot(
        general: _hide(
          GeneralSettings.withDefaults(),
          VisibilitySwitch.expertDetails,
        ),
        engine: EngineSettings.withDefaults(javascriptEnabled: false),
        strictContainers: true,
      );
      expect(snapshot.suspended, {
        HiddenSetting.javascript,
        HiddenSetting.strictMode,
      });
    });

    test('exempt settings are never suspended: Secure DNS, the sync '
        'server', () {
      final snapshot = _snapshot(
        general:
            _hide(
              GeneralSettings.withDefaults(syncServerOverride: 'https://x.org'),
              VisibilitySwitch.expertDetails,
            ).withVisibilitySwitch(
              VisibilitySwitch.privacyAdvanced,
              enabled: false,
            ),
        engine: EngineSettings.withDefaults(
          dohSettingsMode: DohSettingsMode.off,
        ),
      );
      expect(snapshot.suspended, isEmpty);
    });
  });

  group('the warning', () {
    test('lists what stops applying when a switch is turned off', () {
      final stored = _snapshot(
        engine: EngineSettings.withDefaults(
          javascriptEnabled: false,
          httpsOnlyMode: HttpsOnlyMode.disabled,
        ),
      );
      final next = _hide(stored.general, VisibilitySwitch.expertDetails);
      expect(settingsStoppingToApply(stored, next), [HiddenSetting.javascript]);
      expect(settingsApplyingAgain(stored, next), isEmpty);
    });

    test('hiding a second guard of a suspended change lists nothing', () {
      // A custom tracking policy needs Advanced privacy and Expert details.
      final stored = _snapshot(
        general: _hide(
          GeneralSettings.withDefaults(),
          VisibilitySwitch.privacyAdvanced,
        ),
        engine: EngineSettings.withDefaults(
          trackingProtectionPolicy: TrackingProtectionPolicy.custom,
        ),
      );
      expect(stored.suspended, contains(HiddenSetting.trackingProtection));

      final next = _hide(stored.general, VisibilitySwitch.expertDetails);
      expect(settingsStoppingToApply(stored, next), isEmpty);
    });

    test('showing a feature again lists what applies again', () {
      final stored = _snapshot(
        general: _hide(
          GeneralSettings.withDefaults(),
          VisibilitySwitch.expertDetails,
        ),
        engine: EngineSettings.withDefaults(javascriptEnabled: false),
      );
      final next = stored.general.withVisibilitySwitch(
        VisibilitySwitch.expertDetails,
        enabled: true,
      );
      expect(settingsApplyingAgain(stored, next), [HiddenSetting.javascript]);
      expect(settingsStoppingToApply(stored, next), isEmpty);
    });
  });

  test('hiding tree tabs lists the child tab placement', () {
    final stored = _snapshot(
      general: GeneralSettings.withDefaults(
        childTabPlacement: ChildTabPlacement.endOfList,
      ),
    );
    final next = _hide(stored.general, VisibilitySwitch.treeTabs);
    expect(settingsStoppingToApply(stored, next), [
      HiddenSetting.childTabPlacement,
    ]);
  });

  test('a restart is offered for settings the engine reads at start', () {
    expect(
      {
        for (final setting in HiddenSetting.values)
          if (setting.appliesOnRestart) setting,
      },
      {
        // Not query parameter stripping: content blocking reaches the running
        // engine, and its own row offers no restart.
        HiddenSetting.bounceTrackingProtection,
        HiddenSetting.siteIsolation,
        HiddenSetting.isolatedProcess,
        HiddenSetting.appZygoteProcess,
        HiddenSetting.addonCollection,
        // Open tabs keep the override they started with.
        HiddenSetting.userAgent,
      },
    );
  });

  test('every entry belongs to a feature a switch can hide', () {
    for (final setting in HiddenSetting.values) {
      expect(
        setting.feature.policy.isAlwaysShown,
        isFalse,
        reason: setting.name,
      );
    }
  });

  group('legacy container options', () {
    // Hid the container UI before visibility switches existed.
    final legacyHidden = GeneralSettings.withDefaults(showContainerUi: false);
    final strict = ContainerMetadata.withDefaults(
      contextualIdentity: 'context-1',
      strictMode: true,
    );
    final appLinks = ContainerMetadata.withDefaults(
      contextualIdentity: 'context-2',
      isolatedAppLinkSettings: true,
    );
    final plain = ContainerMetadata.withDefaults(
      contextualIdentity: 'context-3',
    );

    test('shows containers for strict mode or own app link settings', () {
      expect(
        shouldShowContainersForLegacyOptions(legacyHidden, [strict]),
        true,
      );
      expect(
        shouldShowContainersForLegacyOptions(legacyHidden, [appLinks]),
        true,
      );
    });

    test('leaves every other profile alone', () {
      expect(
        shouldShowContainersForLegacyOptions(legacyHidden, [plain]),
        false,
      );
      expect(
        shouldShowContainersForLegacyOptions(GeneralSettings.withDefaults(), [
          strict,
        ]),
        false,
        reason: 'the container UI was shown',
      );
      expect(
        shouldShowContainersForLegacyOptions(
          legacyHidden.withVisibilitySwitch(
            VisibilitySwitch.containers,
            enabled: false,
          ),
          [strict],
        ),
        false,
        reason: 'the switch was written: the user chose',
      );
    });
  });
}
