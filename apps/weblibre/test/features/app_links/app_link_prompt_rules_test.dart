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
import 'package:weblibre/features/app_links/presentation/widgets/app_link_prompt_dialog.dart';

AppLinkTarget _target({
  String url = 'https://youtu.be/abc',
  String? packageName = 'com.google.android.youtube',
  bool isAmbiguous = false,
  String scopeKey = 'host:youtu.be',
  bool engineSupportsScheme = true,
}) {
  return AppLinkTarget(
    url: url,
    appName: 'YouTube',
    packageName: packageName,
    fallbackUrl: null,
    isMarketplace: false,
    isAmbiguous: isAmbiguous,
    engineSupportsScheme: engineSupportsScheme,
    scopeKey: scopeKey,
  );
}

void main() {
  group('alwaysOpenRuleFor', () {
    test('binds the resolved package to the target scope', () {
      final rule = alwaysOpenRuleFor(_target());
      expect(rule, isNotNull);
      expect(rule!.decision, AppLinkRuleDecision.alwaysOpen);
      expect(rule.scope, 'host:youtu.be');
      expect(rule.packageName, 'com.google.android.youtube');
    });

    test('cannot be remembered for an ambiguous resolution', () {
      expect(alwaysOpenRuleFor(_target(isAmbiguous: true)), isNull);
    });

    test('cannot be remembered without a bound package', () {
      expect(alwaysOpenRuleFor(_target(packageName: null)), isNull);
      expect(alwaysOpenRuleFor(_target(packageName: '')), isNull);
    });

    test('scopes a custom-scheme target by its package key', () {
      final rule = alwaysOpenRuleFor(
        _target(
          url: 'zoommtg://zoom.us/join',
          packageName: 'us.zoom.videomeetings',
          scopeKey: 'pkg:us.zoom.videomeetings',
          engineSupportsScheme: false,
        ),
      );
      expect(rule, isNotNull);
      expect(rule!.scope, 'pkg:us.zoom.videomeetings');
      expect(rule.packageName, 'us.zoom.videomeetings');
    });
  });

  group('neverOpenRuleFor', () {
    test('scopes to the target without binding a package', () {
      final rule = neverOpenRuleFor(_target());
      expect(rule.decision, AppLinkRuleDecision.neverOpen);
      expect(rule.scope, 'host:youtu.be');
      expect(rule.packageName, isNull);
    });

    test('is producible even for an ambiguous resolution', () {
      // neverOpen never launches, so it does not need a bound package.
      final rule = neverOpenRuleFor(
        _target(isAmbiguous: true, packageName: null),
      );
      expect(rule.decision, AppLinkRuleDecision.neverOpen);
      expect(rule.isValid, isTrue);
    });
  });

  group('rememberedRuleFor', () {
    test('maps explicit choices to persistent rules', () {
      expect(
        rememberedRuleFor(AppLinkDecision.open, _target())?.decision,
        AppLinkRuleDecision.alwaysOpen,
      );
      expect(
        rememberedRuleFor(AppLinkDecision.cancel, _target())?.decision,
        AppLinkRuleDecision.neverOpen,
      );
    });

    test('does not persist passive dismissal', () {
      expect(rememberedRuleFor(AppLinkDecision.dismiss, _target()), isNull);
    });
  });
}
