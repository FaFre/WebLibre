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
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nullability/nullability.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/domain/setup_draft/setup_draft.dart';
import 'package:weblibre/features/bangs/data/models/bang_key.dart';
import 'package:weblibre/features/bangs/domain/providers/bangs.dart';
import 'package:weblibre/features/bangs/presentation/widgets/bang_label.dart';
import 'package:weblibre/features/onboarding/presentation/widgets/setup_section.dart';
import 'package:weblibre/features/search/domain/entities/abstract/i_search_suggestion_provider.dart';
import 'package:weblibre/features/settings/presentation/utils/tab_bar_position_setting_l10n.dart';
import 'package:weblibre/features/settings/presentation/widgets/bang_icon.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/features/user/presentation/utils/search_suggestion_providers_l10n.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';
import 'package:weblibre/presentation/widgets/browser_page.dart';
import 'package:weblibre/presentation/widgets/failure_widget.dart';
import 'package:weblibre/presentation/widgets/url_icon.dart';

const defaultBangs = ['ddg', 'brave', 'startpage', 'qwant'];

/// The questions every preset asks (`user_choice` in the policy): the default
/// search provider, with the autocomplete provider behind "More", and the tab
/// bar position.
///
/// Reads the draft's settings (the displayed layer) and files its own
/// answers in the draft as Basics answers.
class BasicsPage extends HookConsumerWidget {
  const BasicsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    final bangs = ref.watch(bangListProvider(triggers: defaultBangs));

    final activeBang = ref.watch(
      displayedDefaultSearchBangDataProvider.select((value) => value.value),
    );
    final activeAutosuggest = ref.watch(
      displayedGeneralSettingsProvider.select(
        (value) => value.defaultSearchSuggestionsProvider,
      ),
    );
    final tabBarPosition = ref.watch(
      displayedGeneralSettingsProvider.select((s) => s.tabBarPosition),
    );

    // Onboarding code: Basics files its answers in the draft itself, apart
    // from the Customize changes a preset change drops.
    Future<void> save(UpdateGeneralSettingsFunc update) async => ref
        .read(setupDraftControllerProvider.notifier)
        .editGeneral(SetupDraftStep.basics, update);

    Future<void> updateSearchProvider(BangKey key) =>
        save((current) => current.copyWith.defaultSearchProvider(key));

    return BrowserPage(
      child: BrowserPageContent(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            Center(
              child: Text(
                l10n.onboarding_basicsTitle,
                style: theme.textTheme.headlineMedium,
              ),
            ),
            const SizedBox(height: 24),
            SetupSectionTitle(l10n.onboarding_searchDefaultProviderLabel),
            const SizedBox(height: 12),
            bangs.when(
              skipLoadingOnReload: true,
              data: (availableBangs) => Wrap(
                spacing: 8.0,
                children: [
                  // The current choice, when it is not one of the shortlist.
                  if (activeBang != null &&
                      !availableBangs.any(
                        (bang) => bang.trigger == activeBang.trigger,
                      ))
                    ChoiceChip(
                      showCheckmark: false,
                      label: BangLabel(activeBang),
                      avatar: UrlIcon([
                        activeBang.getDefaultUrl(),
                      ], iconSize: 20),
                      selected: true,
                      onSelected: (_) {},
                    ),
                  ...availableBangs.map(
                    (bang) => ChoiceChip(
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
              error: (error, stackTrace) => Center(
                child: FailureWidget(
                  title: l10n.onboarding_searchLoadFailedTitle,
                  exception: error,
                  onRetry: () =>
                      ref.refresh(bangListProvider(triggers: defaultBangs)),
                ),
              ),
              // Chip-shaped placeholders where the chips will be, like the
              // permissions page; nothing to read out until they load.
              loading: () => ExcludeSemantics(
                child: Skeletonizer(
                  child: Wrap(
                    spacing: 8.0,
                    children: [
                      for (final name in defaultBangs)
                        ChoiceChip(
                          showCheckmark: false,
                          label: Text(name.padRight(10, 'x')),
                          selected: false,
                        ),
                    ],
                  ),
                ),
              ),
            ),
            Theme(
              data: theme.copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                tilePadding: EdgeInsets.zero,
                childrenPadding: const EdgeInsets.only(bottom: 8),
                title: Text(l10n.onboarding_basicsMoreSearchOptions),
                children: [
                  DropdownMenu<SearchSuggestionProviders>(
                    label: Text(l10n.onboarding_searchDefaultAutocompleteLabel),
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
                        await save(
                          (current) => current.copyWith
                              .defaultSearchSuggestionsProvider(value),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SetupSectionTitle(l10n.onboarding_basicsTabBarTitle),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: SegmentedButton<TabBarPositionSetting>(
                segments: [
                  for (final position in const [
                    TabBarPositionSetting.auto,
                    TabBarPositionSetting.top,
                    TabBarPositionSetting.bottom,
                  ])
                    ButtonSegment(
                      value: position,
                      label: Text(position.label(context)),
                    ),
                ],
                selected: {tabBarPosition},
                onSelectionChanged: (selection) => save(
                  (current) =>
                      current.copyWith.tabBarPosition(selection.single),
                ),
              ),
            ),
            // Supporting text below the control, as for a text field.
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Text(
                l10n.onboarding_basicsTabBarAutoHint,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
