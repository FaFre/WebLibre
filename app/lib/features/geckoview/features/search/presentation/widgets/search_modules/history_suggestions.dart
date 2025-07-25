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
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nullability/nullability.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:weblibre/features/geckoview/domain/controllers/bottom_sheet.dart';
import 'package:weblibre/features/geckoview/domain/repositories/tab.dart';
import 'package:weblibre/features/geckoview/features/search/domain/providers/engine_suggestions.dart';
import 'package:weblibre/features/geckoview/utils/image_helper.dart';
import 'package:weblibre/presentation/hooks/cached_future.dart';
import 'package:weblibre/presentation/hooks/listenable_callback.dart';
import 'package:weblibre/presentation/widgets/failure_widget.dart';

class HistorySuggestions extends HookConsumerWidget {
  final bool isPrivate;
  final ValueListenable<TextEditingValue> searchTextListenable;

  const HistorySuggestions({
    super.key,
    required this.isPrivate,
    required this.searchTextListenable,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historySuggestionsAsync = ref.watch(engineHistorySuggestionsProvider);

    useListenableCallback(searchTextListenable, () async {
      await ref
          .watch(engineSuggestionsProvider.notifier)
          .addQuery(searchTextListenable.value.text);
    });

    if (historySuggestionsAsync.hasValue &&
        (historySuggestionsAsync.valueOrNull.isEmpty)) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return MultiSliver(
      children: [
        const SliverToBoxAdapter(child: Divider()),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Text(
              'History',
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ),
        ),
        SliverSkeletonizer(
          enabled: historySuggestionsAsync.isLoading,
          child: historySuggestionsAsync.when(
            skipLoadingOnReload: true,
            data: (historySuggestions) {
              return SliverList.builder(
                itemCount: historySuggestions.length,
                itemBuilder: (context, index) {
                  final suggestion = historySuggestions[index];

                  return HookBuilder(
                    key: ValueKey(suggestion.id),
                    builder: (context) {
                      final icon = useCachedFuture(
                        () async => suggestion.icon.mapNotNull(tryDecodeImage),
                        //URL as key
                        [suggestion.description],
                      );

                      return ListTile(
                        leading: RepaintBoundary(
                          child: RawImage(
                            image: icon.data?.value,
                            height: 24,
                            width: 24,
                          ),
                        ),
                        title: suggestion.title.mapNotNull(
                          (title) => Text(title),
                        ),
                        subtitle: suggestion.description.mapNotNull(
                          (description) => Text(
                            description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        onTap: () async {
                          if (suggestion.description != null) {
                            if (Uri.tryParse(suggestion.description!)
                                case final Uri url) {
                              await ref
                                  .read(tabRepositoryProvider.notifier)
                                  .addTab(url: url, private: isPrivate);

                              if (context.mounted) {
                                ref
                                    .read(
                                      bottomSheetControllerProvider.notifier,
                                    )
                                    .dismiss();

                                context.pop();
                              }
                            }
                          }
                        },
                      );
                    },
                  );
                },
              );
            },
            error: (error, stackTrace) {
              return SliverToBoxAdapter(
                child: FailureWidget(
                  title: 'Could not load history',
                  exception: error,
                ),
              );
            },
            loading: () => SliverList.builder(
              itemCount: historySuggestionsAsync.valueOrNull?.length ?? 3,
              itemBuilder: (context, index) {
                return const ListTile(title: Bone.text());
              },
            ),
          ),
        ),
      ],
    );
  }
}
