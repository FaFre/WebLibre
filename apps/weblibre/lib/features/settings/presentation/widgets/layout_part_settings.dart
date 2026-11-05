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
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/domain/feature_policy/feature_policy.dart';
import 'package:weblibre/features/geckoview/features/browser/features/contextual_toolbar/data/providers/toolbar_button_configs.dart';
import 'package:weblibre/features/geckoview/features/browser/features/contextual_toolbar/domain/entities/toolbar_config_location.dart';
import 'package:weblibre/features/settings/presentation/screens/contextual_toolbar_settings.dart';
import 'package:weblibre/features/settings/presentation/screens/menu_layout_settings.dart';
import 'package:weblibre/features/settings/presentation/utils/toolbar_preview_l10n.dart';
import 'package:weblibre/features/settings/presentation/widgets/layout_part.dart';
import 'package:weblibre/features/settings/presentation/widgets/reset_to_defaults_menu.dart';
import 'package:weblibre/features/settings/presentation/widgets/settings_detail.dart';
import 'package:weblibre/features/settings/presentation/widgets/toolbar_layout_content.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';

/// The settings of the selected [part] of the preview: the entries of its
/// section, drawn by the same widgets as the full list, and the editor it has
/// inline ([layoutPartEditor]): a toolbar's buttons, the menu's arrangement.
class LayoutPartSettings extends HookConsumerWidget {
  const LayoutPartSettings({
    super.key,
    required this.part,
    required this.onSelectPart,
    this.header,
    this.scrollController,
    this.revealEditor,
  });

  final LayoutPart part;

  /// Selects another part, from the path back to the parts around this one.
  final ValueChanged<LayoutPart> onSelectPart;

  /// Kept above the settings while they scroll, usually a [LayoutPartHeader].
  /// Null where the caller draws it itself: the sheet, whose header is also
  /// what it is dragged by.
  final Widget? header;

  /// For the settings' scroll view: the sheet's, which resizes the sheet
  /// before it scrolls.
  final ScrollController? scrollController;

  /// Set to scroll down to the inline editor, for the "Customize …" row that
  /// opened it: each new value scrolls again.
  final Object? revealEditor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final menuShown = ref.watch(menuCustomizationShown);
    final editor = layoutPartEditor(part, menuShown: menuShown);
    final sections = layoutPartSections(context, part, editor: editor);
    // The menu's only row is the one its editor replaces: no "No settings
    // available" above the editor.
    final listsSettings =
        editor == null || visibleSettingsSections(sections).isNotEmpty;
    final editorKey = useMemoized(GlobalKey.new);

    useEffect(() {
      if (revealEditor == null || editor == null) return null;
      // Once laid out: the sheet or pane may only just have appeared.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final target = editorKey.currentContext;
        if (target == null || !target.mounted) return;
        Scrollable.ensureVisible(
          target,
          duration: MediaQuery.disableAnimationsOf(target)
              ? Duration.zero
              : Durations.medium2,
          curve: Curves.easeInOutCubicEmphasized,
        );
      });
      return null;
    }, [revealEditor]);

    final settings = CustomScrollView(
      controller: scrollController,
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (listsSettings)
                  SettingsSectionList(sections: sections, query: ''),
                // Where the "Customize …" row scrolls to: the editor starts
                // right below. In the same box as the list, which is always
                // built, rather than a sliver of its own, which the viewport
                // may not have built yet when it is asked to scroll there.
                SizedBox(key: editorKey),
              ],
            ),
          ),
        ),
        if (editor != null) ...[
          switch (editor.buttonLocation) {
            final location? => SliverMainAxisGroup(
              slivers: [
                SliverToBoxAdapter(child: _ButtonsHeader(location: location)),
                ToolbarButtonConfigEditor(location: location),
              ],
            ),
            null => const MenuLayoutEditor(),
          },
        ],
      ],
    );

    return switch (header) {
      final header? => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          header,
          Expanded(child: settings),
        ],
      ),
      null => settings,
    };
  }
}

/// Whether the menu's arrangement can be customized, for
/// [layoutPartEditor]'s `menuShown`: while hidden, its row stays and asks to
/// show it before it opens.
final menuCustomizationShown = displayedShownFeaturesProvider.select(
  (shown) => shown.contains(FeatureId.layoutMenuCustomization),
);

