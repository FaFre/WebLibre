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
import 'dart:async';
import 'dart:io';

import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';

part 'display_mode.g.dart';

Future<void> _applyRefreshRateMode(RefreshRateMode mode) async {
  // `flutter_displaymode` only supports Android; the calls throw on other
  // platforms, so skip them entirely.
  if (!Platform.isAndroid) {
    return;
  }

  try {
    switch (mode) {
      case RefreshRateMode.system:
        // No dedicated "auto" helper; selecting the auto mode hands control
        // back to the OS-managed default.
        await FlutterDisplayMode.setPreferredMode(DisplayMode.auto);
      case RefreshRateMode.high:
        await FlutterDisplayMode.setHighRefreshRate();
      case RefreshRateMode.low:
        await FlutterDisplayMode.setLowRefreshRate();
    }
  } catch (e, s) {
    logger.w('Failed to apply refresh rate mode', error: e, stackTrace: s);
  }
}

/// Always-mounted side-effect provider that pushes the configured
/// [RefreshRateMode] to the OS whenever it changes. Flutter does not request a
/// high refresh rate by default, so without this the app stays at 60Hz on many
/// devices even when the panel supports more.
///
/// Watched from the root widget so it stays alive for the whole app lifetime.
/// The body re-runs on every change of the setting (including the initial
/// build), so the mode is applied at startup as well as on later edits.
@Riverpod(keepAlive: true)
void displayModeApplier(Ref ref) {
  final mode = ref.watch(
    generalSettingsWithDefaultsProvider.select((s) => s.refreshRateMode),
  );

  unawaited(_applyRefreshRateMode(mode));
}
