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
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nullability/nullability.dart';
import 'package:weblibre/core/design/display_features.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/providers.dart';
import 'package:weblibre/features/search/domain/entities/abstract/i_search_suggestion_provider.dart';
import 'package:weblibre/features/settings/presentation/controllers/save_settings.dart';
import 'package:weblibre/features/settings/presentation/widgets/bang_icon.dart';
import 'package:weblibre/features/settings/presentation/widgets/default_search_selector.dart';
import 'package:weblibre/features/settings/presentation/widgets/settings_detail.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/features/user/presentation/utils/search_suggestion_providers_l10n.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';

List<SettingsSectionDefinition> searchSettingsSections(BuildContext context) {
  final l10n = AppLocalizations.of(context);

  return [
    SettingsSectionDefinition(
      title: l10n.settings_searchSectionProvidersTitle,
      keywords: settingsKeywords(l10n.settings_searchSectionProvidersKeywords),
      entries: [
        SettingsEntryDefinition(
          title: l10n.settings_defaultSearchProviderTitle,
          subtitle: l10n.settings_indexDefaultSearchProviderSubtitle,
          keywords: settingsKeywords(
            l10n.settings_defaultSearchProviderKeywords,
          ),
          child: const _DefaultSearchProviderSection(),
        ),
        SettingsEntryDefinition(
          title: l10n.settings_defaultAutocompleteProviderTitle,
          subtitle: l10n.settings_indexDefaultAutocompleteProviderSubtitle,
          keywords: settingsKeywords(
            l10n.settings_defaultAutocompleteProviderKeywords,
          ),
          child: const _AutocompleteProviderSection(),
        ),
        SettingsEntryDefinition(
          title: l10n.settings_customSearchEnginesTitle,
          subtitle: l10n.settings_customSearchEnginesSubtitle,
          keywords: settingsKeywords(l10n.settings_customSearchEnginesKeywords),
          child: const _CustomSearchEnginesTile(),
        ),
      ],
    ),
    SettingsSectionDefinition(
      title: l10n.settings_searchSectionBangShortcutsTitle,
      keywords: settingsKeywords(
        l10n.settings_searchSectionBangShortcutsKeywords,
      ),
      entries: [
        SettingsEntryDefinition(
          title: l10n.settings_bangSettingsTitle,
          subtitle: l10n.settings_bangSettingsListSubtitle,
          keywords: settingsKeywords(l10n.settings_bangSettingsKeywords),
          child: const _BangsTile(),
        ),
      ],
    ),
    SettingsSectionDefinition(
      title: l10n.settings_searchSectionHistorySuggestionsTitle,
      entries: [
        SettingsEntryDefinition(
          title: l10n.settings_searchHistoryLimitTitle,
          subtitle: l10n.settings_searchHistoryLimitSubtitle,
          keywords: settingsKeywords(l10n.settings_searchHistoryLimitKeywords),
          child: const _MaxSearchHistoryEntriesSection(),
        ),
        SettingsEntryDefinition(
          title: l10n.settings_allowClipboardAccessTitle,
          subtitle: l10n.settings_allowClipboardAccessSubtitle,
          keywords: settingsKeywords(
            l10n.settings_allowClipboardAccessKeywords,
          ),
          child: const _AllowClipboardAccessTile(),
        ),
        SettingsEntryDefinition(
          title: l10n.settings_acceptSuggestionOnSubmitTitle,
          subtitle: l10n.settings_indexAcceptSuggestionOnSubmitSubtitle,
          keywords: settingsKeywords(
            l10n.settings_acceptSuggestionOnSubmitKeywords,
          ),
          child: const _AcceptSuggestionOnSubmitTile(),
        ),
        SettingsEntryDefinition(
          title: l10n.settings_popularSitesAutocompleteTitle,
          subtitle: l10n.settings_indexPopularSitesAutocompleteSubtitle,
          keywords: settingsKeywords(
            l10n.settings_popularSitesAutocompleteKeywords,
          ),
          child: const _PopularSitesAutocompleteTile(),
        ),
      ],
    ),
    SettingsSectionDefinition(
      title: l10n.settings_searchSectionLocalIndexTitle,
      keywords: settingsKeywords(l10n.settings_searchSectionLocalIndexKeywords),
      entries: [
        SettingsEntryDefinition(
          title: l10n.settings_localIndexEnabledTitle,
          subtitle: l10n.settings_indexLocalIndexEnabledSubtitle,
          keywords: settingsKeywords(l10n.settings_localIndexEnabledKeywords),
          child: const _LocalIndexEnabledTile(),
        ),
        SettingsEntryDefinition(
          title: l10n.settings_indexPrivateTabsTitle,
          subtitle: l10n.settings_indexIndexPrivateTabsSubtitle,
          keywords: settingsKeywords(l10n.settings_indexPrivateTabsKeywords),
          child: const _IndexPrivateTabsTile(),
        ),
        SettingsEntryDefinition(
          title: l10n.settings_localIndexStatsTitle,
          subtitle: l10n.settings_indexLocalIndexStatsSubtitle,
          keywords: settingsKeywords(l10n.settings_localIndexStatsKeywords),
          child: const _LocalIndexStatsTile(),
        ),
      ],
    ),
  ];
}

