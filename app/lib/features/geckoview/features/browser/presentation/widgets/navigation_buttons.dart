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
import 'package:weblibre/features/geckoview/domain/providers/tab_session.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_state.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/history_menu.dart';
import 'package:weblibre/features/geckoview/features/readerview/presentation/controllers/readerable.dart';
import 'package:weblibre/presentation/hooks/menu_controller.dart';

class NavigateForwardButton extends HookConsumerWidget {
  const NavigateForwardButton({
    super.key,
    required this.selectedTabId,
    this.menuControllerToClose,
    this.canGoForward = true,
  });

  final String? selectedTabId;
  final MenuController? menuControllerToClose;
  final bool canGoForward;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyMenuController = useMenuController();

    return HistoryMenu(
      selectedTabId: selectedTabId,
      controller: historyMenuController,
      direction: HistoryMenuDirection.forward,
      child: IconButton(
        onPressed: canGoForward
            ? () async {
                final controller = ref.read(
                  tabSessionProvider(tabId: selectedTabId).notifier,
                );

                await controller.goForward();
                menuControllerToClose?.close();
              }
            : null,
        onLongPress: canGoForward
            ? () {
                if (!historyMenuController.isOpen) {
                  historyMenuController.open();
                }
              }
            : null,
        icon: const Icon(Icons.arrow_forward),
      ),
    );
  }
}

class NavigateBackButton extends HookConsumerWidget {
  const NavigateBackButton({
    super.key,
    required this.selectedTabId,
    required this.isLoading,
    this.menuControllerToClose,
    this.canGoBack = true,
  });

  final String? selectedTabId;
  final bool isLoading;
  final MenuController? menuControllerToClose;
  final bool canGoBack;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyMenuController = useMenuController();

    return HistoryMenu(
      selectedTabId: selectedTabId,
      controller: historyMenuController,
      direction: HistoryMenuDirection.back,
      child: IconButton(
        onPressed: (canGoBack || isLoading)
            ? () async {
                final controller = ref.read(
                  tabSessionProvider(tabId: selectedTabId).notifier,
                );

                final isReaderActive = ref.read(
                  selectedTabStateProvider.select(
                    (state) => state?.readerableState.active ?? false,
                  ),
                );

                if (isLoading) {
                  await controller.stopLoading();
                } else if (isReaderActive) {
                  await ref
                      .read(readerableScreenControllerProvider.notifier)
                      .toggleReaderView(false);
                } else {
                  await controller.goBack();
                }

                menuControllerToClose?.close();
              }
            : null,
        onLongPress: (canGoBack && !isLoading)
            ? () {
                if (!historyMenuController.isOpen) {
                  historyMenuController.open();
                }
              }
            : null,
        icon: isLoading
            ? const Icon(Icons.close)
            : const Icon(Icons.arrow_back),
      ),
    );
  }
}
