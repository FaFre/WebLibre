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
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/core/design/app_colors.dart';
import 'package:weblibre/features/geckoview/domain/controllers/bottom_sheet.dart';
import 'package:weblibre/features/geckoview/domain/providers.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/entities/sheet.dart';
import 'package:weblibre/features/geckoview/features/split_view/domain/entities/split_pair.dart';
import 'package:weblibre/features/geckoview/features/split_view/domain/providers/split_view.dart';
import 'package:weblibre/features/geckoview/features/split_view/domain/providers/split_view_inputs.dart';
import 'package:weblibre/features/geckoview/features/split_view/domain/services/split_presentation.dart';
import 'package:weblibre/features/geckoview/features/split_view/domain/services/split_view_native_sync.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';
import 'package:weblibre/utils/ui_helper.dart';

/// Wraps the engine view and connects it to split view.
///
/// - Measures the platform view's size, the input of the layout resolver.
///   This is the right place: inside the browser's safe area, after bars,
///   rail and the keyboard inset.
/// - Reports the theme colors and localized labels native draws its chrome
///   with.
/// - Keeps the native sync running and handles native's chrome events.
class SplitViewHost extends HookConsumerWidget {
  final Widget child;

  const SplitViewHost({required this.child, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Both are keep-alive; listening here starts them with the browser
    // without rebuilding the host on every change of the synced state.
    ref
      ..listen(splitViewNativeSyncProvider, (_, _) {})
      ..listen(splitViewReconciliationProvider, (_, _) {});
    final service = ref.watch(splitViewServiceProvider);

    final colorScheme = Theme.of(context).colorScheme;
    final appColors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);
    final chrome = SplitViewChrome(
      divider: colorScheme.surfaceContainerHighest,
      grip: colorScheme.outline,
      dragPreview: colorScheme.primary,
      placeholder: colorScheme.surface,
      onPlaceholder: colorScheme.onSurface,
      regularAccent: colorScheme.primary,
      privateAccent: appColors.privateTabPurple,
      isolatedAccent: appColors.isolatedTabTeal,
      dividerDescription: l10n.splitView_dividerDescription,
      dividerOptionsAction: l10n.splitView_dividerOptions,
      crashedTitle: l10n.splitView_crashedTitle,
      crashedReload: l10n.splitView_crashedReload,
    );
    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          ref.read(splitViewChromeControllerProvider.notifier).report(chrome);
        }
      });
      return null;
    }, [chrome]);

    bool isOwnEpoch(String epoch) =>
        epoch == ref.read(splitViewNativeSyncProvider).epoch;

    useOnStreamChange(
      service.ratioCommits,
      onData: (commit) {
        if (!isOwnEpoch(commit.epoch)) return;
        ref.read(splitViewControllerProvider.notifier).setRatio(
          commit.pairId,
          switch (commit.axis) {
            SplitAxis.sideBySide => SplitRatioAxis.sideBySide,
            SplitAxis.stacked => SplitRatioAxis.stacked,
          },
          commit.ratio,
        );
      },
    );

    useOnStreamChange(
      service.dividerCollapses,
      onData: (collapse) {
        if (!isOwnEpoch(collapse.epoch)) return;
        final collapsed = ref
            .read(splitViewControllerProvider.notifier)
            .collapseTo(collapse.pairId, collapse.keptTabId);
        if (!collapsed || !context.mounted) return;

        // A drag to the edge is easy to make by accident, and nothing else on
        // screen says the other page is still there. The menu's split toggle
        // brings it back too, but this is where the user is looking now.
        final l10n = AppLocalizations.of(context);
        showInfoMessage(
          context,
          l10n.splitView_showingOnlyThisPage,
          action: SnackBarAction(
            label: l10n.splitView_showBothPages,
            onPressed: () {
              if (!context.mounted) return;
              ref
                  .read(splitViewControllerProvider.notifier)
                  .showBothPages(collapse.pairId);
            },
          ),
        );
      },
    );

    useOnStreamChange(
      service.handleTaps,
      onData: (tap) {
        if (!isOwnEpoch(tap.epoch)) return;
        if (ref.read(splitViewControllerProvider)?.pairId != tap.pairId) return;
        ref.read(bottomSheetControllerProvider.notifier).show(SplitViewSheet());
      },
    );

    useOnStreamChange(
      service.paneActivations,
      onData: (activation) async {
        if (!isOwnEpoch(activation.epoch)) return;
        // Applied at once through the same sequence-ordered path as the
        // debounced selection event, which then arrives as a no-op. A toolbar
        // tap right after touching a pane acts on that pane.
        await ref
            .read(eventServiceProvider)
            .onSelectedTabChange(activation.sequence, activation.tabId);
      },
    );

    final displayFeatures = MediaQuery.displayFeaturesOf(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest;
        if (size.isFinite) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!context.mounted) return;
            ref.read(browserContentGeometryProvider.notifier).report(size);

            // Display features are in window coordinates; the resolver wants
            // the hinge where it crosses this view.
            Rect? hinge;
            final box = context.findRenderObject();
            if (displayFeatures.isNotEmpty && box is RenderBox && box.hasSize) {
              hinge = separatingHingeInContent(
                features: displayFeatures,
                content: box.localToGlobal(Offset.zero) & box.size,
              );
            }
            ref.read(browserContentHingeProvider.notifier).report(hinge);
          });
        }
        return child;
      },
    );
  }
}
