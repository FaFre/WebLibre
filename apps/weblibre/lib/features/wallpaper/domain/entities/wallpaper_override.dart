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
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:fast_equatable/fast_equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:weblibre/features/wallpaper/domain/entities/home_wallpaper.dart';

part 'wallpaper_override.g.dart';

/// One holder's own home wallpaper, replacing the profile-wide one from
/// `GeneralSettings` — today that holder is a container, while the container is
/// the one selected.
///
/// Exists as a value rather than as loose fields on its holder so the only
/// meaningless combination cannot be written down: a blur or a dim with no
/// picture to apply it to. Either there is an override, with a [file], or there
/// is none at all.
@CopyWith()
@JsonSerializable(constructor: 'withDefaults')
class WallpaperOverride with FastEquatable {
  /// Name of the wallpaper within the profile's wallpaper directory, never a
  /// path. See `WallpaperStore`.
  final String file;

  /// Null inherits the profile-wide value, so an override that only wants a
  /// different picture does not have to restate the treatment — and keeps
  /// following the profile if that treatment is later changed.
  final double? blur;
  final double? dim;

  WallpaperOverride({required this.file, this.blur, this.dim});

  /// The constructor everything reading stored data goes through, [fromJson]
  /// included.
  ///
  /// [blur] and [dim] end up as an [ImageFilter] sigma and a colour alpha, and
  /// a value out of a hand-edited database must not be able to hand either one
  /// something invalid. The clamp cannot live in the primary constructor
  /// because copy_with_extension_gen requires its parameters to be initialising
  /// formals — the same reason [ContainerMetadata] normalizes this way.
  WallpaperOverride.withDefaults({
    required String file,
    double? blur,
    double? dim,
  }) : this(
         file: file,
         blur: blur?.clamp(0, maxHomeWallpaperBlur),
         dim: dim?.clamp(0, maxHomeWallpaperDim),
       );

  factory WallpaperOverride.fromJson(Map<String, dynamic> json) =>
      _$WallpaperOverrideFromJson(json);

  Map<String, dynamic> toJson() => _$WallpaperOverrideToJson(this);

  @override
  List<Object?> get hashParameters => [file, blur, dim];
}
