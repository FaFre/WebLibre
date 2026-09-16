import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:weblibre/core/design/window_size_class.dart';

void main() {
  group('WindowSizeClass.widthClassFor', () {
    test('uses exact Material 3 breakpoints, with the boundary inclusive', () {
      // The boundary value itself belongs to the *larger* class: M3 defines
      // medium as "600 and up", not "over 600".
      expect(WindowSizeClass.widthClassFor(0), WindowWidthClass.compact);
      expect(WindowSizeClass.widthClassFor(599), WindowWidthClass.compact);
      expect(WindowSizeClass.widthClassFor(599.99), WindowWidthClass.compact);
      expect(WindowSizeClass.widthClassFor(600), WindowWidthClass.medium);
      expect(WindowSizeClass.widthClassFor(839), WindowWidthClass.medium);
      expect(WindowSizeClass.widthClassFor(839.99), WindowWidthClass.medium);
      expect(WindowSizeClass.widthClassFor(840), WindowWidthClass.expanded);
      expect(WindowSizeClass.widthClassFor(1600), WindowWidthClass.expanded);
    });

    test('folds the large and extra-large M3 classes into expanded', () {
      for (final width in [840.0, 1200.0, 1599.0, 1600.0, 2560.0]) {
        expect(
          WindowSizeClass.widthClassFor(width),
          WindowWidthClass.expanded,
          reason: '$width should classify as expanded',
        );
      }
    });
  });

  group('WindowSizeClass.heightClassFor', () {
    test('uses exact Material 3 breakpoints, with the boundary inclusive', () {
      expect(WindowSizeClass.heightClassFor(0), WindowHeightClass.compact);
      expect(WindowSizeClass.heightClassFor(479), WindowHeightClass.compact);
      expect(WindowSizeClass.heightClassFor(480), WindowHeightClass.medium);
      expect(WindowSizeClass.heightClassFor(899), WindowHeightClass.medium);
      expect(WindowSizeClass.heightClassFor(900), WindowHeightClass.expanded);
      expect(WindowSizeClass.heightClassFor(2000), WindowHeightClass.expanded);
    });
  });

  group('classification is history-independent', () {
    // There is deliberately no hysteresis band: a margin would make the same
    // window classify differently depending on which direction it was resized
    // from. Growing through a boundary and shrinking back through it must
    // produce identical results at identical sizes.
    test('the same width classifies the same in both directions', () {
      const widths = [400.0, 599.0, 600.0, 700.0, 839.0, 840.0, 1000.0];

      final growing = [
        for (final w in widths) WindowSizeClass.widthClassFor(w),
      ];
      final shrinking = [
        for (final w in widths.reversed) WindowSizeClass.widthClassFor(w),
      ];

      expect(growing, shrinking.reversed.toList());
    });
  });

  group('fromSize', () {
    test('classifies both axes independently', () {
      const landscapePhone = Size(840, 390);
      final sizeClass = WindowSizeClass.fromSize(landscapePhone);

      expect(sizeClass.width, WindowWidthClass.expanded);
      expect(sizeClass.height, WindowHeightClass.compact);
    });

    test('the compact default matches a phone in portrait', () {
      expect(
        WindowSizeClass.fromSize(const Size(412, 915)),
        isNot(WindowSizeClass.compact),
        reason: 'a tall phone is height-expanded, not the compact default',
      );
      expect(
        WindowSizeClass.fromSize(const Size(412, 732)).width,
        WindowSizeClass.compact.width,
      );
    });
  });

  group('prefersSideRail', () {
    test('is false on compact width', () {
      expect(
        WindowSizeClass.fromSize(const Size(412, 915)).prefersSideRail,
        isFalse,
      );
      expect(
        WindowSizeClass.fromSize(const Size(700, 1000)).prefersSideRail,
        isTrue,
      );
      expect(
        WindowSizeClass.fromSize(const Size(1280, 800)).prefersSideRail,
        isTrue,
      );
    });
  });

  group('prefersSideRail on short windows', () {
    test('is false on a wide but short window', () {
      // Expanded by width, compact by height: a phone in landscape stays a
      // phone, and rotating it must not move the tab bar.
      expect(
        WindowSizeClass.fromSize(const Size(840, 390)).prefersSideRail,
        isFalse,
      );
      expect(
        WindowSizeClass.fromSize(const Size(1400, 300)).prefersSideRail,
        isFalse,
      );
    });
  });

  group('allowsWideRail', () {
    test('requires expanded width', () {
      expect(
        WindowSizeClass.fromSize(const Size(700, 1000)).allowsWideRail,
        isFalse,
        reason: 'medium width gets the narrow icon rail, not the tab panel',
      );
      expect(
        WindowSizeClass.fromSize(const Size(1280, 800)).allowsWideRail,
        isTrue,
      );
    });

    test('refuses a wide but short window', () {
      // A landscape phone (840x390) and a DeX strip (1400x300) are both
      // expanded by width. Neither has room for titled chips plus a stacked
      // switcher, so the height guard has to veto them.
      expect(
        WindowSizeClass.fromSize(const Size(840, 390)).allowsWideRail,
        isFalse,
      );
      expect(
        WindowSizeClass.fromSize(const Size(1400, 300)).allowsWideRail,
        isFalse,
      );
    });
  });

  group('isHeightConstrained', () {
    test('flags windows shorter than the medium height breakpoint', () {
      expect(
        WindowSizeClass.fromSize(const Size(840, 479)).isHeightConstrained,
        isTrue,
      );
      expect(
        WindowSizeClass.fromSize(const Size(840, 480)).isHeightConstrained,
        isFalse,
      );
    });
  });

  group('layout tokens', () {
    test('sheets are uncapped on compact and capped above it', () {
      expect(
        WindowSizeClass.fromSize(const Size(412, 915)).sheetMaxWidth,
        double.infinity,
        reason: 'a full-width sheet is correct on a phone',
      );
      expect(
        WindowSizeClass.fromSize(const Size(1280, 800)).sheetMaxWidth,
        ContentWidth.sheet,
      );
    });

    test('dialogs are uncapped on compact and capped above it', () {
      expect(
        WindowSizeClass.fromSize(const Size(412, 915)).dialogMaxWidth,
        double.infinity,
      );
      expect(
        WindowSizeClass.fromSize(const Size(1280, 800)).dialogMaxWidth,
        ContentWidth.dialog,
      );
    });
  });

  group('value semantics', () {
    test('equal class pairs are equal and hash equally', () {
      final a = WindowSizeClass.fromSize(const Size(1280, 800));
      final b = WindowSizeClass.fromSize(const Size(1400, 850));

      expect(a, b, reason: 'both are expanded/medium');
      expect(a.hashCode, b.hashCode);
    });

    test('differing class pairs are not equal', () {
      final a = WindowSizeClass.fromSize(const Size(1280, 800));
      final b = WindowSizeClass.fromSize(const Size(1280, 400));

      expect(a, isNot(b));
    });
  });
}
