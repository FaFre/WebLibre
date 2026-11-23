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
import 'package:weblibre/features/geckoview/features/tabs/domain/providers/container_freeze.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';

/// The pause glyph (never the snowflake, which marks isolated tabs) beside a
/// container shown as frozen, with "Frozen" for screen readers (7.2). Takes
/// no space otherwise. Never hidden by the feature policy (P5).
class ContainerFrozenGlyph extends HookConsumerWidget {
  final String containerId;
  final double size;
  final Color? color;

  /// Space after the glyph, when it is shown.
  final double trailingGap;

  const ContainerFrozenGlyph({
    required this.containerId,
    this.size = 14,
    this.color,
    this.trailingGap = 4,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final frozen = ref.watch(
      containerFreezeStateProvider(
        containerId,
      ).select((view) => view?.showsFrozen ?? false),
    );
    if (!frozen) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsetsDirectional.only(end: trailingGap),
      child: Icon(
        MdiIcons.pause,
        size: size,
        color: color,
        semanticLabel: AppLocalizations.of(
          context,
        ).browser_containerFrozenLabel,
      ),
    );
  }
}
