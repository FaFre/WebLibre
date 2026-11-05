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
import 'dart:math' as math;

import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:fast_equatable/fast_equatable.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:weblibre/core/design/window_size_class.dart';
import 'package:weblibre/core/providers/window_size_class.dart';
import 'package:weblibre/features/settings/domain/providers/pending_settings_highlight.dart';
import 'package:weblibre/features/settings/presentation/utils/toolbar_preview_l10n.dart';
import 'package:weblibre/features/settings/presentation/widgets/layout_part.dart';
import 'package:weblibre/features/settings/presentation/widgets/layout_part_settings.dart';
import 'package:weblibre/features/settings/presentation/widgets/settings_detail.dart';
import 'package:weblibre/features/settings/presentation/widgets/toolbar_layout_content.dart';
import 'package:weblibre/features/settings/presentation/widgets/toolbar_preview.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';
import 'package:weblibre/presentation/widgets/pointer_scrollable_sheet.dart';
import 'package:weblibre/utils/ui_helper.dart';

part 'toolbar_layout_settings.g.dart';

/// Toolbar & Layout: a preview of the browser beside the settings that shape
/// it, where tapping a part of the toolbar opens just its settings.
///
/// Follows Material's supporting-pane layout. A large window, or a short one
/// such as a phone held sideways, shows the preview and the settings side by
/// side; anything else switches between them with tabs, and opens a selected
/// part's settings in a sheet under the preview.
/// The full list stays one tab or one button away, for screen readers and for
/// the settings search.
///
/// Also opened by the onboarding: everything here reads the settings through
/// the edit and displayed layers, which follow the onboarding's draft.
/// How long a Try message stays: a third of the app's usual 4 s. They come
/// in quick succession while trying the layout, each replacing the last.
const _tryMessageDuration = Duration(milliseconds: 1500);

/// What the Toolbar & Layout screen shows: the device and sample state the
/// preview draws, whether a tap selects a part or tries the layout, and the
/// part whose settings are open. Ephemeral, held in one hook of the screen;
/// its transitions are the named methods.
///
/// No value equality on purpose: every transition rebuilds, as the separate
/// hooks it replaces did.
@CopyWith()
final class ToolbarLayoutEditorViewState {
  const ToolbarLayoutEditorViewState({
    this.device = PreviewDevice.thisWindow,
    this.sampleState = PreviewSampleState.page,
    this.mode = PreviewMode.select,
    this.selectedPart,
    this.revealEditor,
  });

  final PreviewDevice device;
  final PreviewSampleState sampleState;
  final PreviewMode mode;
  final LayoutPart? selectedPart;

  /// Set by a "Customize …" row to scroll the opened part to its editor
  /// ([LayoutPartSettings.revealEditor]).
  final ({LayoutPart part})? revealEditor;

  /// The part whose settings are shown: the selected one, while selecting.
  LayoutPart? get shownPart => mode == PreviewMode.select ? selectedPart : null;

  /// [revealEditor], while it is for [shownPart].
  ({LayoutPart part})? get revealShownEditor =>
      revealEditor?.part == shownPart ? revealEditor : null;

  /// Whether a part's settings take the room before the preview
  /// ([LayoutPreview.pageGivesWay]).
  bool get pageGivesWay => mode == PreviewMode.select && selectedPart != null;

  /// Back to selecting, with [part]'s settings open (none for null).
  ToolbarLayoutEditorViewState select(LayoutPart? part) => copyWith(
    mode: PreviewMode.select,
    selectedPart: part,
    revealEditor: null,
  );

  /// [part] selected by a tap on the preview, in whatever mode it is in.
  ToolbarLayoutEditorViewState tapPart(LayoutPart? part) =>
      copyWith(selectedPart: part, revealEditor: null);

  /// [part] open with its editor scrolled into view, for a "Customize …"
  /// row.
  ToolbarLayoutEditorViewState openEditor(LayoutPart part) =>
      select(part).copyWith(revealEditor: (part: part));
}

class ToolbarLayoutSettingsScreen extends HookConsumerWidget {
  const ToolbarLayoutSettingsScreen({super.key});

