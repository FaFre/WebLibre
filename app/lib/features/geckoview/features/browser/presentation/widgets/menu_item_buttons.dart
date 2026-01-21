/*
 * Copyright (c) 2024-2025 Fabian Freund.
 *
 * This file is part of WebLibre
 * (see https://weblibre.eu).
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nullability/nullability.dart';
import 'package:share_plus/share_plus.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_session.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_state.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/dialogs/content_selection_dialog.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/dialogs/qr_code.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/database/definitions.drift.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/repositories/tab.dart';
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

class SaveToPdfMenuItemButton extends HookConsumerWidget {
  const SaveToPdfMenuItemButton({super.key, required this.selectedTabId});

  final String? selectedTabId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MenuItemButton(
      leadingIcon: const Icon(MdiIcons.filePdfBox),
      closeOnActivate: false,
      onPressed: () async {
        await ref
            .read(tabSessionProvider(tabId: selectedTabId).notifier)
            .saveToPdf();

        if (context.mounted) {
          MenuController.maybeOf(context)?.close();
        }
      },
      child: const Text('Export as PDF'),
    );
  }
}

class ShareMarkdownActionMenuItemButton extends HookConsumerWidget {
  const ShareMarkdownActionMenuItemButton({
    super.key,
    required this.selectedTabId,
    required this.icon,
    required this.title,
    required this.shareMarkdownAction,
  });

  final String selectedTabId;
  final Widget icon;
  final Widget title;
  final Future<void> Function(String content, String? fileName)
  shareMarkdownAction;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MenuItemButton(
      leadingIcon: icon,
      closeOnActivate: false,
      onPressed: () => _handleShare(context, ref),
      child: title,
    );
  }

  Future<void> _handleShare(BuildContext context, WidgetRef ref) async {
    final tabData = await ref
        .read(tabDataRepositoryProvider.notifier)
        .getTabDataById(selectedTabId);

    if (tabData == null || tabData.fullContentMarkdown.isEmpty) {
      if (context.mounted) {
        MenuController.maybeOf(context)?.close();
      }
      return;
    }

    final shouldShowDialog =
        tabData.isProbablyReaderable == true &&
        tabData.extractedContentMarkdown.isNotEmpty;

    if (shouldShowDialog && context.mounted) {
      await _showContentSelectionDialog(context, tabData);
    } else {
      await shareMarkdownAction(
        tabData.fullContentMarkdown!,
        tabData.title ?? tabData.url?.authority,
      );
    }

    if (context.mounted) {
      MenuController.maybeOf(context)?.close();
    }
  }

  Future<void> _showContentSelectionDialog(
    BuildContext context,
    TabData tabData,
  ) async {
    await showContentSelectionDialog(
      context,
      title: title,
      tabData: tabData,
      shareMarkdownAction: shareMarkdownAction,
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
            try {
              final png = await result.toByteData(
                format: ui.ImageByteFormat.png,
              );

              if (png != null) {
                final file = XFile.fromData(
                  png.buffer.asUint8List(),
                  mimeType: 'image/png',
                );

                await SharePlus.instance.share(
                  ShareParams(
                    files: [file],
                    subject: tabState.titleOrAuthority,
                  ),
                );
              }
            } finally {
              result.dispose();
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
