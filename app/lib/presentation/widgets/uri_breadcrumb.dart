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
import 'package:collection/collection.dart';
import 'package:fading_scroll/fading_scroll.dart';
import 'package:flutter/material.dart';

class UriBreadcrumb extends StatelessWidget {
  final Uri uri;
  final Widget? icon;
  final TextStyle? style;

  const UriBreadcrumb({super.key, required this.uri, this.icon, this.style});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: uri.toString(),
      child: DefaultTextStyle(
        style: style ?? DefaultTextStyle.of(context).style,
        child: FadingScroll(
          fadingSize: 15,
          builder: (context, controller) {
            return SingleChildScrollView(
              controller: controller,
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ?icon,
                  Text(
                    uri.authority,
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.visible,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  if (uri.pathSegments.any((s) => s.isNotEmpty))
                    Text(
                      ' › ${uri.pathSegments.whereNot((s) => s.isEmpty).join(' › ')}',
                      maxLines: 1,
                      softWrap: false,
                      overflow: TextOverflow.visible,
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