  /// Width of the settings pane beside the preview in a large window.
  static const settingsPaneWidth = 360.0;

  /// Width of the pane in a window of medium width, a phone held sideways.
  static const narrowSettingsPaneWidth = 320.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final window = ref.watch(windowSizeClassControllerProvider);
    final view = useState(const ToolbarLayoutEditorViewState());
    final search = useSettingsSearch();
    final expanded = window.width == WindowWidthClass.expanded;
    // Side by side also where a sheet under the preview would leave either
    // too little height: a short window that is not narrow too.
    final sidePanes =
        expanded ||
        (window.isHeightConstrained &&
            window.width != WindowWidthClass.compact);
    // The sheet's height, as a share of the body, from one opening to the
    // next. A ref, not part of [view]: it follows every frame of a drag, and
    // nothing rebuilds for it.
    final lastSheetSize = useRef<double?>(null);

    void select(LayoutPart? part) => view.value = view.value.select(part);

    // A "Customize …" row opens its part with the editor beside the preview,
    // rather than a screen of its own that would hide it.
    void openEditor(BuildContext context, ToolbarLayoutEditor editor) {
      view.value = view.value.openEditor(layoutPartOfEditor(editor));
      // On a phone the row is on the Settings tab.
      DefaultTabController.maybeOf(context)?.animateTo(0);
    }

    void onTryAction(PreviewTryAction action) {
      final settings = ref.read(displayedGeneralSettingsProvider);
      // What was tried, the part whose settings Adjust opens, and the setting
      // there it scrolls to and highlights (by its title, as the settings
      // search does); none where the part's settings start with it.
      final (message, part, setting) = switch (action) {
        PreviewTryAction.toolbarHidden => (
          l10n.settings_tryToolbarHidden(
            NumberFormat.percentPattern().format(
              settings.autoHideTabBarDistance / defaultAutoHideTabBarDistance,
            ),
          ),
          LayoutPart.tabBar,
          l10n.settings_autoHideTabBarDistanceTitle,
        ),
        PreviewTryAction.sidePanelHidden => (
          l10n.settings_trySidePanelHidden,
          LayoutPart.tabBar,
          l10n.settings_autoHideSidePanelTitle,
        ),
        PreviewTryAction.openedTabView => (
          l10n.settings_tryOpensTabView,
          LayoutPart.tabView,
          null,
        ),
        PreviewTryAction.openedMenu => (
          l10n.settings_tryOpensMenu,
          LayoutPart.menu,
          null,
        ),
      };
      // Through the app's helper: a bare SnackBar with an action stays until
      // it is tapped. The next one replaces it rather than queueing behind
      // it, so the message always matches what was just tried.
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      showInfoMessage(
        context,
        message,
        duration: _tryMessageDuration,
        action: SnackBarAction(
          label: l10n.settings_tryAdjust,
          onPressed: () {
            select(part);
            if (setting != null) {
              ref.read(pendingSettingsHighlightProvider.notifier).set(setting);
            }
          },
        ),
      );
    }

    final previewPane = _PreviewPane(
      view: view.value,
      labelledModes: expanded,
      onViewChanged: (value) => view.value = value,
      onTryAction: onTryAction,
    );
    // Opened from the settings search: start on the list, where the entry it
    // found is waiting to be highlighted. Read once, before the layout
    // branches, so the hook stays put when the window crosses the expanded
    // breakpoint and the tabs do not start over each time it does.
    final initialTab = useMemoized(
      () => ref.read(pendingSettingsHighlightProvider) != null ? 1 : 0,
    );
    // The "Customize …" rows are drawn here only: a part's own settings
    // already hold its editor.
    final settingsList = ToolbarLayoutEditorOpener(
      onOpen: openEditor,
      child: _SettingsList(search: search),
    );
    final shownPart = view.value.shownPart;

