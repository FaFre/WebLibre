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
import 'package:weblibre/features/app_links/domain/entities/app_link_rule.dart';

void main() {
  group('PersistedAppLinkRule', () {
    test('round-trips through json', () {
      final rule = PersistedAppLinkRule(
        decision: AppLinkRuleDecision.alwaysOpen,
        scope: 'host:youtube.com',
        packageName: 'com.google.android.youtube',
      );
      final restored = PersistedAppLinkRule.fromJson(rule.toJson());
      expect(restored, rule);
    });

    test('validity requires a package for alwaysOpen and a known prefix', () {
      expect(
        PersistedAppLinkRule(
          decision: AppLinkRuleDecision.alwaysOpen,
          scope: 'host:x.com',
          packageName: 'pkg',
        ).isValid,
        isTrue,
      );
      expect(
        PersistedAppLinkRule(
          decision: AppLinkRuleDecision.alwaysOpen,
          scope: 'host:x.com',
        ).isValid,
        isFalse,
      );
      expect(
        PersistedAppLinkRule(
          decision: AppLinkRuleDecision.neverOpen,
          scope: 'host:x.com',
        ).isValid,
        isTrue,
      );
      expect(
        PersistedAppLinkRule(
          decision: AppLinkRuleDecision.neverOpen,
          scope: 'notaprefix',
        ).isValid,
        isFalse,
      );
    });
  });

  group('parseAppLinkRules', () {
    test('keeps valid rules keyed by matching scope', () {
      final parsed = parseAppLinkRules({
        'host:youtube.com': {
          'decision': 'alwaysOpen',
          'scope': 'host:youtube.com',
          'packageName': 'com.google.android.youtube',
        },
        'pkg:us.zoom.videomeetings': {
          'decision': 'neverOpen',
          'scope': 'pkg:us.zoom.videomeetings',
        },
      });
      expect(parsed.length, 2);
      expect(
        parsed['host:youtube.com']!.decision,
        AppLinkRuleDecision.alwaysOpen,
      );
    });

    test('drops entries whose map key disagrees with the rule scope', () {
      final parsed = parseAppLinkRules({
        'host:wrong.com': {'decision': 'neverOpen', 'scope': 'host:right.com'},
      });
      expect(parsed, isEmpty);
    });

    test('drops malformed and invalid rules', () {
      final parsed = parseAppLinkRules({
        'host:a.com': {'decision': 'garbage', 'scope': 'host:a.com'},
        'host:b.com': {
          'decision': 'alwaysOpen',
          'scope': 'host:b.com',
        }, // missing package
        'host:c.com': 'not a map',
      });
      expect(parsed, isEmpty);
    });

    test('null input yields an empty map', () {
      expect(parseAppLinkRules(null), isEmpty);
    });
  });
}
