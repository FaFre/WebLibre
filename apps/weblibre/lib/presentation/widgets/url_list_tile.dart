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
import 'package:weblibre/presentation/widgets/uri_breadcrumb.dart';
import 'package:weblibre/presentation/widgets/url_icon.dart';

class UrlListTile extends StatelessWidget {
  final String title;
  final Uri uri;
  final Widget? leading;
  final Widget? trailing;
  final Color? borderColor;
  final bool showHttpScheme;
  final VoidCallback? onTap;

  const UrlListTile({
    super.key,
    required this.title,
    required this.uri,
    this.leading,
    this.trailing,
    this.borderColor,
    this.showHttpScheme = true,
    this.onTap,
  });

  static const iconSize = 32.0;
  static const _borderRadius = BorderRadius.all(Radius.circular(12.0));

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 3.0, horizontal: 4.0),
      decoration: BoxDecoration(
        borderRadius: _borderRadius,
        border: borderColor != null
            ? Border(right: BorderSide(color: borderColor!, width: 4.0))
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: _borderRadius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          borderRadius: _borderRadius,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.only(
              left: 12.0,
              top: 10.0,
              bottom: 10.0,
              right: 12.0,
            ),
            child: Row(
              children: [
                leading ??
                    RepaintBoundary(child: UrlIcon([uri], iconSize: iconSize)),
                const SizedBox(width: 14.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 3.0),
                      UriBreadcrumb(
                        uri: uri,
                        showHttpScheme: showHttpScheme,
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                if (trailing != null) ...[
                  const SizedBox(width: 8.0),
                  trailing!,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
