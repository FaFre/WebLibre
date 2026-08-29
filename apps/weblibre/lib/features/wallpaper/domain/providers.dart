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
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/core/filesystem.dart';
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/models/container_data.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/providers/selected_container.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/repositories/container.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/features/wallpaper/domain/entities/home_wallpaper.dart';
import 'package:weblibre/features/wallpaper/domain/services/wallpaper_store.dart';

part 'providers.g.dart';

@Riverpod(keepAlive: true)
WallpaperStore wallpaperStore(Ref ref) {
  return WallpaperStore(profileDir: () => filesystem.selectedProfileDir);
}

/// The wallpaper to draw behind the home surface right now, or null when there
/// is none.
///
/// The selected container's own wallpaper wins over the profile-wide one; its
/// blur and dim fall back to the profile's values when unset, so a container
/// that only wants a different picture does not have to restate the treatment.
@Riverpod()
HomeWallpaper? resolvedHomeWallpaper(Ref ref) {
  final settings = ref.watch(generalSettingsWithDefaultsProvider);
  final container = ref.watch(
    selectedContainerDataProvider.select((value) => value.value),
  );

  return resolveHomeWallpaper(
    store: ref.watch(wallpaperStoreProvider),
    settings: settings,
    container: container,
  );
}

/// Deletes wallpapers nothing points at any more.
///
/// Nothing else reclaims them: replacing a wallpaper, cancelling a container
/// edit that imported one, and deleting a container all leave a file behind on
/// purpose, because the writer cannot tell whether some other setting still
/// refers to it. Restoring a profile from an archive can leave some too.
///
/// Run at startup, from the browser view's housekeeping — the one moment when
/// no picker can be holding an import that has not been saved yet.
@Riverpod(keepAlive: true)
class WallpaperSweeper extends _$WallpaperSweeper {
  @override
  void build() {}

  Future<void> sweep() async {
    final settings = await ref
        .read(generalSettingsRepositoryProvider.notifier)
        .fetchSettings();

    final containers = await ref
        .read(containerRepositoryProvider.notifier)
        .getAllContainersWithCount();

    final referenced = <String>{
      if (settings.homeWallpaperFile != null) settings.homeWallpaperFile!,
      for (final container in containers)
        if (container.metadata.wallpaper != null)
          container.metadata.wallpaper!.file,
    };

    final deleted = await ref
        .read(wallpaperStoreProvider)
        .deleteUnreferenced(referenced);

    if (deleted > 0) {
      logger.i('Deleted $deleted unreferenced wallpaper(s)');
    }
  }
}

/// The resolution itself, apart from the providers, so it can be exercised
/// directly and reused by the settings screen's preview.
HomeWallpaper? resolveHomeWallpaper({
  required WallpaperStore store,
  required GeneralSettings settings,
  required ContainerData? container,
}) {
  final override = container?.metadata.wallpaper;

  if (override != null) {
    return HomeWallpaper(
      file: store.resolve(override.file),
      blur: override.blur ?? settings.homeWallpaperBlur,
      dim: override.dim ?? settings.homeWallpaperDim,
    );
  }

  final profileFile = settings.homeWallpaperFile;
  if (profileFile == null) return null;

  return HomeWallpaper(
    file: store.resolve(profileFile),
    blur: settings.homeWallpaperBlur,
    dim: settings.homeWallpaperDim,
  );
}