    if (sidePanes) {
      final colorScheme = Theme.of(context).colorScheme;
      return Scaffold(
        appBar: AppBar(title: Text(l10n.settings_toolbarLayoutTitle)),
        body: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: previewPane),
                const SizedBox(width: 24),
                SizedBox(
                  width: expanded ? settingsPaneWidth : narrowSettingsPaneWidth,
                  child: Material(
                    color: colorScheme.surfaceContainerLow,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: shownPart == null
                        ? settingsList
                        : LayoutPartSettings(
                            key: ValueKey(shownPart),
                            part: shownPart,
                            revealEditor: view.value.revealShownEditor,
                            onSelectPart: select,
                            header: LayoutPartHeader(
                              part: shownPart,
                              onSelectPart: select,
                              trailing: TextButton(
                                onPressed: () => select(null),
                                child: Text(l10n.settings_previewAllSettings),
                              ),
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return DefaultTabController(
      length: 2,
      initialIndex: initialTab,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.settings_toolbarLayoutTitle),
          bottom: TabBar(
            tabs: [
              Tab(text: l10n.settings_layoutEditorPreviewTab),
              Tab(text: l10n.settings_layoutEditorSettingsTab),
            ],
          ),
        ),
        body: SafeArea(
          top: false,
          child: TabBarView(
            // A swipe across the preview belongs to the preview.
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _PreviewWithSheet(
                previewPane: previewPane,
                view: view.value,
                lastSheetSize: lastSheetSize,
                onSelectPart: select,
              ),
              settingsList,
            ],
          ),
        ),
      ),
    );
  }
}

class _PreviewPane extends ConsumerWidget {
  const _PreviewPane({
    required this.view,
    required this.labelledModes,
    required this.onViewChanged,
    required this.onTryAction,
  });

  /// What the preview shows. With a part's settings open beside or under it
  /// ([ToolbarLayoutEditorViewState.pageGivesWay]) the pane drops its hints,
  /// and its controls too when even less is left, rather than scroll.
  final ToolbarLayoutEditorViewState view;

  /// Whether the mode switch has room for its labels, or shows icons only.
  final bool labelledModes;
  final ValueChanged<ToolbarLayoutEditorViewState> onViewChanged;
  final ValueChanged<PreviewTryAction> onTryAction;

  /// Below this height the pane leaves out its hints; see [build].
  static const _hintsBelowHeight = 360.0;

  /// Height the window keeps when the pane scrolls.
  static const _minWindowHeight = 200.0;

  /// Below this height the pane is the window alone while a part is open
  /// (its controls are for choosing what to look at, not for editing), and
  /// scrolls otherwise.
  static const _controlsBelowHeight = 240.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final settings = ref.watch(displayedGeneralSettingsProvider);
    final liveWindow = ref.watch(windowSizeClassControllerProvider);
    final ToolbarLayoutEditorViewState(
      :device,
      sampleState: state,
      :mode,
      :selectedPart,
      :pageGivesWay,
    ) = view;
    final pageLayout = previewChromeLayout(
      settings,
      window: resolvePreviewWindow(context, liveWindow, device),
      state: PreviewSampleState.page,
    );
    final effectiveState = previewStateBlocker(state, pageLayout) == null
        ? state
        : PreviewSampleState.page;
    final hintStyle = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );

    final controlsRow = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MenuChip<PreviewDevice>(
                values: PreviewDevice.values,
                selected: device,
                highlighted: device != PreviewDevice.thisWindow,
                label: (value) => value.label(context),
                icon: (value) => value.icon,
                onSelected: (value) =>
                    onViewChanged(view.copyWith(device: value)),
              ),
              _MenuChip<PreviewSampleState>(
                values: PreviewSampleState.values,
                selected: effectiveState,
                highlighted: effectiveState != PreviewSampleState.page,
                label: (value) => value.label(context),
                icon: (value) => value.icon,
                disabledReason: (value) =>
                    previewStateBlocker(value, pageLayout)?.describe(context),
                onSelected: (value) =>
                    onViewChanged(view.copyWith(sampleState: value)),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        SegmentedButton<PreviewMode>(
          showSelectedIcon: labelledModes,
          segments: [
            ButtonSegment(
              value: PreviewMode.select,
              icon: const Icon(Icons.ads_click),
              tooltip: labelledModes ? null : l10n.settings_previewModeSelect,
              label: labelledModes
                  ? Text(l10n.settings_previewModeSelect)
                  : null,
            ),
            ButtonSegment(
              value: PreviewMode.tryIt,
              icon: const Icon(Icons.play_arrow_outlined),
              tooltip: labelledModes ? null : l10n.settings_previewModeTry,
              label: labelledModes ? Text(l10n.settings_previewModeTry) : null,
            ),
          ],
          selected: {mode},
          onSelectionChanged: (selection) =>
              onViewChanged(view.copyWith(mode: selection.first)),
        ),
      ],
    );
    final hints = <Widget>[
      Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Text(
          mode == PreviewMode.select
              ? l10n.settings_previewSelectHint
              : l10n.settings_previewTryHint,
          style: hintStyle,
        ),
      ),
      if (device != PreviewDevice.thisWindow)
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            l10n.settings_previewOtherDeviceHint(device.name),
            style: hintStyle,
          ),
        ),
    ];
    final preview = LayoutPreview(
      device: device,
      state: effectiveState,
      mode: mode,
      selectedPart: selectedPart,
      onPartSelected: (part) => onViewChanged(view.tapPart(part)),
      onTryAction: onTryAction,
      pageGivesWay: pageGivesWay,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final height = constraints.maxHeight;
        // With a part open, its settings come first: the window alone.
        if (pageGivesWay && height < _controlsBelowHeight) return preview;
        if (pageGivesWay || height >= _controlsBelowHeight) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              controlsRow,
              // The hints only where they leave the window its room.
              if (height >= _hintsBelowHeight) ...hints,
              const SizedBox(height: 12),
              Expanded(child: preview),
            ],
          );
        }

        // Too short for the controls and a window that can still be read:
        // the two scroll together, the window at its minimum height, rather
        // than overflow.
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              controlsRow,
              const SizedBox(height: 12),
              SizedBox(height: _minWindowHeight, child: preview),
            ],
          ),
        );
      },
    );
  }
}

