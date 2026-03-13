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
import 'package:nullability/nullability.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/features/search/domain/entities/abstract/i_search_suggestion_provider.dart';
import 'package:weblibre/features/settings/presentation/controllers/save_settings.dart';
import 'package:weblibre/features/settings/presentation/widgets/bang_icon.dart';
import 'package:weblibre/features/settings/presentation/widgets/default_search_selector.dart';
import 'package:weblibre/features/settings/presentation/widgets/sections.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';

class SearchSettingsScreen extends StatelessWidget {
  const SearchSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search')),
      body: SafeArea(
        child: FadingScroll(
          fadingSize: 25,
          builder: (context, controller) {
            return ListView(
              controller: controller,
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              children: const [
                _ProvidersSection(),
                _BangShortcutsSection(),
                _HistorySuggestionsSection(),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ProvidersSection extends StatelessWidget {
  const _ProvidersSection();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        SettingSection(name: 'Providers'),
        _DefaultSearchProviderSection(),
        _AutocompleteProviderSection(),
        _CustomSearchEnginesTile(),
      ],
    );
  }
}

class _BangShortcutsSection extends StatelessWidget {
  const _BangShortcutsSection();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        SettingSection(name: 'Bang Shortcuts'),
        _BangsTile(),
      ],
    );
  }
}

class _HistorySuggestionsSection extends StatelessWidget {
  const _HistorySuggestionsSection();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        SettingSection(name: 'History & Suggestions'),
        _MaxSearchHistoryEntriesSection(),
        _AllowClipboardAccessTile(),
      ],
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
