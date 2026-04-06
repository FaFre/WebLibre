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
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:weblibre/features/geckoview/features/open_link_tools/presentation/utils/open_in_custom_tab.dart';

class AttributionLink extends StatelessWidget {
  final String label;
  final String url;
  final TextStyle style;

  const AttributionLink({
    super.key,
    required this.label,
    required this.url,
    required this.style,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        unawaited(openInPrivateCustomTab(context, url));
      },
      child: Text(label, style: style),
    );
  }
}
