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
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:weblibre/utils/number_format.dart';

class AddonListingIcon extends StatelessWidget {
  final String? iconUrl;
  final double size;

  const AddonListingIcon({required this.iconUrl, this.size = 40, super.key});

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(12);
    if (iconUrl == null || iconUrl!.isEmpty) {
      return _fallback(context);
    }
    return ClipRRect(
      borderRadius: borderRadius,
      child: Image.network(
        iconUrl!,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _fallback(context),
      ),
    );
  }

  Widget _fallback(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(Icons.extension, color: theme.colorScheme.onSurfaceVariant),
    );
  }
}

class AddonListingCard extends StatelessWidget {
  final AddonListing listing;
  final bool isInstalled;
  final VoidCallback? onTap;
  final Widget? trailing;

  const AddonListingCard({
    required this.listing,
    required this.isInstalled,
    this.onTap,
    this.trailing,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: theme.colorScheme.surfaceContainerHigh,
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AddonListingIcon(iconUrl: listing.iconUrl),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(listing.name, style: theme.textTheme.titleMedium),
                    if ((listing.summary ?? '').isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        listing.summary!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        if (listing.promoted == AddonStorePromoted.recommended)
                          const Chip(
                            avatar: Icon(Icons.verified, size: 16),
                            label: Text('Recommended'),
                          ),
                        if (listing.ratingAverage != null)
                          Chip(
                            avatar: const Icon(Icons.star, size: 16),
                            label: Text(
                              listing.ratingAverage!.toStringAsFixed(1),
                            ),
                          ),
                        if (listing.averageDailyUsers != null)
                          Chip(
                            avatar: const Icon(Icons.group_outlined, size: 16),
                            label: Text(
                              formatCompactNumber(listing.averageDailyUsers!),
                            ),
                          ),
                        if (isInstalled)
                          const Chip(
                            avatar: Icon(Icons.check, size: 16),
                            label: Text('Installed'),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              trailing ?? const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
