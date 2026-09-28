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
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/entities/home_target.dart';
import 'package:weblibre/features/settings/presentation/controllers/save_settings.dart';
import 'package:weblibre/features/settings/presentation/utils/home_search_bar_placement_l10n.dart';
import 'package:weblibre/features/settings/presentation/utils/home_target_l10n.dart';
import 'package:weblibre/features/settings/presentation/widgets/settings_detail.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';
import 'package:weblibre/utils/uri_parser.dart' as uri_parser;

List<SettingsSectionDefinition> homeSettingsSections(BuildContext context) {
  final l10n = AppLocalizations.of(context);

  return [
    SettingsSectionDefinition(
      title: l10n.settings_startupSectionTitle,
      keywords: settingsKeywords(l10n.settings_startupSectionKeywords),
      entries: [
        SettingsEntryDefinition(
          title: l10n.settings_indexHomeTargetTitle,
          subtitle: l10n.settings_indexHomeTargetSubtitle,
          keywords: settingsKeywords(l10n.settings_indexHomeTargetKeywords),
          child: const _HomeTargetTile(),
        ),
        SettingsEntryDefinition(
          title: l10n.settings_applyWhenLastTabClosesTitle,
          subtitle: l10n.settings_indexHomeTargetOnLastTabClosedSubtitle,
          keywords: settingsKeywords(
            l10n.settings_applyWhenLastTabClosesKeywords,
          ),
          child: const _HomeTargetOnLastTabClosedTile(),
        ),
      ],
    ),
    SettingsSectionDefinition(
      title: l10n.settings_homeAppearanceSectionTitle,
      keywords: settingsKeywords(l10n.settings_homeAppearanceSectionKeywords),
      entries: [
        SettingsEntryDefinition(
          title: l10n.settings_wallpaperTitle,
          subtitle: l10n.settings_indexWallpaperSubtitle,
          keywords: settingsKeywords(l10n.settings_wallpaperKeywords),
          child: const _WallpaperTile(),
        ),
      ],
    ),
    SettingsSectionDefinition(
      title: l10n.settings_layoutSectionTitle,
      keywords: settingsKeywords(l10n.settings_layoutSectionKeywords),
      entries: [
        SettingsEntryDefinition(
          title: l10n.settings_indexHomeSearchBarPlacementTitle,
          subtitle: l10n.settings_indexHomeSearchBarPlacementSubtitle,
          keywords: settingsKeywords(
            l10n.settings_indexHomeSearchBarPlacementKeywords,
          ),
          child: const _HomeSearchBarPlacementTile(),
        ),
        SettingsEntryDefinition(
          title: l10n.settings_customizeHomeSectionsTitle,
          subtitle: l10n.settings_customizeHomeSectionsSubtitle,
          keywords: settingsKeywords(
            l10n.settings_customizeHomeSectionsKeywords,
          ),
          child: const _CustomizeHomeSectionsTile(),
        ),
        SettingsEntryDefinition(
          title: l10n.settings_customizeNewTabSectionsTitle,
          subtitle: l10n.settings_customizeNewTabSectionsSubtitle,
          keywords: settingsKeywords(
            l10n.settings_customizeNewTabSectionsKeywords,
          ),
          child: const _CustomizeNewTabSectionsTile(),
        ),
      ],
    ),
  ];
}

class HomeSettingsScreen extends StatelessWidget {
  const HomeSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SettingsDetailScaffold(
      title: l10n.settings_homeAndNewTabTitle,
      subtitle: l10n.settings_homeAndNewTabSubtitle,
      icon: MdiIcons.homeOutline,
      sections: homeSettingsSections(context),
    );
  }
}

class _HomeTargetTile extends HookConsumerWidget {
  const _HomeTargetTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(generalSettingsWithDefaultsProvider);
    final l10n = AppLocalizations.of(context);

    Future<void> save(GeneralSettings Function(GeneralSettings) update) {
      return ref
          .read(saveGeneralSettingsControllerProvider.notifier)
          .save(update);
    }

    final urlController = useTextEditingController(
      text: settings.homeTargetUrl ?? '',
    );

