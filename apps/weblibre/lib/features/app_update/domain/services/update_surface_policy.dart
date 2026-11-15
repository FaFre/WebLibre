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
import 'package:fast_equatable/fast_equatable.dart';
import 'package:weblibre/features/app_update/domain/entities/update_preferences.dart';
import 'package:weblibre/features/app_update/domain/entities/update_state.dart';

/// The browser menu row (8.3). Drawn outside the customizable menu layout, so
/// it can't be arranged away and needs no layout migration.
enum UpdateMenuRow {
  none,
  available,
  downloading,
  readyToInstall,
  finishInstalling,
  installing,
  preferencesUnreadable;

  /// The dot on the menu button marks rows waiting for the user. Neither the
  /// dot nor the row can be dismissed.
  bool get dot => switch (this) {
    available ||
    readyToInstall ||
    finishInstalling ||
    preferencesUnreadable => true,
    none || downloading || installing => false,
  };
}

class UpdateSurface with FastEquatable {
  UpdateSurface({required this.row, this.progress});

  static final none = UpdateSurface(row: UpdateMenuRow.none);

  final UpdateMenuRow row;
  final double? progress;

  bool get dot => row.dot;

  @override
  List<Object?> get hashParameters => [row, progress];
}

/// Which passive surfaces show what (8.2, 8.3).
class UpdateSurfacePolicy {
  const UpdateSurfacePolicy();

  UpdateSurface surfaceFor(
    UpdateState state, {
    required UpdatePreferences preferences,
  }) {
    if (preferences.recoveryRequired) {
      return UpdateSurface(row: UpdateMenuRow.preferencesUnreadable);
    }

    final surface = switch (state) {
      // A failure doesn't take back what is still true: a background check
      // failing offline leaves a downloaded update ready to install.
      UpdateFailed(:final returnTo) => surfaceFor(
        returnTo,
        preferences: preferences,
      ),
      UpdateAvailable() => UpdateSurface(row: UpdateMenuRow.available),
      UpdateDownloading(:final progress) => UpdateSurface(
        row: UpdateMenuRow.downloading,
        progress: progress,
      ),
      UpdateVerifying() => UpdateSurface(row: UpdateMenuRow.downloading),
      UpdateReadyToInstall() => UpdateSurface(
        row: UpdateMenuRow.readyToInstall,
      ),
      UpdateAwaitingPermission() || UpdateAwaitingUserAction() => UpdateSurface(
        row: UpdateMenuRow.finishInstalling,
      ),
      UpdateInstalling() => UpdateSurface(row: UpdateMenuRow.installing),
      _ => UpdateSurface.none,
    };

    // Switched off: no signal for a new version, only for what the user
    // started and may want to find again (8.2).
    if (!preferences.automaticChecks &&
        surface.row == UpdateMenuRow.available) {
      return UpdateSurface.none;
    }
    return surface;
  }
}
