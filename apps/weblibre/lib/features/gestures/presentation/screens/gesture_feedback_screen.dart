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
import 'package:weblibre/features/gestures/data/models/gesture_settings.dart';
import 'package:weblibre/features/gestures/domain/repositories/gesture_settings.dart';
import 'package:weblibre/features/settings/presentation/widgets/settings_detail.dart';

const List<SettingsSectionDefinition> _feedbackSections = [
  SettingsSectionDefinition(
    title: 'Overlay',
    entries: [
      SettingsEntryDefinition(
        title: 'Live feedback',
        subtitle: 'Show the stroke and its action while you draw',
        child: _LiveFeedbackTile(),
      ),
      SettingsEntryDefinition(
        title: 'Suggest next',
        subtitle: 'Also show the other gestures you can complete',
        child: _SuggestNextTile(),
      ),
      SettingsEntryDefinition(
        title: 'Suggest after',
        subtitle: 'Number of strokes to draw before suggestions appear',
        child: _SuggestAfterSection(),
      ),
    ],
  ),
];

/// Controls the live feedback overlay shown while drawing a gesture.
class GestureFeedbackScreen extends StatelessWidget {
  const GestureFeedbackScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SettingsDetailScaffold(
      title: 'Feedback',
      subtitle: 'Live overlay and gesture suggestions.',
      icon: Icons.bolt_outlined,
      sections: _feedbackSections,
    );
  }
}

class _LiveFeedbackTile extends HookConsumerWidget {
  const _LiveFeedbackTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showFeedback = ref.watch(
      gestureSettingsWithDefaultsProvider.select((s) => s.showFeedback),
    );

    return SwitchListTile.adaptive(
      secondary: const Icon(Icons.bolt_outlined),
      title: const Text('Live feedback'),
      subtitle: const Text('Show the stroke and its action while you draw'),
      value: showFeedback,
      onChanged: (value) async {
        await ref
            .read(gestureSettingsRepositoryProvider.notifier)
            .updateSettings((current) => current.copyWith.showFeedback(value));
      },
    );
  }
}

class _SuggestNextTile extends HookConsumerWidget {
  const _SuggestNextTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(gestureSettingsWithDefaultsProvider);

    return SwitchListTile.adaptive(
      secondary: const Icon(Icons.lightbulb_outline),
      title: const Text('Suggest next'),
      subtitle: const Text('Also show the other gestures you can complete'),
      value: settings.suggestNext,
      onChanged: settings.showFeedback
          ? (value) async {
              await ref
                  .read(gestureSettingsRepositoryProvider.notifier)
                  .updateSettings(
                    (current) => current.copyWith.suggestNext(value),
                  );
            }
          : null,
    );
  }
}

class _SuggestAfterSection extends HookConsumerWidget {
  const _SuggestAfterSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(gestureSettingsWithDefaultsProvider);
    final enabled = settings.showFeedback && settings.suggestNext;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          enabled: enabled,
          leading: const Icon(Icons.straighten),
          title: const Text('Suggest after'),
          subtitle: Slider.adaptive(
            min: minGestureMinSuggestionStroke.toDouble(),
            max: maxGestureMinSuggestionStroke.toDouble(),
            divisions:
                maxGestureMinSuggestionStroke - minGestureMinSuggestionStroke,
            value: settings.minSuggestionStroke
                .clamp(
                  minGestureMinSuggestionStroke,
                  maxGestureMinSuggestionStroke,
                )
                .toDouble(),
            label: '${settings.minSuggestionStroke} strokes',
            onChanged: enabled
                ? (value) async {
                    await ref
                        .read(gestureSettingsRepositoryProvider.notifier)
                        .updateSettings(
                          (current) =>
                              current.copyWith.minSuggestionStroke(value.round()),
                        );
                  }
                : null,
          ),
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(72, 0, 16, 8),
          child: Text('Number of strokes to draw before suggestions appear.'),
        ),
      ],
    );
  }
}
