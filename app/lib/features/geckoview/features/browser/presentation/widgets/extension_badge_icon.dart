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
import 'package:nullability/nullability.dart';
import 'package:weblibre/features/geckoview/domain/entities/states/web_extension.dart';

class ExtensionBadgeIcon extends StatelessWidget {
  final WebExtensionState state;

  const ExtensionBadgeIcon(this.state);

  @override
  Widget build(BuildContext context) {
    final hasBadge = state.badgeText.isNotEmpty;

    return Badge(
      isLabelVisible: hasBadge,
      label: hasBadge ? Text(state.badgeText!) : null,
      textColor: state.badgeTextColor,
      backgroundColor: state.badgeBackgroundColor,
      child: RepaintBoundary(
        child:
            state.icon?.value.mapNotNull(
              (image) => RawImage(image: image, width: 24, height: 24),
            ) ??
            const SizedBox(width: 24, height: 24),
      ),
    );
  }
}
