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
import 'package:weblibre/core/design/display_features.dart';
import 'package:weblibre/features/gestures/data/models/gesture_settings.dart';
import 'package:weblibre/features/gestures/domain/repositories/gesture_settings.dart';
import 'package:weblibre/features/settings/presentation/widgets/settings_detail.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';
import 'package:weblibre/presentation/utils/units_l10n.dart';

List<SettingsSectionDefinition> _behaviorSections(BuildContext context) {
  final l10n = AppLocalizations.of(context);

  return [
    SettingsSectionDefinition(
      title: l10n.gestures_strokesSectionTitle,
      entries: [
        SettingsEntryDefinition(
          title: l10n.gestures_minStrokeLengthTitle,
          subtitle: l10n.gestures_indexMinStrokeLengthSubtitle,
          keywords: settingsKeywords(l10n.gestures_minStrokeLengthKeywords),
          child: const _StrokeLengthSection(),
        ),
      ],
    ),
    SettingsSectionDefinition(
      title: l10n.gestures_timingSectionTitle,
      entries: [
        SettingsEntryDefinition(
          title: l10n.gestures_timeoutTitle,
          subtitle: l10n.gestures_indexTimeoutSubtitle,
          keywords: settingsKeywords(l10n.gestures_timeoutKeywords),
          child: const _TimeoutSection(),
        ),
        SettingsEntryDefinition(
          title: l10n.gestures_cooldownTitle,
          subtitle: l10n.gestures_indexCooldownSubtitle,
          keywords: settingsKeywords(l10n.gestures_cooldownKeywords),
          child: const _CooldownSection(),
        ),
        SettingsEntryDefinition(
          title: l10n.gestures_strokeIntervalTitle,
          subtitle: l10n.gestures_indexStrokeIntervalSubtitle,
          keywords: settingsKeywords(l10n.gestures_strokeIntervalKeywords),
          child: const _StrokeIntervalSection(),
        ),
      ],
    ),
  ];
}

/// Tuning for the gesture recognizer: stroke size, idle timeout and cooldown.
class GestureBehaviorScreen extends StatelessWidget {
  const GestureBehaviorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SettingsDetailScaffold(
      title: l10n.gestures_behaviorTimingTitle,
      subtitle: l10n.gestures_behaviorTimingScreenSubtitle,
      icon: Icons.tune,
      sections: _behaviorSections(context),
      actions: const [_ResetBehaviorButton()],
    );
  }
}

/// App-bar action that restores the behavior & timing fields (stroke length,
/// timeout, cooldown, stroke interval) to their defaults, leaving bindings,
/// excluded sites and feedback untouched.
class _ResetBehaviorButton extends ConsumerWidget {
  const _ResetBehaviorButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return IconButton(
      icon: const Icon(Icons.settings_backup_restore),
      tooltip: l10n.gestures_resetToDefaultsTooltip,
      onPressed: () async {
        final confirmed = await showDialog<bool>(
          context: context,
          anchorPoint: preferredAnchorPoint(MediaQuery.of(context)),
          builder: (context) => AlertDialog(
            icon: const Icon(Icons.settings_backup_restore),
            title: Text(l10n.gestures_resetBehaviorTimingConfirmTitle),
            content: Text(l10n.gestures_resetBehaviorTimingConfirmContent),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(l10n.common_cancel),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(l10n.common_reset),
              ),
            ],
          ),
        );

        if (confirmed != true) return;

        await ref
            .read(gestureSettingsRepositoryProvider.notifier)
            .updateSettings(
              (current) => current.copyWith(
                strokeSize: defaultGestureStrokeSize,
                timeoutMs: defaultGestureTimeoutMs,
                intervalMs: defaultGestureIntervalMs,
                minStrokeIntervalMs: defaultGestureStrokeIntervalMs,
              ),
            );
      },
    );
  }
}

class _StrokeLengthSection extends HookConsumerWidget {
  const _StrokeLengthSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final settings = ref.watch(gestureSettingsWithDefaultsProvider);

