import 'package:fading_scroll/fading_scroll.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lensai/features/bangs/data/models/bang_data.dart';
import 'package:lensai/features/bangs/domain/providers/search.dart';
import 'package:lensai/features/geckoview/domain/repositories/tab.dart';
import 'package:lensai/features/geckoview/features/browser/domain/providers.dart';
import 'package:lensai/features/geckoview/features/search/domain/providers/search_suggestions.dart';
import 'package:lensai/features/geckoview/features/search/presentation/widgets/search_field.dart';
import 'package:lensai/features/geckoview/features/search/presentation/widgets/search_modules/search_suggestions.dart';
import 'package:lensai/presentation/hooks/listenable_callback.dart';
import 'package:lensai/presentation/widgets/bang_icon.dart';
import 'package:lensai/presentation/widgets/selectable_chips.dart';

class SiteSearch extends HookConsumerWidget {
  final String domain;
  final List<BangData> availableBangs;

  const SiteSearch({
    required this.domain,
    required this.availableBangs,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormState>());

    final searchTextController = useTextEditingController();

    useListenableCallback(
      searchTextController,
      () async {
        ref
            .read(searchSuggestionsProvider().notifier)
            .addQuery(searchTextController.text);
      },
    );

    final selectedBang = ref.watch(
      selectedBangDataProvider(domain: domain)
          .select((value) => value.valueOrNull),
    );

    final activeBang = selectedBang ?? availableBangs.firstOrNull;

    Future<void> submitSearch(String query) async {
      if (activeBang != null && (formKey.currentState?.validate() == true)) {
        final searchUri = await ref.read(
          triggerBangSearchProvider(activeBang, query).future,
        );

        await ref.read(tabRepositoryProvider.notifier).addTab(url: searchUri);

        if (context.mounted) {
          context.pop();
        }
      }
    }

    return Form(
      key: formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 48,
            width: double.maxFinite,
            child: SelectableChips(
              itemId: (bang) => bang.trigger,
              itemAvatar: (bang) => UrlIcon(bang.getUrl(''), iconSize: 20),
              itemLabel: (bang) => Text(bang.websiteName),
              availableItems: availableBangs,
              selectedItem: selectedBang,
              onSelected: (bang) {
                ref
                    .read(
                      selectedBangTriggerProvider(domain: domain).notifier,
                    )
                    .setTrigger(bang.trigger);
              },
              onDeleted: (bang) {
                if (ref.read(
                      selectedBangTriggerProvider(domain: domain),
                    ) ==
                    bang.trigger) {
                  ref
                      .read(
                        selectedBangTriggerProvider(domain: domain).notifier,
                      )
                      .clearTrigger();
                }
              },
            ),
          ),
          SearchField(
            textEditingController: searchTextController,
            activeBang: activeBang,
            onSubmitted: (_) async {
              await submitSearch(searchTextController.text);
            },
            showSuggestions: false,
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 150),
            child: FadingScroll(
              fadingSize: 25,
              builder: (context, controller) {
                return CustomScrollView(
                  shrinkWrap: true,
                  controller: controller,
                  slivers: [
                    SearchTermSuggestions(
                      searchTextController: searchTextController,
                      activeBang: activeBang,
                      submitSearch: submitSearch,
                      showHistory: false,
                      showChips: false,
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
