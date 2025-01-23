import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lensai/core/routing/routes.dart';
import 'package:lensai/features/bangs/domain/providers/bangs.dart';
import 'package:lensai/features/bangs/presentation/widgets/bang_details.dart';
import 'package:lensai/features/geckoview/features/browser/domain/entities/sheet.dart';
import 'package:lensai/features/geckoview/features/browser/domain/providers.dart';
import 'package:lensai/features/geckoview/domain/controllers/bottom_sheet.dart';
import 'package:lensai/features/kagi/data/entities/modes.dart';
import 'package:lensai/presentation/widgets/failure_widget.dart';

class BangListScreen extends HookConsumerWidget {
  final String? category;
  final String? subCategory;

  const BangListScreen({this.category, this.subCategory, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bangsAsync = ref.watch(
      bangDataListProvider(
        filter: (
          categoryFilter: (category != null)
              ? (category: category!, subCategory: subCategory)
              : null,
          domain: null,
          groups: null,
          orderMostFrequentFirst: null,
        ),
      ),
    );

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.medium(
            title: Text('$category: $subCategory'),
          ),
          bangsAsync.when(
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

                      if (ref.read(bottomSheetControllerProvider)
                          is! CreateTabSheet) {
                        ref.read(bottomSheetControllerProvider.notifier).show(
                              CreateTabSheet(
                                preferredTool: KagiTool.search,
                              ),
                            );
                      }

                      context.go(BrowserRoute().location);
                    },
                  );
                },
              );
            },
            error: (error, stackTrace) => SliverToBoxAdapter(
              child: Center(
                child: FailureWidget(
                  title: 'Failed to load Bangs',
                  exception: error,
                ),
              ),
            ),
            loading: () => const SliverToBoxAdapter(
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
        ],
      ),
    );
  }
}
