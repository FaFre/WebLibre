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
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/features/proxy/domain/services/proxy_latency_tester.dart';
import 'package:weblibre/features/proxy/presentation/widgets/profile_list/autostart_chip.dart';
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

  @override
  Widget build(BuildContext context) {
    final latency = this.latency;
    final egressIp = latency?.value?.egressIp;

    // The marker rides in the chip row rather than next to the type label:
    // sharing that line left the label fighting the marker for width, and the
    // label lost (ellipsized to nothing on narrower tiles).
    final chips = <Widget>[
      if (autostart) const AutostartChip(),
      if (latency != null) LatencyChip(result: latency),
      if (egressIp != null) IpChip(ip: egressIp),
    ];

    if (chips.isEmpty) return Text(typeLabel);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(typeLabel),
        const SizedBox(height: 4),
        Wrap(
          spacing: 6,
          runSpacing: 4,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: chips,
        ),
      ],
    );
  }
}
