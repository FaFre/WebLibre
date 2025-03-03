import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lensai/core/routing/routes.dart';
import 'package:lensai/extensions/nullable.dart';
import 'package:lensai/features/bangs/domain/providers/bangs.dart';
import 'package:lensai/features/bangs/presentation/widgets/bang_details.dart';
import 'package:lensai/features/geckoview/features/browser/domain/providers.dart';
import 'package:lensai/presentation/widgets/failure_widget.dart';

class BangListScreen extends HookConsumerWidget {
  final String? category;
  final String? subCategory;

  const BangListScreen({this.category, this.subCategory, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bangsAsync = ref.watch(
      bangListProvider(
        categoryFilter: category.mapNotNull(
          (category) => (category: category, subCategory: subCategory),
        ),
      ),
    );

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.medium(title: Text('$category: $subCategory')),
          bangsAsync.when(
            skipLoadingOnReload: true,
            data: (bangs) {
              return SliverList.builder(
                itemCount: bangs.length,
                itemBuilder: (context, index) {
                  final bang = bangs[index];
                  return BangDetails(
                    bang,
                    onTap: () {
                      ref
                          .read(selectedBangTriggerProvider().notifier)
                          .setTrigger(bang.trigger);

                      const SearchRoute().go(context);
                    },
                  );
                },
              );
            },
            error:
                (error, stackTrace) => SliverToBoxAdapter(
                  child: Center(
                    child: FailureWidget(
                      title: 'Failed to load Bangs',
                      exception: error,
                    ),
                  ),
                ),
            loading:
                () => const SliverToBoxAdapter(
                  child: Center(child: CircularProgressIndicator()),
                ),
          ),
        ],
      ),
    );
  }
}
