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
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/features/settings/presentation/controllers/save_settings.dart';
import 'package:weblibre/features/settings/presentation/widgets/sections.dart';
import 'package:weblibre/features/user/data/models/engine_settings.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';
import 'package:weblibre/features/user/domain/repositories/engine_settings.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';

class AppearanceDisplaySettingsScreen extends StatelessWidget {
  const AppearanceDisplaySettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Appearance & Display')),
      body: SafeArea(
        child: FadingScroll(
          fadingSize: 25,
          builder: (context, controller) {
            return ListView(
              controller: controller,
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              children: const [
                _VisualSection(),
                _WebContentSection(),
                _TabBarSection(),
                _TabViewSection(),
                _GesturesSection(),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _VisualSection extends StatelessWidget {
  const _VisualSection();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        SettingSection(name: 'Visual'),
        _UiZoomSection(),
        _DisableAnimationsTile(),
        _ShowModalBarrierTile(),
        _ThemeSection(),
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

class _TabBarSection extends StatelessWidget {
  const _TabBarSection();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        SettingSection(name: 'Tab Bar'),
        _TabBarSettingsTile(),
      ],
    );
  }
}

class _TabViewSection extends StatelessWidget {
  const _TabViewSection();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        SettingSection(name: 'Tab View'),
        _BottomSheetTabViewTile(),
        _TabListShowFaviconsTile(),
      ],
    );
  }
}

class _TabBarSettingsTile extends StatelessWidget {
  const _TabBarSettingsTile();

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: const Text('Customize Tab Bar'),
      subtitle: const Text(
        'Layout, contextual bar, quick switcher, and preview',
      ),
      leading: const Icon(MdiIcons.tabUnselected),
      trailing: const Icon(Icons.chevron_right),
      onTap: () async {
        await TabBarSettingsRoute().push(context);
      },
    );
  }
}

class _GesturesSection extends StatelessWidget {
  const _GesturesSection();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        SettingSection(name: 'Gestures'),
        _PullToRefreshTile(),
        _DoubleBackCloseTabTile(),
      ],
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

class _BottomSheetTabViewTile extends HookConsumerWidget {
  const _BottomSheetTabViewTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabViewBottomSheet = ref.watch(
      generalSettingsWithDefaultsProvider.select((s) => s.tabViewBottomSheet),
    );

    return SwitchListTile.adaptive(
      title: const Text('Bottom Sheet Tab View'),
      subtitle: const Text(
        'Display tabs in a bottom sheet instead of fullscreen',
      ),
      secondary: const Icon(MdiIcons.dockBottom),
      value: tabViewBottomSheet,
      onChanged: (value) async {
        await ref
            .read(saveGeneralSettingsControllerProvider.notifier)
            .save(
              (currentSettings) =>
                  currentSettings.copyWith.tabViewBottomSheet(value),
            );
      },
    );
  }
}

class _TabListShowFaviconsTile extends HookConsumerWidget {
  const _TabListShowFaviconsTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabListShowFavicons = ref.watch(
      generalSettingsWithDefaultsProvider.select((s) => s.tabListShowFavicons),
    );

    return SwitchListTile.adaptive(
      title: const Text('Show Favicons in List View'),
      subtitle: const Text(
        'Display website icons instead of page thumbnails in tab list view',
      ),
      secondary: const Icon(MdiIcons.web),
      value: tabListShowFavicons,
      onChanged: (value) async {
        await ref
            .read(saveGeneralSettingsControllerProvider.notifier)
            .save(
              (currentSettings) =>
                  currentSettings.copyWith.tabListShowFavicons(value),
            );
      },
    );
  }
}

class _PullToRefreshTile extends HookConsumerWidget {
  const _PullToRefreshTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pullToRefreshEnabled = ref.watch(
      generalSettingsWithDefaultsProvider.select((s) => s.pullToRefreshEnabled),
    );

    return SwitchListTile.adaptive(
      title: const Text('Pull to Refresh'),
      subtitle: const Text('Swipe down on pages to reload them'),
      secondary: const Icon(MdiIcons.gestureSwipeDown),
      value: pullToRefreshEnabled,
      onChanged: (value) async {
        await ref
            .read(saveGeneralSettingsControllerProvider.notifier)
            .save(
              (currentSettings) =>
                  currentSettings.copyWith.pullToRefreshEnabled(value),
            );
      },
    );
  }
}

class _DoubleBackCloseTabTile extends HookConsumerWidget {
  const _DoubleBackCloseTabTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final doubleBackCloseTab = ref.watch(
      generalSettingsWithDefaultsProvider.select((s) => s.doubleBackCloseTab),
    );

    return SwitchListTile.adaptive(
      title: const Text('Double Back to Close Tab'),
      subtitle: const Text(
        'When enabled, press back twice to close the tab. When disabled, back button only navigates page history.',
      ),
      secondary: const Icon(MdiIcons.gestureDoubleTap),
      value: doubleBackCloseTab,
      onChanged: (value) async {
        await ref
            .read(saveGeneralSettingsControllerProvider.notifier)
            .save(
              (currentSettings) =>
                  currentSettings.copyWith.doubleBackCloseTab(value),
            );
      },
    );
  }
}

class _WebContentSection extends StatelessWidget {
  const _WebContentSection();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        SettingSection(name: 'Web Content'),
        _WebFontsEnabledTile(),
        _AutomaticFontSizeAdjustmentTile(),
        _FontSizeFactorSlider(),
        _FontInflationTile(),
        _InputAutoZoomEnabledTile(),
      ],
    );
  }
}

