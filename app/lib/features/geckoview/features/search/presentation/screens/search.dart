import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lensai/features/bangs/data/models/bang_data.dart';
import 'package:lensai/features/bangs/domain/providers/bangs.dart';
import 'package:lensai/features/bangs/domain/providers/search.dart';
import 'package:lensai/features/geckoview/domain/controllers/bottom_sheet.dart';
import 'package:lensai/features/geckoview/domain/repositories/tab.dart';
import 'package:lensai/features/geckoview/features/browser/domain/providers.dart';
import 'package:lensai/features/geckoview/features/search/presentation/widgets/search_field.dart';
import 'package:lensai/features/geckoview/features/search/presentation/widgets/search_modules/feed_search.dart';
import 'package:lensai/features/geckoview/features/search/presentation/widgets/search_modules/history_suggestions.dart';
import 'package:lensai/features/geckoview/features/search/presentation/widgets/search_modules/search_suggestions.dart';
import 'package:lensai/features/geckoview/features/search/presentation/widgets/search_modules/tab_search.dart';
import 'package:lensai/utils/uri_parser.dart' as uri_parser;

class SearchScreen extends HookConsumerWidget {
  final String? initialSearchText;

  const SearchScreen({required this.initialSearchText});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormState>());

    final searchTextController = useTextEditingController(
      text: initialSearchText,
    );
    final searchFocusNode = useFocusNode();

    final defaultSearchBang = ref.watch(
      defaultSearchBangDataProvider.select((value) => value.valueOrNull),
    );

    final selectedBang = useState<BangData?>(null);
    final activeBang = selectedBang.value ?? defaultSearchBang;
    final showBangIcon = useState(false);

    ref.listen(selectedBangDataProvider(), (previous, next) {
      if (previous != next) {
        showBangIcon.value = true;
      }

      selectedBang.value = next;
    });

    Future<void> submitSearch(String query) async {
      if (activeBang != null && (formKey.currentState?.validate() == true)) {
        final searchUri = await ref
            .read(bangSearchProvider.notifier)
            .triggerBangSearch(activeBang, query);

        await ref.read(tabRepositoryProvider.notifier).addTab(url: searchUri);

        if (context.mounted) {
          ref.read(bottomSheetControllerProvider.notifier).dismiss();

          context.pop();
        }
      }
    }

    return Scaffold(
      body: Form(
        key: formKey,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: true,
              pinned: true,
              automaticallyImplyLeading: false,
              title: SearchField(
                showBangIcon: showBangIcon.value,
                textEditingController: searchTextController,
                focusNode: searchFocusNode,
                autofocus: true,
                onSubmitted: (value) async {
                  if (value.isNotEmpty) {
                    var newUrl = uri_parser.tryParseUrl(
                      value,
                      eagerParsing: true,
                    );

                    if (newUrl == null) {
                      final defaultSearchBang =
                          ref.read(selectedBangDataProvider()) ??
                          await ref.read(defaultSearchBangDataProvider.future);

                      newUrl = defaultSearchBang?.getTemplateUrl(value);
                    }

                    if (newUrl != null) {
                      await ref
                          .read(tabRepositoryProvider.notifier)
                          .addTab(url: newUrl);

                      if (context.mounted) {
                        ref
                            .read(bottomSheetControllerProvider.notifier)
                            .dismiss();

                        context.pop();
                      }
                    }
                  }
                },
                activeBang: activeBang,
                showSuggestions: true,
              ),
            ),
            const SliverToBoxAdapter(child: Divider()),
            SearchTermSuggestions(
              searchTextController: searchTextController,
              activeBang: activeBang,
              submitSearch: submitSearch,
            ),
            const SliverToBoxAdapter(child: Divider()),
            TabSearch(searchTextController: searchTextController),
            FeedSearch(searchTextController: searchTextController),
            HistorySuggestions(searchTextController: searchTextController),
          ],
        ),
      ),
    );
  }
}
