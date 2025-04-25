import 'package:flutter/material.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lensai/extensions/nullable.dart';
import 'package:lensai/features/geckoview/features/contextmenu/extensions/hit_result.dart';
import 'package:share_plus/share_plus.dart';

class ShareLink extends HookConsumerWidget {
  final HitResult hitResult;

  const ShareLink({super.key, required this.hitResult});

  static bool isSupported(HitResult hitResult) {
    return hitResult.isUri() || hitResult.isImage() || hitResult.isVideoAudio();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: const Icon(Icons.share),
      title: const Text('Share link'),
      onTap: () async {
        await hitResult.tryGetLink().mapNotNull(
          (url) => SharePlus.instance.share(ShareParams(uri: url)),
        );

        if (context.mounted) {
          context.pop();
        }
      },
    );
  }
}
