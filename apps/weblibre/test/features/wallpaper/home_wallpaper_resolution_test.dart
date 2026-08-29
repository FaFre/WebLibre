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
 */
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:weblibre/features/geckoview/features/tabs/data/models/container_data.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';
import 'package:weblibre/features/wallpaper/domain/entities/home_wallpaper.dart';
import 'package:weblibre/features/wallpaper/domain/entities/wallpaper_override.dart';
import 'package:weblibre/features/wallpaper/domain/providers.dart';
import 'package:weblibre/features/wallpaper/domain/services/wallpaper_store.dart';
import 'package:weblibre/features/wallpaper/presentation/widgets/wallpaper_backdrop.dart';

ContainerData _container({
  String? wallpaperFile,
  double? wallpaperBlur,
  double? wallpaperDim,
}) {
  return ContainerData(
    id: 'container',
    color: const Color(0xFF112233),
    orderKey: 'a',
    metadata: ContainerMetadata.withDefaults(
      wallpaper: wallpaperFile == null
          ? null
          : WallpaperOverride.withDefaults(
              file: wallpaperFile,
              blur: wallpaperBlur,
              dim: wallpaperDim,
            ),
    ),
  );
}

/// Scoped to the backdrop itself: [MaterialApp] wraps whatever it is given in
/// widgets of the same types.
Finder _inBackdrop(Type type) => find.descendant(
  of: find.byType(WallpaperBackdrop),
  matching: find.byType(type),
);

