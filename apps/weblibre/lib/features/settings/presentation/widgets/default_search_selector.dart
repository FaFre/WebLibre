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
import 'package:weblibre/presentation/widgets/url_icon.dart';

class DefaultSearchSelector extends HookConsumerWidget {
  const DefaultSearchSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeBang = ref.watch(
      defaultSearchBangDataProvider.select((value) => value.value),
    );

    Future<void> updateSearchProvider(BangKey key) async {
      await ref
          .read(saveGeneralSettingsControllerProvider.notifier)
          .save(
            (currentSettings) =>
                currentSettings.copyWith.defaultSearchProvider(key),
          );
    }

    Future<void> pickProvider() async {
      final trigger = await const BangSearchRoute().push<BangKey?>(context);
      if (trigger != null) {
        await updateSearchProvider(trigger);
      }
    }

    return SizedBox(
      height: 48,
      child: Row(
        children: [
          Expanded(
            child: activeBang == null
                ? OutlinedButton.icon(
                    onPressed: pickProvider,
                    icon: const Icon(Icons.search),
                    label: const Text('Choose a search provider'),
                  )
                : ActionChip(
                    avatar: UrlIcon([activeBang.getDefaultUrl()], iconSize: 20),
                    label: Text(activeBang.websiteName),
                    tooltip: activeBang.trigger,
                    onPressed: pickProvider,
                  ),
          ),
          IconButton(
            onPressed: pickProvider,
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }
}