/// The heights the part sheet rests at, as shares of the body it shares with
/// the preview: Material's collapsed, half-expanded and expanded states.
class PartSheetStops with FastEquatable {
  PartSheetStops({required this.peek, required this.half, required this.full});

  /// The sheet's handle, its header and the first row of settings: the
  /// preview at nearly its full height.
  final double peek;

  /// Half the body; null where it would sit too close to [peek] or [full] to
  /// tell apart.
  final double? half;

  /// What the preview leaves at its smallest: the bars holding the selected
  /// part, without the page between them. In a body too short for those and
  /// [minSheetHeight], the sheet keeps its minimum and the preview is scaled
  /// down to what is left, no less than [minPreviewHeight].
  final double full;

  /// The sheet's height at [peek].
  static const peekHeight = 176.0;

  /// The least the sheet takes: its handle, its header and a row of settings.
  /// Below it the header would overflow and leave the settings no room.
  static const minSheetHeight = 152.0;

  /// The least the preview keeps when the sheet needs the rest of a short
  /// body: a scaled-down strip of its bars.
  static const minPreviewHeight = 64.0;

  /// Space between two stops below which [half] is left out.
  static const _minStopGap = 0.08;

  /// The stops in a body [available] tall, where the preview needs
  /// [previewHeight] for its bars at their real size.
  factory PartSheetStops.resolve({
    required double available,
    required double previewHeight,
  }) {
    if (available <= 0) {
      return PartSheetStops(peek: 1, half: null, full: 1);
    }
    final previewAtFull = math.min(
      previewHeight,
      math.max(available - minSheetHeight, minPreviewHeight),
    );
    final fullHeight = math.max(available - previewAtFull, 0.0);
    final full = fullHeight / available;
    final peek = math.min(peekHeight, fullHeight) / available;
    const half = 0.5;
    return PartSheetStops(
      peek: peek,
      half: half - peek >= _minStopGap && full - half >= _minStopGap
          ? half
          : null,
      full: full,
    );
  }

  List<double> get all => [peek, ?half, full];

