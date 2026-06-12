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
import 'package:weblibre/features/gestures/data/models/gesture_settings.dart';
import 'package:weblibre/features/gestures/domain/repositories/gesture_settings.dart';
import 'package:weblibre/features/settings/presentation/widgets/settings_detail.dart';

const List<SettingsSectionDefinition> _behaviorSections = [
  SettingsSectionDefinition(
    title: 'Strokes',
    entries: [
      SettingsEntryDefinition(
        title: 'Minimum stroke length',
        subtitle: 'Minimum swipe length recognised as a direction',
        keywords: ['size', 'length', 'sensitivity'],
        child: _StrokeLengthSection(),
      ),
    ],
  ),
  SettingsSectionDefinition(
    title: 'Timing',
    entries: [
      SettingsEntryDefinition(
        title: 'Timeout',
        subtitle: 'Drop a stroke if no new direction is drawn',
        keywords: ['delay'],
        child: _TimeoutSection(),
      ),
      SettingsEntryDefinition(
        title: 'Cooldown',
        subtitle: 'Minimum delay between two gestures firing',
        keywords: ['interval'],
        child: _CooldownSection(),
      ),
      SettingsEntryDefinition(
        title: 'Stroke interval',
        subtitle: 'Reject a gesture when direction changes come too fast',
        keywords: ['debounce', 'jitter', 'accidental'],
        child: _StrokeIntervalSection(),
      ),
    ],
  ),
];

/// Tuning for the gesture recognizer: stroke size, idle timeout and cooldown.
class GestureBehaviorScreen extends StatelessWidget {
  const GestureBehaviorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SettingsDetailScaffold(
      title: 'Behavior & timing',
      subtitle: 'Stroke length, timeout, and cooldown.',
      icon: Icons.tune,
      sections: _behaviorSections,
      actions: [_ResetBehaviorButton()],
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
    return IconButton(
      icon: const Icon(Icons.settings_backup_restore),
      tooltip: 'Reset to defaults',
      onPressed: () async {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            icon: const Icon(Icons.settings_backup_restore),
            title: const Text('Reset behavior & timing?'),
            content: const Text(
              'Stroke length, timeout, cooldown and stroke interval will be '
              'restored to their defaults. Your gesture bindings and other '
              'settings are kept.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Reset'),
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
    final settings = ref.watch(gestureSettingsWithDefaultsProvider);

    return ListTile(
      leading: const Icon(MdiIcons.gestureTap),
      title: const Text('Minimum stroke length'),
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
    final settings = ref.watch(gestureSettingsWithDefaultsProvider);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          leading: const Icon(Icons.hourglass_empty),
          title: const Text('Timeout'),
          subtitle: Slider.adaptive(
            min: minGestureTimeoutMs.toDouble(),
            max: maxGestureTimeoutMs.toDouble(),
            divisions: (maxGestureTimeoutMs - minGestureTimeoutMs) ~/ 100,
            value: settings.timeoutMs
                .clamp(minGestureTimeoutMs, maxGestureTimeoutMs)
                .toDouble(),
            label: '${settings.timeoutMs} ms',
            onChanged: (value) async {
              await ref
                  .read(gestureSettingsRepositoryProvider.notifier)
                  .updateSettings(
                    (current) => current.copyWith.timeoutMs(value.round()),
                  );
            },
          ),
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(72, 0, 16, 8),
          child: Text(
            'A stroke is dropped if no new direction is drawn within this time.',
          ),
        ),
      ],
    );
  }
}

class _CooldownSection extends HookConsumerWidget {
  const _CooldownSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(gestureSettingsWithDefaultsProvider);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          leading: const Icon(Icons.timer_outlined),
          title: const Text('Cooldown'),
          subtitle: Slider.adaptive(
            min: minGestureIntervalMs.toDouble(),
            max: maxGestureIntervalMs.toDouble(),
            divisions: (maxGestureIntervalMs - minGestureIntervalMs) ~/ 100,
            value: settings.intervalMs
                .clamp(minGestureIntervalMs, maxGestureIntervalMs)
                .toDouble(),
            label: settings.intervalMs == 0
                ? 'Off'
                : '${settings.intervalMs} ms',
            onChanged: (value) async {
              await ref
                  .read(gestureSettingsRepositoryProvider.notifier)
                  .updateSettings(
                    (current) => current.copyWith.intervalMs(value.round()),
                  );
            },
          ),
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(72, 0, 16, 8),
          child: Text('Minimum delay between two gestures firing.'),
        ),
      ],
    );
  }
}

class _StrokeIntervalSection extends HookConsumerWidget {
  const _StrokeIntervalSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(gestureSettingsWithDefaultsProvider);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          leading: const Icon(Icons.gesture),
          title: const Text('Stroke interval'),
          subtitle: Slider.adaptive(
            min: minGestureStrokeIntervalMs.toDouble(),
            max: maxGestureStrokeIntervalMs.toDouble(),
            divisions:
                (maxGestureStrokeIntervalMs - minGestureStrokeIntervalMs) ~/ 25,
            value: settings.minStrokeIntervalMs
                .clamp(minGestureStrokeIntervalMs, maxGestureStrokeIntervalMs)
                .toDouble(),
            label: settings.minStrokeIntervalMs == 0
                ? 'Off'
                : '${settings.minStrokeIntervalMs} ms',
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
        const Padding(
          padding: EdgeInsets.fromLTRB(72, 0, 16, 8),
          child: Text(
            'Minimum time between direction changes within one gesture. '
            'Faster changes abort the gesture, guarding against accidental '
            'triggers.',
          ),
        ),
      ],
    );
  }
}
