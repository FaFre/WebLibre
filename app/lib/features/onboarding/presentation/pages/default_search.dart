import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/features/bangs/domain/providers/bangs.dart';
import 'package:weblibre/features/search/domain/entities/abstract/i_search_suggestion_provider.dart';
import 'package:weblibre/features/settings/presentation/controllers/save_settings.dart';
import 'package:weblibre/features/settings/presentation/widgets/bang_icon.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/presentation/widgets/url_icon.dart';

const defaultBangs = ['ddg', 'brave', 'startpage', 'qwant'];

class DefaultSearchPage extends HookConsumerWidget {
  const DefaultSearchPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    final bangs = ref.watch(bangListProvider(triggers: defaultBangs));

    final activeBang = ref.watch(
      defaultSearchBangDataProvider.select((value) => value.valueOrNull),
    );
    final activeAutosuggest = ref.watch(
      generalSettingsRepositoryProvider.select(
        (value) => value.defaultSearchSuggestionsProvider,
      ),
    );

    Future<void> updateSearchProvider(String trigger) async {
      await ref
          .read(saveGeneralSettingsControllerProvider.notifier)
          .save(
            (currentSettings) =>
                currentSettings.copyWith.defaultSearchProvider(trigger),
          );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: bangs.when(
        skipLoadingOnReload: true,
        data: (availableBangs) {
          return ListView(
            children: [
              const SizedBox(height: 24),
              Center(
                child: Text('Search', style: theme.textTheme.headlineMedium),
              ),
              const SizedBox(height: 24),
              const ListTile(
                title: Text('Default Search Provider'),
                leading: Icon(MdiIcons.cloudSearch),
                contentPadding: EdgeInsets.zero,
              ),
              if (activeBang != null)
                Align(
                  alignment: Alignment.centerLeft,
                  child: FilterChip(
                    showCheckmark: false,
                    label: Text(activeBang.websiteName),
                    avatar: UrlIcon([
                      activeBang.getTemplateUrl(''),
                    ], iconSize: 20),
                    selected: true,
                    onSelected: (value) {},
                  ),
                ),
              const Divider(),
              Wrap(
                spacing: 8.0,
                children: [
                  ...availableBangs.map(
                    (bang) => FilterChip(
                      showCheckmark: false,
                      label: Text(bang.websiteName),
                      avatar: UrlIcon([bang.getTemplateUrl('')], iconSize: 20),
                      selected: activeBang?.trigger == bang.trigger,
                      onSelected: (selected) async {
                        if (selected) {
                          await updateSearchProvider(bang.trigger);
                        }
                      },
                    ),
                  ),
                  ActionChip(
                    label: const Text('Search more'),
                    avatar: const Icon(Icons.search),
                    onPressed: () async {
                      final trigger = await const BangSearchRoute()
                          .push<String?>(context);

                      if (trigger != null) {
                        await updateSearchProvider(trigger);
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const ListTile(
                title: Text('Default Autocomplete Provider'),
                leading: Icon(MdiIcons.weatherCloudyArrowRight),
                contentPadding: EdgeInsets.zero,
              ),
              DropdownMenu<SearchSuggestionProviders>(
                initialSelection: activeAutosuggest,
                inputDecorationTheme: InputDecorationTheme(
                  prefixIconConstraints: BoxConstraints.tight(
                    const Size.square(24),
                  ),
                ),
                width: double.infinity,
                leadingIcon: BangIcon(trigger: activeAutosuggest.relatedBang),
                dropdownMenuEntries: SearchSuggestionProviders.values.map((
                  provider,
                ) {
                  return DropdownMenuEntry(
                    value: provider,
                    label: provider.label,
                    leadingIcon: BangIcon(trigger: provider.relatedBang),
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
            ],
          );
        },
        error: (error, stackTrace) => const SizedBox.shrink(),
        loading: () => const SizedBox(height: 48, width: double.infinity),
      ),
    );
  }
}
