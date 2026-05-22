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
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/providers.dart';
import 'package:weblibre/features/search/domain/entities/abstract/i_search_suggestion_provider.dart';
import 'package:weblibre/features/settings/presentation/controllers/save_settings.dart';
import 'package:weblibre/features/settings/presentation/widgets/bang_icon.dart';
import 'package:weblibre/features/settings/presentation/widgets/default_search_selector.dart';
import 'package:weblibre/features/settings/presentation/widgets/settings_detail.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';

const List<SettingsSectionDefinition> searchSettingsSections = [
  SettingsSectionDefinition(
    title: 'Providers',
    keywords: ['engines'],
    entries: [
      SettingsEntryDefinition(
        title: 'Default Search Provider',
        subtitle: 'Choose the default engine for searches',
        keywords: ['search engine'],
        child: _DefaultSearchProviderSection(),
      ),
      SettingsEntryDefinition(
        title: 'Default Autocomplete Provider',
        subtitle: 'Choose the provider for search suggestions',
        keywords: ['suggestions'],
        child: _AutocompleteProviderSection(),
      ),
      SettingsEntryDefinition(
        title: 'Custom Search Engines',
        subtitle: 'Add and manage your own search providers',
        keywords: ['user bangs', 'providers'],
        child: _CustomSearchEnginesTile(),
      ),
    ],
  ),
  SettingsSectionDefinition(
    title: 'Bang Shortcuts',
    keywords: ['bangs'],
    entries: [
      SettingsEntryDefinition(
        title: 'Bang Settings',
        subtitle: 'Manage bang repositories and usage data',
        keywords: ['shortcuts', 'bangs'],
        child: _BangsTile(),
      ),
    ],
  ),
  SettingsSectionDefinition(
    title: 'History & Suggestions',
    entries: [
      SettingsEntryDefinition(
        title: 'Search History Limit',
        subtitle: 'Maximum number of recent searches to remember',
        keywords: ['history', 'entries'],
        child: _MaxSearchHistoryEntriesSection(),
      ),
      SettingsEntryDefinition(
        title: 'Allow clipboard access for suggestions',
        subtitle: 'Browser can read clipboard to suggest URLs',
        keywords: ['clipboard'],
        child: _AllowClipboardAccessTile(),
      ),
      SettingsEntryDefinition(
        title: 'Autocomplete on enter',
        subtitle: 'Accept the inline suggestion when pressing enter',
        keywords: ['submit', 'keyboard', 'suggestions'],
        child: _AcceptSuggestionOnSubmitTile(),
      ),
    ],
  ),
  SettingsSectionDefinition(
    title: 'Local Search Index',
    keywords: ['on device search', 'index'],
    entries: [
      SettingsEntryDefinition(
        title: 'Enable local search index',
        subtitle: 'Index visited pages locally for content search',
        keywords: ['page text', 'history'],
        child: _LocalIndexEnabledTile(),
      ),
      SettingsEntryDefinition(
        title: 'Index private tabs',
        subtitle: 'Include private tabs in the local index',
        keywords: ['incognito'],
        child: _IndexPrivateTabsTile(),
      ),
      SettingsEntryDefinition(
        title: 'Indexed pages',
        subtitle: 'View and clear the local index',
        keywords: ['clear index', 'stats'],
        child: _LocalIndexStatsTile(),
      ),
    ],
  ),
];

class SearchSettingsScreen extends StatelessWidget {
  const SearchSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SettingsDetailScaffold(
      title: 'Search',
      subtitle: 'Providers, bangs, history suggestions, and on-device search.',
      icon: MdiIcons.magnify,
      sections: searchSettingsSections,
    );
  }
}

class _DefaultSearchProviderSection extends StatelessWidget {
  const _DefaultSearchProviderSection();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: Text('Default Search Provider'),
            leading: Icon(MdiIcons.cloudSearch),
            contentPadding: EdgeInsets.zero,
          ),
          Padding(
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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ListTile(
            title: Text('Default Autocomplete Provider'),
            leading: Icon(MdiIcons.weatherCloudyArrowRight),
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
                  label: provider.label,
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
    return ListTile(
      title: const Text('Custom Search Engines'),
      subtitle: const Text('Add and manage your own search providers'),
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
    return ListTile(
      title: const Text('Bang Settings'),
      subtitle: const Text('Manage bang repositories and usage data'),
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
          const ListTile(
            title: Text('Search History Limit'),
            subtitle: Text('Maximum number of recent searches to remember'),
            leading: Icon(MdiIcons.history),
            contentPadding: EdgeInsets.zero,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 40.0),
            child: Form(
              key: formKey,
              child: TextFormField(
                initialValue: maxSearchHistoryEntries.toString(),
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(suffixText: 'entries'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a value';
                  }
                  final parsedValue = int.tryParse(value);
                  if (parsedValue == null) {
                    return 'Please enter a valid number';
                  }
                  if (parsedValue < 0 || parsedValue > 100) {
                    return 'Value must be between 0 and 100';
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

    return SwitchListTile.adaptive(
      title: const Text('Allow clipboard access for suggestions'),
      subtitle: const Text('Browser can read clipboard to suggest URLs'),
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

    return SwitchListTile.adaptive(
      title: const Text('Autocomplete on enter'),
      subtitle: const Text(
        'Accept the inline suggestion when pressing enter on the keyboard',
      ),
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

class _LocalIndexEnabledTile extends HookConsumerWidget {
  const _LocalIndexEnabledTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enabled = ref.watch(
      generalSettingsWithDefaultsProvider.select(
        (s) => s.enableLocalSearchIndex,
      ),
    );

    return SwitchListTile.adaptive(
      title: const Text('Enable local search index'),
      subtitle: const Text(
        'Index visited pages locally so the browser can search their '
        'content. Visit metadata stays in the engine; only page text is '
        'stored on-device.',
      ),
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

    return SwitchListTile.adaptive(
      title: const Text('Index private tabs'),
      subtitle: const Text(
        'Include pages opened in private tabs in the local index. '
        'Off by default.',
      ),
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
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear local search index?'),
        content: const Text(
          'This removes all locally indexed page content. Engine history '
          '(visit metadata) is not affected.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
      title: const Text('Indexed pages'),
      subtitle: Text(count.mapNotNull((c) => '$c pages indexed') ?? 'Loading…'),
      trailing: TextButton.icon(
        icon: const Icon(MdiIcons.deleteOutline),
        label: const Text('Clear'),
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
