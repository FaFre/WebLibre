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
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nullability/nullability.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/features/bangs/domain/providers/bangs.dart';
import 'package:weblibre/features/bangs/presentation/widgets/bang_details.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_state.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/providers.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/presentation/widgets/failure_widget.dart';

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
                          .setTrigger(bang.toKey());

                      final settings = ref.read(
                        generalSettingsWithDefaultsProvider,
                      );

                      SearchRoute(
                        tabType:
                            ref.read(selectedTabTypeProvider) ??
                            settings.defaultCreateTabType,
                      ).go(context);
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
