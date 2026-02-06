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
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/features/bangs/data/models/bang_key.dart';
import 'package:weblibre/features/bangs/domain/providers/bangs.dart';
import 'package:weblibre/features/settings/presentation/controllers/save_settings.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';
import 'package:weblibre/presentation/widgets/selectable_chips.dart';
import 'package:weblibre/presentation/widgets/url_icon.dart';

class DefaultSearchSelector extends HookConsumerWidget {
  const DefaultSearchSelector();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeBang = ref.watch(
      defaultSearchBangDataProvider.select((value) => value.value),
    );
    final availableBangs = ref.watch(frequentBangListProvider);

    Future<void> updateSearchProvider(BangKey key) async {
      await ref
          .read(saveGeneralSettingsControllerProvider.notifier)
          .save(
            (currentSettings) =>
                currentSettings.copyWith.defaultSearchProvider(key),
          );
    }

    return availableBangs.when(
      skipLoadingOnReload: true,
      data: (availableBangs) {
        return SizedBox(
          height: 48,
          child: Row(
            children: [
              Expanded(
                child: SelectableChips(
                  itemId: (bang) => bang.trigger,
                  itemAvatar: (bang) =>
                      UrlIcon([bang.getDefaultUrl()], iconSize: 20),
                  itemLabel: (bang) => Text(bang.websiteName),
                  itemTooltip: (bang) => bang.trigger,
                  availableItems: availableBangs,
                  selectedItem: activeBang,
                  onSelected: (bang) async {
                    await updateSearchProvider(bang.toKey());
                  },
                ),
              ),
              IconButton(
                onPressed: () async {
                  final trigger = await const BangSearchRoute().push<BangKey?>(
                    context,
                  );

                  if (trigger != null) {
                    await updateSearchProvider(trigger);
                  }
                },
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
        );
      },
      error: (error, stackTrace) => Center(
        child: Icon(Icons.error, color: Theme.of(context).colorScheme.error),
      ),
      loading: () => const SizedBox(height: 48, width: double.infinity),
    );
  }
}
