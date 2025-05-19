import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/features/geckoview/domain/controllers/overlay.dart';
import 'package:weblibre/features/tor/domain/services/tor_proxy.dart';
import 'package:weblibre/features/tor/presentation/widgets/tor_dialog.dart';
import 'package:weblibre/features/tor/presentation/widgets/tor_notification.dart';

part 'start_tor_proxy.g.dart';

@Riverpod()
class StartProxyController extends _$StartProxyController {
  // ignore: document_ignores is used for dialog
  // ignore: avoid_build_context_in_providers
  Future<void> maybeStartProxy(BuildContext context) async {
    final torProxyRunning =
        await ref.read(torProxyServiceProvider.notifier).requestSync();

    if (torProxyRunning == null) {
      if (context.mounted) {
        final result = await showDialog<bool>(
          context: context,
          builder: (context) {
            return TorDialog();
          },
        );

        if (result == true) {
          final connection =
              ref.read(torProxyServiceProvider.notifier).connect();

          ref
              .read(overlayControllerProvider.notifier)
              .show(Positioned(top: 0, left: 0, child: TorNotification()));

          await connection;
        }
      }
    }
  }

  @override
  void build() {}
}
