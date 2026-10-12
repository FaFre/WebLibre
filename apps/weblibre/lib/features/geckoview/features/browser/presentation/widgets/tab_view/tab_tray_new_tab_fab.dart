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
import 'package:weblibre/features/geckoview/domain/providers/tab_state.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/tab_view/tab_view_header.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/presentation/hooks/scroll_visibility.dart';

/// The tab tray's new-tab button, over the bottom-right corner of the tab list
/// (list, grid and tree alike).
///
/// It slides away while the list scrolls down and comes back as soon as it
/// scrolls up, like the full-screen tab view's button. In the tray's sheet
/// ([sheetController]) the sheet growing and shrinking count as scrolling too:
/// a drag resizes the sheet first and only scrolls the list once the sheet is
/// at its full height.
class TabTrayNewTabFab extends HookConsumerWidget {
  final ScrollController scrollController;
  final DraggableScrollableController? sheetController;
  final VoidCallback onClose;

  const TabTrayNewTabFab({
    required this.scrollController,
    required this.sheetController,
    required this.onClose,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final disableAnimations = MediaQuery.disableAnimationsOf(context);
    final isVisible = useScrollVisibility(
      scrollController,
      sheetController: sheetController,
      disableAnimations: disableAnimations,
    );
    final duration = disableAnimations
        ? Duration.zero
        : const Duration(milliseconds: 200);

    return AnimatedSlide(
      duration: duration,
      offset: isVisible.value ? Offset.zero : const Offset(0, 2),
      curve: Curves.easeInOut,
      child: AnimatedOpacity(
        duration: duration,
        opacity: isVisible.value ? 1.0 : 0.0,
        child: Padding(
          padding: EdgeInsets.only(
            // Clear of the header, which runs behind the status bar once the
            // sheet slides under it, and grows by its height.
            top:
                TabViewHeader.headerSize +
                MediaQuery.paddingOf(context).top +
                4,
            right: 4,
          ),
          child: FloatingActionButton.small(
            onPressed: () async {
              final settings = ref.read(generalSettingsWithDefaultsProvider);

              await SearchRoute(
                tabType:
                    ref.read(selectedTabTypeProvider) ??
                    settings.effectiveDefaultCreateTabType,
              ).push(context);

              // A search usually closes the tray, and this button with it.
              if (context.mounted) onClose();
            },
            child: const Icon(Icons.add),
          ),
        ),
      ),
    );
  }
}
