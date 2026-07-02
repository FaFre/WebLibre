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
import 'package:weblibre/features/settings/presentation/controllers/save_settings.dart';
import 'package:weblibre/features/settings/presentation/widgets/settings_detail.dart';
import 'package:weblibre/features/user/data/models/engine_settings.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';
import 'package:weblibre/features/user/domain/repositories/engine_settings.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/presentation/hooks/keyed_state.dart';

const List<SettingsSectionDefinition> webContentSettingsSections = [
  SettingsSectionDefinition(
    title: 'Display',
    entries: [
      SettingsEntryDefinition(
        title: 'Web Fonts',
        subtitle: 'Allow websites to use custom fonts',
        keywords: ['fonts'],
        child: _WebFontsEnabledTile(),
      ),
      SettingsEntryDefinition(
        title: 'Automatic Font Size',
        subtitle: 'Adjust font size based on system settings',
        keywords: ['text size'],
        child: _AutomaticFontSizeAdjustmentTile(),
      ),
      SettingsEntryDefinition(
        title: 'Font Size Factor',
        subtitle: 'Scale web page text size',
        keywords: ['zoom', 'text'],
        child: _FontSizeFactorSlider(),
      ),
      SettingsEntryDefinition(
        title: 'Font Inflation',
        subtitle: 'Enlarge text on pages without a mobile viewport',
        keywords: ['readability'],
        child: _FontInflationTile(),
      ),
      SettingsEntryDefinition(
        title: 'Input Auto Zoom',
        subtitle: 'Automatically zoom when focusing text inputs',
        keywords: ['forms'],
        child: _InputAutoZoomEnabledTile(),
      ),
    ],
  ),
  SettingsSectionDefinition(
    title: 'Content Features',
    entries: [
      SettingsEntryDefinition(
        title: 'Built-in PDF Viewer',
        subtitle: 'Open PDF files directly in the browser',
        keywords: ['pdf'],
        child: _PdfViewerTile(),
      ),
      SettingsEntryDefinition(
        title: 'Enable Reader Mode',
        subtitle: 'Extract and simplify pages for readability',
        keywords: ['reader', 'readability'],
        child: _EnableReaderModeTile(),
      ),
      SettingsEntryDefinition(
        title: 'Enforce Reader Mode',
        subtitle: 'Always show Reader Mode capabilities',
        keywords: ['reader'],
        child: _EnforceReaderModeTile(),
      ),
      SettingsEntryDefinition(
        title: 'On Device AI',
        subtitle: 'Local AI features including topic and tab suggestions',
        keywords: ['local ai', 'suggestions'],
        child: _OnDeviceAiTile(),
      ),
    ],
  ),
];

class WebContentSettingsScreen extends StatelessWidget {
  const WebContentSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SettingsDetailScaffold(
      title: 'Web Content',
      subtitle: 'Text rendering, reader mode, PDFs, and local AI features.',
      icon: MdiIcons.fileDocumentOutline,
      sections: webContentSettingsSections,
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
    final sliderValue = useKeyedState(fontSizeFactor, [fontSizeFactor]);

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

class _PdfViewerTile extends HookConsumerWidget {
  const _PdfViewerTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enablePdfJs = ref.watch(
      engineSettingsWithDefaultsProvider.select((s) => s.enablePdfJs),
    );

    return SwitchListTile.adaptive(
      title: const Text('Built-in PDF Viewer'),
      subtitle: const Text(
        'Open PDF files directly in the browser without downloading',
      ),
      secondary: const Icon(MdiIcons.filePdfBox),
      value: enablePdfJs,
      onChanged: (value) async {
        await ref
            .read(saveEngineSettingsControllerProvider.notifier)
            .save(
              (currentSettings) => currentSettings.copyWith.enablePdfJs(value),
            );
      },
    );
  }
}

class _EnableReaderModeTile extends HookConsumerWidget {
  const _EnableReaderModeTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enableReadability = ref.watch(
      generalSettingsWithDefaultsProvider.select((s) => s.enableReadability),
    );

    return SwitchListTile.adaptive(
      title: const Text('Enable Reader Mode'),
      subtitle: const Text(
        'Optional browser app bar tool that extracts and simplifies web pages for improved readability by removing ads, sidebars, and other non-essential elements.',
      ),
      secondary: const Icon(MdiIcons.bookOpen),
      value: enableReadability,
      onChanged: (value) async {
        await ref
            .read(saveGeneralSettingsControllerProvider.notifier)
            .save(
              (currentSettings) =>
                  currentSettings.copyWith.enableReadability(value),
            );
      },
    );
  }
}

class _EnforceReaderModeTile extends HookConsumerWidget {
  const _EnforceReaderModeTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enableReadability = ref.watch(
      generalSettingsWithDefaultsProvider.select((s) => s.enableReadability),
    );
    final enforceReadability = ref.watch(
      generalSettingsWithDefaultsProvider.select((s) => s.enforceReadability),
    );

    return SwitchListTile.adaptive(
      title: const Text('Enforce Reader Mode'),
      subtitle: const Text(
        'Override readability probability of websites and always show Reader Mode capabilities even the site might not be compatible.',
      ),
      secondary: const Icon(MdiIcons.bookCheck),
      value: enableReadability && enforceReadability,
      onChanged: enableReadability
          ? (value) async {
              await ref
                  .read(saveGeneralSettingsControllerProvider.notifier)
                  .save(
                    (currentSettings) =>
                        currentSettings.copyWith.enforceReadability(value),
                  );
            }
          : null,
    );
  }
}

class _OnDeviceAiTile extends HookConsumerWidget {
  const _OnDeviceAiTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enableLocalAiFeatures = ref.watch(
      generalSettingsWithDefaultsProvider.select(
        (s) => s.enableLocalAiFeatures,
      ),
    );

    return SwitchListTile.adaptive(
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
    );
  }
}
