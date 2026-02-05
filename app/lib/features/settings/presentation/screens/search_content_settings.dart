/*
 * Copyright (c) 2024-2025 Fabian Freund.
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
import 'package:weblibre/features/user/data/models/engine_settings.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';
import 'package:weblibre/features/user/domain/repositories/engine_settings.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';

class SearchContentSettingsScreen extends StatelessWidget {
  const SearchContentSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search & Content')),
      body: SafeArea(
        child: FadingScroll(
          fadingSize: 25,
          builder: (context, controller) {
            return ListView(
              controller: controller,
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              children: const [
                _SearchSection(),
                _ContentViewingSection(),
                _ContentEnhancementSection(),
                _ExtensionsSection(),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SearchSection extends StatelessWidget {
  const _SearchSection();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        SettingSection(name: 'Search'),
        _DefaultSearchProviderSection(),
        _BangsTile(),
        _AutocompleteProviderSection(),
        _MaxSearchHistoryEntriesSection(),
        _AllowClipboardAccessTile(),
      ],
    );
  }
}

class _ContentViewingSection extends StatelessWidget {
  const _ContentViewingSection();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        SettingSection(name: 'Content Viewing'),
        _PdfViewerTile(),
        _EnableReaderModeTile(),
        _ReaderModeInTabBarTile(),
        _EnforceReaderModeTile(),
      ],
    );
  }
}

class _ContentEnhancementSection extends StatelessWidget {
  const _ContentEnhancementSection();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        SettingSection(name: 'Content Enhancement'),
        _OnDeviceAiTile(),
      ],
    );
  }
}

class _ExtensionsSection extends StatelessWidget {
  const _ExtensionsSection();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        SettingSection(name: 'Extensions'),
        _AddonCollectionTile(),
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

class _BangsTile extends StatelessWidget {
  const _BangsTile();

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: const Text('Bangs'),
      subtitle: const Text('Search shortcuts management'),
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

class _ReaderModeInTabBarTile extends HookConsumerWidget {
  const _ReaderModeInTabBarTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabBarReaderView = ref.watch(
      generalSettingsWithDefaultsProvider.select((s) => s.tabBarReaderView),
    );

    return SwitchListTile.adaptive(
      title: const Text('Reader Mode in Tab Bar'),
      subtitle: const Text(
        'Show reader mode button in the tab bar instead of only in the tab menu',
      ),
      secondary: const Icon(MdiIcons.bookHeart),
      value: tabBarReaderView,
      onChanged: (value) async {
        await ref
            .read(saveGeneralSettingsControllerProvider.notifier)
            .save(
              (currentSettings) =>
                  currentSettings.copyWith.tabBarReaderView(value),
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

class _AddonCollectionTile extends StatelessWidget {
  const _AddonCollectionTile();

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: const Text('Custom Extension Collection'),
      subtitle: const Text(
        'Custom Add-on Collections are curated lists of extensions that users can create and share.',
      ),
      contentPadding: const EdgeInsets.symmetric(
        vertical: 8.0,
        horizontal: 16.0,
      ),
      leading: const Icon(MdiIcons.puzzle),
      trailing: const Icon(Icons.chevron_right),
      onTap: () async {
        await AddonCollectionRoute().push(context);
      },
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