  /// Where the sheet comes to rest from [size]: the next stop up or down after
  /// a fling ([velocity] in pixels per second, down positive), the nearest one
  /// otherwise.
  double settle(double size, {required double velocity}) {
    final stops = all;
    if (velocity.abs() >= kMinFlingVelocity) {
      return velocity < 0
          ? stops.firstWhere((stop) => stop > size + 0.001, orElse: () => full)
          : stops.lastWhere((stop) => stop < size - 0.001, orElse: () => peek);
    }
    return stops.reduce((a, b) => (a - size).abs() <= (b - size).abs() ? a : b);
  }

  /// The stop a tap on the handle moves to from [size]: the next one up, or
  /// back down a step from the top.
  double next(double size) {
    final stops = all;
    final at = stops.indexOf(settle(size, velocity: 0));
    return at < stops.length - 1 ? stops[at + 1] : stops[math.max(0, at - 1)];
  }

  @override
  List<Object?> get hashParameters => [peek, half, full];
}

/// The preview, with the selected part's settings in a sheet under it.
///
/// The preview is drawn in what the sheet leaves, so the selected part is
/// never hidden behind it: as the sheet is pulled up, the preview first drops
/// its hints and controls, then the page, down to the bars holding the part.
class _PreviewWithSheet extends HookConsumerWidget {
  const _PreviewWithSheet({
    required this.previewPane,
    required this.view,
    required this.lastSheetSize,
    required this.onSelectPart,
  });

  final Widget previewPane;

  /// What the preview shows; the sheet shows the settings of its
  /// [ToolbarLayoutEditorViewState.shownPart], and closes without one.
  final ToolbarLayoutEditorViewState view;

  /// The sheet's size from one opening to the next.
  final ObjectRef<double?> lastSheetSize;

  /// Opens a part's settings, or closes the sheet for null.
  final ValueChanged<LayoutPart?> onSelectPart;

  /// Room around the preview while a part is open.
  static const _openPadding = EdgeInsets.fromLTRB(16, 8, 16, 8);
  static const _closedPadding = EdgeInsets.fromLTRB(16, 12, 16, 16);

  /// Least the preview keeps of a body with a side rail, which is only ever
  /// scaled as a whole: no less than this, and no less than [_railShare].
  static const _minRailPreviewHeight = 160.0;
  static const _railShare = 0.35;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = useDraggableScrollableController();
    final settings = ref.watch(displayedGeneralSettingsProvider);
    final liveWindow = ref.watch(windowSizeClassControllerProvider);
    final previewWindow = resolvePreviewWindow(
      context,
      liveWindow,
      view.device,
    );
    final menuShown = ref.watch(menuCustomizationShown);
    final part = view.shownPart;
    final revealEditor = view.revealShownEditor;
    // A part with an editor inline opens with the room it needs.
    final opensFull =
        revealEditor != null ||
        (part != null && layoutPartEditor(part, menuShown: menuShown) != null);

    useEffect(() {
      void remember() {
        if (controller.isAttached) lastSheetSize.value = controller.size;
      }

      controller.addListener(remember);
      return () => controller.removeListener(remember);
    }, [controller]);

    return LayoutBuilder(
      builder: (context, constraints) {
        final available = constraints.maxHeight;
        final layout = previewEffectiveLayout(
          settings,
          window: previewWindow,
          state: view.sampleState,
        ).layout;
        final bars = previewBarsExtent(
          layout,
          device: previewWindow.size,
          availableWidth: constraints.maxWidth - _openPadding.horizontal,
        );
        final stops = PartSheetStops.resolve(
          available: available,
          previewHeight:
              (bars ??
                  math.max(_minRailPreviewHeight, available * _railShare)) +
              _openPadding.vertical,
        );
        final initialSize =
            (opensFull ? stops.full : lastSheetSize.value ?? stops.half)?.clamp(
              stops.peek,
              stops.full,
            ) ??
            stops.peek;

        return Stack(
          children: [
            Positioned.fill(
              child: _SheetFollower(
                controller: controller,
                open: part != null,
                initialSize: initialSize,
                availableHeight: available,
                child: Padding(
                  padding: part == null ? _closedPadding : _openPadding,
                  child: previewPane,
                ),
              ),
            ),
            if (part != null)
              _PartSheet(
                controller: controller,
                stops: stops,
                initialSize: initialSize,
                availableHeight: available,
                part: part,
                opensFull: opensFull,
                revealEditor: revealEditor,
                onSelectPart: onSelectPart,
                onClose: () => onSelectPart(null),
              ),
          ],
        );
      },
    );
  }
}

