import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/features/geckoview/domain/controllers/overlay.dart';
import 'package:weblibre/features/tor/domain/services/tor_proxy.dart';
import 'package:weblibre/presentation/icons/tor_icons.dart';
import 'package:weblibre/presentation/widgets/animate_gradient_shader.dart';

class TorNotification extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(torProxyServiceProvider, (previous, next) {
      if (!next.isLoading) {
        ref.read(overlayControllerProvider.notifier).dismiss();
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
                    ref.read(overlayControllerProvider.notifier).dismiss();
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
