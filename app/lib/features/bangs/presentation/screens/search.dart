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
