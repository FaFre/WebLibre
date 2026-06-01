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
import 'package:weblibre/features/bangs/data/models/bang.dart';
import 'package:weblibre/features/bangs/data/models/bang_group.dart';

/// Renders a bang's website name, appending an amber crown for the official
/// WebLibre bang ([BangGroup.weblibre]) so it stands out as first-party.
class BangLabel extends StatelessWidget {
  final Bang bang;

  const BangLabel(this.bang, {super.key});

  @override
  Widget build(BuildContext context) {
    final label = Text(bang.websiteName);

    if (bang.group != BangGroup.weblibre) {
      return label;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(child: label),
        const SizedBox(width: 4.0),
        const Icon(MdiIcons.crown, color: Colors.amber, size: 16.0),
      ],
    );
  }
}