    // Persist on focus loss as well as on submit. Settings screens have no
    // save button, so a user who types an address and taps back would
    // otherwise lose it silently.
    Future<void> saveUrlIfChanged() async {
      final text = urlController.text.trim();
      if (text == (settings.homeTargetUrl ?? '')) return;
      if (text.isNotEmpty && uri_parser.tryParseUrl(text) == null) return;

      await save((s) => s.copyWith.homeTargetUrl(text));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RadioGroup<HomeTarget>(
          groupValue: settings.homeTarget,
          onChanged: (value) async {
            if (value != null) {
              await save((s) => s.copyWith.homeTarget(value));
            }
          },
          child: Column(
            children: [
              for (final target in HomeTarget.values)
                RadioListTile<HomeTarget>(
                  value: target,
                  title: Text(target.label(context)),
                  subtitle: Text(target.description(context)),
                ),
            ],
          ),
        ),
        if (settings.homeTarget == HomeTarget.customUrl)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Focus(
              onFocusChange: (hasFocus) {
                if (!hasFocus) unawaited(saveUrlIfChanged());
              },
              child: TextFormField(
                controller: urlController,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                keyboardType: TextInputType.url,
                decoration: InputDecoration(
                  labelText: l10n.settings_addressFieldLabel,
                  hintText: 'https://example.com',
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  final text = value?.trim() ?? '';
                  if (text.isEmpty) {
                    return l10n.settings_homeTargetUrlEmptyError;
                  }
                  if (uri_parser.tryParseUrl(text) == null) {
                    return l10n.settings_homeTargetUrlInvalidError;
                  }
                  return null;
                },
                onFieldSubmitted: (_) => unawaited(saveUrlIfChanged()),
              ),
            ),
          ),
      ],
    );
  }
}

class _HomeTargetOnLastTabClosedTile extends ConsumerWidget {
  const _HomeTargetOnLastTabClosedTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enabled = ref.watch(
      generalSettingsWithDefaultsProvider.select(
        (s) => s.homeTargetOnLastTabClosed,
      ),
    );
    final l10n = AppLocalizations.of(context);

    return SwitchListTile.adaptive(
      value: enabled,
      title: Text(l10n.settings_applyWhenLastTabClosesTitle),
      subtitle: Text(l10n.settings_applyWhenLastTabClosesSubtitle),
      secondary: const Icon(Icons.tab_unselected),
      onChanged: (value) async {
        await ref
            .read(saveGeneralSettingsControllerProvider.notifier)
            .save((s) => s.copyWith.homeTargetOnLastTabClosed(value));
      },
    );
  }
}

/// Where the home surface's search entry sits.
///
/// A placement, not a visibility toggle: the home surface has no address field
/// of its own, so one of the two positions always holds it. There is no "off".
class _HomeSearchBarPlacementTile extends ConsumerWidget {
  const _HomeSearchBarPlacementTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(generalSettingsWithDefaultsProvider);
    final resolved = ref.watch(effectiveHomeSearchBarPlacementProvider);
    final l10n = AppLocalizations.of(context);

    return RadioGroup<HomeSearchBarPlacement>(
      groupValue: settings.homeSearchBarPlacement,
      onChanged: (value) async {
        if (value == null) return;

        await ref
            .read(saveGeneralSettingsControllerProvider.notifier)
            .save((s) => s.copyWith.homeSearchBarPlacement(value));
      },
      child: Column(
        children: [
          for (final placement in HomeSearchBarPlacement.values)
            RadioListTile<HomeSearchBarPlacement>(
              value: placement,
              title: Text(placement.label(context)),
              // Auto says what it currently resolves to; the fixed choices
              // already describe themselves.
              subtitle: Text(
                placement == HomeSearchBarPlacement.auto
                    ? l10n.settings_homeSearchBarCurrentlyLabel(
                        resolved.label(context),
                      )
                    : placement.description(context),
              ),
            ),
        ],
      ),
    );
  }
}

/// Entry point for the profile-wide home wallpaper. A container can override it
/// from the container editor, which is where that setting belongs — it is one
/// container's property, not a global one.
class _WallpaperTile extends ConsumerWidget {
  const _WallpaperTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasWallpaper = ref.watch(
      generalSettingsWithDefaultsProvider.select(
        (s) => s.homeWallpaperFile != null,
      ),
    );
    final l10n = AppLocalizations.of(context);

    return ListTile(
      leading: const Icon(MdiIcons.imageOutline),
      title: Text(l10n.settings_wallpaperTitle),
      subtitle: Text(
        hasWallpaper
            ? l10n.settings_wallpaperSetSubtitle
            : l10n.settings_wallpaperUnsetSubtitle,
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => const WallpaperSettingsRoute().push(context),
    );
  }
}

class _CustomizeHomeSectionsTile extends ConsumerWidget {
  const _CustomizeHomeSectionsTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return ListTile(
      leading: const Icon(MdiIcons.homeOutline),
      title: Text(l10n.settings_customizeHomeSectionsTitle),
      subtitle: Text(l10n.settings_customizeHomeSectionsSubtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => const HomeModulesSettingsRoute().push(context),
    );
  }
}

class _CustomizeNewTabSectionsTile extends ConsumerWidget {
  const _CustomizeNewTabSectionsTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return ListTile(
      leading: const Icon(MdiIcons.tabPlus),
      title: Text(l10n.settings_customizeNewTabSectionsTitle),
      subtitle: Text(l10n.settings_customizeNewTabSectionsSubtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => const NewTabModulesSettingsRoute().push(context),
    );
  }
}
