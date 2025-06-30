import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nullability/nullability.dart';
import 'package:share_plus/share_plus.dart';
import 'package:weblibre/features/geckoview/features/contextmenu/extensions/hit_result.dart';

class ShareEmail extends HookConsumerWidget {
  final HitResult hitResult;

  const ShareEmail({super.key, required this.hitResult});

  static bool isSupported(HitResult hitResult) {
    return hitResult.isMailto();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: const Icon(MdiIcons.emailArrowRight),
      title: const Text('Share email address'),
      onTap: () async {
        final email = hitResult.tryGetLink().mapNotNull((url) => url.path);
        if (email != null) {
          await SharePlus.instance.share(ShareParams(text: email));

          if (context.mounted) {
            context.pop();
          }
        }
      },
    );
  }
}
