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
import 'package:weblibre/l10n/generated/app_localizations.dart';
import 'package:weblibre/presentation/hooks/keyed_state.dart';

List<SettingsSectionDefinition> webContentSettingsSections(
  BuildContext context,
) {
  final l10n = AppLocalizations.of(context);

  return [
    SettingsSectionDefinition(
      title: l10n.settings_webContentSectionDisplayTitle,
      entries: [
        SettingsEntryDefinition(
          title: l10n.settings_webFontsTitle,
          subtitle: l10n.settings_webFontsSubtitle,
          keywords: settingsKeywords(l10n.settings_webFontsKeywords),
          child: const _WebFontsEnabledTile(),
        ),
        SettingsEntryDefinition(
          title: l10n.settings_automaticFontSizeTitle,
          subtitle: l10n.settings_indexAutomaticFontSizeSubtitle,
          keywords: settingsKeywords(l10n.settings_automaticFontSizeKeywords),
          child: const _AutomaticFontSizeAdjustmentTile(),
        ),
        SettingsEntryDefinition(
          title: l10n.settings_fontSizeFactorTitle,
          subtitle: l10n.settings_fontSizeFactorSubtitle,
          keywords: settingsKeywords(l10n.settings_fontSizeFactorKeywords),
          child: const _FontSizeFactorSlider(),
        ),
        SettingsEntryDefinition(
          title: l10n.settings_fontInflationTitle,
          subtitle: l10n.settings_indexFontInflationSubtitle,
          keywords: settingsKeywords(l10n.settings_fontInflationKeywords),
          child: const _FontInflationTile(),
        ),
        SettingsEntryDefinition(
          title: l10n.settings_inputAutoZoomTitle,
          subtitle: l10n.settings_indexInputAutoZoomSubtitle,
          keywords: settingsKeywords(l10n.settings_inputAutoZoomKeywords),
          child: const _InputAutoZoomEnabledTile(),
        ),
        SettingsEntryDefinition(
          title: l10n.settings_forceUserScalableTitle,
          subtitle: l10n.settings_forceUserScalableSubtitle,
          keywords: settingsKeywords(l10n.settings_forceUserScalableKeywords),
          child: const _ForceUserScalableContentTile(),
        ),
      ],
    ),
    SettingsSectionDefinition(
      title: l10n.settings_webContentSectionContentFeaturesTitle,
      entries: [
        SettingsEntryDefinition(
          title: l10n.settings_pdfViewerTitle,
          subtitle: l10n.settings_indexPdfViewerSubtitle,
          keywords: settingsKeywords(l10n.settings_pdfViewerKeywords),
          child: const _PdfViewerTile(),
        ),
        SettingsEntryDefinition(
          title: l10n.settings_enableReaderModeTitle,
          subtitle: l10n.settings_indexEnableReaderModeSubtitle,
          keywords: settingsKeywords(l10n.settings_enableReaderModeKeywords),
          child: const _EnableReaderModeTile(),
        ),
        SettingsEntryDefinition(
          title: l10n.settings_enforceReaderModeTitle,
          subtitle: l10n.settings_indexEnforceReaderModeSubtitle,
          keywords: settingsKeywords(l10n.settings_enforceReaderModeKeywords),
          child: const _EnforceReaderModeTile(),
        ),
        SettingsEntryDefinition(
          title: l10n.settings_onDeviceAiTitle,
          subtitle: l10n.settings_indexOnDeviceAiSubtitle,
          keywords: settingsKeywords(l10n.settings_onDeviceAiKeywords),
          child: const _OnDeviceAiTile(),
        ),
      ],
    ),
  ];
}

class WebContentSettingsScreen extends StatelessWidget {
  const WebContentSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SettingsDetailScaffold(
      title: l10n.settings_webContentTitle,
      subtitle: l10n.settings_webContentSubtitle,
      icon: MdiIcons.fileDocumentOutline,
      sections: webContentSettingsSections(context),
    );
  }
}

class _WebFontsEnabledTile extends HookConsumerWidget {
  const _WebFontsEnabledTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final webFontsEnabled = ref.watch(
      engineSettingsWithDefaultsProvider.select((s) => s.webFontsEnabled),
    );

