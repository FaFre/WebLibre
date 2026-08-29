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
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/features/settings/presentation/controllers/save_settings.dart';
import 'package:weblibre/features/settings/presentation/widgets/settings_detail.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/features/wallpaper/presentation/widgets/wallpaper_editor.dart';

/// The profile-wide home wallpaper.
///
/// A container can override it from the container editor; this screen says so
/// rather than trying to show both, because which one applies depends on what
/// is selected at the time.
class WallpaperSettingsScreen extends ConsumerWidget {
  const WallpaperSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final settings = ref.watch(generalSettingsWithDefaultsProvider);

    Future<void> save(GeneralSettings Function(GeneralSettings) update) {
      return ref
          .read(saveGeneralSettingsControllerProvider.notifier)
          .save(update);
    }

    return SettingsCustomScrollScaffold(
      title: 'Wallpaper',
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          sliver: SliverList.list(
            children: [
              Text(
                'Shown behind the home page, in every container that does not '
                'set its own.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              WallpaperEditor(
                fileName: settings.homeWallpaperFile,
                blur: settings.homeWallpaperBlur,
                dim: settings.homeWallpaperDim,
                onFileChanged: (fileName) async {
                  await save((s) => s.copyWith.homeWallpaperFile(fileName));
                },
                onBlurChanged: (value) async {
                  await save((s) => s.copyWith.homeWallpaperBlur(value));
                },
                onDimChanged: (value) async {
                  await save((s) => s.copyWith.homeWallpaperDim(value));
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
