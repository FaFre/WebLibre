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
import 'package:weblibre/features/user/data/models/general_settings.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  GeneralSettings withSwitches(Map<VisibilitySwitch, bool> switches) =>
      GeneralSettings.withDefaults().copyWith(visibilitySwitches: switches);

  group('an unwritten split view switch starts like layout customization', () {
    test('hidden where layout customization is hidden (Average)', () {
      final settings = withSwitches({VisibilitySwitch.layoutAdvanced: false});

      expect(
        settings.isVisibilitySwitchShown(VisibilitySwitch.splitView),
        isFalse,
      );
      expect(settings.isFeatureShown(FeatureId.tabsSplitView), isFalse);
    });

    test('shown where layout customization is shown', () {
      final settings = withSwitches({VisibilitySwitch.layoutAdvanced: true});

      expect(settings.isFeatureShown(FeatureId.tabsSplitView), isTrue);
    });

    test('shown where neither switch was ever written', () {
      expect(withSwitches({}).isFeatureShown(FeatureId.tabsSplitView), isTrue);
    });

    test('once written, it no longer follows layout customization', () {
      expect(
        withSwitches({
          VisibilitySwitch.layoutAdvanced: false,
          VisibilitySwitch.splitView: true,
        }).isFeatureShown(FeatureId.tabsSplitView),
        isTrue,
      );
      expect(
        withSwitches({
          VisibilitySwitch.layoutAdvanced: true,
          VisibilitySwitch.splitView: false,
        }).isFeatureShown(FeatureId.tabsSplitView),
        isFalse,
      );
    });
  });

  test('startsLike never leads back to the same switch', () {
    for (final visibilitySwitch in VisibilitySwitch.values) {
      final seen = {visibilitySwitch};
      for (var next = visibilitySwitch.startsLike; next != null;) {
        expect(seen.add(next), isTrue, reason: visibilitySwitch.name);
        next = next.startsLike;
      }
    }
  });
}
