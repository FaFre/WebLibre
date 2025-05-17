import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lensai/features/geckoview/features/contextmenu/extensions/hit_result.dart';
import 'package:nullability/nullability.dart';

class CopyLink extends HookConsumerWidget {
  final HitResult hitResult;

  const CopyLink({super.key, required this.hitResult});

  static bool isSupported(HitResult hitResult) {
    return hitResult.isUri() || hitResult.isImage() || hitResult.isVideoAudio();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: const Icon(MdiIcons.contentCopy),
      title: const Text('Copy link'),
      onTap: () async {
        await hitResult.tryGetLink().mapNotNull((link) async {
          await Clipboard.setData(ClipboardData(text: link.toString()));

          if (context.mounted) {
            context.pop();
          }
        });
      },
    );
  }
}