class SearchSettingsScreen extends StatelessWidget {
  const SearchSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SettingsDetailScaffold(
      title: l10n.settings_searchTitle,
      subtitle: l10n.settings_searchSubtitle,
      icon: MdiIcons.magnify,
      sections: searchSettingsSections(context),
    );
  }
}

class _DefaultSearchProviderSection extends StatelessWidget {
  const _DefaultSearchProviderSection();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: Text(l10n.settings_defaultSearchProviderTitle),
            leading: const Icon(MdiIcons.cloudSearch),
            contentPadding: EdgeInsets.zero,
          ),
          const Padding(
            padding: EdgeInsets.only(left: 40),
            child: DefaultSearchSelector(),
          ),
        ],
      ),
    );
  }
}

class _AutocompleteProviderSection extends HookConsumerWidget {
  const _AutocompleteProviderSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final defaultSearchSuggestionsProvider = ref.watch(
      generalSettingsWithDefaultsProvider.select(
        (s) => s.defaultSearchSuggestionsProvider,
      ),
    );
    final relatedBang = defaultSearchSuggestionsProvider.relatedBang;
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: Text(l10n.settings_defaultAutocompleteProviderTitle),
            leading: const Icon(MdiIcons.weatherCloudyArrowRight),
            contentPadding: EdgeInsets.zero,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 40),
            child: DropdownMenu<SearchSuggestionProviders>(
              initialSelection: defaultSearchSuggestionsProvider,
              inputDecorationTheme: InputDecorationTheme(
                prefixIconConstraints: BoxConstraints.tight(
                  const Size.square(24),
                ),
              ),
              width: double.infinity,
              leadingIcon: relatedBang.mapNotNull(
                (trigger) => BangIcon(trigger: trigger),
              ),
              dropdownMenuEntries: SearchSuggestionProviders.values.map((
                provider,
              ) {
                return DropdownMenuEntry(
                  value: provider,
                  label: provider.label(context),
                  leadingIcon: provider.relatedBang.mapNotNull(
                    (trigger) => BangIcon(trigger: trigger),
                  ),
                );
              }).toList(),
              onSelected: (value) async {
                if (value != null) {
                  await ref
                      .read(saveGeneralSettingsControllerProvider.notifier)
                      .save(
                        (currentSettings) => currentSettings.copyWith
                            .defaultSearchSuggestionsProvider(value),
                      );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CustomSearchEnginesTile extends StatelessWidget {
  const _CustomSearchEnginesTile();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return ListTile(
      title: Text(l10n.settings_customSearchEnginesTitle),
      subtitle: Text(l10n.settings_customSearchEnginesSubtitle),
      contentPadding: const EdgeInsets.symmetric(
        vertical: 8.0,
        horizontal: 16.0,
      ),
      leading: const Icon(MdiIcons.searchWeb),
      trailing: const Icon(Icons.chevron_right),
      onTap: () async {
        await const UserBangsRoute().push(context);
      },
    );
  }
}

class _BangsTile extends StatelessWidget {
  const _BangsTile();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return ListTile(
      title: Text(l10n.settings_bangSettingsListTitle),
      subtitle: Text(l10n.settings_bangSettingsListSubtitle),
      contentPadding: const EdgeInsets.symmetric(
        vertical: 8.0,
        horizontal: 16.0,
      ),
      leading: const Icon(MdiIcons.exclamationThick),
      trailing: const Icon(Icons.chevron_right),
      onTap: () async {
        await BangSettingsRoute().push(context);
      },
    );
  }
}

class _MaxSearchHistoryEntriesSection extends HookConsumerWidget {
  const _MaxSearchHistoryEntriesSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final formKey = useMemoized(() => GlobalKey<FormState>());

    final maxSearchHistoryEntries = ref.watch(
      generalSettingsWithDefaultsProvider.select(
        (s) => s.maxSearchHistoryEntries,
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: Text(l10n.settings_searchHistoryLimitTitle),
            subtitle: Text(l10n.settings_searchHistoryLimitSubtitle),
            leading: const Icon(MdiIcons.history),
            contentPadding: EdgeInsets.zero,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 40.0),
            child: Form(
              key: formKey,
              child: TextFormField(
                initialValue: maxSearchHistoryEntries.toString(),
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  suffixText: l10n.settings_searchHistoryLimitSuffix,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n.settings_validationEnterValue;
                  }
                  final parsedValue = int.tryParse(value);
                  if (parsedValue == null) {
                    return l10n.settings_validationEnterValidNumber;
                  }
                  if (parsedValue < 0 || parsedValue > 100) {
                    return l10n.settings_validationValueBetween0And100;
                  }
                  return null;
                },
                onFieldSubmitted: (value) async {
                  if (formKey.currentState?.validate() ?? false) {
                    final parsedValue = int.parse(value);
                    await ref
                        .read(saveGeneralSettingsControllerProvider.notifier)
                        .save(
                          (currentSettings) => currentSettings.copyWith
                              .maxSearchHistoryEntries(parsedValue),
                        );
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AllowClipboardAccessTile extends HookConsumerWidget {
  const _AllowClipboardAccessTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allowClipboardAccess = ref.watch(
      generalSettingsWithDefaultsProvider.select((s) => s.allowClipboardAccess),
    );
    final l10n = AppLocalizations.of(context);

    return SwitchListTile.adaptive(
      title: Text(l10n.settings_allowClipboardAccessTitle),
      subtitle: Text(l10n.settings_allowClipboardAccessSubtitle),
      secondary: const Icon(MdiIcons.clipboardTextOutline),
      value: allowClipboardAccess,
      onChanged: (value) async {
        await ref
            .read(saveGeneralSettingsControllerProvider.notifier)
            .save(
              (currentSettings) =>
                  currentSettings.copyWith.allowClipboardAccess(value),
            );
      },
    );
  }
}

class _AcceptSuggestionOnSubmitTile extends HookConsumerWidget {
  const _AcceptSuggestionOnSubmitTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final acceptSuggestionOnSubmit = ref.watch(
      generalSettingsWithDefaultsProvider.select(
        (s) => s.acceptSuggestionOnSubmit,
      ),
    );
    final l10n = AppLocalizations.of(context);

    return SwitchListTile.adaptive(
      title: Text(l10n.settings_acceptSuggestionOnSubmitTitle),
      subtitle: Text(l10n.settings_acceptSuggestionOnSubmitSubtitle),
      secondary: const Icon(Icons.keyboard_return),
      value: acceptSuggestionOnSubmit,
      onChanged: (value) async {
        await ref
            .read(saveGeneralSettingsControllerProvider.notifier)
            .save(
              (currentSettings) =>
                  currentSettings.copyWith.acceptSuggestionOnSubmit(value),
            );
      },
    );
  }
}

class _PopularSitesAutocompleteTile extends HookConsumerWidget {
  const _PopularSitesAutocompleteTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final popularSitesAutocompleteEnabled = ref.watch(
      generalSettingsWithDefaultsProvider.select(
        (s) => s.popularSitesAutocompleteEnabled,
      ),
    );
    final l10n = AppLocalizations.of(context);

    return SwitchListTile.adaptive(
      title: Text(l10n.settings_popularSitesAutocompleteTitle),
      subtitle: Text(l10n.settings_popularSitesAutocompleteSubtitle),
      secondary: const Icon(MdiIcons.web),
      value: popularSitesAutocompleteEnabled,
      onChanged: (value) async {
        await ref
            .read(saveGeneralSettingsControllerProvider.notifier)
            .save(
              (currentSettings) => currentSettings.copyWith
                  .popularSitesAutocompleteEnabled(value),
            );
      },
    );
  }
}

class _LocalIndexEnabledTile extends HookConsumerWidget {
  const _LocalIndexEnabledTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enabled = ref.watch(
      generalSettingsWithDefaultsProvider.select(
        (s) => s.enableLocalSearchIndex,
      ),
    );
    final l10n = AppLocalizations.of(context);

    return SwitchListTile.adaptive(
      title: Text(l10n.settings_localIndexEnabledTitle),
      subtitle: Text(l10n.settings_localIndexEnabledSubtitle),
      secondary: const Icon(MdiIcons.bookSearchOutline),
      value: enabled,
      onChanged: (value) async {
        await ref
            .read(saveGeneralSettingsControllerProvider.notifier)
            .save(
              (currentSettings) =>
                  currentSettings.copyWith.enableLocalSearchIndex(value),
            );
      },
    );
  }
}

class _IndexPrivateTabsTile extends HookConsumerWidget {
  const _IndexPrivateTabsTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(generalSettingsWithDefaultsProvider);
    final enabled = settings.enableLocalSearchIndex;
    final indexPrivate = settings.indexPrivateTabs;
    final l10n = AppLocalizations.of(context);

    return SwitchListTile.adaptive(
      title: Text(l10n.settings_indexPrivateTabsTitle),
      subtitle: Text(l10n.settings_indexPrivateTabsSubtitle),
      secondary: const Icon(MdiIcons.incognito),
      value: indexPrivate,
      onChanged: enabled
          ? (value) async {
              await ref
                  .read(saveGeneralSettingsControllerProvider.notifier)
                  .save(
                    (currentSettings) =>
                        currentSettings.copyWith.indexPrivateTabs(value),
                  );
            }
          : null,
    );
  }
}

