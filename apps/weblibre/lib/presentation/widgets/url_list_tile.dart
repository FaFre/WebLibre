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
import 'package:weblibre/features/geckoview/features/tabs/utils/container_colors.dart';
import 'package:weblibre/features/geckoview/features/tabs/utils/container_icons.dart';
import 'package:weblibre/presentation/widgets/uri_breadcrumb.dart';
import 'package:weblibre/presentation/widgets/url_icon.dart';

class UrlListTile extends StatelessWidget {
  final String title;
  final Uri uri;
  final Widget? leading;
  final Widget? trailing;
  final Color? containerColor;
  final IconData? containerIcon;
  final bool useCustomColor;
  final bool showHttpScheme;
  final VoidCallback? onTap;

  const UrlListTile({
    super.key,
    required this.title,
    required this.uri,
    this.leading,
    this.trailing,
    this.containerColor,
    this.containerIcon,
    this.useCustomColor = false,
    this.showHttpScheme = true,
    this.onTap,
  });

  static const iconSize = 32.0;
  static const _badgeWidth = 56.0;
  static const _borderRadius = BorderRadius.all(Radius.circular(12.0));

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final containerPalette = containerColor != null
        ? ContainerColors.palette(
            context,
            containerColor!,
            useCustomColor: useCustomColor,
          )
        : null;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 3.0, horizontal: 4.0),
      decoration: BoxDecoration(
        color: containerPalette?.surfaceColor,
        borderRadius: _borderRadius,
        border: containerPalette != null
            ? Border.all(color: containerPalette.outlineColor)
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: _borderRadius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          borderRadius: _borderRadius,
          onTap: onTap,
          child: Stack(
            children: [
              Padding(
                padding: EdgeInsets.only(
                  left: 12.0,
                  top: 10.0,
                  bottom: 10.0,
                  // Reserve room for the trailing badge so content never
                  // slides underneath it.
                  right: containerPalette != null ? _badgeWidth + 12.0 : 12.0,
                ),
                child: Row(
                  children: [
                    leading ??
                        RepaintBoundary(
                          child: UrlIcon([uri], iconSize: iconSize),
                        ),
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
              // Stretches to the card height set by the content above without
              // the extra layout pass an IntrinsicHeight Row would cost.
              if (containerPalette != null)
                Positioned(
                  top: 0.0,
                  bottom: 0.0,
                  right: 0.0,
                  width: _badgeWidth,
                  child: _ContainerBadge(
                    palette: containerPalette,
                    icon: resolveContainerIcon(containerIcon),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Trailing accent-coloured strip flush against the card's right edge that
/// surfaces the owning container's identity (its colour and icon).
class _ContainerBadge extends StatelessWidget {
  final ContainerColorPalette palette;
  final IconData icon;

  const _ContainerBadge({required this.palette, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: UrlListTile._badgeWidth,
      alignment: Alignment.center,
      color: palette.accentColor,
      child: Icon(icon, size: 22.0, color: palette.onAccentColor),
    );
  }
}
