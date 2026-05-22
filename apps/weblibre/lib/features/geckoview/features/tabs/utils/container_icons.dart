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
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';

const IconData defaultContainerIcon = MdiIcons.folderOutline;

/// Always returns a non-null icon, defaulting to [defaultContainerIcon]
/// when the container has no icon set. Use this for any rendering surface
/// where the slot can't be empty (settings rows, full-size container
/// displays, the icon-picker preview).
IconData resolveContainerIcon(IconData? iconData) {
  return iconData ?? defaultContainerIcon;
}

bool isDefaultContainerIcon(IconData? iconData) {
  return resolveContainerIcon(iconData) == defaultContainerIcon;
}

/// Returns null when the container is using the default folder icon, and
/// the resolved icon otherwise. Use this for compact surfaces (chips,
/// breadcrumb-style strips) that should omit the icon slot rather than
/// render the generic folder placeholder.
IconData? chipContainerIcon(IconData? iconData) {
  return isDefaultContainerIcon(iconData)
      ? null
      : resolveContainerIcon(iconData);
}

class ContainerIconOption {
  const ContainerIconOption({
    required this.iconData,
    required this.name,
    required this.searchText,
  });

  final IconData iconData;
  final String name;
  final String searchText;
}
