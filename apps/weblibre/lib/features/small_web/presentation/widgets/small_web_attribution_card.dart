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
import 'package:weblibre/features/small_web/data/models/kagi_small_web_mode.dart';
import 'package:weblibre/features/small_web/data/models/small_web_source_kind.dart';
import 'package:weblibre/features/small_web/presentation/utils/kagi_small_web_mode_l10n.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';

class SmallWebAttributionAction {
  final String label;
  final IconData icon;
  final Uri uri;

  const SmallWebAttributionAction({
    required this.label,
    required this.icon,
    required this.uri,
  });
}

class SmallWebAttributionData {
  final IconData icon;
  final String title;
  final String? badgeLabel;
  final String description;
  final String attributionLine;
  final String? metadataLine;
  final List<SmallWebAttributionAction> actions;

  const SmallWebAttributionData({
    required this.icon,
    required this.title,
    this.badgeLabel,
    required this.description,
    required this.attributionLine,
    required this.actions,
    this.metadataLine,
  });

  factory SmallWebAttributionData.forSelection({
    required BuildContext context,
    required SmallWebSourceKind sourceKind,
    KagiSmallWebMode? mode,
  }) {
    final l10n = AppLocalizations.of(context);

    return switch (sourceKind) {
      SmallWebSourceKind.kagi => SmallWebAttributionData._forKagi(
        context,
        l10n,
        mode ?? KagiSmallWebMode.web,
      ),
      SmallWebSourceKind.wander => SmallWebAttributionData._forWander(l10n),
    };
  }

  factory SmallWebAttributionData._forKagi(
    BuildContext context,
    AppLocalizations l10n,
    KagiSmallWebMode mode,
  ) {
    final commonActions = [
      SmallWebAttributionAction(
        label: l10n.smallWeb_kagiBlogPostAction,
        icon: Icons.article_outlined,
        uri: Uri.https('blog.kagi.com', '/small-web'),
      ),
      SmallWebAttributionAction(
        label: l10n.smallWeb_kagiGithubAction,
        icon: Icons.code,
        uri: Uri.https('github.com', '/kagisearch/smallweb'),
      ),
    ];

    final description = switch (mode) {
      KagiSmallWebMode.web => l10n.smallWeb_kagiDescriptionWeb,
      KagiSmallWebMode.appreciated => l10n.smallWeb_kagiDescriptionAppreciated,
      KagiSmallWebMode.videos => l10n.smallWeb_kagiDescriptionVideos,
      KagiSmallWebMode.code => l10n.smallWeb_kagiDescriptionCode,
      KagiSmallWebMode.comics => l10n.smallWeb_kagiDescriptionComics,
    };

    return SmallWebAttributionData(
      icon: Icons.travel_explore,
      title: l10n.smallWeb_kagiTitle,
      badgeLabel: mode.label(context),
      description: description,
      attributionLine: l10n.smallWeb_kagiAttributionLine,
      actions: [...commonActions],
    );
  }

  factory SmallWebAttributionData._forWander(AppLocalizations l10n) {
    return SmallWebAttributionData(
      icon: Icons.dns,
      title: l10n.smallWeb_wanderTitle,
      description: l10n.smallWeb_wanderDescription,
      attributionLine: l10n.smallWeb_wanderAttributionLine,
      actions: [
        SmallWebAttributionAction(
          label: l10n.smallWeb_wanderProjectAction,
          icon: Icons.public,
          uri: Uri.https('codeberg.org', '/susam/wander'),
        ),
        SmallWebAttributionAction(
          label: l10n.smallWeb_wanderSetupConsoleAction,
          icon: Icons.forum_outlined,
          uri: Uri.https('codeberg.org', '/susam/wander#install'),
        ),
      ],
    );
  }
}

class SmallWebAttributionCard extends StatelessWidget {
  final SmallWebAttributionData data;
  final ValueChanged<Uri> onOpenUri;
  final bool compact;

  const SmallWebAttributionCard({
    super.key,
    required this.data,
    required this.onOpenUri,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final headerStyle = compact
        ? theme.textTheme.titleSmall
        : theme.textTheme.titleMedium;
    final bodyStyle = compact
        ? theme.textTheme.bodySmall
        : theme.textTheme.bodyMedium;
    final spacing = compact ? 8.0 : 12.0;

    return Card(
      color: colorScheme.surfaceContainerHigh,
      child: Padding(
        padding: EdgeInsets.all(compact ? 12 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  data.icon,
                  size: compact ? 20 : 22,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    data.title,
                    style: headerStyle?.copyWith(color: colorScheme.primary),
                  ),
                ),
                if (data.badgeLabel != null)
                  Chip(
                    visualDensity: VisualDensity.compact,
                    label: Text(data.badgeLabel!),
                  ),
              ],
            ),
            SizedBox(height: spacing),
            Text(data.description, style: bodyStyle),
            SizedBox(height: spacing),
            Text(
              data.attributionLine,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            if (data.metadataLine case final metadataLine?) ...[
              const SizedBox(height: 4),
              Text(
                metadataLine,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            SizedBox(height: spacing),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final action in data.actions)
                  ActionChip(
                    avatar: Icon(action.icon, size: 18),
                    label: Text(action.label),
                    onPressed: () => onOpenUri(action.uri),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