/// Leaves [child] what the sheet over it leaves, following it as it is
/// dragged.
///
/// Only this follows the sheet, frame by frame, not the sheet itself: a sheet
/// rebuilt mid-drag would start settling under the finger.
class _SheetFollower extends HookWidget {
  const _SheetFollower({
    required this.controller,
    required this.open,
    required this.initialSize,
    required this.availableHeight,
    required this.child,
  });

  final DraggableScrollableController controller;

  /// Whether the sheet is shown at all.
  final bool open;

  /// The sheet's size until it is laid out and its controller reports one.
  final double initialSize;
  final double availableHeight;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final rebuild = useReducer<int, void>(
      (count, _) => count + 1,
      initialState: 0,
      initialAction: null,
    );
    useEffect(() {
      // The controller can report a new size while the sheet rebuilds (new
      // stops after a rotation); this, built before it, follows a frame
      // later then.
      void follow() {
        if (SchedulerBinding.instance.schedulerPhase ==
            SchedulerPhase.persistentCallbacks) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) rebuild.dispatch(null);
          });
        } else {
          rebuild.dispatch(null);
        }
      }

      controller.addListener(follow);
      return () => controller.removeListener(follow);
    }, [controller]);

    final size = !open
        ? 0.0
        : controller.isAttached
        ? controller.size
        : initialSize;
    return Padding(
      padding: EdgeInsets.only(bottom: size * availableHeight),
      child: child,
    );
  }
}

/// The selected part's settings under the preview: Material's standard
/// (non-modal) bottom sheet, so the preview above stays live and a tap on
/// another part switches straight to it.
///
/// It rests at [stops], and is resized by dragging its handle and header, or
/// by scrolling the settings, which pull the sheet up before they scroll and
/// push it down once back at their top. A tap on the handle moves it a stop.
class _PartSheet extends HookWidget {
  const _PartSheet({
    required this.controller,
    required this.stops,
    required this.initialSize,
    required this.availableHeight,
    required this.part,
    required this.opensFull,
    required this.onSelectPart,
    required this.onClose,
    this.revealEditor,
  });

  final DraggableScrollableController controller;
  final PartSheetStops stops;
  final double initialSize;

  /// Height of the tab body the sheet shares with the preview.
  final double availableHeight;
  final LayoutPart part;

  /// Whether [part] needs the sheet pulled all the way up: it shows an editor
  /// inline. Opening another such part pulls it up again.
  final bool opensFull;
  final ValueChanged<LayoutPart> onSelectPart;
  final VoidCallback onClose;

  /// See [LayoutPartSettings.revealEditor].
  final Object? revealEditor;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    void moveTo(double size) {
      if (!controller.isAttached) return;
      if (reduceMotion) {
        controller.jumpTo(size);
        return;
      }
      controller.animateTo(
        size,
        duration: Durations.medium2,
        curve: Curves.easeOutCubic,
      );
    }