/// The editor [part] has inline, if any, in place of the "Customize …" row
/// that would open it on a screen of its own. In onboarding too: its draft
/// scope holds the buttons and the menu as it holds the settings.
///
/// Not the menu's arrangement while it is hidden ([menuShown]): its row stays
/// then, and asks to show it before it opens.
ToolbarLayoutEditor? layoutPartEditor(
  LayoutPart part, {
  required bool menuShown,
}) => switch (part) {
  LayoutPart.contextualToolbar => ToolbarLayoutEditor.contextualButtons,
  LayoutPart.quickTabSwitcher => ToolbarLayoutEditor.switcherButtons,
  LayoutPart.menu when menuShown => ToolbarLayoutEditor.menu,
  _ => null,
};

/// The part whose settings show [editor] inline.
LayoutPart layoutPartOfEditor(ToolbarLayoutEditor editor) => switch (editor) {
  ToolbarLayoutEditor.contextualButtons => LayoutPart.contextualToolbar,
  ToolbarLayoutEditor.switcherButtons => LayoutPart.quickTabSwitcher,
  ToolbarLayoutEditor.menu => LayoutPart.menu,
};

/// The settings sections [part] opens, as [LayoutPartSettings] lists them
/// above its inline [editor].
List<SettingsSectionDefinition> layoutPartSections(
  BuildContext context,
  LayoutPart part, {
  required ToolbarLayoutEditor? editor,
}) {
  final sections = switch (part.section) {
    final section? => [toolbarLayoutSection(context, section)],
    null => menuLayoutSettingsSections(context),
  };
  if (editor == null) return sections;

  // The editor is right here rather than on a screen of its own, so the row
  // that opens that screen goes.
  return [
    for (final section in sections)
      section.copyWith(
        entries: [
          for (final entry in section.entries)
            if (entry.id != editor) entry,
        ],
      ),
  ];
}

/// Names the inline button editor and offers its reset in an overflow menu,
/// as the button screen's app bar does.
class _ButtonsHeader extends ConsumerWidget {
  const _ButtonsHeader({required this.location});

  final ToolbarConfigLocation location;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 8, 0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              switch (location) {
                ToolbarConfigLocation.contextual =>
                  l10n.settings_customizeToolbarButtons,
                ToolbarConfigLocation.quickSwitcher =>
                  l10n.settings_customizeSwitcherButtons,
              },
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          ResetToDefaultsMenu(
            onOpenFullScreen: () =>
                openToolbarLayoutEditorScreen(context, switch (location) {
                  ToolbarConfigLocation.contextual =>
                    ToolbarLayoutEditor.contextualButtons,
                  ToolbarConfigLocation.quickSwitcher =>
                    ToolbarLayoutEditor.switcherButtons,
                }),
            onReset: () => unawaited(
              reportFailedToolbarEdit(
                context,
                ref
                    .read(toolbarButtonLayoutProvider(location).notifier)
                    .resetToDefaults(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The path to the selected part, each step a way back to it, and [trailing].
class LayoutPartHeader extends StatelessWidget {
  const LayoutPartHeader({
    super.key,
    required this.part,
    required this.onSelectPart,
    required this.trailing,
  });

  final LayoutPart part;
  final ValueChanged<LayoutPart> onSelectPart;

  /// Closes the settings: a close button in a sheet, "All settings" in a
  /// pane.
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final ancestors = part.path.sublist(0, part.path.length - 1);

    // A part with nothing around it has no path: the section title below
    // names it already.
    if (ancestors.isEmpty) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(8, 4, 4, 0),
        child: Align(
          alignment: AlignmentDirectional.centerEnd,
          child: trailing,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 4, 0),
      child: Row(
        children: [
          Expanded(
            child: Semantics(
              container: true,
              label: l10n.settings_previewSelectionPath,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (final ancestor in ancestors) ...[
                      TextButton(
                        style: TextButton.styleFrom(
                          minimumSize: const Size(
                            kMinInteractiveDimension,
                            kMinInteractiveDimension,
                          ),
                        ),
                        onPressed: () => onSelectPart(ancestor),
                        child: Text(ancestor.label(context)),
                      ),
                      Icon(
                        Icons.chevron_right,
                        size: 18,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ],
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Semantics(
                        selected: true,
                        child: Text(
                          part.label(context),
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}
