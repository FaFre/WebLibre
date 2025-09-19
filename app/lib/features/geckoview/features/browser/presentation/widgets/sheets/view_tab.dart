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

import 'package:fading_scroll/fading_scroll.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/features/bangs/domain/providers/bangs.dart';
import 'package:weblibre/features/bangs/presentation/widgets/site_search.dart';
import 'package:weblibre/features/geckoview/domain/controllers/bottom_sheet.dart';
import 'package:weblibre/features/geckoview/domain/entities/states/tab.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_session.dart';
import 'package:weblibre/features/geckoview/domain/repositories/tab.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/dialogs/qr_code.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/certificate_tile.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/draggable_scrollable_header.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/providers.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/repositories/container.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/repositories/tab.dart';
import 'package:weblibre/presentation/widgets/share_tile.dart';
import 'package:weblibre/presentation/widgets/website_feed_tile.dart';
import 'package:weblibre/presentation/widgets/website_title_tile.dart';
import 'package:weblibre/utils/ui_helper.dart' as ui_helper;

class ClampingScrollPhysicsWithoutImplicit extends ClampingScrollPhysics {
  const ClampingScrollPhysicsWithoutImplicit({super.parent});

  @override
  ClampingScrollPhysicsWithoutImplicit applyTo(ScrollPhysics? ancestor) {
    return ClampingScrollPhysicsWithoutImplicit(parent: buildParent(ancestor));
  }

  @override
  bool get allowImplicitScrolling => false;
}

class ViewTabSheetWidget extends HookConsumerWidget {
  final TabState initialTabState;
  final ScrollController sheetScrollController;
  final DraggableScrollableController draggableScrollableController;
  final VoidCallback onClose;
  final double initialHeight;