class _LocalIndexStatsTile extends HookConsumerWidget {
  const _LocalIndexStatsTile();

  Future<bool?> _confirmClear(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return showDialog<bool>(
      context: context,
      anchorPoint: preferredAnchorPoint(MediaQuery.of(context)),
      builder: (context) => AlertDialog(
        title: Text(l10n.settings_clearLocalIndexDialogTitle),
        content: Text(l10n.settings_clearLocalIndexDialogContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.common_cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.common_clear),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    // Bump on Clear to re-trigger the count query.
    final refreshTick = useState(0);
    final countSnapshot = useFuture(
      useMemoized(() => ref.read(tabDatabaseProvider).historyDao.countRows(), [
        refreshTick.value,
      ]),
    );
    final count = countSnapshot.data;

    return ListTile(
      leading: const Icon(MdiIcons.databaseOutline),
      title: Text(l10n.settings_localIndexStatsTitle),
      subtitle: Text(
        count.mapNotNull(l10n.settings_localIndexPagesIndexed) ??
            l10n.common_loading,
      ),
      trailing: TextButton.icon(
        icon: const Icon(MdiIcons.deleteOutline),
        label: Text(l10n.common_clear),
        onPressed: count == null || count == 0
            ? null
            : () async {
                final confirmed = await _confirmClear(context);
                if (confirmed != true) return;
                await ref.read(tabDatabaseProvider).historyDao.clear();
                refreshTick.value++;
              },
      ),
    );
  }
}
