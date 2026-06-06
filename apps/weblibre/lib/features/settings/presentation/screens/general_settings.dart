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
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart'
    show GeckoBrowserService;
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/features/settings/presentation/controllers/save_settings.dart';
import 'package:weblibre/features/settings/presentation/widgets/custom_list_tile.dart';
import 'package:weblibre/features/settings/presentation/widgets/settings_detail.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/presentation/hooks/cached_future.dart';

const List<SettingsSectionDefinition> generalSettingsSections = [
  SettingsSectionDefinition(
    title: 'Default Browser',
    keywords: ['browser defaults'],
    entries: [
      SettingsEntryDefinition(
        title: 'Default Browser',
        subtitle: 'Set WebLibre as your default browser',
        keywords: ['system browser'],
        child: _DefaultBrowserTile(),
      ),
    ],
  ),
  SettingsSectionDefinition(
    title: 'Appearance',
    entries: [
      SettingsEntryDefinition(
        title: 'Theme',
        subtitle: 'Choose system, light, or dark mode',
        keywords: ['light', 'dark', 'theme mode'],
        child: _ThemeSection(),
      ),
      SettingsEntryDefinition(
        title: 'Pure Black (OLED)',
        subtitle: 'Use true-black surfaces in dark mode to save power on OLED '
            'screens',
        keywords: ['oled', 'amoled', 'high contrast', 'black', 'dark'],
        child: _PureBlackTile(),
      ),
      SettingsEntryDefinition(
        title: 'User Interface Zoom',
        subtitle: 'Make the user interface smaller or larger',
        keywords: ['ui scale', 'zoom'],
        child: _UiZoomSection(),
      ),
      SettingsEntryDefinition(
        title: 'Disable Animations',
        subtitle: 'Reduce motion and turn off app animations',
        keywords: ['motion'],
        child: _DisableAnimationsTile(),
      ),
      SettingsEntryDefinition(
        title: 'Show Modal Barrier',
        subtitle: 'Dim the background behind dialogs and bottom sheets',
        keywords: ['dialogs', 'bottom sheets', 'overlay'],
        child: _ShowModalBarrierTile(),
      ),
    ],
  ),
  SettingsSectionDefinition(
    title: 'Downloads',
    entries: [
      SettingsEntryDefinition(
        title: 'Use external download manager',
        subtitle: 'Manage downloads with another app',
        keywords: ['downloads'],
        child: _ExternalDownloadManagerTile(),
      ),
    ],
  ),
];

class GeneralSettingsScreen extends StatelessWidget {
  const GeneralSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SettingsDetailScaffold(
      title: 'General',
      subtitle: 'Appearance, downloads, and browser defaults.',
      icon: Icons.tune,
      sections: generalSettingsSections,
    );
  }
}

class _DefaultBrowserTile extends HookConsumerWidget {
  const _DefaultBrowserTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final defaultBrowserRefreshKey = useState(0);

    useOnAppLifecycleStateChange((previous, current) {
      if (current == AppLifecycleState.resumed) {
        defaultBrowserRefreshKey.value++;
      }
    });

    final isDefault = useCachedFuture(
      () => GeckoBrowserService().isDefaultBrowser(),
      [defaultBrowserRefreshKey.value],
    );

    final isCurrentDefaultBrowser = isDefault.data == true;

    return CustomListTile(
      title: 'Default Browser',
      subtitle: isCurrentDefaultBrowser
          ? 'WebLibre is your default browser'
          : 'Set WebLibre as your default browser',
      prefix: Padding(
        padding: const EdgeInsets.only(right: 16.0),
        child: Icon(
          Icons.public,
          size: 24,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
      suffix: FilledButton.icon(
        onPressed: isCurrentDefaultBrowser
            ? null
            : () async {
                await GeckoBrowserService().requestDefaultBrowser();
                defaultBrowserRefreshKey.value++;
              },
        icon: Icon(isCurrentDefaultBrowser ? Icons.check : Icons.open_in_new),
        label: Text(isCurrentDefaultBrowser ? 'Default' : 'Set'),
      ),
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

class _PureBlackTile extends HookConsumerWidget {
  const _PureBlackTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pureBlack = ref.watch(
      generalSettingsWithDefaultsProvider.select((s) => s.pureBlack),
    );
    final themeMode = ref.watch(
      generalSettingsWithDefaultsProvider.select((s) => s.themeMode),
    );

    // OLED surfaces only apply to dark mode; disable the toggle when the app
    // is locked to light mode so the setting can't appear to have no effect.
    final enabled = themeMode != ThemeMode.light;

    return SwitchListTile.adaptive(
      title: const Text('Pure Black (OLED)'),
      subtitle: const Text(
        'Use true-black surfaces in dark mode to save power on OLED screens',
      ),
      secondary: const Icon(Icons.contrast),
      value: pureBlack,
      onChanged: enabled
          ? (value) async {
              await ref
                  .read(saveGeneralSettingsControllerProvider.notifier)
                  .save(
                    (currentSettings) =>
                        currentSettings.copyWith.pureBlack(value),
                  );
            }
          : null,
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
