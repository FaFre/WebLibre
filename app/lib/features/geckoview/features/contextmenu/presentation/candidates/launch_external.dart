import 'package:flutter/material.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lensai/features/geckoview/features/contextmenu/extensions/hit_result.dart';
import 'package:lensai/utils/ui_helper.dart';
import 'package:nullability/nullability.dart';
import 'package:url_launcher/url_launcher.dart';

class LaunchExternal extends HookConsumerWidget {
  final HitResult hitResult;

  const LaunchExternal({super.key, required this.hitResult});

  static Future<bool> isSupported(HitResult hitResult) async {
    return hitResult.tryGetLink().mapNotNull((url) => canLaunchUrl(url)) ??
        false;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: const Icon(Icons.open_in_browser),
      title: const Text('Launch External'),
      onTap: () async {
        await hitResult.tryGetLink().mapNotNull((url) async {
          await launchUrlFeedback(context, url);

          if (context.mounted) {
            context.pop();
          }
        });
      },
    );
  }
}
