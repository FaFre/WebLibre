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
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:weblibre/features/geckoview/features/open_link_tools/domain/entities/url_cleaner_result.dart';
import 'package:weblibre/features/geckoview/features/open_link_tools/presentation/dialogs/tracking_details_dialog.dart';

class UrlCleanerTile extends StatelessWidget {
  final UrlCleanerResult result;
  final String currentUrl;
  final bool allowReferralMarketing;
  final VoidCallback? onClean;
  final ValueChanged<String>? onApplySelectedRemovals;
  final bool applied;

  const UrlCleanerTile({
    super.key,
    required this.result,
    required this.currentUrl,
    required this.allowReferralMarketing,
    this.onClean,
    this.onApplySelectedRemovals,
    this.applied = false,
  });

  @override
  Widget build(BuildContext context) {
    final paramCount = result.removedParams.length;
    final hasParams = paramCount > 0;

    final String subtitle;
    if (!hasParams) {
      subtitle = 'Tracking parameters removed';
    } else if (paramCount == 1) {
      subtitle = '1 tracking parameter found';
    } else {
      subtitle = '$paramCount tracking parameters found';
    }

    return ListTile(
      leading: Icon(
        applied ? MdiIcons.checkCircle : MdiIcons.broom,
        color: applied
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.error,
      ),
      title: Text(applied ? 'URL cleaned' : 'Tracking detected'),
      subtitle: Text(subtitle),
      trailing: applied || !hasParams
          ? null
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 24, child: VerticalDivider(width: 16)),

                IconButton(
                  icon: const Icon(MdiIcons.linkVariantRemove),
                  tooltip: 'Clean URL',
                  onPressed: onClean,
                ),
              ],
            ),
      dense: true,
      onTap: hasParams
          ? () {
              unawaited(
                showDialog(
                  context: context,
                  builder: (context) => TrackingDetailsDialog(
                    currentUrl: currentUrl,
                    result: result,
                    allowReferralMarketing: allowReferralMarketing,
                    onApplySelectedRemovals: onApplySelectedRemovals,
                  ),
                ),
              );
            }
          : null,
    );
  }
}
