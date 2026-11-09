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
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/features/geckoview/features/split_view/domain/providers/split_view.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';

/// The split glyph on a tab that belongs to the shown split pair (tab tray,
/// quick switcher). Takes no space for any other tab.
class SplitMemberMark extends ConsumerWidget {
  final String tabId;
  final double size;
  final EdgeInsetsGeometry padding;
  final bool withBackground;

  const SplitMemberMark({
    required this.tabId,
    this.size = 14,
    this.padding = EdgeInsets.zero,
    this.withBackground = false,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isMember = ref.watch(isSplitMemberProvider(tabId));
    if (!isMember) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;
    final icon = Icon(
      MdiIcons.viewSplitVertical,
      size: size,
      color: colorScheme.primary,
      semanticLabel: AppLocalizations.of(context).splitView_memberMark,
    );

    return Padding(
      padding: padding,
      child: withBackground
          ? DecoratedBox(
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withAlpha(200),
                borderRadius: const BorderRadius.all(Radius.circular(8.0)),
              ),
              child: Padding(padding: const EdgeInsets.all(6), child: icon),
            )
          : icon,
    );
  }
}
