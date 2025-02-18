import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lensai/features/geckoview/domain/controllers/overlay_dialog.dart';
import 'package:lensai/features/tor/domain/services/tor_proxy.dart';
import 'package:lensai/presentation/icons/tor_icons.dart';
import 'package:lensai/presentation/widgets/animate_gradient_shader.dart';

class TorNotification extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(torProxyServiceProvider, (previous, next) {
      if (!next.isLoading) {
        ref.read(overlayDialogControllerProvider.notifier).dismiss();
      }
    });

    return SafeArea(
      child: ColoredBox(
        color: const Color(0xFF7D4698),
        child: SizedBox(
          height: 56,
          width: MediaQuery.of(context).size.width,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                AnimateGradientShader(
                  duration: const Duration(milliseconds: 500),
                  primaryEnd: Alignment.bottomLeft,
                  secondaryEnd: Alignment.topRight,
                  primaryColors: const [Color(0xFF68B030), Color(0xFF68B030)],
                  secondaryColors: const [Colors.white, Colors.white],
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Icon(TorIcons.onionAlt),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Tor Proxy is connecting...',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.white),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    ref
                        .read(overlayDialogControllerProvider.notifier)
                        .dismiss();
                  },
                  icon: const Icon(Icons.close, color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
