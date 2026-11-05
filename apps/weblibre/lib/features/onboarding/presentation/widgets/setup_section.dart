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

/// A titled group of tiles, drawn like a settings section: the title in the
/// primary color above a filled card, the tiles separated by dividers. The
/// card always spans the full width, whatever its content.
class SetupSection extends StatelessWidget {
  const SetupSection({
    super.key,
    this.title,
    this.supportingText,
    required this.children,
  });

  final String? title;

  /// A line under [title] that explains the group, outside the card: the
  /// card holds only its rows (Material 3 lists).
  final String? supportingText;

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (title case final title?) ...[
            SetupSectionTitle(title),
            SizedBox(height: supportingText == null ? 12 : 4),
          ],
          if (supportingText case final supportingText?) ...[
            Text(
              supportingText,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
          ],
          Card.filled(
            margin: EdgeInsets.zero,
            color: colorScheme.surfaceContainer,
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                for (var i = 0; i < children.length; i++) ...[
                  if (i > 0) const Divider(height: 1),
                  children[i],
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The title of a [SetupSection], also for a group of controls drawn without
/// its card (chips, a segmented button).
class SetupSectionTitle extends StatelessWidget {
  const SetupSectionTitle(this.title, {super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      header: true,
      child: Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// A row that opens another screen over the onboarding, which edits the
/// draft through the edit layer.
class SetupLinkTile extends StatelessWidget {
  const SetupLinkTile({
    super.key,
    required this.icon,
    required this.title,
    required this.open,
    this.subtitle,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Future<void> Function(BuildContext context) open;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing: const Icon(Icons.chevron_right),
      onTap: () => open(context),
    );
  }
}

/// What to know about the switch above it, drawn as part of that row: it
/// starts at the row's text (past the 16 padding, 24 icon and 16 gap of the
/// list tile) and ends with its 24 end padding, so it reads as the row's
/// own detail rather than a panel of its own.
class SetupNotice extends StatelessWidget {
  const SetupNotice({
    super.key,
    required this.color,
    required this.onColor,
    required this.title,
    required this.points,
    this.margin = const EdgeInsetsDirectional.fromSTEB(56, 0, 24, 16),
    this.action,
  });

  final Color color;
  final Color onColor;
  final String title;
  final List<String> points;

  /// Defaults to the row-detail inset above; a notice about the whole page
  /// passes its own.
  final EdgeInsetsGeometry margin;

  /// A button under the points, at the end.
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      margin: margin,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              color: onColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          for (final point in points) ...[
            const SizedBox(height: 8),
            Text(
              '• $point',
              style: theme.textTheme.bodySmall?.copyWith(color: onColor),
            ),
          ],
          if (action case final action?) ...[
            const SizedBox(height: 12),
            Align(alignment: AlignmentDirectional.centerEnd, child: action),
          ],
        ],
      ),
    );
  }
}

/// Opens [screen] over the onboarding. A plain route: the screens edit the
/// draft through the edit layer wherever they are built.
Future<void> pushSetupScreen(BuildContext context, Widget screen) =>
    Navigator.of(context).push<void>(MaterialPageRoute(builder: (_) => screen));
