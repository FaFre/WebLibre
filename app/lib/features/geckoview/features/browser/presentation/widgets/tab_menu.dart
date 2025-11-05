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
import 'package:share_plus/share_plus.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/features/geckoview/domain/controllers/bottom_sheet.dart';
import 'package:weblibre/features/geckoview/domain/providers/desktop_mode.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_session.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_state.dart';
import 'package:weblibre/features/geckoview/domain/repositories/tab.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/dialogs/qr_code.dart';
import 'package:weblibre/features/geckoview/features/find_in_page/presentation/controllers/find_in_page.dart';
import 'package:weblibre/features/geckoview/features/readerview/presentation/controllers/readerable.dart';
import 'package:weblibre/features/geckoview/features/readerview/presentation/widgets/reader_button.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/providers.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/repositories/container.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/repositories/tab.dart';
import 'package:weblibre/presentation/widgets/website_feed_menu_button.dart';
import 'package:weblibre/utils/ui_helper.dart' as ui_helper;

class TabMenu extends HookConsumerWidget {
  final Widget child;
  final MenuController controller;
  final String selectedTabId;

  const TabMenu({
    super.key,
    required this.child,
    required this.controller,
    required this.selectedTabId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MenuAnchor(
      controller: controller,
      builder: (context, controller, child) {
        return child!;
      },
      menuChildren: [
        MenuItemButton(
          onPressed: () {
            ref.read(bottomSheetControllerProvider.notifier).requestDismiss();

            ref
                .read(findInPageControllerProvider(selectedTabId).notifier)
                .show();
          },
          leadingIcon: const Icon(Icons.search),
          child: const Text('Find in page'),
        ),
        ReaderButton(
          buttonBuilder: (isLoading, readerActive, icon) => MenuItemButton(
            onPressed: isLoading
                ? null
                : () async {
                    await ref
                        .read(readerableScreenControllerProvider.notifier)
                        .toggleReaderView(!readerActive);
                  },
            leadingIcon: icon,
            trailingIcon: Checkbox(
              value: readerActive,
              onChanged: (value) async {
                if (value != null && !isLoading) {
                  await ref
                      .read(readerableScreenControllerProvider.notifier)
                      .toggleReaderView(!readerActive);
                  controller.close();
                }
              },
            ),
            child: const Text('Reader Mode'),
          ),
        ),
        Consumer(
          builder: (context, childRef, child) {
            final enabled = childRef.watch(desktopModeProvider(selectedTabId));

            return MenuItemButton(
              onPressed: () {
                ref.read(desktopModeProvider(selectedTabId).notifier).toggle();
              },
              leadingIcon: const Icon(MdiIcons.monitor),
              trailingIcon: Checkbox(
                value: enabled,
                onChanged: (value) {
                  if (value != null) {
                    ref
                        .read(desktopModeProvider(selectedTabId).notifier)
                        .enabled(value);
                    controller.close();
                  }
                },
              ),
              child: const Text('Desktop Mode'),
            );
          },
        ),
        const Divider(),
        MenuItemButton(
          leadingIcon: const Icon(MdiIcons.contentCopy),
          child: const Text('Copy address'),
          onPressed: () async {
            final tabState = ref.read(tabStateProvider(selectedTabId))!;

            await Clipboard.setData(
              ClipboardData(text: tabState.url.toString()),
            );
          },
        ),
        MenuItemButton(
          leadingIcon: const Icon(Icons.open_in_browser),
          child: const Text('Launch External'),
          onPressed: () async {
            final tabState = ref.read(tabStateProvider(selectedTabId))!;

            await ui_helper.launchUrlFeedback(context, tabState.url);
          },
        ),
        MenuItemButton(
          leadingIcon: const Icon(MdiIcons.tabPlus),
          child: const Text('Clone tab'),
          onPressed: () async {
            final tabState = ref.read(tabStateProvider(selectedTabId))!;

            final tabId = await ref
                .read(tabRepositoryProvider.notifier)
                .addTab(url: tabState.url, private: false, selectTab: false);

            if (context.mounted) {
              //save reference before pop `ref` gets disposed
              final repo = ref.read(tabRepositoryProvider.notifier);

              ui_helper.showTabSwitchMessage(
                context,
                onSwitch: () async {
                  await repo.selectTab(tabId);
                },
              );
            }
          },
        ),
        MenuItemButton(
          leadingIcon: const Icon(MdiIcons.tabUnselected),
          child: const Text('Clone as private tab'),
          onPressed: () async {
            final tabState = ref.read(tabStateProvider(selectedTabId))!;

            final tabId = await ref
                .read(tabRepositoryProvider.notifier)
                .addTab(url: tabState.url, private: true, selectTab: false);

            if (context.mounted) {
              //save reference before pop `ref` gets disposed
              final repo = ref.read(tabRepositoryProvider.notifier);

              ui_helper.showTabSwitchMessage(
                context,
                onSwitch: () async {
                  await repo.selectTab(tabId);
                },
              );
            }
          },
        ),
        MenuItemButton(
          leadingIcon: const Icon(MdiIcons.folderArrowUpDownOutline),
          child: const Text('Assign container'),
          onPressed: () async {
            final targetContainerId = await ContainerSelectionRoute()
                .push<String?>(context);

            if (targetContainerId != null) {
              final containerData = await ref
                  .read(containerRepositoryProvider.notifier)
                  .getContainerData(targetContainerId);

              if (containerData != null) {
                final tabState = ref.read(tabStateProvider(selectedTabId))!;

                await ref
                    .read(tabDataRepositoryProvider.notifier)
                    .assignContainer(tabState.id, containerData);
              }
            }
          },
        ),
        Consumer(
          child: MenuItemButton(
            leadingIcon: const Icon(MdiIcons.folderCancelOutline),
            child: const Text('Unassign container'),
            onPressed: () async {
              final tabState = ref.read(tabStateProvider(selectedTabId))!;

              await ref
                  .read(tabDataRepositoryProvider.notifier)
                  .unassignContainer(tabState.id);
            },
          ),
          builder: (context, ref, child) {
            final containerId = ref.watch(
              watchContainerTabIdProvider(
                selectedTabId,
              ).select((value) => value.value),
            );

            return Visibility(visible: containerId != null, child: child!);
          },
        ),
        MenuItemButton(
          leadingIcon: const Icon(Icons.share),
          onPressed: () async {
            final tabState = ref.read(tabStateProvider(selectedTabId))!;

            await SharePlus.instance.share(ShareParams(uri: tabState.url));
          },
          trailingIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const VerticalDivider(indent: 4, endIndent: 4),
              IconButton(
                icon: const Icon(Icons.qr_code),
                onPressed: () async {
                  final tabState = ref.read(tabStateProvider(selectedTabId))!;

                  await showQrCode(context, tabState.url.toString());
                  controller.close();
                },
              ),
            ],
          ),
          child: const Text('Share link'),
        ),
        MenuItemButton(
          leadingIcon: const Icon(Icons.mobile_screen_share),
          child: const Text('Share screenshot'),
          onPressed: () async {
            final screenshot = await ref
                .read(selectedTabSessionProvider)
                .requestScreenshot();

            final tabState = ref.read(tabStateProvider(selectedTabId))!;

            if (screenshot != null) {
              ui.decodeImageFromList(screenshot, (result) async {
                final png = await result.toByteData(
                  format: ui.ImageByteFormat.png,
                );

                if (png != null) {
                  final file = XFile.fromData(
                    png.buffer.asUint8List(),
                    mimeType: 'image/png',
                  );

                  await SharePlus.instance.share(
                    ShareParams(files: [file], subject: tabState.title),
                  );
                }
              });
            }
          },
        ),
        WebsiteFeedMenuButton(selectedTabId),
      ],
      child: child,
    );
  }
}
