import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:weblibre/presentation/main_app.dart';

void main() {
  group('applyAppMediaQueryOverrides', () {
    test('returns the original media query when no overrides are enabled', () {
      const mediaQuery = MediaQueryData();

      final result = applyAppMediaQueryOverrides(
        mediaQuery: mediaQuery,
        uiScaleFactor: 1.0,
        disableAnimations: false,
      );

      expect(result, same(mediaQuery));
    });

    test(
      'preserves the system animation preference when app override is off',
      () {
        const mediaQuery = MediaQueryData(disableAnimations: true);

        final result = applyAppMediaQueryOverrides(
          mediaQuery: mediaQuery,
          uiScaleFactor: 1.0,
          disableAnimations: false,
        );

        expect(result.disableAnimations, isTrue);
        expect(result, same(mediaQuery));
      },
    );

    test('forces animations off when the app setting is enabled', () {
      const mediaQuery = MediaQueryData(disableAnimations: false);

      final result = applyAppMediaQueryOverrides(
        mediaQuery: mediaQuery,
        uiScaleFactor: 1.0,
        disableAnimations: true,
      );

      expect(result.disableAnimations, isTrue);
    });

    test('applies ui scale on top of the base text scaler', () {
      const mediaQuery = MediaQueryData();

      final result = applyAppMediaQueryOverrides(
        mediaQuery: mediaQuery,
        uiScaleFactor: 1.25,
        disableAnimations: false,
      );

      expect(result.textScaler.scale(20), 25);
    });
  });
}
