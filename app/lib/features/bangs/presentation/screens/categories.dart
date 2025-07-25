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
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/features/bangs/domain/providers/bangs.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/providers.dart';
import 'package:weblibre/presentation/widgets/failure_widget.dart';

class BangCategoriesScreen extends HookConsumerWidget {
  const BangCategoriesScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(bangCategoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bang Categories'),
        actions: [
          IconButton(
            onPressed: () async {
              final trigger = await const BangSearchRoute().push<String?>(
                context,
              );

              if (trigger != null) {
                ref
                    .read(selectedBangTriggerProvider().notifier)
                    .setTrigger(trigger);
              }
            },
            icon: const Icon(Icons.search),
          ),
        ],
      ),
      body: categoriesAsync.when(
        skipLoadingOnReload: true,
        data: (categories) {
          return FadingScroll(
            fadingSize: 25,
            builder: (context, controller) {
              return SingleChildScrollView(
                controller: controller,
                child: HookBuilder(
                  builder: (context) {
                    final expanded = useState(<String>{});

                    return ExpansionPanelList(
                      expansionCallback: (index, expand) {
                        final key = categories.keys.elementAt(index);
                        if (!expanded.value.contains(key)) {
                          expanded.value = {...expanded.value, key};
                        } else {
                          expanded.value = {...expanded.value}..remove(key);
                        }
                      },
                      children: categories.entries
                          .map(
                            (category) => ExpansionPanel(
                              canTapOnHeader: true,
                              isExpanded: expanded.value.contains(category.key),
                              headerBuilder: (context, isExpanded) =>
                                  ListTile(title: Text(category.key)),
                              body: Padding(
                                padding: const EdgeInsets.only(left: 16.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: category.value
                                      .map(
                                        (subCategory) => ListTile(
                                          title: Text(subCategory),
                                          onTap: () async {
                                            await BangSubCategoryRoute(
                                              category: category.key,
                                              subCategory: subCategory,
                                            ).push(context);
                                          },
                                        ),
                                      )
                                      .toList(),
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    );
                  },
                ),
              );
            },
          );
        },
        error: (error, stackTrace) => Center(
          child: FailureWidget(
            title: 'Failed to load Bang Categories',
            exception: error,
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
