import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_state.dart';
import 'package:weblibre/features/geckoview/features/contextmenu/extensions/hit_result.dart';

class CopyImage extends HookConsumerWidget {
  final HitResult hitResult;

  const CopyImage({super.key, required this.hitResult});

  static bool isSupported(HitResult hitResult) {
    return hitResult.isImage();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: const Icon(MdiIcons.imageMultiple),
      title: const Text('Copy image'),
      onTap: () async {
        final currentTab = ref.read(selectedTabStateProvider);
        final url = hitResult.tryGetLink();

        if (currentTab != null && url != null) {
          await GeckoDownloadsService().copyInternetResource(
            currentTab.id,
            url: url,
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
