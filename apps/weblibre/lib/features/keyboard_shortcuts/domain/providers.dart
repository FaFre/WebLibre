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
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/core/design/window_size_class.dart';
import 'package:weblibre/core/providers/pointer_device.dart';
import 'package:weblibre/core/providers/window_size_class.dart';

part 'providers.g.dart';

/// Whether menus show the key that runs each row.
///
/// Android cannot say whether a hardware keyboard is attached, so this goes by
/// what usually comes with one: a pointer in use, or a window wide enough to be
/// a tablet or desktop. A phone held in hand gets no hints to crowd its rows.
@riverpod
bool showKeyboardShortcutHints(Ref ref) {
  if (ref.watch(cursorInUseProvider)) return true;

  return ref.watch(
    windowSizeClassControllerProvider.select(
      (sizeClass) => sizeClass.width == WindowWidthClass.expanded,
    ),
  );
}
