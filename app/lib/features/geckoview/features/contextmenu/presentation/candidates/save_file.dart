import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lensai/features/geckoview/domain/providers/tab_state.dart';
import 'package:lensai/features/geckoview/features/contextmenu/extensions/hit_result.dart';

class SaveFile extends HookConsumerWidget {
  final HitResult hitResult;

  const SaveFile({super.key, required this.hitResult});

  static bool isSupported(HitResult hitResult) {
    return hitResult.isVideoAudio() || hitResult.isFile();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: const Icon(MdiIcons.fileDownload),
      title: const Text('Save file'),
      onTap: () async {
        final currentTab = ref.read(selectedTabStateProvider);
        final url = hitResult.tryGetLink();

        if (currentTab != null && url != null) {
          await GeckoDownloadsService().requestDownload(
            currentTab.id,
            url: url,
            skipConfirmation: true,
            isPrivate: currentTab.isPrivate,
            referrerUrl: currentTab.url,
          );

          if (context.mounted) {
            context.pop();
          }
        }
      },
    );
  }
}
