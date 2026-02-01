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
import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nullability/nullability.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/features/geckoview/domain/controllers/bottom_sheet.dart';
import 'package:weblibre/features/geckoview/domain/providers/desktop_mode.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_session.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_state.dart';
import 'package:weblibre/features/geckoview/domain/repositories/tab.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/menu_item_buttons.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/navigation_buttons.dart';
import 'package:weblibre/features/geckoview/features/find_in_page/presentation/controllers/find_in_page.dart';
import 'package:weblibre/features/geckoview/features/readerview/presentation/controllers/readerable.dart';
import 'package:weblibre/features/geckoview/features/readerview/presentation/widgets/reader_button.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/models/container_data.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/providers.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/repositories/container.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/repositories/tab.dart';
import 'package:weblibre/presentation/hooks/menu_controller.dart';
import 'package:weblibre/presentation/widgets/website_feed_menu_button.dart';
import 'package:weblibre/utils/ui_helper.dart' as ui_helper;

class TabMenu extends HookConsumerWidget {
  final MenuAnchorChildBuilder builder;
  final MenuController? controller;
  final String selectedTabId;
  final bool enableFindInPage;
  final bool enableReaderMode;
  final bool enableDesktopMode;
  final bool enableFetchFeeds;
  final bool enableAddBookmark;
  final bool enableCloneTab;
  final bool enableContainer;
  final bool enableShare;
  final bool enableExport;
  final bool enableCloseTab;

