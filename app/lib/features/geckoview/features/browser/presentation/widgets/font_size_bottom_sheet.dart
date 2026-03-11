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
import 'package:weblibre/features/geckoview/features/browser/domain/entities/font_size_constants.dart';
import 'package:weblibre/features/settings/presentation/controllers/save_settings.dart';
import 'package:weblibre/features/user/data/models/engine_settings.dart';
import 'package:weblibre/features/user/domain/repositories/engine_settings.dart';

Future<void> showFontSizeBottomSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) => const FontSizeBottomSheet(),
  );
}

class FontSizeBottomSheet extends ConsumerWidget {
  const FontSizeBottomSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(engineSettingsWithDefaultsProvider);
    final factor = settings.fontSizeFactor;
    final isAutomatic = settings.automaticFontSizeAdjustment;
    final canDecrease = !isAutomatic && factor > fontSizeMin;
    final canIncrease = !isAutomatic && factor < fontSizeMax;
    final isDefault = factor == fontSizeDefault;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(
                  MdiIcons.formatSize,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Text Size',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (isAutomatic)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Card(
                  color: Theme.of(context)
                      .colorScheme
                      .surfaceContainerHighest,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 20,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Automatic font size is enabled. '
                            'Disable in Settings to adjust manually.',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton.filled(
                  onPressed: canDecrease
                      ? () => _adjustFontSize(ref, increase: false)
                      : null,
                  icon: const Icon(MdiIcons.formatFontSizeDecrease),
                ),
                const SizedBox(width: 24),
                SizedBox(
                  width: 72,
                  child: Text(
                    '${(factor * 100).round()}%',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ),
                const SizedBox(width: 24),
                IconButton.filled(
                  onPressed: canIncrease
                      ? () => _adjustFontSize(ref, increase: true)
                      : null,
                  icon: const Icon(MdiIcons.formatFontSizeIncrease),
                ),
              ],
            ),
            if (!isDefault && !isAutomatic) ...[
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => _resetFontSize(ref),
                child: const Text('Reset to 100%'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _adjustFontSize(WidgetRef ref, {required bool increase}) async {
    final current = ref.read(engineSettingsWithDefaultsProvider).fontSizeFactor;
    final newValue = increase
        ? (current + fontSizeStep).clamp(fontSizeMin, fontSizeMax)
        : (current - fontSizeStep).clamp(fontSizeMin, fontSizeMax);
    final rounded = (newValue * 10).round() / 10;

    if (rounded == current) return;

    await ref
        .read(saveEngineSettingsControllerProvider.notifier)
        .save(
          (currentSettings) => currentSettings.copyWith.fontSizeFactor(rounded),
        );
  }

  Future<void> _resetFontSize(WidgetRef ref) async {
    await ref
        .read(saveEngineSettingsControllerProvider.notifier)
        .save(
          (currentSettings) =>
              currentSettings.copyWith.fontSizeFactor(fontSizeDefault),
        );
  }
}
