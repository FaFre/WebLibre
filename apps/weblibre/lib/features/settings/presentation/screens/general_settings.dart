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
import 'dart:convert';

import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart'
    show GeckoBrowserService, PreferredDownloadManager;
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:saf_util/saf_util.dart';
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/core/providers/app_localizations.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/domain/repositories/locale_resolver.dart';
import 'package:weblibre/extensions/locale.dart';
import 'package:weblibre/features/settings/domain/providers/preferred_download_manager.dart';
import 'package:weblibre/features/settings/presentation/controllers/save_settings.dart';
import 'package:weblibre/features/settings/presentation/widgets/custom_list_tile.dart';
import 'package:weblibre/features/settings/presentation/widgets/settings_detail.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';
import 'package:weblibre/features/user/domain/providers.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';
import 'package:weblibre/presentation/hooks/cached_future.dart';
import 'package:weblibre/presentation/hooks/keyed_state.dart';

List<SettingsSectionDefinition> generalSettingsSections(BuildContext context) {
  final l10n = AppLocalizations.of(context);

  return [
    SettingsSectionDefinition(
      title: l10n.settings_defaultBrowserSectionTitle,
      keywords: settingsKeywords(l10n.settings_defaultBrowserSectionKeywords),
      entries: [
        SettingsEntryDefinition(
          title: l10n.settings_defaultBrowserTileTitle,
          subtitle: l10n.settings_indexDefaultBrowserSubtitle,
          keywords: settingsKeywords(l10n.settings_defaultBrowserTileKeywords),
          child: const _DefaultBrowserTile(),
        ),
      ],
    ),
    SettingsSectionDefinition(
      title: l10n.settings_appearanceSectionTitle,
      entries: [
        SettingsEntryDefinition(
          title: l10n.settings_themeTitle,
          subtitle: l10n.settings_indexThemeSubtitle,
          keywords: settingsKeywords(l10n.settings_themeKeywords),
          child: const _ThemeSection(),
        ),
        SettingsEntryDefinition(
          title: l10n.settings_indexAppLanguageTitle,
          subtitle: l10n.settings_indexAppLanguageSubtitle,
          keywords: settingsKeywords(l10n.settings_indexAppLanguageKeywords),
          child: const _AppLanguageSection(),
        ),
        SettingsEntryDefinition(
          title: l10n.settings_pureBlackTitle,
          subtitle: l10n.settings_pureBlackSubtitle,
          keywords: settingsKeywords(l10n.settings_pureBlackKeywords),
          child: const _PureBlackTile(),
        ),
        SettingsEntryDefinition(
          title: l10n.settings_uiZoomTitle,
          subtitle: l10n.settings_uiZoomSubtitle,
          keywords: settingsKeywords(l10n.settings_uiZoomKeywords),
          child: const _UiZoomSection(),
        ),
        SettingsEntryDefinition(
          title: l10n.settings_refreshRateTitle,
          subtitle: l10n.settings_indexRefreshRateSubtitle,
          keywords: settingsKeywords(l10n.settings_refreshRateKeywords),
          child: const _RefreshRateSection(),
        ),
        SettingsEntryDefinition(
          title: l10n.settings_disableAnimationsTitle,
          subtitle: l10n.settings_disableAnimationsSubtitle,
          keywords: settingsKeywords(l10n.settings_disableAnimationsKeywords),
          child: const _DisableAnimationsTile(),
        ),
        SettingsEntryDefinition(
          title: l10n.settings_showModalBarrierTitle,
          subtitle: l10n.settings_showModalBarrierSubtitle,
          keywords: settingsKeywords(l10n.settings_showModalBarrierKeywords),
          child: const _ShowModalBarrierTile(),
        ),
        SettingsEntryDefinition(
          title: l10n.settings_showSearchCloseButtonTitle,
          subtitle: l10n.settings_indexShowCloseButtonSubtitle,
          keywords: settingsKeywords(
            l10n.settings_showSearchCloseButtonKeywords,
          ),
          child: const _ShowSearchCloseButtonTile(),
        ),
      ],
    ),
    SettingsSectionDefinition(
      title: l10n.settings_profileSectionTitle,
      keywords: settingsKeywords(l10n.settings_profileSectionKeywords),
      entries: [
        SettingsEntryDefinition(
          title: l10n.settings_backupProfileTitle,
          subtitle: l10n.settings_indexBackupProfileSubtitle,
          keywords: settingsKeywords(l10n.settings_backupProfileKeywords),
          child: const _BackupProfileTile(),
        ),
        SettingsEntryDefinition(
          title: l10n.settings_settingsTransferTileTitle,
          subtitle: l10n.settings_indexSettingsTransferSubtitle,
          keywords: settingsKeywords(
            l10n.settings_settingsTransferTileKeywords,
          ),
          child: const _SettingsTransferTile(),
        ),
      ],
    ),
    SettingsSectionDefinition(
      title: l10n.settings_downloadsSectionTitle,
      entries: [
        SettingsEntryDefinition(
          title: l10n.settings_externalDownloadManagerTitle,
          subtitle: l10n.settings_externalDownloadManagerSubtitle,
          keywords: settingsKeywords(
            l10n.settings_externalDownloadManagerKeywords,
          ),
          child: const _ExternalDownloadManagerTile(),
        ),
        SettingsEntryDefinition(
          title: l10n.settings_preferredDownloadManagerTitle,
          subtitle: l10n.settings_indexPreferredDownloadManagerSubtitle,
          keywords: settingsKeywords(
            l10n.settings_preferredDownloadManagerKeywords,
          ),
          child: const PreferredDownloadManagerTile(),
        ),
        SettingsEntryDefinition(
          title: l10n.settings_downloadFolderTitle,
          subtitle: l10n.settings_indexDownloadFolderSubtitle,
          keywords: settingsKeywords(l10n.settings_downloadFolderKeywords),
          child: const _DownloadDirectoryTile(),
        ),
      ],
    ),
  ];
}