  const ViewTabSheetWidget({
    required this.initialTabState,
    required this.sheetScrollController,
    required this.draggableScrollableController,
    required this.onClose,
    required this.initialHeight,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final headerKey = useMemoized(() => GlobalKey());
    final textFieldKey = useMemoized(() => GlobalKey());

    final availableBangs = ref.watch(
      bangListProvider(
        domain: initialTabState.url.host,
        orderMostFrequentFirst: true,
      ).select((value) => value.value ?? const []),
    );

    final scrolledTo = useRef(0.0);
    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!context.mounted) return;

        final header = headerKey.currentContext?.findRenderObject();
        final text = textFieldKey.currentContext?.findRenderObject();

        if (header case final RenderBox headerBox) {
          if (text case final RenderBox textBox) {
            final totalHeight =
                headerBox.size.height + textBox.size.height + kToolbarHeight;

            final relative = (totalHeight / MediaQuery.of(context).size.height)
                .clamp(0.0, 1.0);

            if (draggableScrollableController.size < relative &&
                relative > scrolledTo.value) {
              await draggableScrollableController.animateTo(
                relative,
                duration: const Duration(milliseconds: 150),
                curve: Curves.easeInOut,
              );
              scrolledTo.value = relative;
            }
          }
        }
      });

      return null;
    });

    final bottomInsets = useRef(0.0);
    useEffect(
      () {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final diff =
              ((MediaQuery.of(context).viewInsets.bottom / 2) /
                  MediaQuery.of(context).size.height) -
              bottomInsets.value;

          final jumpValue = (draggableScrollableController.size + diff).clamp(
            0.0,
            1.0,
          );

          draggableScrollableController.jumpTo(jumpValue);

          bottomInsets.value += diff;
        });

        return null;
      },
      [
        MediaQuery.of(context).viewInsets.bottom,
        MediaQuery.of(context).size.height,
      ],
    );

    return NestedScrollView(
      physics: const NeverScrollableScrollPhysics(),
      headerSliverBuilder: (context, innerBoxIsScrolled) => [
        SliverToBoxAdapter(
          child: DraggableScrollableHeader(
            key: headerKey,
            controller: draggableScrollableController,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 0.0),
                  child: GestureDetector(
                    onTap: () async {
                      if (draggableScrollableController.size > 0.85) {
                        await draggableScrollableController.animateTo(
                          (scrolledTo.value > 0.0)
                              ? scrolledTo.value
                              : initialHeight,
                          duration: const Duration(milliseconds: 150),
                          curve: Curves.easeInOut,
                        );
                      } else {
                        await draggableScrollableController.animateTo(
                          1.0,
                          duration: const Duration(milliseconds: 150),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    child: WebsiteTitleTile(initialTabState),
                  ),
                ),
                CertificateTile(),
                const Divider(),
              ],
            ),
          ),
        ),
      ],
      body: FadingScroll(
        fadingSize: 15,
        controller: sheetScrollController,
        builder: (context, controller) {
          return ListView(
            controller: controller,
            physics: const ClampingScrollPhysicsWithoutImplicit(),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: SiteSearch(
                  key: textFieldKey,
                  domain: initialTabState.url.host,
                  availableBangs: availableBangs,
                  initialText: initialTabState.url.toString(),
                  label: const Text('Address'),
                ),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(MdiIcons.contentCopy),
                title: const Text('Copy address'),
                onTap: () async {
                  await Clipboard.setData(
                    ClipboardData(text: initialTabState.url.toString()),
                  );

                  ref.read(bottomSheetControllerProvider.notifier).dismiss();
                },
              ),
              ListTile(
                onTap: () async {
                  await ui_helper.launchUrlFeedback(
                    context,
                    initialTabState.url,
                  );
                },
                leading: const Icon(Icons.open_in_browser),
                title: const Text('Launch External'),
              ),
              ListTile(
                leading: const Icon(MdiIcons.tabPlus),
                title: const Text('Clone tab'),
                onTap: () async {
                  final tabId = await ref
                      .read(tabRepositoryProvider.notifier)
                      .addTab(url: initialTabState.url, private: false);

                  if (context.mounted) {
                    //save reference before pop `ref` gets disposed
                    final repo = ref.read(tabRepositoryProvider.notifier);

                    ui_helper.showTabSwitchMessage(
                      context,
                      onSwitch: () async {
                        await repo.selectTab(tabId);
                      },
                    );

                    ref.read(bottomSheetControllerProvider.notifier).dismiss();
                  }
                },
              ),
              ListTile(
                leading: const Icon(MdiIcons.tabUnselected),
                title: const Text('Clone as private tab'),
                onTap: () async {
                  final tabId = await ref
                      .read(tabRepositoryProvider.notifier)
                      .addTab(url: initialTabState.url, private: true);

                  if (context.mounted) {
                    //save reference before pop `ref` gets disposed
                    final repo = ref.read(tabRepositoryProvider.notifier);

                    ui_helper.showTabSwitchMessage(
                      context,
                      onSwitch: () async {
                        await repo.selectTab(tabId);
                      },
                    );

                    ref.read(bottomSheetControllerProvider.notifier).dismiss();
                  }
                },
              ),
              ListTile(
                leading: const Icon(MdiIcons.folderArrowUpDownOutline),
                title: const Text('Assign container'),
                onTap: () async {
                  final targetContainerId = await ContainerSelectionRoute()
                      .push<String?>(context);

                  if (targetContainerId != null) {
                    final containerData = await ref
                        .read(containerRepositoryProvider.notifier)
                        .getContainerData(targetContainerId);

                    if (containerData != null) {
                      await ref
                          .read(tabDataRepositoryProvider.notifier)
                          .assignContainer(initialTabState.id, containerData);
                    }
                  }

                  ref.read(bottomSheetControllerProvider.notifier).dismiss();
                },
              ),
              Consumer(
                child: ListTile(
                  leading: const Icon(MdiIcons.folderCancelOutline),
                  title: const Text('Unassign container'),
                  onTap: () async {
                    await ref
                        .read(tabDataRepositoryProvider.notifier)
                        .unassignContainer(initialTabState.id);

                    ref.read(bottomSheetControllerProvider.notifier).dismiss();
                  },
                ),
                builder: (context, ref, child) {
                  final containerId = ref.watch(
                    watchContainerTabIdProvider(
                      initialTabState.id,
                    ).select((value) => value.value),
                  );

                  return Visibility(
                    visible: containerId != null,
                    child: child!,
                  );
                },
              ),
              ShareTile(
                onTap: () async {
                  await SharePlus.instance.share(
                    ShareParams(uri: initialTabState.url),
                  );

                  ref.read(bottomSheetControllerProvider.notifier).dismiss();
                },
                onTapQr: () async {
                  await showQrCode(context, initialTabState.url.toString());
                },
              ),
              ListTile(
                leading: const Icon(Icons.mobile_screen_share),
                title: const Text('Share screenshot'),
                onTap: () async {
                  final screenshot = await ref
                      .read(selectedTabSessionProvider)
                      .requestScreenshot();

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
                          ShareParams(
                            files: [file],
                            subject: initialTabState.title,
                          ),
                        );
                      }
                    });
                  }

                  ref.read(bottomSheetControllerProvider.notifier).dismiss();
                },
              ),
              WebsiteFeedTile(initialTabState),
            ],
          );
        },
      ),
    );
  }
}
