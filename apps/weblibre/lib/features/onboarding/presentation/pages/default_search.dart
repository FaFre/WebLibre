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
import 'package:nullability/nullability.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/features/bangs/data/models/bang_key.dart';
import 'package:weblibre/features/bangs/domain/providers/bangs.dart';
import 'package:weblibre/features/bangs/presentation/widgets/bang_label.dart';
import 'package:weblibre/features/search/domain/entities/abstract/i_search_suggestion_provider.dart';
import 'package:weblibre/features/settings/presentation/controllers/save_settings.dart';
import 'package:weblibre/features/settings/presentation/widgets/bang_icon.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/features/user/presentation/utils/search_suggestion_providers_l10n.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';
import 'package:weblibre/presentation/widgets/browser_page.dart';
import 'package:weblibre/presentation/widgets/failure_widget.dart';
import 'package:weblibre/presentation/widgets/url_icon.dart';

const defaultBangs = ['ddg', 'brave', 'startpage', 'qwant'];

class DefaultSearchPage extends HookConsumerWidget {
  const DefaultSearchPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    final bangs = ref.watch(bangListProvider(triggers: defaultBangs));

    final activeBang = ref.watch(
      defaultSearchBangDataProvider.select((value) => value.value),
    );
    final activeAutosuggest = ref.watch(
      generalSettingsWithDefaultsProvider.select(
        (value) => value.defaultSearchSuggestionsProvider,
      ),
    );

    Future<void> updateSearchProvider(BangKey key) async {
      await ref
          .read(saveGeneralSettingsControllerProvider.notifier)
          .save(
            (currentSettings) =>
                currentSettings.copyWith.defaultSearchProvider(key),
          );
    }

    return BrowserPage(
      child: BrowserPageContent(
        child: bangs.when(
          skipLoadingOnReload: true,
          data: (availableBangs) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                Center(
                  child: Text(
                    l10n.onboarding_searchTitle,
                    style: theme.textTheme.headlineMedium,
                  ),
                ),
                const SizedBox(height: 24),
                ListTile(
                  title: Text(l10n.onboarding_searchDefaultProviderLabel),
                  leading: const Icon(MdiIcons.cloudSearch),
                  contentPadding: EdgeInsets.zero,
                ),
                if (activeBang != null)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: FilterChip(
                      showCheckmark: false,
                      label: BangLabel(activeBang),
                      avatar: UrlIcon([
                        activeBang.getDefaultUrl(),
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
                        label: BangLabel(bang),
                        avatar: UrlIcon([bang.getDefaultUrl()], iconSize: 20),
                        selected: activeBang?.trigger == bang.trigger,
                        onSelected: (selected) async {
                          if (selected) {
                            await updateSearchProvider(bang.toKey());
                          }
                        },
                      ),
                    ),
                    ActionChip(
                      label: Text(l10n.onboarding_searchMore),
                      avatar: const Icon(Icons.search),
                      onPressed: () async {
                        final trigger = await const BangSearchRoute()
                            .push<BangKey?>(context);

                        if (trigger != null) {
                          await updateSearchProvider(trigger);
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                ListTile(
                  title: Text(l10n.onboarding_searchDefaultAutocompleteLabel),
                  leading: const Icon(MdiIcons.weatherCloudyArrowRight),
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
                  leadingIcon: activeAutosuggest.relatedBang.mapNotNull(
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
              ],
            );
          },
          error: (error, stackTrace) => Center(
            child: FailureWidget(
              title: l10n.onboarding_searchLoadFailedTitle,
              exception: error,
              onRetry: () =>
                  ref.refresh(bangListProvider(triggers: defaultBangs)),
            ),
          ),
          loading: () => const SizedBox(height: 48, width: double.infinity),
        ),
      ),
    );
  }
}