class _WebFontsEnabledTile extends HookConsumerWidget {
  const _WebFontsEnabledTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final webFontsEnabled = ref.watch(
      engineSettingsWithDefaultsProvider.select((s) => s.webFontsEnabled),
    );

    return SwitchListTile.adaptive(
      title: const Text('Web Fonts'),
      subtitle: const Text('Allow websites to use custom fonts'),
      secondary: const Icon(MdiIcons.formatFont),
      value: webFontsEnabled,
      onChanged: (value) async {
        await ref
            .read(saveEngineSettingsControllerProvider.notifier)
            .save(
              (currentSettings) =>
                  currentSettings.copyWith.webFontsEnabled(value),
            );
      },
    );
  }
}

class _AutomaticFontSizeAdjustmentTile extends HookConsumerWidget {
  const _AutomaticFontSizeAdjustmentTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final automaticFontSizeAdjustment = ref.watch(
      engineSettingsWithDefaultsProvider.select(
        (s) => s.automaticFontSizeAdjustment,
      ),
    );

    return SwitchListTile.adaptive(
      title: const Text('Automatic Font Size'),
      subtitle: const Text(
        'Automatically adjust font size based on system settings. Disable to manually control font size factor and inflation.',
      ),
      secondary: const Icon(MdiIcons.formatFontSizeIncrease),
      value: automaticFontSizeAdjustment,
      onChanged: (value) async {
        await ref
            .read(saveEngineSettingsControllerProvider.notifier)
            .save(
              (currentSettings) =>
                  currentSettings.copyWith.automaticFontSizeAdjustment(value),
            );
      },
    );
  }
}

class _FontSizeFactorSlider extends HookConsumerWidget {
  const _FontSizeFactorSlider();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final automaticFontSizeAdjustment = ref.watch(
      engineSettingsWithDefaultsProvider.select(
        (s) => s.automaticFontSizeAdjustment,
      ),
    );
    final fontSizeFactor = ref.watch(
      engineSettingsWithDefaultsProvider.select((s) => s.fontSizeFactor),
    );
    final sliderValue = useState(fontSizeFactor);

    useEffect(() {
      sliderValue.value = fontSizeFactor;
      return null;
    }, [fontSizeFactor]);

    final sliderLabel = '${(sliderValue.value * 100).round()}%';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: const Text('Font Size Factor'),
            subtitle: Text(
              automaticFontSizeAdjustment
                  ? 'Disabled while automatic font size is enabled'
                  : 'Scale web page text size',
            ),
            leading: const Icon(MdiIcons.formatSize),
            contentPadding: EdgeInsets.zero,
            enabled: !automaticFontSizeAdjustment,
          ),
          Row(
            children: [
              Text(
                sliderLabel,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: automaticFontSizeAdjustment
                      ? Theme.of(context).disabledColor
                      : null,
                ),
              ),
              Expanded(
                child: Slider(
                  min: 0.5,
                  max: 3.0,
                  divisions: 25,
                  label: sliderLabel,
                  value: sliderValue.value.clamp(0.5, 3.0),
                  onChanged: automaticFontSizeAdjustment
                      ? null
                      : (value) {
                          sliderValue.value = value;
                        },
                  onChangeEnd: automaticFontSizeAdjustment
                      ? null
                      : (value) async {
                          final rounded = (value * 10).round() / 10;
                          sliderValue.value = rounded;
                          await ref
                              .read(
                                saveEngineSettingsControllerProvider.notifier,
                              )
                              .save(
                                (currentSettings) => currentSettings.copyWith
                                    .fontSizeFactor(rounded),
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

class _FontInflationTile extends HookConsumerWidget {
  const _FontInflationTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final automaticFontSizeAdjustment = ref.watch(
      engineSettingsWithDefaultsProvider.select(
        (s) => s.automaticFontSizeAdjustment,
      ),
    );
    final fontInflationEnabled = ref.watch(
      engineSettingsWithDefaultsProvider.select((s) => s.fontInflationEnabled),
    );

    return SwitchListTile.adaptive(
      title: const Text('Font Inflation'),
      subtitle: Text(
        automaticFontSizeAdjustment
            ? 'Disabled while automatic font size is enabled'
            : 'Enlarge text on pages that lack a mobile viewport meta tag',
      ),
      secondary: const Icon(MdiIcons.formatTextVariantOutline),
      value: fontInflationEnabled,
      onChanged: automaticFontSizeAdjustment
          ? null
          : (value) async {
              await ref
                  .read(saveEngineSettingsControllerProvider.notifier)
                  .save(
                    (currentSettings) =>
                        currentSettings.copyWith.fontInflationEnabled(value),
                  );
            },
    );
  }
}

class _InputAutoZoomEnabledTile extends HookConsumerWidget {
  const _InputAutoZoomEnabledTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inputAutoZoomEnabled = ref.watch(
      engineSettingsWithDefaultsProvider.select((s) => s.inputAutoZoomEnabled),
    );

    return SwitchListTile.adaptive(
      title: const Text('Input Auto Zoom'),
      subtitle: const Text('Automatically zoom in when focusing text inputs'),
      secondary: const Icon(MdiIcons.formTextbox),
      value: inputAutoZoomEnabled,
      onChanged: (value) async {
        await ref
            .read(saveEngineSettingsControllerProvider.notifier)
            .save(
              (currentSettings) =>
                  currentSettings.copyWith.inputAutoZoomEnabled(value),
            );
      },
    );
  }
}
