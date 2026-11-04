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
import 'package:flutter_test/flutter_test.dart';
import 'package:weblibre/domain/feature_policy/feature_policy.dart';
import 'package:weblibre/features/geckoview/features/search/domain/providers/search_modules_view.dart';
import 'package:weblibre/features/onboarding/domain/services/preset_bindings.dart';

/// The rules of the feature policy that its types cannot express. Every
/// browser action having one owner, every switch having an existing-install
/// value and `follows` / `uiRequires` being acyclic are compile-time already.
void main() {
  final switchFeatures = {
    for (final s in VisibilitySwitch.values) s.featureId: s,
  };
  final features = [
    for (final feature in FeatureId.values)
      if (!switchFeatures.containsKey(feature)) feature,
  ];

  test('feature ids are unique and well-formed', () {
    final ids = [for (final feature in FeatureId.values) feature.id];
    expect(ids.toSet(), hasLength(ids.length));
    for (final id in ids) {
      expect(id, matches(RegExp(r'^[a-z][a-z_]*\.[a-z0-9_]+$')), reason: id);
    }
  });

  test('the switch entries are exactly the VisibilitySwitches', () {
    for (final feature in FeatureId.values) {
      expect(
        switchFeatures.containsKey(feature),
        feature.id.startsWith('switch.'),
        reason: feature.id,
      );
    }
    for (final MapEntry(key: feature, value: visibilitySwitch)
        in switchFeatures.entries) {
      final policy = feature.policy;
      expect(policy.availability, FeatureAvailability.guarded);
      expect(policy.switches, isEmpty, reason: visibilitySwitch.name);
      expect(policy.uiRequires, isEmpty, reason: visibilitySwitch.name);
      for (final preset in SetupPreset.values) {
        expect(
          policy.resolvedValue(preset),
          anyOf(PolicyToken.enabled, PolicyToken.disabled),
          reason: '${visibilitySwitch.name} (${preset.name})',
        );
      }
    }
  });

  test('a guarded feature names its switches, any other none', () {
    for (final feature in features) {
      final policy = feature.policy;
      final switches = policy.switches;
      expect(switches.toSet(), hasLength(switches.length), reason: feature.id);
      if (policy.availability == FeatureAvailability.guarded) {
        expect(switches, isNotEmpty, reason: feature.id);
      } else {
        expect(switches, isEmpty, reason: feature.id);
      }
    }
  });

  test('uiRequires names other, user-facing features', () {
    for (final feature in FeatureId.values) {
      for (final required in feature.policy.uiRequires) {
        expect(required, isNot(feature), reason: feature.id);
        expect(
          required.policy.availability,
          isNot(FeatureAvailability.notUserFacing),
          reason: '${feature.id} needs ${required.id}',
        );
      }
    }
  });

  test('values that say shown or hidden agree with the switches', () {
    const shownTokens = {PolicyToken.uiShown, PolicyToken.shown};
    const hiddenTokens = {PolicyToken.uiHidden, PolicyToken.hiddenShowSummary};
    for (final feature in features) {
      for (final preset in SetupPreset.values) {
        final token = feature.policy.resolvedValue(preset);
        if (!shownTokens.contains(token) && !hiddenTokens.contains(token)) {
          continue;
        }
        final shown = feature.policy.isShownWith(
          (s) => presetSwitchValue(s, preset),
        );
        expect(
          shownTokens.contains(token),
          shown,
          reason: '${feature.id} (${preset.name}: ${token.name})',
        );
      }
    }
  });

  test('the calm new-tab layout lists every new-tab module once', () {
    final listed = [for (final m in calmNewTabLayout) m.type];
    expect(listed.toSet(), hasLength(listed.length));
    expect(listed.toSet(), {
      for (final d in ModuleSurface.newTab.defaultModules) d.type,
    });
  });
}
