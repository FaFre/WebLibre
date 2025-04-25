import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lensai/extensions/nullable.dart';
import 'package:lensai/features/geckoview/domain/controllers/bottom_sheet.dart';
import 'package:lensai/features/geckoview/domain/repositories/tab.dart';
import 'package:lensai/features/geckoview/features/search/domain/providers/engine_suggestions.dart';
import 'package:lensai/features/geckoview/utils/image_helper.dart';
import 'package:lensai/presentation/hooks/cached_future.dart';
import 'package:lensai/presentation/hooks/listenable_callback.dart';
import 'package:lensai/presentation/widgets/failure_widget.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:sliver_tools/sliver_tools.dart';

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
            loading:
                () => SliverList.builder(
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
