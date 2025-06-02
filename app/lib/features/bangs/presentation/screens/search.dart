import 'dart:async';

import 'package:fading_scroll/fading_scroll.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/features/bangs/domain/providers/search.dart';
import 'package:weblibre/features/bangs/presentation/widgets/bang_details.dart';
import 'package:weblibre/features/user/domain/providers.dart';
import 'package:weblibre/presentation/hooks/listenable_callback.dart';
import 'package:weblibre/presentation/widgets/failure_widget.dart';

class BangSearchScreen extends HookConsumerWidget {
  final String? initialSearchText;

  const BangSearchScreen({super.key, this.initialSearchText});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resultsAsync = ref.watch(bangSearchProvider);
    final incognitoEnabled = ref.watch(incognitoModeEnabledProvider);

    final focusNode = useFocusNode();
    final textEditingController = useTextEditingController(
      text: initialSearchText,
    );

    useListenableCallback(textEditingController, () {
      unawaited(
        ref
            .read(bangSearchProvider.notifier)
            .search(textEditingController.text),
      );
    });

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          enableIMEPersonalizedLearning: !incognitoEnabled,
          focusNode: focusNode,
          controller: textEditingController,
          autofocus: true,
          autocorrect: false,
          decoration: const InputDecoration.collapsed(hintText: 'Search'),
        ),
        actions: [
          IconButton(
            onPressed: () {
              if (textEditingController.text.isEmpty) {
                context.pop();
              } else {
                textEditingController.clear();
                focusNode.requestFocus();
              }
            },
            icon: const Icon(Icons.clear),
          ),
        ],
      ),
      body: resultsAsync.when(
        skipLoadingOnReload: true,
        data: (bangs) => FadingScroll(
          fadingSize: 25,
          builder: (context, controller) {
            return ListView.builder(
              controller: controller,
              itemCount: bangs.length,
              itemBuilder: (context, index) {
                final bang = bangs[index];
                return BangDetails(
                  bang,
                  onTap: () {
                    context.pop(bang.trigger);
                  },
                );
              },
            );
          },
        ),
        error: (error, stackTrace) => Center(
          child: FailureWidget(title: 'Bang Search failed', exception: error),
        ),
        loading: () => const SizedBox.shrink(),
      ),
    );
  }
}
