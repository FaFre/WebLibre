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
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weblibre/core/design/window_size_class.dart';
import 'package:weblibre/features/settings/presentation/widgets/toolbar_preview.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';

void main() {
  group('TabBarPreviewHeaderDelegate', () {
    test('rebuilds when only the window class changes', () {
      // The window alone decides whether the preview is a bar or a rail, and
      // with it the header's extent.
      final settings = GeneralSettings.withDefaults();
      final phone = TabBarPreviewHeaderDelegate(
        settings: settings,
        window: WindowSizeClass.compact,
      );
      final tablet = TabBarPreviewHeaderDelegate(
        settings: settings,
        window: WindowSizeClass.fromSize(const Size(1280, 800)),
      );

      expect(tablet.maxExtent, isNot(phone.maxExtent));
      expect(tablet.shouldRebuild(phone), isTrue);
    });

    test('does not rebuild for an identical delegate', () {
      final settings = GeneralSettings.withDefaults();
      final a = TabBarPreviewHeaderDelegate(
        settings: settings,
        window: WindowSizeClass.compact,
      );
      final b = TabBarPreviewHeaderDelegate(
        settings: settings,
        window: WindowSizeClass.compact,
      );

      expect(b.shouldRebuild(a), isFalse);
    });
  });
}
