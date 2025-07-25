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
                      'WebLibre uses a local AI model to read your open tab titles and suggest container tabs and names. Everything happens on your device.\n\n',
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
