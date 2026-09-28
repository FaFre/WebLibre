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
import 'package:weblibre/l10n/generated/app_localizations.dart';

List<SettingsSectionDefinition> _feedbackSections(BuildContext context) {
  final l10n = AppLocalizations.of(context);

  return [
    SettingsSectionDefinition(
      title: l10n.gestures_overlaySectionTitle,
      entries: [
        SettingsEntryDefinition(
          title: l10n.gestures_liveFeedbackTitle,
          subtitle: l10n.gestures_liveFeedbackSubtitle,
          child: const _LiveFeedbackTile(),
        ),
        SettingsEntryDefinition(
          title: l10n.gestures_suggestNextTitle,
          subtitle: l10n.gestures_suggestNextSubtitle,
          child: const _SuggestNextTile(),
        ),
        SettingsEntryDefinition(
          title: l10n.gestures_suggestAfterTitle,
          subtitle: l10n.gestures_indexSuggestAfterSubtitle,
          child: const _SuggestAfterSection(),
        ),
      ],
    ),
  ];
}

/// Controls the live feedback overlay shown while drawing a gesture.
class GestureFeedbackScreen extends StatelessWidget {
  const GestureFeedbackScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SettingsDetailScaffold(
      title: l10n.gestures_feedbackTitle,
      subtitle: l10n.gestures_feedbackScreenSubtitle,
      icon: Icons.bolt_outlined,
      sections: _feedbackSections(context),
    );
  }
}

class _LiveFeedbackTile extends HookConsumerWidget {
  const _LiveFeedbackTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final showFeedback = ref.watch(
      gestureSettingsWithDefaultsProvider.select((s) => s.showFeedback),
    );

    return SwitchListTile.adaptive(
      secondary: const Icon(Icons.bolt_outlined),
      title: Text(l10n.gestures_liveFeedbackTitle),
      subtitle: Text(l10n.gestures_liveFeedbackSubtitle),
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
    final l10n = AppLocalizations.of(context);
    final settings = ref.watch(gestureSettingsWithDefaultsProvider);

    return SwitchListTile.adaptive(
      secondary: const Icon(Icons.lightbulb_outline),
      title: Text(l10n.gestures_suggestNextTitle),
      subtitle: Text(l10n.gestures_suggestNextSubtitle),
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
    final l10n = AppLocalizations.of(context);
    final settings = ref.watch(gestureSettingsWithDefaultsProvider);
    final enabled = settings.showFeedback && settings.suggestNext;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          enabled: enabled,
          leading: const Icon(Icons.straighten),
          title: Text(l10n.gestures_suggestAfterTitle),
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
            label: l10n.gestures_strokeCount(settings.minSuggestionStroke),
            onChanged: enabled
                ? (value) async {
                    await ref
                        .read(gestureSettingsRepositoryProvider.notifier)
                        .updateSettings(
                          (current) => current.copyWith.minSuggestionStroke(
                            value.round(),
                          ),
                        );
                  }
                : null,
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(72, 0, 16, 8),
          child: Text(l10n.gestures_suggestAfterDescription),
        ),
      ],
    );
  }
}
