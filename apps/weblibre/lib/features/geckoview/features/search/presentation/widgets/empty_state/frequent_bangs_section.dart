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
import 'package:weblibre/features/bangs/domain/repositories/data.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/providers.dart';
import 'package:weblibre/features/geckoview/features/search/domain/providers/search_modules_view.dart';
import 'package:weblibre/features/geckoview/features/search/presentation/dialogs/reset_bang_dialog.dart';
import 'package:weblibre/features/geckoview/features/search/presentation/widgets/bang_chip_strip.dart';
import 'package:weblibre/features/geckoview/features/search/presentation/widgets/search_modules/search_module_section.dart';

// Both helpers are conceptually `FrequentBangsSection`-private — they
// implement the section's own display-ordering and delete-affordance
// rules. `@visibleForTesting` keeps them reachable from the section's
// test file without exposing a wider API.
@visibleForTesting
List<BangData> buildFrequentBangDisplayList({
  required List<BangData> frequentBangs,
  BangData? selectedBang,
  BangData? defaultBang,
}) {
  final selectedKey = selectedBang?.toKey();
  final defaultKey = defaultBang?.toKey();

  return [
    if (selectedBang != null) selectedBang,
    ...frequentBangs.where(
      (bang) => bang.toKey() != selectedKey && bang.toKey() != defaultKey,
    ),
    if (defaultBang != null && defaultKey != selectedKey) defaultBang,
  ];
}

/// Whether the chip's delete affordance (selection-clear or
/// frequency-reset) should be enabled for [bang].
///
/// Two distinct actions hide behind the single delete affordance:
///   1. Selection clear — always offered for the currently-selected bang.
///   2. Frequency reset — offered for any bang that isn't the user's
///      default search bang. The default is protected to keep the
///      frecency-ranked list anchored on a stable provider.
///
/// When no default is set yet (onboarding / explicitly cleared), no bang
/// is "protected" and frequency reset is offered for any non-selected
/// bang.
@visibleForTesting
bool canDeleteFrequentBang({
  required BangData bang,
  BangData? selectedBang,
  BangData? defaultBang,
}) {
  final isSelected = selectedBang?.toKey() == bang.toKey();
  if (isSelected) return true;
  final isProtectedDefault =
      defaultBang != null && defaultBang.toKey() == bang.toKey();
  return !isProtectedDefault;
}

class FrequentBangsSection extends ConsumerWidget {
  const FrequentBangsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final frequentBangs = ref.watch(
      frequentBangListProvider.select((v) => v.value ?? const <BangData>[]),
    );

    final selectedBang = ref.watch(selectedBangDataProvider());
    final defaultBang = ref.watch(
      defaultSearchBangDataProvider.select((v) => v.value),
    );
    final activeBang = selectedBang ?? defaultBang;

    final bangs = buildFrequentBangDisplayList(
      frequentBangs: frequentBangs,
      selectedBang: selectedBang,
      defaultBang: defaultBang,
    );

    void selectBang(BangData bang) {
      ref.read(selectedBangTriggerProvider().notifier).setTrigger(bang.toKey());
    }

    Future<void> handleDeletion(BangData bang) async {
      final currentSelection = ref.read(selectedBangTriggerProvider());

      if (currentSelection == bang.toKey()) {
        ref.read(selectedBangTriggerProvider().notifier).clearTrigger();
        return;
      }

      if (!canDeleteFrequentBang(
        bang: bang,
        selectedBang: selectedBang,
        defaultBang: defaultBang,
      )) {
        return;
      }

      final dialogResult = await showResetBangDialog(
        context,
        triggerName: bang.trigger,
      );

      if (dialogResult == true) {
        await ref
            .read(bangDataRepositoryProvider.notifier)
            .resetFrequency(bang.trigger);
      }
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
                    deletableSelectedBang: selectedBang,
                    canDeleteBang: (bang) => canDeleteFrequentBang(
                      bang: bang,
                      selectedBang: selectedBang,
                      defaultBang: defaultBang,
                    ),
                    maxCount: visibleCount >= bangs.length
                        ? null
                        : visibleCount,
                    sortSelectedFirst: false,
                    allowFrequencyResetAction: true,
                    onSelected: selectBang,
                    onDeleted: handleDeletion,
                  ),
                ),
              ),
          ],
    );
  }
}