    return ListTile(
      leading: const Icon(MdiIcons.gestureTap),
      title: Text(l10n.gestures_minStrokeLengthTitle),
      subtitle: Slider.adaptive(
        min: minGestureStrokeSize.toDouble(),
        max: maxGestureStrokeSize.toDouble(),
        divisions: maxGestureStrokeSize - minGestureStrokeSize,
        value: settings.strokeSize
            .clamp(minGestureStrokeSize, maxGestureStrokeSize)
            .toDouble(),
        label: '${settings.strokeSize}',
        onChanged: (value) async {
          await ref
              .read(gestureSettingsRepositoryProvider.notifier)
              .updateSettings(
                (current) => current.copyWith.strokeSize(value.round()),
              );
        },
      ),
    );
  }
}

class _TimeoutSection extends HookConsumerWidget {
  const _TimeoutSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final settings = ref.watch(gestureSettingsWithDefaultsProvider);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          leading: const Icon(Icons.hourglass_empty),
          title: Text(l10n.gestures_timeoutTitle),
          subtitle: Slider.adaptive(
            min: minGestureTimeoutMs.toDouble(),
            max: maxGestureTimeoutMs.toDouble(),
            divisions: (maxGestureTimeoutMs - minGestureTimeoutMs) ~/ 100,
            value: settings.timeoutMs
                .clamp(minGestureTimeoutMs, maxGestureTimeoutMs)
                .toDouble(),
            label: formatMilliseconds(l10n, settings.timeoutMs),
            onChanged: (value) async {
              await ref
                  .read(gestureSettingsRepositoryProvider.notifier)
                  .updateSettings(
                    (current) => current.copyWith.timeoutMs(value.round()),
                  );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(72, 0, 16, 8),
          child: Text(l10n.gestures_timeoutDescription),
        ),
      ],
    );
  }
}

class _CooldownSection extends HookConsumerWidget {
  const _CooldownSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final settings = ref.watch(gestureSettingsWithDefaultsProvider);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          leading: const Icon(Icons.timer_outlined),
          title: Text(l10n.gestures_cooldownTitle),
          subtitle: Slider.adaptive(
            min: minGestureIntervalMs.toDouble(),
            max: maxGestureIntervalMs.toDouble(),
            divisions: (maxGestureIntervalMs - minGestureIntervalMs) ~/ 100,
            value: settings.intervalMs
                .clamp(minGestureIntervalMs, maxGestureIntervalMs)
                .toDouble(),
            label: settings.intervalMs == 0
                ? l10n.gestures_offLabel
                : formatMilliseconds(l10n, settings.intervalMs),
            onChanged: (value) async {
              await ref
                  .read(gestureSettingsRepositoryProvider.notifier)
                  .updateSettings(
                    (current) => current.copyWith.intervalMs(value.round()),
                  );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(72, 0, 16, 8),
          child: Text(l10n.gestures_cooldownDescription),
        ),
      ],
    );
  }
}

class _StrokeIntervalSection extends HookConsumerWidget {
  const _StrokeIntervalSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final settings = ref.watch(gestureSettingsWithDefaultsProvider);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          leading: const Icon(Icons.gesture),
          title: Text(l10n.gestures_strokeIntervalTitle),
          subtitle: Slider.adaptive(
            min: minGestureStrokeIntervalMs.toDouble(),
            max: maxGestureStrokeIntervalMs.toDouble(),
            divisions:
                (maxGestureStrokeIntervalMs - minGestureStrokeIntervalMs) ~/ 25,
            value: settings.minStrokeIntervalMs
                .clamp(minGestureStrokeIntervalMs, maxGestureStrokeIntervalMs)
                .toDouble(),
            label: settings.minStrokeIntervalMs == 0
                ? l10n.gestures_offLabel
                : formatMilliseconds(l10n, settings.minStrokeIntervalMs),
            onChanged: (value) async {
              await ref
                  .read(gestureSettingsRepositoryProvider.notifier)
                  .updateSettings(
                    (current) =>
                        current.copyWith.minStrokeIntervalMs(value.round()),
                  );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(72, 0, 16, 8),
          child: Text(l10n.gestures_strokeIntervalDescription),
        ),
      ],
    );
  }
}
