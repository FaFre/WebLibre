import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/features/bangs/data/models/bang_data.dart';
import 'package:weblibre/features/bangs/domain/providers/bangs.dart';
import 'package:weblibre/features/bangs/domain/providers/search.dart';
import 'package:weblibre/features/geckoview/domain/controllers/bottom_sheet.dart';
import 'package:weblibre/features/geckoview/domain/repositories/tab.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/providers.dart';
import 'package:weblibre/features/geckoview/features/search/presentation/widgets/clipboard_fill.dart';
import 'package:weblibre/features/geckoview/features/search/presentation/widgets/search_field.dart';
import 'package:weblibre/features/geckoview/features/search/presentation/widgets/search_modules/feed_search.dart';
import 'package:weblibre/features/geckoview/features/search/presentation/widgets/search_modules/history_suggestions.dart';
import 'package:weblibre/features/geckoview/features/search/presentation/widgets/search_modules/search_suggestions.dart';
import 'package:weblibre/features/geckoview/features/search/presentation/widgets/search_modules/tab_search.dart';
import 'package:weblibre/presentation/hooks/sampled_value_notifier.dart';
import 'package:weblibre/utils/uri_parser.dart' as uri_parser;

class SearchScreen extends HookConsumerWidget {
  final String? initialSearchText;
  final TabType tabType;

  const SearchScreen({required this.initialSearchText, required this.tabType});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormState>());

    final selectedTabType = useState(tabType);
    final isPrivate = selectedTabType.value == TabType.private;

    final searchTextController = useTextEditingController(
      text: initialSearchText,
    );
    final sampledSearchText = useSampledValueNotifier(
      source: searchTextController,
      sampleDuration: const Duration(milliseconds: 150),
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
        final searchUri = activeBang.getTemplateUrl(query);

        if (!isPrivate) {
          await ref
              .read(bangSearchProvider.notifier)
              .triggerBangSearch(activeBang, query);
        }

        await ref
            .read(tabRepositoryProvider.notifier)
            .addTab(url: searchUri, private: isPrivate);

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
              title: Align(
                child: Focus(
                  canRequestFocus: false,
                  child: SegmentedButton(
                    showSelectedIcon: false,
                    segments: const [
                      ButtonSegment(
                        value: TabType.regular,
                        label: Text('Regular'),
                        icon: Icon(MdiIcons.tab),
                      ),
                      ButtonSegment(
                        value: TabType.private,
                        label: Text('Private'),
                        icon: Icon(MdiIcons.tabUnselected),
                      ),
                    ],
                    selected: {selectedTabType.value},
                    onSelectionChanged: (value) {
                      selectedTabType.value = value.first;
                      // Restore focus to search field after segment change
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        searchFocusNode.requestFocus();
                      });
                    },
                    style: switch (selectedTabType.value) {
                      TabType.regular => null,
                      TabType.private => SegmentedButton.styleFrom(
                        selectedBackgroundColor: const Color(0x648000D7),
                      ),
                    },
                  ),
                ),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(kToolbarHeight),
                child: Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: SearchField(
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
                              await ref.read(
                                defaultSearchBangDataProvider.future,
                              );

                          newUrl = defaultSearchBang?.getTemplateUrl(value);
                        }

                        if (newUrl != null) {
                          await ref
                              .read(tabRepositoryProvider.notifier)
                              .addTab(url: newUrl, private: isPrivate);

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
              ),
            ),
            SliverToBoxAdapter(
              child: ClipboardFillLink(controller: searchTextController),
            ),
            const SliverToBoxAdapter(child: Divider()),
            SearchTermSuggestions(
              searchTextController: searchTextController,
              activeBang: activeBang,
              submitSearch: submitSearch,
            ),
            TabSearch(searchTextListenable: sampledSearchText),
            FeedSearch(searchTextNotifier: sampledSearchText),
            HistorySuggestions(
              isPrivate: isPrivate,
              searchTextListenable: sampledSearchText,
            ),
          ],
        ),
      ),
    );
  }
}
