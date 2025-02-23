import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lensai/features/geckoview/domain/providers/selected_tab.dart';
import 'package:lensai/features/geckoview/domain/repositories/tab.dart';
import 'package:lensai/features/geckoview/features/contextmenu/extensions/hit_result.dart';

class OpenImageInNewTab extends HookConsumerWidget {
  final HitResult hitResult;

  const OpenImageInNewTab({super.key, required this.hitResult});

  static bool isSupported(HitResult hitResult) {
    return hitResult.isImage();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: const Icon(MdiIcons.tabPlus),
      title: const Text('Open image in new tab'),
      onTap: () async {
        final currentTabId = ref.read(selectedTabProvider);
        await ref
            .read(tabRepositoryProvider.notifier)
            .addTab(url: hitResult.tryGetLink(), parentId: currentTabId);
      },
    );
  }
}
