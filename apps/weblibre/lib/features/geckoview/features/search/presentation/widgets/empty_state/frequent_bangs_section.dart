/*
 * Copyright (c) 2024-2026 Fabian Freund.
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
import 'package:weblibre/features/bangs/data/models/bang_data.dart';
import 'package:weblibre/features/bangs/domain/providers/bangs.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/providers.dart';
import 'package:weblibre/features/geckoview/features/search/domain/providers/search_modules_view.dart';
import 'package:weblibre/features/geckoview/features/search/presentation/widgets/bang_chip_strip.dart';
import 'package:weblibre/features/geckoview/features/search/presentation/widgets/search_modules/search_module_section.dart';

// Both helpers are conceptually `FrequentBangsSection`-private — they
// implement the section's own display-ordering and delete-affordance
// rules. `@visibleForTesting` keeps them reachable from the section's
// test file without exposing a wider API.
@visibleForTesting
List<BangData> buildFrequentBangDisplayList({
  required List<BangData> frequentBangs,
  List<BangData> pinnedBangs = const [],
  BangData? selectedBang,
  BangData? defaultBang,
}) {
  final selectedKey = selectedBang?.toKey();
  final defaultKey = defaultBang?.toKey();

  // Pins lead the frequency-ranked chips; the selection and the default keep
  // their existing first/last anchor positions around the whole run.
  final ranked = mergePinnedBangs(pinned: pinnedBangs, rest: frequentBangs);

  return [
    if (selectedBang != null) selectedBang,
    ...ranked.where(
      (bang) => bang.toKey() != selectedKey && bang.toKey() != defaultKey,
    ),
    if (defaultBang != null && defaultKey != selectedKey) defaultBang,
  ];
}

class FrequentBangsSection extends ConsumerWidget {
  const FrequentBangsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final frequentBangs = ref.watch(
      frequentBangListProvider.select((v) => v.value ?? const <BangData>[]),
    );

    final pinnedBangs = ref.watch(
      pinnedBangListProvider.select((v) => v.value ?? const <BangData>[]),
    );

    final selectedBang = ref.watch(selectedBangDataProvider());
    final defaultBang = ref.watch(
      defaultSearchBangDataProvider.select((v) => v.value),
    );
    final activeBang = selectedBang ?? defaultBang;

    final bangs = buildFrequentBangDisplayList(
      frequentBangs: frequentBangs,
      pinnedBangs: pinnedBangs,
      selectedBang: selectedBang,
      defaultBang: defaultBang,
    );

    void selectBang(BangData bang) {
      ref.read(selectedBangTriggerProvider().notifier).setTrigger(bang.toKey());
    }

    // The `x` only ever clears the selection; frequency reset moved to the
    // chip's long-press menu, where it can't be mistaken for it.
    void handleDeletion(BangData bang) {
      ref.read(selectedBangTriggerProvider().notifier).clearTrigger();
    }

    return SearchModuleSection(
      title: 'Frequent Bangs',
      moduleType: SearchModuleType.frequentBangs,
      totalCount: bangs.length,
      contentSliverBuilder:
          ({required bool isCollapsed, required int visibleCount}) => [
            if (!isCollapsed)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: BangChipStrip(
                    bangs: bangs,
                    selectedBang: activeBang,
                    clearableBang: selectedBang,
                    maxCount: visibleCount >= bangs.length
                        ? null
                        : visibleCount,
                    sortSelectedFirst: false,
                    onSelected: selectBang,
                    onDeleted: handleDeletion,
                  ),
                ),
              ),
          ],
    );
  }
}
