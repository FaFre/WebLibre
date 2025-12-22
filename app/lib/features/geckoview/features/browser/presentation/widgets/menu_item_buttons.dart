import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_session.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_state.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/dialogs/qr_code.dart';
import 'package:weblibre/utils/ui_helper.dart' as ui_helper;

class ShareMenuItemButton extends HookConsumerWidget {
  const ShareMenuItemButton({super.key, required this.selectedTabId});

  final String? selectedTabId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MenuItemButton(
      leadingIcon: const Icon(Icons.share),
      closeOnActivate: false,
      onPressed: () async {
        final tabState = ref.read(tabStateProvider(selectedTabId))!;

        await SharePlus.instance.share(ShareParams(uri: tabState.url));

        if (context.mounted) {
          MenuController.maybeOf(context)?.close();
        }
      },
      child: const Text('Share Link'),
    );
  }
}

class ShowQrCodeMenuItemButton extends HookConsumerWidget {
  const ShowQrCodeMenuItemButton({super.key, required this.selectedTabId});

  final String? selectedTabId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MenuItemButton(
      leadingIcon: const Icon(Icons.qr_code),
      closeOnActivate: false,
      onPressed: () async {
        final tabState = ref.read(tabStateProvider(selectedTabId))!;

        await showQrCode(context, tabState.url.toString());

        if (context.mounted) {
          MenuController.maybeOf(context)?.close();
        }
      },
      child: const Text('Show QR Code'),
    );
  }
}

class ShareScreenshotMenuItemButton extends HookConsumerWidget {
  const ShareScreenshotMenuItemButton({super.key, required this.selectedTabId});

  final String? selectedTabId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MenuItemButton(
      leadingIcon: const Icon(Icons.mobile_screen_share),
      closeOnActivate: false,
      child: const Text('Share Screenshot'),
      onPressed: () async {
        final screenshot = await ref
            .read(selectedTabSessionProvider)
            .requestScreenshot();

        final tabState = ref.read(tabStateProvider(selectedTabId))!;

        if (screenshot != null) {
          ui.decodeImageFromList(screenshot, (result) async {
            final png = await result.toByteData(format: ui.ImageByteFormat.png);

            if (png != null) {
              final file = XFile.fromData(
                png.buffer.asUint8List(),
                mimeType: 'image/png',
              );

              await SharePlus.instance.share(
                ShareParams(files: [file], subject: tabState.titleOrAuthority),
              );
            }
          });
        }

        if (context.mounted) {
          MenuController.maybeOf(context)?.close();
        }
      },
    );
  }
}

class LaunchExternalMenuItemButton extends HookConsumerWidget {
  const LaunchExternalMenuItemButton({super.key, required this.selectedTabId});

  final String? selectedTabId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MenuItemButton(
      leadingIcon: const Icon(Icons.open_in_browser),
      closeOnActivate: false,
      child: const Text('Launch External'),
      onPressed: () async {
        final tabState = ref.read(tabStateProvider(selectedTabId))!;

        await ui_helper.launchUrlFeedback(context, tabState.url);

        if (context.mounted) {
          MenuController.maybeOf(context)?.close();
        }
      },
    );
  }
}

class CopyAddressMenuItemButton extends HookConsumerWidget {
  const CopyAddressMenuItemButton({super.key, required this.selectedTabId});

  final String? selectedTabId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MenuItemButton(
      leadingIcon: const Icon(MdiIcons.contentCopy),
      closeOnActivate: false,
      child: const Text('Copy Address'),
      onPressed: () async {
        final tabState = ref.read(tabStateProvider(selectedTabId))!;

        await Clipboard.setData(ClipboardData(text: tabState.url.toString()));

        if (context.mounted) {
          MenuController.maybeOf(context)?.close();
        }
      },
    );
  }
}
