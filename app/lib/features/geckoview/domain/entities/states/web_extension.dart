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
import 'dart:ui';

import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:fast_equatable/fast_equatable.dart';
import 'package:weblibre/domain/entities/equatable_image.dart';

part 'web_extension.g.dart';

@CopyWith()
class WebExtensionState with FastEquatable {
  String extensionId;

  String? title;
  bool enabled;
  String? badgeText;
  Color? badgeTextColor;
  Color? badgeBackgroundColor;

  final EquatableImage? icon;

  WebExtensionState({
    required this.extensionId,
    required this.enabled,
    this.title,
    this.badgeText,
    this.badgeTextColor,
    this.badgeBackgroundColor,
    this.icon,
  });

  @override
  List<Object?> get hashParameters => [
    extensionId,
    title,
    enabled,
    badgeText,
    badgeTextColor,
    badgeBackgroundColor,
    icon,
  ];
}
