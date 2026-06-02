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

class NavigateForwardButtonView extends StatelessWidget {
  const NavigateForwardButtonView({
    super.key,
    required this.canGoForward,
    this.onPressed,
    this.onLongPress,
  });

  final bool canGoForward;
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: canGoForward ? onPressed : null,
      onLongPress: canGoForward ? onLongPress : null,
      icon: const Icon(Icons.arrow_forward),
    );
  }
}

class NavigateBackButtonView extends StatelessWidget {
  const NavigateBackButtonView({
    super.key,
    required this.canGoBack,
    required this.isLoading,
    this.stopLoadingFallback = true,
    this.onPressed,
    this.onLongPress,
  });

  final bool canGoBack;
  final bool isLoading;

  /// When `true` (default), the button doubles as a stop-loading control while
  /// [isLoading] (shows a close icon, taps cancel the load). When `false` it
  /// stays a plain back button even during loading — used when a dedicated
  /// reload/stop button is present elsewhere in the toolbar.
  final bool stopLoadingFallback;
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final showStop = isLoading && stopLoadingFallback;

    return IconButton(
      onPressed: (canGoBack || showStop) ? onPressed : null,
      onLongPress: (canGoBack && !showStop) ? onLongPress : null,
      icon: showStop ? const Icon(Icons.close) : const Icon(Icons.arrow_back),
    );
  }
}

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
      child: NavigateForwardButtonView(
        canGoForward: canGoForward,
        onPressed: () async {
          final controller = ref.read(
            tabSessionProvider(tabId: selectedTabId).notifier,
          );

          await controller.goForward();
          menuControllerToClose?.close();
        },
        onLongPress: () {
          if (historyMenuController.isOpen) {
            historyMenuController.close();
          } else {
            historyMenuController.open();
          }
        },
      ),
    );
  }
}

class NavigateBackButton extends HookConsumerWidget {
  const NavigateBackButton({
    super.key,
    required this.selectedTabId,
    required this.isLoading,
    this.stopLoadingFallback = true,
    this.menuControllerToClose,
    this.canGoBack = true,
  });

  final String? selectedTabId;
  final bool isLoading;

  /// See [NavigateBackButtonView.stopLoadingFallback].
  final bool stopLoadingFallback;
  final MenuController? menuControllerToClose;
  final bool canGoBack;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyMenuController = useMenuController();
    final showStop = isLoading && stopLoadingFallback;

    return HistoryMenu(
      selectedTabId: selectedTabId,
      controller: historyMenuController,
      direction: HistoryMenuDirection.back,
      child: NavigateBackButtonView(
        canGoBack: canGoBack,
        isLoading: isLoading,
        stopLoadingFallback: stopLoadingFallback,
        onPressed: () async {
          final controller = ref.read(
            tabSessionProvider(tabId: selectedTabId).notifier,
          );

          final isReaderActive = ref.read(
            selectedTabStateProvider.select(
              (state) => state?.readerableState.active ?? false,
            ),
          );

          if (showStop) {
            await controller.stopLoading();
          } else if (isReaderActive) {
            await ref
                .read(readerableScreenControllerProvider.notifier)
                .toggleReaderView(false);
          } else {
            await controller.goBack();
          }

          menuControllerToClose?.close();
        },
        onLongPress: () {
          if (historyMenuController.isOpen) {
            historyMenuController.close();
          } else {
            historyMenuController.open();
          }
        },
      ),
    );
  }
}
