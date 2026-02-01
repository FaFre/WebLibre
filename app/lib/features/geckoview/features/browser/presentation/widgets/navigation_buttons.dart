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