  const TabMenu({
    super.key,
    required this.builder,
    required this.selectedTabId,
    this.controller,
    this.enableFindInPage = true,
    this.enableReaderMode = true,
    this.enableDesktopMode = true,
    this.enableFetchFeeds = true,
    this.enableAddBookmark = true,
    this.enableCloneTab = true,
    this.enableContainer = true,
    this.enableShare = true,
    this.enableExport = true,
    this.enableCloseTab = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showFeeds = useState(false);

    final controller = this.controller ?? useMenuController();

    return MenuAnchor(
      controller: controller,
      onClose: () {
        showFeeds.value = false;
      },
      builder: builder,
      menuChildren: [
        if (enableFindInPage)
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
        if (enableReaderMode)
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
        if (enableDesktopMode)
          Consumer(
            builder: (context, childRef, child) {
              final enabled = childRef.watch(
                desktopModeProvider(selectedTabId),
              );

              return MenuItemButton(
                onPressed: () {
                  ref
                      .read(desktopModeProvider(selectedTabId).notifier)
                      .toggle();
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
        if (enableFindInPage || enableReaderMode || enableDesktopMode)
          const Divider(),
        if (enableFetchFeeds)
          Visibility(
            visible: showFeeds.value,
            replacement: MenuItemButton(
              closeOnActivate: false,
              leadingIcon: const Icon(Icons.rss_feed),
              child: const Text('Fetch Feeds'),
              onPressed: () {
                showFeeds.value = true;
              },
            ),
            child: WebsiteFeedMenuButton(selectedTabId),
          ),
        if (enableAddBookmark)
          MenuItemButton(
            leadingIcon: const Icon(MdiIcons.bookmarkPlus),
            child: const Text('Add Bookmark'),
            onPressed: () async {
              final tabState = ref.read(tabStateProvider(selectedTabId))!;

              await BookmarkEntryAddRoute(
                bookmarkInfo: jsonEncode(
                  BookmarkInfo(
                    title: tabState.titleOrAuthority,
                    url: tabState.url.toString(),
                  ).encode(),
                ),
              ).push(context);
            },
          ),
        if (enableCloneTab)
          SubmenuButton(
            menuChildren: [
              MenuItemButton(
                leadingIcon: const Icon(MdiIcons.tab),
                child: const Text('Regular'),
                onPressed: () async {
                  final tabState = ref.read(tabStateProvider(selectedTabId))!;
                  final containerData = await ref
                      .read(tabDataRepositoryProvider.notifier)
                      .getTabContainerData(selectedTabId);

                  final tabId = (tabState.isPrivate)
                      ? await ref
                            .read(tabRepositoryProvider.notifier)
                            .addTab(
                              url: tabState.url,
                              private: false,
                              container: Value(containerData),
                              selectTab: false,
                            )
                      : await ref
                            .read(tabRepositoryProvider.notifier)
                            .duplicateTab(
                              selectTabId: selectedTabId,
                              containerData: containerData,
                              selectTab: false,
                            );

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
                child: const Text('Private'),
                onPressed: () async {
                  final tabState = ref.read(tabStateProvider(selectedTabId))!;
                  final containerData = await ref
                      .read(tabDataRepositoryProvider.notifier)
                      .getTabContainerData(selectedTabId);

                  final tabId = (!tabState.isPrivate)
                      ? await ref
                            .read(tabRepositoryProvider.notifier)
                            .addTab(
                              url: tabState.url,
                              private: true,
                              container: Value(containerData),
                              selectTab: false,
                            )
                      : await ref
                            .read(tabRepositoryProvider.notifier)
                            .duplicateTab(
                              selectTabId: selectedTabId,
                              containerData: containerData,
                              selectTab: false,
                            );

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
            ],
            leadingIcon: const Icon(MdiIcons.tabPlus),
            child: const Text('Clone Tab'),
          ),
        if (enableContainer)
          SubmenuButton(
            menuChildren: [
              MenuItemButton(
                leadingIcon: const Icon(MdiIcons.folderArrowUpDownOutline),
                child: const Text('Assign Container'),
                onPressed: () async {
                  final targetContainerId =
                      await const ContainerSelectionRoute().push<String?>(
                        context,
                      );

                  if (targetContainerId != null) {
                    final containerData = await ref
                        .read(containerRepositoryProvider.notifier)
                        .getContainerData(targetContainerId);

                    if (containerData != null) {
                      final tabState = ref.read(
                        tabStateProvider(selectedTabId),
                      )!;

                      await ref
                          .read(tabDataRepositoryProvider.notifier)
                          .assignContainer(tabState.id, containerData);
                    }
                  }
                },
              ),
              Consumer(
                child: MenuItemButton(
                  leadingIcon: const Icon(MdiIcons.webPlus),
                  child: const Text('URL relation'),
                  onPressed: () async {
                    final targetContainerId =
                        await const ContainerSelectionRoute().push<String?>(
                          context,
                        );

                    if (targetContainerId != null) {
                      final containerData = await ref
                          .read(containerRepositoryProvider.notifier)
                          .getContainerData(targetContainerId);

                      if (containerData != null) {
                        final tabState = ref.read(
                          tabStateProvider(selectedTabId),
                        );
                        final origin = tabState?.url.origin.mapNotNull(
                          Uri.parse,
                        );

                        if (origin != null) {
                          await ref
                              .read(containerRepositoryProvider.notifier)
                              .replaceContainer(
                                containerData.copyWith.metadata(
                                  containerData.metadata.copyWith.assignedSites(
                                    [
                                      ...?containerData.metadata.assignedSites,
                                      origin,
                                    ],
                                  ),
                                ),
                              );
                        }
                      }
                    }
                  },
                ),
                builder: (context, ref, child) {
                  final isSiteAssigned = ref.watch(
                    watchIsCurrentSiteAssignedToContainerProvider,
                  );

                  return Visibility(
                    visible:
                        isSiteAssigned.hasValue && !isSiteAssigned.requireValue,
                    child: child!,
                  );
                },
              ),
              Consumer(
                child: MenuItemButton(
                  leadingIcon: const Icon(MdiIcons.folderCancelOutline),
                  child: const Text('Unassign Container'),
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

                  return Visibility(
                    visible: containerId != null,
                    child: child!,
                  );
                },
              ),
            ],
            leadingIcon: const Icon(MdiIcons.folder),
            child: const Text('Container'),
          ),
        if (enableShare)
          SubmenuButton(
            menuChildren: [
              CopyAddressMenuItemButton(selectedTabId: selectedTabId),
              OpenInAppMenuItemButton(selectedTabId: selectedTabId),
              ShareScreenshotMenuItemButton(selectedTabId: selectedTabId),
              ShareMenuItemButton(selectedTabId: selectedTabId),
              ShowQrCodeMenuItemButton(selectedTabId: selectedTabId),
            ],
            leadingIcon: const Icon(Icons.share),
            child: const Text('Share'),
          ),
        if (enableExport)
          SubmenuButton(
            menuChildren: [
              ShareMarkdownActionMenuItemButton(
                selectedTabId: selectedTabId,
                title: const Text('Copy as Markdown'),
                // ignore: deprecated_member_use
                icon: const Icon(MdiIcons.languageMarkdownOutline),
                shareMarkdownAction: (content, fileName) async {
                  await Clipboard.setData(ClipboardData(text: content));

                  if (context.mounted) {
                    ui_helper.showInfoMessage(
                      context,
                      'Markdown copied to clipboard',
                    );
                  }
                },
              ),
              ShareMarkdownActionMenuItemButton(
                selectedTabId: selectedTabId,
                title: const Text('Export as Markdown'),
                // ignore: deprecated_member_use
                icon: const Icon(MdiIcons.languageMarkdown),
                shareMarkdownAction: (content, fileName) async {
                  await FilePicker.platform.saveFile(
                    fileName: fileName,
                    type: FileType.custom,
                    allowedExtensions: ['md'],
                    bytes: utf8.encode(content),
                  );
                },
              ),
              SaveToPdfMenuItemButton(selectedTabId: selectedTabId),
            ],
            leadingIcon: const Icon(MdiIcons.fileExport),
            child: const Text('Export'),
          ),
        if (enableCloseTab)
          MenuItemButton(
            onPressed: () async {
              await ref
                  .read(tabRepositoryProvider.notifier)
                  .closeTab(selectedTabId);

              if (context.mounted) {
                ui_helper.showTabUndoClose(
                  context,
                  ref.read(tabRepositoryProvider.notifier).undoClose,
                );
              }
            },
            leadingIcon: const Icon(MdiIcons.tabMinus),
            child: const Text('Close Tab'),
          ),
        const Divider(),
        MenuItemButton(
          onPressed: () async {
            final sessionController = ref.read(
              tabSessionProvider(tabId: selectedTabId).notifier,
            );

            await sessionController.reload();
            controller.close();
          },
          leadingIcon: const Icon(Icons.refresh),
          child: const Text('Reload'),
        ),
        Consumer(
          builder: (context, ref, child) {
            final history = ref.watch(
              tabStateProvider(
                selectedTabId,
              ).select((value) => value?.historyState),
            );

            final isLoading = ref.watch(
              selectedTabStateProvider.select(
                (state) => state?.isLoading ?? false,
              ),
            );

            return Row(
              children: [
                Expanded(
                  child: NavigateBackButton(
                    selectedTabId: selectedTabId,
                    isLoading: isLoading,
                    menuControllerToClose: controller,
                    canGoBack: history?.canGoBack == true,
                  ),
                ),
                const SizedBox(height: 48, child: VerticalDivider()),
                Expanded(
                  child: NavigateForwardButton(
                    selectedTabId: selectedTabId,
                    menuControllerToClose: controller,
                    canGoForward: history?.canGoForward == true,
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
