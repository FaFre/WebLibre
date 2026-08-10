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
import 'package:weblibre/features/proxy/domain/services/proxy_latency_tester.dart';
import 'package:weblibre/features/proxy/presentation/widgets/profile_list/ip_chip.dart';
import 'package:weblibre/features/proxy/presentation/widgets/profile_list/latency_chip.dart';

class ProfileSubtitle extends StatelessWidget {
  final String typeLabel;
  final AsyncValue<ProxyLatencyData>? latency;
  final bool autostart;

  const ProfileSubtitle({
    super.key,
    required this.typeLabel,
    required this.latency,
    this.autostart = false,
  });

  Widget _label(BuildContext context) {
    if (!autostart) return Text(typeLabel);

    final scheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(child: Text(typeLabel, overflow: TextOverflow.ellipsis)),
        const SizedBox(width: 6),
        Icon(
          MdiIcons.rocketLaunchOutline,
          size: 14,
          color: scheme.onSurfaceVariant,
        ),
        const SizedBox(width: 2),
        Text(
          'Starts with WebLibre',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final latency = this.latency;
    if (latency == null) {
      return _label(context);
    }

    final egressIp = latency.value?.egressIp;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(context),
        const SizedBox(height: 4),
        Wrap(
          spacing: 6,
          runSpacing: 4,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            LatencyChip(result: latency),
            if (egressIp != null) IpChip(ip: egressIp),
          ],
        ),
      ],
    );
  }
}
