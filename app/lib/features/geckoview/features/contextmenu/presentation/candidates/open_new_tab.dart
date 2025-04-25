import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lensai/features/geckoview/domain/providers/tab_state.dart';
import 'package:lensai/features/geckoview/domain/repositories/tab.dart';
import 'package:lensai/features/geckoview/features/contextmenu/extensions/hit_result.dart';
import 'package:lensai/utils/ui_helper.dart';

class OpenInNewTab extends HookConsumerWidget {
  final HitResult hitResult;

  const OpenInNewTab({super.key, required this.hitResult});

  static bool isSupported(HitResult hitResult) {
    return hitResult.isHttpLink();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: const Icon(MdiIcons.tabPlus),
      title: const Text('Open in new tab'),
      onTap: () async {
        final currentTab = ref.read(selectedTabStateProvider);

        final tabId = await ref
            .read(tabRepositoryProvider.notifier)
            .addTab(
              url: hitResult.tryGetLink(),
              parentId: currentTab?.id,
              selectTab: false,
              private: currentTab?.isPrivate ?? false,
            );

        if (context.mounted) {
          //save reference before pop `ref` gets disposed
          final repo = ref.read(tabRepositoryProvider.notifier);

          showTabSwitchMessage(
            context,
            onSwitch: () {
              repo.selectTab(tabId);
            },
          );

          context.pop();
        }
      },
    );
  }
}