void main() {
  final store = WallpaperStore(profileDir: () => Directory('/profile'));

  group('resolveHomeWallpaper', () {
    test('is nothing when neither level sets one', () {
      expect(
        resolveHomeWallpaper(
          store: store,
          settings: GeneralSettings.withDefaults(),
          container: _container(),
        ),
        isNull,
      );
    });

    test('uses the profile wallpaper when the container has none', () {
      final resolved = resolveHomeWallpaper(
        store: store,
        settings: GeneralSettings.withDefaults(
          homeWallpaperFile: 'profile.png',
          homeWallpaperBlur: 8,
          homeWallpaperDim: 0.5,
        ),
        container: _container(),
      );

      expect(p.basename(resolved!.file.path), 'profile.png');
      expect(resolved.blur, 8);
      expect(resolved.dim, 0.5);
    });

    test('applies with no container selected', () {
      final resolved = resolveHomeWallpaper(
        store: store,
        settings: GeneralSettings.withDefaults(
          homeWallpaperFile: 'profile.png',
        ),
        container: null,
      );

      expect(p.basename(resolved!.file.path), 'profile.png');
    });

    test("the container's own wallpaper wins", () {
      final resolved = resolveHomeWallpaper(
        store: store,
        settings: GeneralSettings.withDefaults(
          homeWallpaperFile: 'profile.png',
        ),
        container: _container(
          wallpaperFile: 'container.png',
          wallpaperBlur: 12,
          wallpaperDim: 0.2,
        ),
      );

      expect(p.basename(resolved!.file.path), 'container.png');
      expect(resolved.blur, 12);
      expect(resolved.dim, 0.2);
    });

    test('a container wallpaper inherits an unset treatment', () {
      final resolved = resolveHomeWallpaper(
        store: store,
        settings: GeneralSettings.withDefaults(
          homeWallpaperFile: 'profile.png',
          homeWallpaperBlur: 6,
          homeWallpaperDim: 0.4,
        ),
        container: _container(wallpaperFile: 'container.png'),
      );

      expect(p.basename(resolved!.file.path), 'container.png');
      expect(resolved.blur, 6);
      expect(resolved.dim, 0.4);
    });

    test('a container wallpaper applies without a profile-wide one', () {
      final resolved = resolveHomeWallpaper(
        store: store,
        settings: GeneralSettings.withDefaults(),
        container: _container(wallpaperFile: 'container.png'),
      );

      expect(p.basename(resolved!.file.path), 'container.png');
      expect(resolved.dim, defaultHomeWallpaperDim);
    });
  });

  group('WallpaperOverride', () {
    test('carries its treatment through a round trip', () {
      final override = WallpaperOverride.withDefaults(
        file: 'container.png',
        blur: 4,
        dim: 0.5,
      );

      final restored = WallpaperOverride.fromJson(
        jsonDecode(jsonEncode(override.toJson())) as Map<String, dynamic>,
      );

      expect(restored, override);
    });

    test('an unset treatment survives as unset rather than as a default', () {
      // The whole point of the nullable pair: an override that only wanted a
      // different picture has to keep following the profile's treatment.
      final restored = WallpaperOverride.fromJson(
        jsonDecode(
              jsonEncode(WallpaperOverride(file: 'container.png').toJson()),
            )
            as Map<String, dynamic>,
      );

      expect(restored.blur, isNull);
      expect(restored.dim, isNull);
    });

    test('travels inside the metadata it is stored in', () {
      final metadata = ContainerMetadata.withDefaults(
        wallpaper: WallpaperOverride(file: 'container.png', blur: 4),
      );

      final restored = ContainerMetadata.fromJson(
        jsonDecode(jsonEncode(metadata.toJson())) as Map<String, dynamic>,
      );

      expect(restored.wallpaper, metadata.wallpaper);
    });
  });

  group('stored treatment', () {
    test('is clamped into range on the way out of the database', () {
      final settings = GeneralSettings.withDefaults(
        homeWallpaperBlur: 500,
        homeWallpaperDim: 4,
      );

      expect(settings.homeWallpaperBlur, maxHomeWallpaperBlur);
      expect(settings.homeWallpaperDim, maxHomeWallpaperDim);

      final override = WallpaperOverride.withDefaults(
        file: 'container.png',
        blur: -3,
        dim: 9,
      );

      expect(override.blur, 0);
      expect(override.dim, maxHomeWallpaperDim);
    });
  });

  group('blur slider curve', () {
    test('spans the whole range end to end', () {
      expect(homeWallpaperBlurFromSlider(0), 0);
      expect(homeWallpaperBlurFromSlider(1), maxHomeWallpaperBlur);
      expect(homeWallpaperBlurToSlider(0), 0);
      expect(homeWallpaperBlurToSlider(maxHomeWallpaperBlur), 1);
    });

    test('round-trips a stored sigma back to its slider position', () {
      for (final blur in [0.0, 0.75, 3.0, 6.0, maxHomeWallpaperBlur]) {
        expect(
          homeWallpaperBlurFromSlider(homeWallpaperBlurToSlider(blur)),
          closeTo(blur, 1e-9),
        );
      }
    });

    test('gives half its travel to the range a picture survives', () {
      // The reason the curve exists: linearly, everything below sigma 3 — the
      // part where the wallpaper is still a picture rather than a smear — got
      // an eighth of the slider.
      expect(homeWallpaperBlurFromSlider(0.5), lessThanOrEqualTo(3));
      expect(homeWallpaperBlurFromSlider(0.25), lessThan(1));
    });

    test('clamps a position outside its range', () {
      expect(homeWallpaperBlurFromSlider(-1), 0);
      expect(homeWallpaperBlurFromSlider(2), maxHomeWallpaperBlur);
      expect(homeWallpaperBlurToSlider(-5), 0);
      expect(homeWallpaperBlurToSlider(100), 1);
    });
  });

  group('WallpaperBackdrop', () {
    testWidgets('hands the child straight through with no wallpaper', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WallpaperBackdrop(wallpaper: null, child: Text('home')),
        ),
      );

      expect(find.text('home'), findsOneWidget);
      // Nothing is stacked over the surface below, so the home page keeps its
      // own backdrop untouched.
      expect(_inBackdrop(Image), findsNothing);
      expect(_inBackdrop(ColoredBox), findsNothing);
    });

    testWidgets('draws the image and its scrim under the child', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: WallpaperBackdrop(
            wallpaper: HomeWallpaper(
              file: File('/profile/files/wallpapers/picture.png'),
              blur: 0,
              dim: 0.4,
            ),
            child: const Text('home'),
          ),
        ),
      );

      expect(find.text('home'), findsOneWidget);
      expect(_inBackdrop(Image), findsOneWidget);
      expect(_inBackdrop(ColoredBox), findsOneWidget);
      // No blur means no filter layer at all, rather than a zero-sigma one.
      expect(_inBackdrop(ImageFiltered), findsNothing);
    });

    testWidgets('holds its size and place while its box is inset', (
      tester,
    ) async {
      // What showing and hiding the tab bar does: `browser.dart` positions the
      // browser with offsets that come and go with the toolbar, so the home
      // surface's box loses height from the bottom. Fitted to that box, the
      // cover scale would be re-derived and the picture would visibly zoom.
      Future<Rect> pumpWithBottomInset(double inset) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Align(
              alignment: Alignment.topLeft,
              child: SizedBox(
                width: 800,
                height: 600 - inset,
                child: WallpaperBackdrop(
                  wallpaper: HomeWallpaper(
                    file: File('/profile/files/wallpapers/picture.png'),
                    blur: 0,
                    dim: 0.4,
                  ),
                  screenAnchor: Alignment.topLeft,
                  child: const Text('home'),
                ),
              ),
            ),
          ),
        );

        return tester.getRect(_inBackdrop(Image));
      }

      final full = await pumpWithBottomInset(0);
      final inset = await pumpWithBottomInset(120);

      // The test view is 800x600, so the image stays the size of the screen
      // and the shrinking box only clips it.
      expect(full.size, const Size(800, 600));
      expect(inset.size, full.size);
      expect(inset.topLeft, full.topLeft);
    });

    testWidgets('fits its box when no screen anchor is given', (tester) async {
      // The settings preview: its box is the whole of what it stands for, so
      // there is nothing to anchor against.
      await tester.pumpWidget(
        MaterialApp(
          home: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: 160,
              height: 320,
              child: WallpaperBackdrop(
                wallpaper: HomeWallpaper(
                  file: File('/profile/files/wallpapers/picture.png'),
                  blur: 0,
                  dim: 0.4,
                ),
                child: const Text('home'),
              ),
            ),
          ),
        ),
      );

      expect(tester.getRect(_inBackdrop(Image)).size, const Size(160, 320));
    });

    testWidgets('adds a filter layer only when blur is set', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: WallpaperBackdrop(
            wallpaper: HomeWallpaper(
              file: File('/profile/files/wallpapers/picture.png'),
              blur: 10,
              dim: 0,
            ),
            child: const Text('home'),
          ),
        ),
      );

      expect(_inBackdrop(ImageFiltered), findsOneWidget);
      // Dim of zero paints nothing rather than a fully transparent box.
      expect(_inBackdrop(ColoredBox), findsNothing);
    });
  });
}
