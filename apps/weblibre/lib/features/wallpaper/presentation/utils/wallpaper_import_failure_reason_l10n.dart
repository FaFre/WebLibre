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
import 'package:weblibre/features/wallpaper/domain/services/wallpaper_store.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';

/// Display messages for [WallpaperImportFailureReason].
extension WallpaperImportFailureReasonL10n on WallpaperImportFailureReason {
  String describe(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return switch (this) {
      WallpaperImportFailureReason.unreadableSource =>
        l10n.wallpaper_importErrorUnreadable,
      WallpaperImportFailureReason.tooLarge =>
        l10n.wallpaper_importErrorTooLarge,
      WallpaperImportFailureReason.notAnImage =>
        l10n.wallpaper_importErrorNotAnImage,
      WallpaperImportFailureReason.decodeFailed =>
        l10n.wallpaper_importErrorDecodeFailed,
    };
  }
}