/// Takes a backup of the *active* profile without switching away from it.
///
/// The route it opens is the same one the user list reaches, and nothing about
/// the operation is special-cased here: the backup is queued and taken by the
/// next process, with the profile closed. This tile exists only because backing
/// up the profile you are using is the common case, and getting to it through
/// Profiles → yourself → Backup is not an obvious path.
class _BackupProfileTile extends HookConsumerWidget {
  const _BackupProfileTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(selectedProfileProvider);
    final l10n = AppLocalizations.of(context);

    return ListTile(
      enabled: profile.hasValue,
      leading: const Icon(MdiIcons.safe),
      title: Text(l10n.settings_backupProfileTitle),
      subtitle: Text(switch (profile) {
        AsyncData(:final value) => l10n.settings_backupProfileSubtitleReady(
          value.name,
        ),
        AsyncError() => l10n.settings_backupProfileSubtitleError,
        _ => l10n.common_loading,
      }),
      trailing: const Icon(Icons.chevron_right),
      onTap: profile.hasValue
          ? () async {
              await BackupProfileRoute(
                profile: jsonEncode(profile.requireValue.toJson()),
              ).push(context);
            }
          : null,
    );
  }
}

/// Settings only — the profile backup above it is the whole-profile answer.
///
/// Sits next to it because that is where people look for "get my setup onto
/// the other device", and the two differ in what they carry rather than in
/// where they live.
class _SettingsTransferTile extends StatelessWidget {
  const _SettingsTransferTile();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return ListTile(
      leading: const Icon(MdiIcons.swapHorizontal),
      title: Text(l10n.settings_settingsTransferTileTitle),
      subtitle: Text(l10n.settings_settingsTransferTileSubtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => const SettingsTransferRoute().push(context),
    );
  }
}

