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

import 'package:fading_scroll/fading_scroll.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/features/bangs/domain/providers/bangs.dart';
import 'package:weblibre/features/bangs/presentation/widgets/site_search.dart';
import 'package:weblibre/features/geckoview/domain/entities/states/tab.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/certificate_tile.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/draggable_scrollable_header.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/sheets/clear_site_data_section.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/sheets/permissions_section.dart';
import 'package:weblibre/presentation/widgets/website_title_tile.dart';

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
  final double bottomAppBarHeight;

  const ViewTabSheetWidget({
    required this.initialTabState,
    required this.sheetScrollController,
    required this.draggableScrollableController,
    required this.onClose,
    required this.initialHeight,
    required this.bottomAppBarHeight,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final headerKey = useMemoized(() => GlobalKey());
    final textFieldKey = useMemoized(() => GlobalKey());

    final scrolledTo = useRef(0.0);

    final searchTextController = useTextEditingController(
      text: initialTabState.url.toString(),
    );

    Future<void> scroll() async {
      if (!context.mounted) return;

      final header = headerKey.currentContext?.findRenderObject();
      final text = textFieldKey.currentContext?.findRenderObject();

      if (header case final RenderBox headerBox) {
        if (text case final RenderBox textBox) {
          final totalHeight =
              headerBox.size.height +
              textBox.size.height +
              bottomAppBarHeight +
              MediaQuery.of(context).viewInsets.bottom;

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
    }

    useOnListenableChange(searchTextController, () {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await scroll();
      });
    });

    final availableBangs = ref.watch(
      bangListProvider(
        domain: initialTabState.url.host,
        orderMostFrequentFirst: true,
      ).select((value) => value.value ?? const []),
    );

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await scroll();
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
                const CertificateTile(),
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
            padding: EdgeInsets.zero,
            controller: controller,
            physics: const ClampingScrollPhysicsWithoutImplicit(),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: SiteSearch(
                  key: textFieldKey,
                  domain: initialTabState.url.host,
                  availableBangs: availableBangs,
                  controller: searchTextController,
                ),
              ),
              const Divider(),
              // Permissions Section
              PermissionsSection(
                origin: initialTabState.url.origin,
                isPrivate: initialTabState.isPrivate,
              ),
              const Divider(),
              // Clear Site Data Section
              ClearSiteDataSection(
                url: initialTabState.url,
              ),
              const SizedBox(height: 16.0),
            ],
          );
        },
      ),
    );
  }
}
