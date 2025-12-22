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
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/features/geckoview/domain/entities/states/readerable.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_state.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/controllers/tab_bar_dismissable.dart';
import 'package:weblibre/features/geckoview/features/readerview/domain/providers/readerable.dart';

class BrowserFab extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabBarDismissed = ref.watch(tabBarDismissableControllerProvider);

    final appearanceButtonVisible = ref.watch(
      appearanceButtonVisibilityProvider.select(
        (value) => value.value ?? false,
      ),
    );

    final readerabilityState = ref.watch(
      selectedTabStateProvider.select(
        (state) => state?.readerableState ?? ReaderableState.$default(),
      ),
    );

    return Visibility(
      visible: readerabilityState.active && appearanceButtonVisible,
      replacement: tabBarDismissed
          ? FloatingActionButton(
              child: const Icon(MdiIcons.dockBottom),
              onPressed: () {
                ref.read(tabBarDismissableControllerProvider.notifier).show();
              },
            )
          : const SizedBox.shrink(),
      child: FloatingActionButton(
        onPressed: () async {
          await ref.read(readerableServiceProvider).onAppearanceButtonTap();
        },
        child: const Icon(MdiIcons.formatFont),
      ),
    );
  }
}