class GeneralSettingsScreen extends StatelessWidget {
  const GeneralSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SettingsDetailScaffold(
      title: l10n.settings_generalTitle,
      subtitle: l10n.settings_generalSubtitle,
      icon: Icons.tune,
      sections: generalSettingsSections(context),
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
    final l10n = AppLocalizations.of(context);

    return CustomListTile(
      title: l10n.settings_defaultBrowserTileTitle,
      subtitle: isCurrentDefaultBrowser
          ? l10n.settings_defaultBrowserTileSubtitleSet
          : l10n.settings_defaultBrowserTileSubtitleNotSet,
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
        label: Text(
          isCurrentDefaultBrowser
              ? l10n.settings_defaultBrowserButtonDefault
              : l10n.settings_defaultBrowserButtonSet,
        ),
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
    final sliderValue = useKeyedState(uiScaleFactor, [uiScaleFactor]);

    final sliderLabel = '${(sliderValue.value * 100).round()}%';
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: Text(l10n.settings_uiZoomTitle),
            subtitle: Text(l10n.settings_uiZoomSubtitle),
            leading: const Icon(Icons.zoom_in),
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
    final l10n = AppLocalizations.of(context);

    return SwitchListTile.adaptive(
      title: Text(l10n.settings_disableAnimationsTitle),
      subtitle: Text(l10n.settings_disableAnimationsSubtitle),
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
    final l10n = AppLocalizations.of(context);

    return SwitchListTile.adaptive(
      title: Text(l10n.settings_showModalBarrierTitle),
      subtitle: Text(l10n.settings_showModalBarrierSubtitle),
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

class _ShowSearchCloseButtonTile extends HookConsumerWidget {
  const _ShowSearchCloseButtonTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showSearchCloseButton = ref.watch(
      generalSettingsWithDefaultsProvider.select(
        (s) => s.showSearchCloseButton,
      ),
    );
    final l10n = AppLocalizations.of(context);

    return SwitchListTile.adaptive(
      title: Text(l10n.settings_showSearchCloseButtonTitle),
      subtitle: Text(l10n.settings_showSearchCloseButtonSubtitle),
      secondary: const Icon(Icons.close),
      value: showSearchCloseButton,
      onChanged: (value) async {
        await ref
            .read(saveGeneralSettingsControllerProvider.notifier)
            .save(
              (currentSettings) =>
                  currentSettings.copyWith.showSearchCloseButton(value),
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
    final l10n = AppLocalizations.of(context);

    return SwitchListTile.adaptive(
      title: Text(l10n.settings_pureBlackTitle),
      subtitle: Text(l10n.settings_pureBlackSubtitle),
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
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: Text(l10n.settings_themeTitle),
            leading: const Icon(Icons.palette),
            contentPadding: EdgeInsets.zero,
          ),
          Center(
            child: SegmentedButton<ThemeMode>(
              segments: [
                ButtonSegment(
                  value: ThemeMode.system,
                  icon: const Icon(Icons.brightness_auto),
                  label: Text(l10n.settings_themeModeSystem),
                ),
                ButtonSegment(
                  value: ThemeMode.light,
                  icon: const Icon(Icons.light_mode),
                  label: Text(l10n.settings_themeModeLight),
                ),
                ButtonSegment(
                  value: ThemeMode.dark,
                  icon: const Icon(Icons.dark_mode),
                  label: Text(l10n.settings_themeModeDark),
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

/// Picks the language WebLibre's own UI renders in, distinct from the
/// "Browser Languages" setting under Privacy & Security (which is the
/// Accept-Language list exposed to websites, not the app's own interface).
///
/// `null` means "follow the system locale". The choices are
/// [AppLocalizations.supportedLocales], i.e. every locale with an
/// `app_<locale>.arb`.
class _AppLanguageSection extends HookConsumerWidget {
  const _AppLanguageSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // The resolved override rather than the raw tag: a stored tag that is no
    // longer supported falls back to the system locale, and the list has to
    // show that instead of leaving every option unselected.
    final appLocale = ref.watch(effectiveAppLocaleProvider);
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: Text(l10n.settings_indexAppLanguageTitle),
            subtitle: Text(l10n.settings_indexAppLanguageSubtitle),
            leading: const Icon(Icons.language),
            contentPadding: EdgeInsets.zero,
          ),
          RadioGroup<String?>(
            groupValue: appLocale?.toLanguageTag(),
            onChanged: (value) async {
              await ref
                  .read(saveGeneralSettingsControllerProvider.notifier)
                  .save(
                    (currentSettings) =>
                        currentSettings.copyWith.appLocale(value),
                  );
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RadioListTile<String?>(
                  value: null,
                  title: Text(l10n.settings_appLanguageSystemDefault),
                  // Says which language "system" lands on, since a device
                  // language WebLibre does not ship falls back to another.
                  subtitle: _LanguageName(
                    systemAppLocale,
                    builder: (name) =>
                        Text(l10n.settings_appLanguageCurrentlyLabel(name)),
                  ),
                ),
                for (final locale in AppLocalizations.supportedLocales)
                  RadioListTile<String?>(
                    value: locale.toLanguageTag(),
                    title: _LanguageName(locale, builder: Text.new),
                    // Icon-sized, so it stays a hint beside the name rather
                    // than competing with it.
                    secondary: CountryFlag.fromLanguageCode(
                      locale.languageCode,
                      theme: const ImageTheme(
                        width: 24,
                        height: 24,
                        shape: Circle(),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// [locale]'s language, named in that language itself, so someone who cannot
/// read the current UI language can still find theirs.
class _LanguageName extends ConsumerWidget {
  const _LanguageName(this.locale, {required this.builder});

  final Locale locale;
  final Widget Function(String name) builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final intlLocale = locale.toIntlLocale();
    final resolvedAsync = ref.watch(
      resolveLocaleProvider(intlLocale, intlLocale),
    );

    return builder(
      resolvedAsync.maybeWhen(
        data: (data) => data.languageName,
        orElse: () => locale.toLanguageTag(),
      ),
    );
  }
}

class _RefreshRateSection extends HookConsumerWidget {
  const _RefreshRateSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final refreshRateMode = ref.watch(
      generalSettingsWithDefaultsProvider.select((s) => s.refreshRateMode),
    );
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: Text(l10n.settings_refreshRateTitle),
            subtitle: Text(l10n.settings_refreshRateSubtitle),
            leading: const Icon(Icons.speed),
            contentPadding: EdgeInsets.zero,
          ),
          Center(
            child: SegmentedButton<RefreshRateMode>(
              segments: [
                ButtonSegment(
                  value: RefreshRateMode.system,
                  icon: const Icon(Icons.smartphone),
                  label: Text(l10n.settings_refreshRateModeSystem),
                ),
                ButtonSegment(
                  value: RefreshRateMode.high,
                  icon: const Icon(Icons.bolt),
                  label: Text(l10n.settings_refreshRateModeHigh),
                ),
                ButtonSegment(
                  value: RefreshRateMode.low,
                  icon: const Icon(Icons.battery_saver),
                  label: Text(l10n.settings_refreshRateModeLow),
                ),
              ],
              selected: {refreshRateMode},
              onSelectionChanged: (value) async {
                await ref
                    .read(saveGeneralSettingsControllerProvider.notifier)
                    .save(
                      (currentSettings) =>
                          currentSettings.copyWith.refreshRateMode(value.first),
                    );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// The tree URI a picked folder is addressed by.
///
/// `saf_util` takes the persisted grant on the tree URI the system returned, but
/// hands back `DocumentFile.fromTreeUri(...).uri` — the same folder in its
/// *document* form, `…/tree/<id>/document/<id>`. Nothing downstream accepts that
/// form: the grant list is keyed on the tree URI, and Mozilla's writer compares
/// `directoryPath` against it by exact equality before writing. Saving the
/// picker's URI verbatim therefore stored a folder that matched no grant, so
/// every download quietly went to the public Downloads folder instead.
String normalizeDownloadTreeUri(String uri) {
  final tree = uri.indexOf('/tree/');
  if (tree < 0) {
    return uri;
  }

  final document = uri.indexOf('/document/', tree);

  return document < 0 ? uri : uri.substring(0, document);
}

/// Reads a folder name out of a tree URI, for the moment before the document
/// provider has answered — and for when it never does.
///
/// A tree URI ends in the provider's own document id, conventionally
/// `volume:relative/path`; anything else is shown whole rather than guessed at.
String describeDownloadTreeUri(String uri) {
  final documentId = Uri.decodeComponent(uri.split('/').last);
  final separator = documentId.indexOf(':');

  if (separator < 0 || separator == documentId.length - 1) {
    return documentId;
  }

  return documentId.substring(separator + 1);
}

class _DownloadDirectoryTile extends HookConsumerWidget {
  const _DownloadDirectoryTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final directoryUri = ref.watch(
      generalSettingsWithDefaultsProvider.select((s) => s.downloadDirectoryUri),
    );
    // With WebLibre remembered as the download manager, the chooser is skipped
    // and WebLibre downloads the file itself, into this folder.
    final useExternalDownloadManager =
        ref.watch(
          generalSettingsWithDefaultsProvider.select(
            (s) => s.useExternalDownloadManager,
          ),
        ) &&
        ref.watch(
              preferredDownloadManagerChoiceProvider.select(
                (choice) => choice.value?.isThisApp,
              ),
            ) !=
            true;

    // Resolving the folder is also how the grant is checked: access can be
    // revoked in the system settings, or the card it lives on unmounted, and
    // the native side then quietly writes to the default folder instead. Saying
    // so beats showing the name of a folder nothing is being saved to.
    final folder = useCachedFuture(() async {
      if (directoryUri == null) {
        return null;
      }

      try {
        return await SafUtil().documentFileFromUri(directoryUri, true);
      } catch (error, stackTrace) {
        logger.w(
          'Could not resolve the configured download folder',
          error: error,
          stackTrace: stackTrace,
        );
        return null;
      }
    }, [directoryUri]);

    final unavailable =
        directoryUri != null &&
        folder.connectionState == ConnectionState.done &&
        folder.data == null;

    final l10n = AppLocalizations.of(context);
    final subtitle = switch (directoryUri) {
      null => l10n.settings_downloadFolderSubtitleDefault,
      final uri when unavailable =>
        l10n.settings_downloadFolderSubtitleUnavailable(
          describeDownloadTreeUri(uri),
        ),
      final uri => folder.data?.name ?? describeDownloadTreeUri(uri),
    };

    Future<void> pick() async {
      try {
        final picked = await SafUtil().pickDirectory(
          writePermission: true,
          persistablePermission: true,
        );
        if (picked == null) return;

        await ref
            .read(saveGeneralSettingsControllerProvider.notifier)
            .save(
              (currentSettings) => currentSettings.copyWith
                  .downloadDirectoryUri(normalizeDownloadTreeUri(picked.uri)),
            );
      } catch (error, stackTrace) {
        logger.e(
          'Failed to pick a download folder',
          error: error,
          stackTrace: stackTrace,
        );
      }
    }

    Future<void> reset() {
      return ref
          .read(saveGeneralSettingsControllerProvider.notifier)
          .save(
            (currentSettings) =>
                currentSettings.copyWith.downloadDirectoryUri(null),
          );
    }

    return ListTile(
      title: Text(l10n.settings_downloadFolderTitle),
      subtitle: Text(
        useExternalDownloadManager
            ? l10n.settings_downloadFolderSubtitleExternalManager
            : subtitle,
      ),
      leading: Icon(
        unavailable ? MdiIcons.folderAlert : MdiIcons.folderDownload,
      ),
      trailing: directoryUri != null && !useExternalDownloadManager
          ? IconButton(
              icon: const Icon(Icons.settings_backup_restore),
              tooltip: l10n.settings_downloadFolderResetTooltip,
              onPressed: reset,
            )
          : null,
      // The folder is the download manager app's business once it has one, so
      // the choice here would not be honored.
      enabled: !useExternalDownloadManager,
      onTap: pick,
    );
  }
}

/// The app downloads go to without the chooser, as remembered from its
/// "Always use this app" box, and the way back to being asked.
class PreferredDownloadManagerTile extends HookConsumerWidget {
  const PreferredDownloadManagerTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Set from the chooser, which runs while this screen is not showing — and
    // in a Custom Tab, outside the app entirely — and the remembered app can be
    // uninstalled in between. Read it again whenever the app comes back.
    useOnAppLifecycleStateChange((previous, current) {
      if (current == AppLifecycleState.resumed) {
        ref.invalidate(preferredDownloadManagerChoiceProvider);
      }
    });

    final useExternalDownloadManager = ref.watch(
      generalSettingsWithDefaultsProvider.select(
        (s) => s.useExternalDownloadManager,
      ),
    );
    final choice = ref.watch(preferredDownloadManagerChoiceProvider).value;
    final l10n = AppLocalizations.of(context);

    final subtitle = switch (choice) {
      // With the switch off WebLibre downloads everything itself and no
      // chooser ever shows, so neither "ask" nor an external app is true.
      null when !useExternalDownloadManager =>
        l10n.settings_preferredDownloadManagerSubtitleExternalOff,
      null => l10n.settings_preferredDownloadManagerSubtitleNotSet,
      PreferredDownloadManager(
        isThisApp: false,
        :final label,
        :final packageName,
      )
          when !useExternalDownloadManager =>
        l10n.settings_preferredDownloadManagerSubtitleInactive(
          label ?? packageName,
        ),
      PreferredDownloadManager(label: null, :final packageName) =>
        l10n.settings_preferredDownloadManagerSubtitleUnavailable(packageName),
      PreferredDownloadManager(isThisApp: true, :final label?) =>
        l10n.settings_preferredDownloadManagerSubtitleThisApp(label),
      PreferredDownloadManager(:final label?) => label,
    };

    return ListTile(
      title: Text(l10n.settings_preferredDownloadManagerTitle),
      subtitle: Text(subtitle),
      leading: Icon(
        choice != null && choice.label == null
            ? MdiIcons.downloadOff
            : MdiIcons.downloadCircle,
      ),
      trailing: choice != null
          ? IconButton(
              icon: const Icon(Icons.close),
              tooltip: l10n.settings_preferredDownloadManagerClearTooltip,
              onPressed: () async {
                try {
                  await ref
                      .read(preferredDownloadManagerChoiceProvider.notifier)
                      .clear();
                } catch (error, stackTrace) {
                  logger.e(
                    'Failed to clear the preferred download manager',
                    error: error,
                    stackTrace: stackTrace,
                  );
                }
              },
            )
          : null,
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
    final l10n = AppLocalizations.of(context);

    return SwitchListTile.adaptive(
      title: Text(l10n.settings_externalDownloadManagerTitle),
      subtitle: Text(l10n.settings_externalDownloadManagerSubtitle),
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
