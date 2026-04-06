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
import 'package:weblibre/features/geckoview/domain/providers/selected_tab.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_state.dart';
import 'package:weblibre/features/small_web/presentation/controllers/small_web_mode_controller.dart';
import 'package:weblibre/features/small_web/presentation/controllers/small_web_session_controller.dart';
import 'package:weblibre/features/small_web/presentation/widgets/small_web_bottom_bar.dart';
import 'package:weblibre/features/small_web/presentation/widgets/small_web_menu_sheet.dart';

class SmallWebBrowserOverlay extends HookConsumerWidget {
  const SmallWebBrowserOverlay({super.key});

  static const barHeight = 56.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionAsync = ref.watch(smallWebSessionControllerProvider);
    final selectedTabId = ref.watch(selectedTabProvider);

    final tabState = ref.watch(tabStateProvider(selectedTabId));
    final tabUrl = tabState?.url;

    ref.listen(
      tabStateProvider(selectedTabId).select((value) => value?.title),
      (prev, title) async {
        if (title != null && title.isNotEmpty && prev != title) {
          await ref
              .read(smallWebSessionControllerProvider.notifier)
              .updateTitleFromTab(title, tabUrl: tabUrl);
        }
      },
    );

    ref.listen(smallWebSessionControllerProvider, (prev, next) {
      final error = next.asError?.error;
      final previousError = prev?.asError?.error;

      if (error != null && error != previousError && context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString())));
      }
    });

    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: SmallWebBottomBar(
        isLoading: sessionAsync.isLoading,
        currentTabUrl: tabUrl,
        currentTabTitle: tabState?.titleOrAuthority,
        onDiscover: () =>
            ref.read(smallWebSessionControllerProvider.notifier).discover(),
        onMenuTap: () => showSmallWebMenuSheet(context),
        onExit: () => ref.read(smallWebModeControllerProvider.notifier).exit(),
      ),
    );
  }
}
