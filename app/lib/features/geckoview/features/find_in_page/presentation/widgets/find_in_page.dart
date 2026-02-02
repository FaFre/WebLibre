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
import 'package:weblibre/features/geckoview/domain/providers/tab_state.dart';
import 'package:weblibre/features/geckoview/features/find_in_page/presentation/controllers/find_in_page.dart';
import 'package:weblibre/presentation/hooks/debouncer.dart';

class FindInPageWidget extends HookConsumerWidget {
  final String tabId;
  final EdgeInsetsGeometry padding;

  /// The height of the find-in-page widget.
  static const findInPageHeight = 56.0;

  const FindInPageWidget({
    required this.tabId,
    this.padding = EdgeInsets.zero,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final findInPageState = ref.watch(findInPageControllerProvider(tabId));
    final searchResult = ref.watch(
      selectedTabStateProvider.select((state) => state?.findResultState),
    );

    final focusNode = useFocusNode();
    final textController = useTextEditingController(
      text: searchResult?.lastSearchText ?? findInPageState.lastSearchText,
    );

    // Create debouncer with automatic disposal
    final debouncer = useDebouncer(const Duration(milliseconds: 300));

    // Search function that handles debouncing
    Future<void> onSearchTextChanged(String value) async {
      if (value.isEmpty) {
        debouncer.dispose();
        await ref
            .read(findInPageControllerProvider(tabId).notifier)
            .clearMatches();
      } else {
        debouncer.eventOccured(() async {
          await ref
              .read(findInPageControllerProvider(tabId).notifier)
              .findAll(text: value);
        });
      }
    }

    return Visibility(
      visible: findInPageState.visible || searchResult?.hasMatches == true,
      child: Padding(
        padding: padding,
        child: Material(
          child: SizedBox(
            height: findInPageHeight,
            child: Row(
              children: [
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    focusNode: focusNode,
                    controller: textController,
                    autofocus: true,
                    autocorrect: false,
                    decoration: const InputDecoration.collapsed(
                      hintText: 'Find in page',
                    ),
                    keyboardType: TextInputType.text,
                    onChanged: onSearchTextChanged,
                    onSubmitted: (value) async {
                      // Cancel pending debounce and execute immediately
                      debouncer.dispose();
                      if (value.isEmpty) {
                        await ref
                            .read(findInPageControllerProvider(tabId).notifier)
                            .clearMatches();
                      } else {
                        await ref
                            .read(findInPageControllerProvider(tabId).notifier)
                            .findAll(text: value);
                      }
                    },
                  ),
                ),
                Text(
                  (searchResult != null && searchResult.hasMatches)
                      ? '${searchResult.activeMatchOrdinal + 1} of ${searchResult.numberOfMatches}'
                      : 'Not found',
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_upward),
                  onPressed: () async {
                    await ref
                        .read(findInPageControllerProvider(tabId).notifier)
                        .findNext(
                          forward: false,
                          fallbackText: textController.text,
                        );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_downward),
                  onPressed: () async {
                    await ref
                        .read(findInPageControllerProvider(tabId).notifier)
                        .findNext(fallbackText: textController.text);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () async {
                    await ref
                        .read(findInPageControllerProvider(tabId).notifier)
                        .hide();

                    textController.clear();
                    focusNode.requestFocus();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
