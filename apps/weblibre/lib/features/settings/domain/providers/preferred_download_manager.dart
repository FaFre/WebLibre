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
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'preferred_download_manager.g.dart';

/// The download manager remembered from the chooser's "Always use this app",
/// or null while every download asks.
///
/// Native owns the value: the chooser that sets it also runs in Custom Tabs,
/// which have no Flutter engine. This reads it back when the settings screen
/// asks, so a choice made since then shows after an [Ref.invalidate].
@Riverpod()
class PreferredDownloadManagerChoice extends _$PreferredDownloadManagerChoice {
  @override
  Future<PreferredDownloadManager?> build() {
    return GeckoEngineSettingsService().getPreferredDownloadManager();
  }

  /// Forgets the choice, so the chooser asks again.
  Future<void> clear() async {
    await GeckoEngineSettingsService().clearPreferredDownloadManager();
    ref.invalidateSelf();
  }
}
