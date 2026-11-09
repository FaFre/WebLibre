import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:weblibre/features/geckoview/features/split_view/domain/entities/split_pair.dart';
import 'package:weblibre/features/geckoview/features/split_view/domain/services/split_presentation.dart';

SplitPair _pair({
  SplitLayoutPreference layout = SplitLayoutPreference.automatic,
  double sideBySideRatio = 0.5,
  double stackedRatio = 0.5,
  bool focusedOnly = false,
}) => SplitPair(
  pairId: 'p',
  firstTabId: 'a',
  secondTabId: 'b',
  layout: layout,
  sideBySideRatio: sideBySideRatio,
  stackedRatio: stackedRatio,
  focusedOnly: focusedOnly,
);

SplitPresentation _resolve(
  SplitPair pair,
  Size? content, {
  bool keyboard = false,
  Rect? hinge,
}) => resolveSplitPresentation(
  pair: pair,
  content: content,
  keyboardVisible: keyboard,
  hinge: hinge,
);

void main() {
  // Automatic: 2 * 280 + 8 = 568 wide; 2 * 200 + 8 = 408 tall.
  const phonePortrait = Size(360, 640);
  const phoneLandscape = Size(740, 330);
  const tablet = Size(1000, 700);

  group('automatic', () {
    test('portrait stacks, landscape goes side by side', () {
      expect(_resolve(_pair(), phonePortrait).mode, SplitMode.stacked);
      expect(_resolve(_pair(), phoneLandscape).mode, SplitMode.sideBySide);
    });
  });

  group('an explicit preference', () {
    // Shown down to the explicit minimum: 2 * 120 + 8 = 248 wide,
    // 2 * 100 + 8 = 208 tall.
    test('side by side is shown on a phone in portrait', () {
      final pair = _pair(layout: SplitLayoutPreference.sideBySide);
      final shown = _resolve(pair, phonePortrait);
      expect(shown.mode, SplitMode.sideBySide);
      expect(shown.ratio, 0.5);
    });

    test('stacked is shown on a phone in landscape', () {
      final pair = _pair(layout: SplitLayoutPreference.stacked);
      expect(_resolve(pair, phoneLandscape).mode, SplitMode.stacked);
    });

    test('the ratio still stops at the drag minimum', () {
      final pair = _pair(
        layout: SplitLayoutPreference.sideBySide,
        sideBySideRatio: 0.05,
      );
      expect(_resolve(pair, phonePortrait).ratio, closeTo(48 / 352, 1e-9));
    });

    test('one that does not fit uses the other axis temporarily', () {
      final pair = _pair(layout: SplitLayoutPreference.sideBySide);
      final shown = _resolve(pair, const Size(240, 640));
      expect(shown.mode, SplitMode.stacked);
      // The preference itself is untouched.
      expect(pair.layout, SplitLayoutPreference.sideBySide);
    });
  });

  test('nothing fits: focused page only', () {
    expect(_resolve(_pair(), const Size(300, 380)).mode, SplitMode.focusedOnly);
  });

  test('keyboard with stacked shows the focused page only', () {
    expect(
      _resolve(_pair(), phonePortrait, keyboard: true).mode,
      SplitMode.focusedOnly,
    );
  });

  test('keyboard with side by side keeps both when the height fits', () {
    expect(
      _resolve(_pair(), phoneLandscape, keyboard: true).mode,
      SplitMode.sideBySide,
    );
  });

  test('keyboard with an explicit side by side keeps both in portrait', () {
    final pair = _pair(layout: SplitLayoutPreference.sideBySide);
    expect(
      _resolve(pair, phonePortrait, keyboard: true).mode,
      SplitMode.sideBySide,
    );
  });

  test('keyboard never falls back to stacked', () {
    final pair = _pair(layout: SplitLayoutPreference.sideBySide);
    expect(
      _resolve(pair, const Size(240, 640), keyboard: true).mode,
      SplitMode.focusedOnly,
    );
  });

  test('show only this page wins over any size', () {
    expect(
      _resolve(_pair(focusedOnly: true), tablet).mode,
      SplitMode.focusedOnly,
    );
  });

  test('not measured yet: focused page only', () {
    expect(_resolve(_pair(), null).mode, SplitMode.focusedOnly);
  });

  test('each axis keeps its own ratio', () {
    final pair = _pair(sideBySideRatio: 0.3, stackedRatio: 0.7);
    // Tablet: 1000 wide, 48 / 992 is the lower clamp, 0.3 is above it.
    expect(_resolve(pair, tablet).ratio, 0.3);
    expect(
      _resolve(
        pair.copyWith(layout: SplitLayoutPreference.stacked),
        tablet,
      ).ratio,
      0.7,
    );
  });

  test('ratios are clamped so neither pane drops below the drag minimum', () {
    final shown = _resolve(_pair(sideBySideRatio: 0.02), tablet);
    expect(shown.ratio, closeTo(48 / 992, 1e-9));
    final other = _resolve(_pair(sideBySideRatio: 0.98), tablet);
    expect(other.ratio, closeTo(1 - 48 / 992, 1e-9));
  });

  test('a pane may be dragged smaller than the size the split needs', () {
    // 0.06 of 992 is about 60 dp: below even the 120 an explicit layout is
    // shown with, above the 48 the divider stops at.
    final shown = _resolve(_pair(sideBySideRatio: 0.06), tablet);
    expect(shown.mode, SplitMode.sideBySide);
    expect(shown.ratio, 0.06);
  });

  group('hinge', () {
    // A book-style foldable: 1200 wide with a vertical hinge in the middle.
    const unfolded = Size(1200, 800);
    const verticalHinge = Rect.fromLTWH(590, 0, 20, 800);

    test('the divider is the hinge and cannot be dragged', () {
      final shown = _resolve(_pair(), unfolded, hinge: verticalHinge);
      expect(shown.mode, SplitMode.sideBySide);
      expect(shown.dividerDp, 20);
      expect(shown.draggable, isFalse);
      expect(shown.ratio, closeTo(590 / 1180, 1e-9));
    });

    test('the hinge axis wins over the preference', () {
      final pair = _pair(layout: SplitLayoutPreference.stacked);
      expect(
        _resolve(pair, unfolded, hinge: verticalHinge).mode,
        SplitMode.sideBySide,
      );
    });

    test('a side too small for a pane: focused page only', () {
      const offCenter = Rect.fromLTWH(200, 0, 20, 800);
      expect(
        _resolve(_pair(), unfolded, hinge: offCenter).mode,
        SplitMode.focusedOnly,
      );
    });

    test('keyboard with a horizontal hinge: focused page only', () {
      const horizontal = Rect.fromLTWH(0, 390, 1200, 20);
      expect(
        _resolve(_pair(), unfolded, hinge: horizontal, keyboard: true).mode,
        SplitMode.focusedOnly,
      );
    });
  });

  group('separatingHingeInContent', () {
    // A 1000x700 window; the browser content sits below a 56dp toolbar.
    const content = Rect.fromLTWH(0, 56, 1000, 644);

    DisplayFeature feature(
      Rect bounds, {
      DisplayFeatureType type = DisplayFeatureType.hinge,
      DisplayFeatureState state = DisplayFeatureState.unknown,
    }) => DisplayFeature(bounds: bounds, type: type, state: state);

    test('a vertical hinge comes back in content coordinates', () {
      final hinge = separatingHingeInContent(
        features: [feature(const Rect.fromLTWH(490, 0, 20, 700))],
        content: content,
      );
      expect(hinge, const Rect.fromLTWH(490, 0, 20, 644));
    });

    test('a horizontal half-open fold is shifted by the content origin', () {
      final hinge = separatingHingeInContent(
        features: [
          feature(
            const Rect.fromLTWH(0, 350, 1000, 0),
            type: DisplayFeatureType.fold,
            state: DisplayFeatureState.postureHalfOpened,
          ),
        ],
        content: content,
      );
      expect(hinge, const Rect.fromLTWH(0, 294, 1000, 0));
    });

    test('a flat fold and a cutout do not separate', () {
      expect(
        separatingHingeInContent(
          features: [
            feature(
              const Rect.fromLTWH(500, 0, 0, 700),
              type: DisplayFeatureType.fold,
              state: DisplayFeatureState.postureFlat,
            ),
            feature(
              const Rect.fromLTWH(480, 0, 40, 30),
              type: DisplayFeatureType.cutout,
            ),
          ],
          content: content,
        ),
        isNull,
      );
    });

    test('a hinge outside the content does not divide it', () {
      // The content is the right half only (a side rail on the left).
      expect(
        separatingHingeInContent(
          features: [feature(const Rect.fromLTWH(490, 0, 20, 700))],
          content: const Rect.fromLTWH(520, 56, 480, 644),
        ),
        isNull,
      );
    });
  });
}
