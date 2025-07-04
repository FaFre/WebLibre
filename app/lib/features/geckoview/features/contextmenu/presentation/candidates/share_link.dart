import 'package:flutter/material.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nullability/nullability.dart';
import 'package:share_plus/share_plus.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/dialogs/qr_code.dart';
import 'package:weblibre/features/geckoview/features/contextmenu/extensions/hit_result.dart';
import 'package:weblibre/presentation/widgets/share_tile.dart';

class ShareLink extends HookConsumerWidget {
  final HitResult hitResult;

  const ShareLink({super.key, required this.hitResult});

  static bool isSupported(HitResult hitResult) {
    return hitResult.isUri() || hitResult.isImage() || hitResult.isVideoAudio();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final link = hitResult.tryGetLink();

    return ShareTile(
      onTap: () async {
        await link.mapNotNull(
          (url) => SharePlus.instance.share(ShareParams(uri: url)),
        );

        if (context.mounted) {
          context.pop();
        }
      },
      onTapQr: link.mapNotNull(
        (url) => () async {
          await showQrCode(context, url.toString());
        },
      ),
    );
  }
}