    // Another part with an editor, or a "Customize …" row, pulls the sheet
    // up; one that opens the sheet starts there already.
    final previousPart = useRef(part);
    useEffect(() {
      final changed = previousPart.value != part;
      previousPart.value = part;
      if (!opensFull || (!changed && revealEditor == null)) return null;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) moveTo(stops.full);
      });
      return null;
    }, [part, revealEditor]);

    double currentSize() =>
        controller.isAttached ? controller.size : initialSize;
    // The same list while the stops stay: a new one makes the sheet settle
    // again.
    final snapSizes = useMemoized(() => [?stops.half], [stops.half]);

    final header = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onVerticalDragUpdate: (details) {
        if (!controller.isAttached) return;
        controller.jumpTo(
          (controller.size - details.delta.dy / availableHeight).clamp(
            stops.peek,
            stops.full,
          ),
        );
      },
      onVerticalDragEnd: (details) => moveTo(
        stops.settle(currentSize(), velocity: details.primaryVelocity ?? 0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ListenableBuilder(
            listenable: controller,
            builder: (context, child) => Semantics(
              button: true,
              label: (currentSize() - stops.full).abs() < 0.001
                  ? l10n.settings_previewSheetCollapse
                  : l10n.settings_previewSheetExpand,
              onTap: () => moveTo(stops.next(currentSize())),
              child: child,
            ),
            child: ExcludeSemantics(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => moveTo(stops.next(currentSize())),
                child: SizedBox(
                  height: 24,
                  child: Center(
                    child: Container(
                      width: 32,
                      height: 4,
                      decoration: BoxDecoration(
                        color: colorScheme.onSurfaceVariant.withValues(
                          alpha: 0.4,
                        ),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          LayoutPartHeader(
            part: part,
            onSelectPart: onSelectPart,
            trailing: IconButton(
              tooltip: l10n.common_close,
              onPressed: onClose,
              icon: const Icon(Icons.close),
            ),
          ),
        ],
      ),
    );

    return PointerScrollableSheet(
      controller: controller,
      initialChildSize: initialSize,
      minChildSize: stops.peek,
      maxChildSize: stops.full,
      snap: true,
      snapSizes: snapSizes,
      shouldCloseOnMinExtent: false,
      builder: (context, scrollController) => Align(
        alignment: Alignment.topCenter,
        // Material's widest bottom sheet.
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: ContentWidth.sheet),
          child: Material(
            color: colorScheme.surfaceContainerLow,
            elevation: 1,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                header,
                Expanded(
                  child: LayoutPartSettings(
                    key: ValueKey(part),
                    part: part,
                    revealEditor: revealEditor,
                    onSelectPart: onSelectPart,
                    scrollController: scrollController,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A filter chip that opens a menu of [values], for the preview's device and
/// sample state.
class _MenuChip<T> extends StatelessWidget {
  const _MenuChip({
    required this.values,
    required this.selected,
    required this.highlighted,
    required this.label,
    required this.icon,
    required this.onSelected,
    this.disabledReason,
  });

  final List<T> values;
  final T selected;

  /// Whether the chip shows as selected: the choice differs from the default.
  final bool highlighted;
  final String Function(T value) label;
  final IconData Function(T value) icon;
  final ValueChanged<T> onSelected;

  /// Why a value cannot be picked right now, or null when it can.
  final String? Function(T value)? disabledReason;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return MenuAnchor(
      menuChildren: [
        for (final value in values)
          _menuItem(theme, value, disabledReason?.call(value)),
      ],
      builder: (context, controller, child) => FilterChip(
        avatar: Icon(icon(selected)),
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(label(selected), overflow: TextOverflow.ellipsis),
            ),
            const SizedBox(width: 4),
            Icon(
              controller.isOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down,
              size: 18,
            ),
          ],
        ),
        showCheckmark: false,
        selected: highlighted,
        onSelected: (_) =>
            controller.isOpen ? controller.close() : controller.open(),
      ),
    );
  }

  Widget _menuItem(ThemeData theme, T value, String? reason) {
    return MenuItemButton(
      leadingIcon: Icon(icon(value)),
      trailingIcon: value == selected ? const Icon(Icons.check) : null,
      onPressed: reason == null ? () => onSelected(value) : null,
      child: reason == null
          ? Text(label(value))
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(label(value)),
                Text(
                  reason,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
    );
  }
}

class _SettingsList extends StatelessWidget {
  const _SettingsList({required this.search});

  final SettingsSearchState search;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final inset = centeringInset(
          constraints.maxWidth,
          maxWidth: ContentWidth.list,
        );

        return CustomScrollView(
          slivers: [
            SliverPadding(
              padding: EdgeInsets.fromLTRB(16 + inset, 12, 16 + inset, 0),
              sliver: SliverToBoxAdapter(
                child: SettingsSearchField(
                  controller: search.controller,
                  hintText: l10n.settings_toolbarLayoutSearchHint,
                ),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(16 + inset, 20, 16 + inset, 20),
              sliver: SliverToBoxAdapter(
                child: ToolbarLayoutContent(
                  query: search.rawQuery,
                  extraSections: menuLayoutSettingsSections(context),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
