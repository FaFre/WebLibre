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
import 'package:weblibre/features/small_web/data/models/kagi_small_web_mode.dart';
import 'package:weblibre/features/small_web/domain/providers.dart';

class SmallWebModeChips extends ConsumerWidget {
  final KagiSmallWebMode? currentMode;
  final bool isLoading;
  final ValueChanged<KagiSmallWebMode> onModeSelected;

  const SmallWebModeChips({
    super.key,
    required this.currentMode,
    required this.isLoading,
    required this.onModeSelected,
  });

  static String _formatCount(int count) {
    if (count >= 1000) {
      final k = count / 1000;
      return k == k.roundToDouble()
          ? '${k.round()}k'
          : '${k.toStringAsFixed(1)}k';
    }
    return count.toString();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final countsAsync = ref.watch(smallWebAllModeItemCountsProvider);
    final counts = countsAsync.value ?? {};
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: 48,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: KagiSmallWebMode.values.length,
        itemBuilder: (context, index) {
          final mode = KagiSmallWebMode.values[index];
          final isSelected = currentMode == mode;
          final count = counts[mode];
          return Padding(
            padding: const EdgeInsets.only(right: 8, top: 4),
            child: ChoiceChip(
              avatar: Icon(mode.icon, size: 18),
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(mode.label),
                  if (count != null && count > 0) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? colorScheme.primary.withValues(alpha: 0.15)
                            : colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        _formatCount(count),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? colorScheme.onPrimaryContainer
                              : colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              selected: isSelected,
              showCheckmark: false,
              onSelected: isLoading ? null : (_) => onModeSelected(mode),
            ),
          );
        },
      ),
    );
  }
}
