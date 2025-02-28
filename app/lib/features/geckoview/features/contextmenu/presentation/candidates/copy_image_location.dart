import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lensai/extensions/nullable.dart';
import 'package:lensai/features/geckoview/features/contextmenu/extensions/hit_result.dart';

class CopyImageLocation extends HookConsumerWidget {
  final HitResult hitResult;

  const CopyImageLocation({super.key, required this.hitResult});

  static bool isSupported(HitResult hitResult) {
    return hitResult.isImage();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: const Icon(MdiIcons.imageMarker),
      title: const Text('Copy image location'),
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
