/*
 * Copyright (c) 2024-2025 Fabian Freund.
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
import 'package:weblibre/features/settings/presentation/controllers/save_settings.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';

class AiConfigurationPage extends HookConsumerWidget {
  const AiConfigurationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    final enableLocalAiFeatures = ref.watch(
      generalSettingsRepositoryProvider.select(
        (settings) => settings.enableLocalAiFeatures,
      ),
    );

    return ListView(
      children: [
        const SizedBox(height: 24),
        Center(
          child: Text('AI Features', style: theme.textTheme.headlineMedium),
        ),
        const SizedBox(height: 24),
        SwitchListTile.adaptive(
          title: const Text('On Device AI'),
          subtitle: const Text(
            'Local on-device features including container topic and tab suggestions',
          ),
          secondary: const Icon(MdiIcons.creation),
          value: enableLocalAiFeatures,
          onChanged: (value) async {
            await ref
                .read(saveGeneralSettingsControllerProvider.notifier)
                .save(
                  (currentSettings) =>
                      currentSettings.copyWith.enableLocalAiFeatures(value),
                );
          },
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24.0),
          margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.error,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Text.rich(
            TextSpan(
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onError,
                height: 1.4,
              ),
              children: [
                TextSpan(
                  text: 'Things to keep in mind\n\n',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onError,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const TextSpan(text: '• '),
                const TextSpan(
                  text:
                      'WebLibre uses a local AI model to analyze your open tab titles and suggest container tabs and names. All processing happens entirely on your device.\n\n',
                ),
                const TextSpan(text: '• '),
                const TextSpan(
                  text:
                      'AI enhancements operate entirely within your browser, keeping all data on your device. Local AI processing respects your privacy and provides faster suggestions for container groups and names. You can control this behavior anytime through settings.\n\n',
                ),
                const TextSpan(text: '• '),
                const TextSpan(
                  text:
                      'AI can sometimes make mistakes, so please review suggested group names and tab selections.',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
