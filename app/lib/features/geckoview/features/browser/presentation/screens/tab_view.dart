import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_state.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/controllers/tree_view.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/view_tabs.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';

class TabViewScreen extends HookConsumerWidget {
  const TabViewScreen();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final treeModeEnabled = ref.watch(treeViewControllerProvider);

    final scrollController = useScrollController();

    return Dialog.fullscreen(
      child: Scaffold(
        body: SafeArea(
          child: treeModeEnabled
              ? ViewTabTreesWidget(
                  scrollController: scrollController,
                  showNewTabFab: false,
                  onClose: () {
                    BrowserRoute().go(context);
                  },
                )
              : ViewTabsWidget(
                  scrollController: scrollController,
                  showNewTabFab: false,
                  onClose: () {
                    BrowserRoute().go(context);
                  },
                ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final settings = ref.read(generalSettingsWithDefaultsProvider);

            await SearchRoute(
              tabType:
                  ref.read(selectedTabTypeProvider) ??
                  settings.defaultCreateTabType,
            ).push(context);

            if (context.mounted) {
              BrowserRoute().go(context);
            }
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
