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
import 'package:nullability/nullability.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/models/container_data.dart';
import 'package:weblibre/features/geckoview/features/tabs/presentation/widgets/container_title.dart';
import 'package:weblibre/features/geckoview/features/tabs/utils/container_colors.dart';
import 'package:weblibre/features/geckoview/features/tabs/utils/container_icons.dart';

Widget? buildContainerChipAvatar(
  BuildContext context,
  ContainerData container,
  bool isSelected, {
  double size = 18,
}) {
  final palette = ContainerColors.palette(context, container.color);

  return chipContainerIcon(container.metadata.iconData).mapNotNull(
    (iconData) => Icon(
      iconData,
      size: size,
      color: isSelected ? palette.selectedAvatarColor : palette.avatarColor,
    ),
  );
}

Widget buildContainerChipLabel(
  BuildContext context,
  ContainerData container,
  bool isSelected, {
  Widget? trailing,
}) {
  final palette = ContainerColors.palette(context, container.color);
  final foregroundColor = isSelected
      ? palette.selectedForegroundColor
      : palette.foregroundColor;

  return DefaultTextStyle.merge(
    style: TextStyle(
      color: foregroundColor,
      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
    ),
    child: IconTheme.merge(
      data: IconThemeData(color: foregroundColor),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (container.isPinned) ...[
            Icon(MdiIcons.pin, size: 14, color: foregroundColor),
            const SizedBox(width: 4),
          ],
          Flexible(child: ContainerTitle(container: container)),
          if (trailing != null) ...[const SizedBox(width: 6), trailing],
        ],
      ),
    ),
  );
}
