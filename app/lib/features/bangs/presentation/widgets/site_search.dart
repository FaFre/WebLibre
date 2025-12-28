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
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nullability/nullability.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/extensions/uri.dart';
import 'package:weblibre/features/bangs/data/models/bang_data.dart';
import 'package:weblibre/features/bangs/domain/providers/bangs.dart';
import 'package:weblibre/features/bangs/domain/providers/search.dart';
import 'package:weblibre/features/geckoview/domain/controllers/bottom_sheet.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_session.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_state.dart';
import 'package:weblibre/features/geckoview/domain/repositories/tab.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/providers.dart';
import 'package:weblibre/features/geckoview/features/search/domain/providers/search_suggestions.dart';
import 'package:weblibre/features/geckoview/features/search/presentation/widgets/search_field.dart';
import 'package:weblibre/features/geckoview/features/search/presentation/widgets/search_modules/fixed_search_suggestions.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/presentation/hooks/listenable_callback.dart';
import 'package:weblibre/presentation/widgets/selectable_chips.dart';
import 'package:weblibre/presentation/widgets/url_icon.dart';
import 'package:weblibre/utils/uri_parser.dart' as uri_parser;

class SiteSearch extends HookConsumerWidget {
  final String domain;
  final List<BangData> availableBangs;
  final TextEditingController? controller;
  final bool searchInNewTab;

  const SiteSearch({
    required this.domain,
    required this.availableBangs,
    super.key,
    this.controller,
    this.searchInNewTab = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchTextController = controller ?? useTextEditingController();
    final searchFocusNode = useFocusNode();

    useListenableCallback(searchTextController, () {
      if (ref.exists(searchSuggestionsProvider())) {
        ref
            .read(searchSuggestionsProvider().notifier)
            .addQuery(searchTextController.text);
      }
    });

    final selectedBang = ref.watch(selectedBangDataProvider(domain: domain));
    final defaultSearchBang = ref.watch(
      defaultSearchBangDataProvider.select((value) => value.value),
    );

    Future<void> submitSearch(String value) async {
      if (value.isNotEmpty) {
        final bang = selectedBang ?? defaultSearchBang;

        final newUrl = uri_parser.tryParseUrl(value, eagerParsing: true);

        if (newUrl != null) {
          await ref
              .read(tabSessionProvider(tabId: null).notifier)
              .loadUrl(url: newUrl);

          ref.read(bottomSheetControllerProvider.notifier).requestDismiss();
        } else if (bang != null) {
          final isPrivate =
              ref.read(selectedTabStateProvider)?.isPrivate ??
              ref
                      .read(generalSettingsWithDefaultsProvider)
                      .defaultCreateTabType ==
                  TabType.private;

          final searchUri = bang.getTemplateUrl(value);

          if (!isPrivate) {
            await ref
                .read(bangSearchProvider.notifier)
                .triggerBangSearch(bang, value);
          }

          if (searchInNewTab) {
            await ref
                .read(tabRepositoryProvider.notifier)
                .addTab(url: searchUri, private: isPrivate);
          } else {
            await ref
                .read(tabSessionProvider(tabId: null).notifier)
                .loadUrl(url: searchUri);
          }

          ref.read(bottomSheetControllerProvider.notifier).requestDismiss();
        }
      }
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Visibility(
          visible: availableBangs.isNotEmpty,
          child: SizedBox(
            height: 48,
            width: double.maxFinite,
            child: SelectableChips(
              itemId: (bang) => bang.trigger,
              itemAvatar: (bang) =>
                  UrlIcon([bang.getDefaultUrl()], iconSize: 20),
              itemLabel: (bang) => Text(bang.websiteName),
              itemTooltip: (bang) => bang.trigger,
              availableItems: availableBangs,
              selectedItem: selectedBang,
              onSelected: (bang) {
                if (selectedBang == null) {
                  final hasSupportedScheme =
                      uri_parser
                          .tryParseUrl(searchTextController.text)
                          .mapNotNull((uri) => uri.hasSupportedScheme) ??
                      false;

                  if (hasSupportedScheme) {
                    searchTextController.clear();
                  }
                }

                ref
                    .read(selectedBangTriggerProvider(domain: domain).notifier)
                    .setTrigger(bang.toKey());
              },
              onDeleted: (bang) {
                if (ref.read(selectedBangTriggerProvider(domain: domain)) ==
                    bang.toKey()) {
                  ref
                      .read(
                        selectedBangTriggerProvider(domain: domain).notifier,
                      )
                      .clearTrigger();
                }
              },
            ),
          ),
        ),
        SearchField(
          textEditingController: searchTextController,
          focusNode: searchFocusNode,
          maxLines: null,
          activeBang: selectedBang,
          showSuggestions: true,
          label: (selectedBang != null)
              ? const Text('Search')
              : const Text('Address / Search'),
          onTap: () {
            if (!searchFocusNode.hasFocus) {
              // Select all text when the field is tapped
              searchTextController.selection = TextSelection(
                baseOffset: 0,
                extentOffset: searchTextController.text.length,
              );
            }
          },
          unfocusOnTapOutside: false,
          onSubmitted: (value) async {
            await submitSearch(value);
          },
        ),
        FixedSearchTermSuggestions(
          searchTextController: searchTextController,
          activeBang: selectedBang,
          submitSearch: submitSearch,
          limit: 25,
        ),
      ],
    );
  }
}
