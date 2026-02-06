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
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';

class HardeningGroupIcon extends StatelessWidget {
  final bool isActive;
  final bool isPartlyActive;

  const HardeningGroupIcon({
    super.key,
    required this.isActive,
    this.isPartlyActive = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isActive) {
      return Icon(
        MdiIcons.shieldLockOutline,
        color: Theme.of(context).colorScheme.secondary,
      );
    } else if (isPartlyActive) {
      return Icon(
        MdiIcons.shieldLockOpenOutline,
        color: Theme.of(context).colorScheme.secondary,
      );
    }

    return Icon(
      MdiIcons.shieldOffOutline,
      color: Theme.of(context).colorScheme.error,
    );
  }
}
