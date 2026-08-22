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
import 'package:weblibre/features/app_links/domain/entities/app_link_rule.dart';
import 'package:weblibre/features/app_links/domain/entities/context_app_link_policy.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';

void main() {
  group('GeneralSettings app-link fields', () {
    test('defaults are ask / empty rules / marketplace off', () {
      final settings = GeneralSettings.withDefaults();
      expect(settings.appLinksMode, AppLinksMode.ask);
      expect(settings.appLinkRules, isEmpty);
      expect(settings.appLinkMarketplaceFallback, isFalse);
    });

    test('blocking while prompting defaults to off', () {
      // The non-blocking banner is the shipped behaviour; holding a navigation is
      // opt-in because a stalled load is a worse failure than an early request.
      expect(
        GeneralSettings.withDefaults().appLinkBlockWhilePrompting,
        isFalse,
      );
    });

    test('blocking while prompting survives a round-trip', () {
      final settings = GeneralSettings.withDefaults(
        appLinkBlockWhilePrompting: true,
      );
      expect(
        GeneralSettings.fromJson(settings.toJson()).appLinkBlockWhilePrompting,
        isTrue,
      );
    });

    test('the three fields survive a toJson -> fromJson round-trip', () {
      final rule = PersistedAppLinkRule(
        decision: AppLinkRuleDecision.alwaysOpen,
        scope: 'host:youtu.be',
        packageName: 'com.google.android.youtube',
      );
      final settings = GeneralSettings.withDefaults(
        appLinksMode: AppLinksMode.always,
        appLinkRules: {rule.scope: rule},
        appLinkMarketplaceFallback: true,
      );

      final restored = GeneralSettings.fromJson(settings.toJson());

      expect(restored.appLinksMode, AppLinksMode.always);
      expect(restored.appLinkMarketplaceFallback, isTrue);
      expect(restored.appLinkRules.keys, ['host:youtu.be']);
      expect(restored.appLinkRules['host:youtu.be'], rule);
    });

    test('malformed persisted rules are dropped on read (parseAppLinkRules)', () {
      final json = GeneralSettings.withDefaults().toJson();
      // A scope key that disagrees with the rule's own scope is invalid and dropped.
      json['appLinkRules'] = {
        'host:youtu.be': {
          'decision': 'alwaysOpen',
          'scope': 'host:evil.example',
          'packageName': 'com.google.android.youtube',
        },
      };

      final restored = GeneralSettings.fromJson(json);
      expect(restored.appLinkRules, isEmpty);
    });
  });

  group('GeneralSettings per-container app-link overrides', () {
    test('defaults to an empty override map', () {
      expect(GeneralSettings.withDefaults().appLinkContextOverrides, isEmpty);
    });

    test('a container override survives a toJson -> fromJson round-trip', () {
      final rule = PersistedAppLinkRule(
        decision: AppLinkRuleDecision.neverOpen,
        scope: 'host:reddit.com',
      );
      final override = ContextAppLinkPolicy(
        mode: AppLinksMode.never,
        rules: {rule.scope: rule},
      );
      final settings = GeneralSettings.withDefaults(
        appLinkContextOverrides: {'work': override},
      );

      final restored = GeneralSettings.fromJson(settings.toJson());

      expect(restored.appLinkContextOverrides.keys, ['work']);
      final restoredOverride = restored.appLinkContextOverrides['work']!;
      expect(restoredOverride.mode, AppLinksMode.never);
      expect(restoredOverride.rules['host:reddit.com'], rule);
    });

    test('the blank override is ask / empty rules', () {
      final blank = ContextAppLinkPolicy.blank();
      expect(blank.mode, AppLinksMode.ask);
      expect(blank.rules, isEmpty);
    });

    test('malformed override entries are dropped on read', () {
      final json = GeneralSettings.withDefaults().toJson();
      json['appLinkContextOverrides'] = {
        'work': <String, dynamic>{'mode': 'not-a-mode'},
      };

      final restored = GeneralSettings.fromJson(json);
      expect(restored.appLinkContextOverrides, isEmpty);
    });
  });
}
