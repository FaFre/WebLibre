import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lensai/features/geckoview/domain/providers/tab_state.dart';
import 'package:lensai/features/geckoview/features/find_in_page/presentation/controllers/find_in_page.dart';

class FindInPageWidget extends HookConsumerWidget {
  final EdgeInsetsGeometry padding;

  const FindInPageWidget({this.padding = EdgeInsets.zero});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final findInPageState = ref.watch(findInPageControllerProvider);

    final textController = useTextEditingController(
      text: findInPageState.searchText,
      keys: [findInPageState.searchText],
    );

    return Visibility(
      visible: findInPageState.visible,
      child: Padding(
        padding: padding,
        child: Material(
          child: Row(
            children: [
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: textController,
                  autofocus: true,
                  autocorrect: false,
                  decoration: const InputDecoration.collapsed(
                    hintText: 'Find in page',
                  ),
                  keyboardType: TextInputType.text,
                  onSubmitted: (value) async {
                    if (value == '') {
                      await ref
                          .read(findInPageControllerProvider.notifier)
                          .clearMatches();
                    } else {
                      await ref
                          .read(findInPageControllerProvider.notifier)
                          .findAll(text: value);
                    }
                  },
                ),
              ),
              HookConsumer(
                builder: (context, ref, child) {
                  final searchResult = ref.watch(
                    selectedTabStateProvider.select(
                      (state) => state?.findResultState,
                    ),
                  );

                  if (searchResult != null) {
                    if (searchResult.numberOfMatches == 0) {
                      return const Text('Not found');
                    }

                    return Text(
                      '${searchResult.activeMatchOrdinal + 1} of ${searchResult.numberOfMatches}',
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
              IconButton(
                icon: const Icon(Icons.arrow_upward),
                onPressed: () async {
                  await ref
                      .read(findInPageControllerProvider.notifier)
                      .findNext(forward: false);
                },
              ),
              IconButton(
                icon: const Icon(Icons.arrow_downward),
                onPressed: () async {
                  await ref
                      .read(findInPageControllerProvider.notifier)
                      .findNext();
                },
              ),
              IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () async {
                  ref.read(findInPageControllerProvider.notifier).hide();

                  await ref
                      .read(findInPageControllerProvider.notifier)
                      .clearMatches();
                  textController.clear();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
