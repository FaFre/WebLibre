/*
 * Copyright (c) 2024-2026 Fabian Freund.
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
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/features/geckoview/domain/controllers/bottom_sheet.dart';
import 'package:weblibre/features/geckoview/domain/entities/states/tab.dart';
import 'package:weblibre/features/geckoview/domain/providers/selected_tab.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_state.dart';
import 'package:weblibre/features/geckoview/domain/repositories/tab.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/tab_url_list_tile.dart';
import 'package:weblibre/features/geckoview/features/split_view/domain/entities/split_pair.dart';
import 'package:weblibre/features/geckoview/features/split_view/domain/providers/split_view.dart';
import 'package:weblibre/features/geckoview/features/split_view/presentation/utils/split_view_actions.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/providers.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';
import 'package:weblibre/presentation/widgets/browser_sheet_surface.dart';
import 'package:weblibre/presentation/widgets/pointer_scrollable_sheet.dart';
import 'package:weblibre/presentation/widgets/sheet_drag_handle.dart';

/// The split view controls, in the browser sheet layer: the two pages (tap
/// one to focus it, swap them between), the layout, "show only this page",
/// equal sizes, replace, end.
///
/// There is deliberately no close-page action here, so ending the layout is
/// never confused with closing a page.
class SplitViewControlsSheet extends HookConsumerWidget {
  static const initialHeight = 0.6;

  const SplitViewControlsSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final pair = ref.watch(splitPairShownProvider);
    final selectedTabId = ref.watch(selectedTabProvider);

    // Nothing to control once the pair is gone (a member closed meanwhile).
    useEffect(() {
      if (pair == null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          // The sheet may have been dismissed in the same frame by another
          // path, and its ref is gone with it.
          if (!context.mounted) return;
          ref.read(bottomSheetControllerProvider.notifier).requestDismiss();
        });
      }
      return null;
    }, [pair == null]);

    if (pair == null) {
      return const SizedBox.shrink();
    }

    final controller = ref.read(splitViewControllerProvider.notifier);
    final equalSizes = pair.sideBySideRatio == 0.5 && pair.stackedRatio == 0.5;

    void dismiss() {
      ref.read(bottomSheetControllerProvider.notifier).requestDismiss();
    }

    return PointerScrollableSheet(
      expand: false,
      initialChildSize: initialHeight,
      minChildSize: 0.1,
      builder: (context, scrollController) {
        return BrowserSheetSurface(
          child: ListTileTheme(
            contentPadding: const EdgeInsets.symmetric(horizontal: 24),
            child: ListView(
              controller: scrollController,
              padding: const EdgeInsets.only(bottom: 16),
              children: [
                const Center(child: SheetDragHandle()),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                  child: Text(
                    l10n.splitView_title,
                    style: theme.textTheme.headlineSmall,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _PagesCard(
                    firstTabId: pair.firstTabId,
                    secondTabId: pair.secondTabId,
                    selectedTabId: selectedTabId,
                    onSwap: controller.swap,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
                  child: Text(
                    l10n.splitView_layout,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                LayoutBuilder(
                  builder: (context, constraints) {
                    // Three equal segments with icon and label need about
                    // 480dp; on a phone the icons go and a label that still
                    // does not fit shrinks, so none wraps.
                    final compact = constraints.maxWidth < 480;
                    ButtonSegment<SplitLayoutPreference> segment(
                      SplitLayoutPreference value,
                      IconData icon,
                      String label,
                    ) => ButtonSegment(
                      value: value,
                      icon: compact ? null : Icon(icon),
                      label: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(label, maxLines: 1),
                      ),
                    );

                    return SegmentedButton<SplitLayoutPreference>(
                      expandedInsets: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                      showSelectedIcon: false,
                      segments: [
                        segment(
                          SplitLayoutPreference.automatic,
                          MdiIcons.autoFix,
                          l10n.splitView_layoutAutomatic,
                        ),
                        segment(
                          SplitLayoutPreference.sideBySide,
                          MdiIcons.viewSplitVertical,
                          l10n.splitView_layoutSideBySide,
                        ),
                        segment(
                          SplitLayoutPreference.stacked,
                          MdiIcons.viewSplitHorizontal,
                          l10n.splitView_layoutStacked,
                        ),
                      ],
                      selected: {pair.layout},
                      onSelectionChanged: (selection) {
                        controller.setLayout(selection.single);
                      },
                    );
                  },
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  secondary: const Icon(Icons.fullscreen),
                  title: Text(l10n.splitView_showOnlyThisPage),
                  value: pair.focusedOnly,
                  onChanged: controller.setFocusedOnly,
                ),
                ListTile(
                  leading: const Icon(MdiIcons.equal),
                  title: Text(l10n.splitView_equalSizes),
                  enabled: !equalSizes,
                  onTap: controller.equalize,
                ),
                ListTile(
                  leading: const Icon(MdiIcons.fileReplaceOutline),
                  title: Text(l10n.splitView_replaceOtherPage),
                  enabled:
                      selectedTabId != null && pair.contains(selectedTabId),
                  onTap: () async {
                    final source = selectedTabId;
                    if (source == null) return;
                    await showSplitPartnerPicker(
                      context,
                      ref.read,
                      sourceTabId: source,
                      pair: pair,
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(MdiIcons.closeBoxMultipleOutline),
                  title: Text(l10n.splitView_end),
                  subtitle: Text(l10n.splitView_endSubtitle),
                  onTap: () {
                    controller.end();
                    dismiss();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// The two pages as one outlined card, in pair order (left/top first), with
/// the swap button on the line between them. The focused page's row is
/// tinted; tapping the other one focuses it.
class _PagesCard extends StatelessWidget {
  final String firstTabId;
  final String secondTabId;
  final String? selectedTabId;
  final VoidCallback onSwap;

  const _PagesCard({
    required this.firstTabId,
    required this.secondTabId,
    required this.selectedTabId,
    required this.onSwap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      color: colorScheme.surfaceContainerLow,
      clipBehavior: Clip.antiAlias,
      child: _DividedPair(
        first: _PageRow(
          tabId: firstTabId,
          focused: selectedTabId == firstTabId,
        ),
        divider: Divider(height: 1, color: colorScheme.outlineVariant),
        second: _PageRow(
          tabId: secondTabId,
          focused: selectedTabId == secondTabId,
        ),
        button: IconButton.outlined(
          tooltip: l10n.splitView_swapSides,
          onPressed: onSwap,
          iconSize: 20,
          // A fixed square at standard density: compact density took 8dp off
          // the height only, which turned the round button into a pill
          // (36 x 32). The tap target stays 48dp.
          visualDensity: VisualDensity.standard,
          style: IconButton.styleFrom(
            fixedSize: const Size.square(36),
            padding: EdgeInsets.zero,
            backgroundColor: colorScheme.surfaceContainerHigh,
            side: BorderSide(color: colorScheme.outlineVariant),
          ),
          icon: const Icon(MdiIcons.swapVertical),
        ),
      ),
    );
  }
}

/// One page of the pair: the shared open-tab row ([TabUrlListTile]: favicon,
/// title, URL breadcrumb, container), tinted while focused.
class _PageRow extends ConsumerWidget {
  /// Holds the card's shape while a member's state is not known yet.
  static const _placeholderHeight = 64.0;

  final String tabId;
  final bool focused;

  const _PageRow({required this.tabId, required this.focused});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final TabState? tabState = ref.watch(tabStateProvider(tabId));
    final containerData = ref.watch(
      watchTabContainerDataProvider(tabId).select((value) => value.value),
    );

    return Semantics(
      selected: focused,
      child: Material(
        color: focused
            ? colorScheme.surfaceContainerHighest
            : Colors.transparent,
        child: tabState == null
            ? const SizedBox(height: _placeholderHeight)
            : TabUrlListTile(
                tabState: tabState,
                containerData: containerData,
                onTap: focused
                    ? null
                    : () => ref
                          .read(tabRepositoryProvider.notifier)
                          .selectTab(tabId),
              ),
      ),
    );
  }
}

/// [first], [divider] and [second] one under the other, each at its own
/// height, with [button] centered on [divider] and drawn above both rows.
///
/// A Stack cannot do this: it would center the button on the card, which is
/// on the divider only while both rows are equally tall, and they are not
/// (titles wrap, text scales).
class _DividedPair extends MultiChildRenderObjectWidget {
  _DividedPair({
    required Widget first,
    required Widget divider,
    required Widget second,
    required Widget button,
  }) : super(children: [first, divider, second, button]);

  @override
  RenderObject createRenderObject(BuildContext context) => _RenderDividedPair();
}

class _DividedPairParentData extends ContainerBoxParentData<RenderBox> {}

class _RenderDividedPair extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _DividedPairParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _DividedPairParentData> {
  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _DividedPairParentData) {
      child.parentData = _DividedPairParentData();
    }
  }

  @override
  void performLayout() {
    // first, divider, second, button: the order the widget passes them in.
    final [first, divider, second, button] = getChildrenAsList();
    final rowConstraints = BoxConstraints.tightFor(width: constraints.maxWidth);

    var top = 0.0;
    for (final row in [first, divider, second]) {
      row.layout(rowConstraints, parentUsesSize: true);
      (row.parentData! as _DividedPairParentData).offset = Offset(0, top);
      top += row.size.height;
    }

    button.layout(constraints.loosen(), parentUsesSize: true);
    final dividerCenter = first.size.height + divider.size.height / 2;
    (button.parentData! as _DividedPairParentData).offset = Offset(
      (constraints.maxWidth - button.size.width) / 2,
      dividerCenter - button.size.height / 2,
    );

    size = constraints.constrain(Size(constraints.maxWidth, top));
  }

  @override
  void paint(PaintingContext context, Offset offset) =>
      defaultPaint(context, offset);

  // From the last child back, so the button wins over the rows under it.
  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) =>
      defaultHitTestChildren(result, position: position);
}