    return SwitchListTile.adaptive(
      title: Text(l10n.settings_webFontsTitle),
      subtitle: Text(l10n.settings_webFontsSubtitle),
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
    final l10n = AppLocalizations.of(context);
    final automaticFontSizeAdjustment = ref.watch(
      engineSettingsWithDefaultsProvider.select(
        (s) => s.automaticFontSizeAdjustment,
      ),
    );

    return SwitchListTile.adaptive(
      title: Text(l10n.settings_automaticFontSizeTitle),
      subtitle: Text(l10n.settings_automaticFontSizeSubtitle),
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
    final l10n = AppLocalizations.of(context);
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
            title: Text(l10n.settings_fontSizeFactorTitle),
            subtitle: Text(
              automaticFontSizeAdjustment
                  ? l10n.settings_disabledWhileAutomaticFontSize
                  : l10n.settings_fontSizeFactorSubtitle,
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
    final l10n = AppLocalizations.of(context);
    final automaticFontSizeAdjustment = ref.watch(
      engineSettingsWithDefaultsProvider.select(
        (s) => s.automaticFontSizeAdjustment,
      ),
    );
    final fontInflationEnabled = ref.watch(
      engineSettingsWithDefaultsProvider.select((s) => s.fontInflationEnabled),
    );

    return SwitchListTile.adaptive(
      title: Text(l10n.settings_fontInflationTitle),
      subtitle: Text(
        automaticFontSizeAdjustment
            ? l10n.settings_disabledWhileAutomaticFontSize
            : l10n.settings_fontInflationSubtitle,
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
    final l10n = AppLocalizations.of(context);
    final inputAutoZoomEnabled = ref.watch(
      engineSettingsWithDefaultsProvider.select((s) => s.inputAutoZoomEnabled),
    );

    return SwitchListTile.adaptive(
      title: Text(l10n.settings_inputAutoZoomTitle),
      subtitle: Text(l10n.settings_inputAutoZoomSubtitle),
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

class _ForceUserScalableContentTile extends HookConsumerWidget {
  const _ForceUserScalableContentTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final forceUserScalableContent = ref.watch(
      engineSettingsWithDefaultsProvider.select(
        (s) => s.forceUserScalableContent,
      ),
    );

    return SwitchListTile.adaptive(
      title: Text(l10n.settings_forceUserScalableTitle),
      subtitle: Text(l10n.settings_forceUserScalableSubtitle),
      secondary: const Icon(MdiIcons.gesturePinch),
      value: forceUserScalableContent,
      onChanged: (value) async {
        await ref
            .read(saveEngineSettingsControllerProvider.notifier)
            .save(
              (currentSettings) =>
                  currentSettings.copyWith.forceUserScalableContent(value),
            );
      },
    );
  }
}

class _PdfViewerTile extends HookConsumerWidget {
  const _PdfViewerTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final enablePdfJs = ref.watch(
      engineSettingsWithDefaultsProvider.select((s) => s.enablePdfJs),
    );

    return SwitchListTile.adaptive(
      title: Text(l10n.settings_pdfViewerTitle),
      subtitle: Text(l10n.settings_pdfViewerSubtitle),
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
    final l10n = AppLocalizations.of(context);
    final enableReadability = ref.watch(
      generalSettingsWithDefaultsProvider.select((s) => s.enableReadability),
    );

    return SwitchListTile.adaptive(
      title: Text(l10n.settings_enableReaderModeTitle),
      subtitle: Text(l10n.settings_enableReaderModeSubtitle),
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
    final l10n = AppLocalizations.of(context);
    final enableReadability = ref.watch(
      generalSettingsWithDefaultsProvider.select((s) => s.enableReadability),
    );
    final enforceReadability = ref.watch(
      generalSettingsWithDefaultsProvider.select((s) => s.enforceReadability),
    );

    return SwitchListTile.adaptive(
      title: Text(l10n.settings_enforceReaderModeTitle),
      subtitle: Text(l10n.settings_enforceReaderModeSubtitle),
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
    final l10n = AppLocalizations.of(context);
    final enableLocalAiFeatures = ref.watch(
      generalSettingsWithDefaultsProvider.select(
        (s) => s.enableLocalAiFeatures,
      ),
    );

    return SwitchListTile.adaptive(
      title: Text(l10n.settings_onDeviceAiTitle),
      subtitle: Text(l10n.settings_onDeviceAiSubtitle),
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
