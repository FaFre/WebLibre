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
import 'package:fading_scroll/fading_scroll.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/features/settings/presentation/controllers/save_settings.dart';
import 'package:weblibre/features/settings/presentation/widgets/sections.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';

class GeneralSettingsScreen extends StatelessWidget {
  const GeneralSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('General')),
      body: SafeArea(
        child: FadingScroll(
          fadingSize: 25,
          builder: (context, controller) {
            return ListView(
              controller: controller,
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              children: const [_AppearanceSection(), _DownloadsSection()],
            );
          },
        ),
      ),
    );
  }
}

class _AppearanceSection extends StatelessWidget {
  const _AppearanceSection();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        SettingSection(name: 'Appearance'),
        _ThemeSection(),
        _UiZoomSection(),
        _DisableAnimationsTile(),
        _ShowModalBarrierTile(),
      ],
    );
  }
}

class _DownloadsSection extends StatelessWidget {
  const _DownloadsSection();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        SettingSection(name: 'Downloads'),
        _ExternalDownloadManagerTile(),
      ],
    );
  }
}

class _UiZoomSection extends HookConsumerWidget {
  const _UiZoomSection();

  static final _sliderDivisions =
      ((maxUiScaleFactor - minUiScaleFactor) / uiScaleFactorStep).round();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uiScaleFactor = ref.watch(
      generalSettingsWithDefaultsProvider.select((s) => s.uiScaleFactor),
    );
    final sliderValue = useState(uiScaleFactor);

    useEffect(() {
      sliderValue.value = uiScaleFactor;
      return null;
    }, [uiScaleFactor]);

    final sliderLabel = '${(sliderValue.value * 100).round()}%';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ListTile(
            title: Text('User Interface Zoom'),
            subtitle: Text('Make the user interface smaller or larger'),
            leading: Icon(Icons.zoom_in),
            contentPadding: EdgeInsets.zero,
          ),
          Row(
            children: [
              Text(sliderLabel, style: Theme.of(context).textTheme.titleLarge),
              Expanded(
                child: Slider(
                  min: minUiScaleFactor,
                  max: maxUiScaleFactor,
                  divisions: _sliderDivisions,
                  label: sliderLabel,
                  value: sliderValue.value.clamp(
                    minUiScaleFactor,
                    maxUiScaleFactor,
                  ),
                  onChanged: (value) {
                    sliderValue.value = value;
                  },
                  onChangeEnd: (value) async {
                    final normalized = _normalizeUiScale(value);
                    sliderValue.value = normalized;
                    await ref
                        .read(saveGeneralSettingsControllerProvider.notifier)
                        .save(
                          (currentSettings) => currentSettings.copyWith
                              .uiScaleFactor(normalized),
                        );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

double _normalizeUiScale(double value) {
  final clampedValue = value.clamp(minUiScaleFactor, maxUiScaleFactor);
  final stepIndex = ((clampedValue - minUiScaleFactor) / uiScaleFactorStep)
      .round();
  final normalized = minUiScaleFactor + (stepIndex * uiScaleFactorStep);
  return normalized.clamp(minUiScaleFactor, maxUiScaleFactor);
}

class _DisableAnimationsTile extends HookConsumerWidget {
  const _DisableAnimationsTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final disableAnimations = ref.watch(
      generalSettingsWithDefaultsProvider.select((s) => s.disableAnimations),
    );

    return SwitchListTile.adaptive(
      title: const Text('Disable Animations'),
      subtitle: const Text('Reduce motion and turn off app animations'),
      secondary: const Icon(Icons.animation),
      value: disableAnimations,
      onChanged: (value) async {
        await ref
            .read(saveGeneralSettingsControllerProvider.notifier)
            .save(
              (currentSettings) =>
                  currentSettings.copyWith.disableAnimations(value),
            );
      },
    );
  }
}

class _ShowModalBarrierTile extends HookConsumerWidget {
  const _ShowModalBarrierTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showModalBarrier = ref.watch(
      generalSettingsWithDefaultsProvider.select((s) => s.showModalBarrier),
    );

    return SwitchListTile.adaptive(
      title: const Text('Show Modal Barrier'),
      subtitle: const Text(
        'Dim the background behind dialogs and bottom sheets',
      ),
      secondary: const Icon(Icons.layers),
      value: showModalBarrier,
      onChanged: (value) async {
        await ref
            .read(saveGeneralSettingsControllerProvider.notifier)
            .save(
              (currentSettings) =>
                  currentSettings.copyWith.showModalBarrier(value),
            );
      },
    );
  }
}

class _ThemeSection extends HookConsumerWidget {
  const _ThemeSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(
      generalSettingsWithDefaultsProvider.select((s) => s.themeMode),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ListTile(
            title: Text('Theme'),
            leading: Icon(Icons.palette),
            contentPadding: EdgeInsets.zero,
          ),
          Center(
            child: SegmentedButton<ThemeMode>(
              segments: const [
                ButtonSegment(
                  value: ThemeMode.system,
                  icon: Icon(Icons.brightness_auto),
                  label: Text('System'),
                ),
                ButtonSegment(
                  value: ThemeMode.light,
                  icon: Icon(Icons.light_mode),
                  label: Text('Light'),
                ),
                ButtonSegment(
                  value: ThemeMode.dark,
                  icon: Icon(Icons.dark_mode),
                  label: Text('Dark'),
                ),
              ],
              selected: {themeMode},
              onSelectionChanged: (value) async {
                await ref
                    .read(saveGeneralSettingsControllerProvider.notifier)
                    .save(
                      (currentSettings) =>
                          currentSettings.copyWith.themeMode(value.first),
                    );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ExternalDownloadManagerTile extends HookConsumerWidget {
  const _ExternalDownloadManagerTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final useExternalDownloadManager = ref.watch(
      generalSettingsWithDefaultsProvider.select(
        (s) => s.useExternalDownloadManager,
      ),
    );

    return SwitchListTile.adaptive(
      title: const Text('Use external download manager'),
      subtitle: const Text('Manage downloads with another app'),
      secondary: const Icon(Icons.download),
      value: useExternalDownloadManager,
      onChanged: (value) async {
        await ref
            .read(saveGeneralSettingsControllerProvider.notifier)
            .save(
              (currentSettings) =>
                  currentSettings.copyWith.useExternalDownloadManager(value),
            );
      },
    );
  }
}
