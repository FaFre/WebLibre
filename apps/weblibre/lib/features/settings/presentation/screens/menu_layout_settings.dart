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
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/features/geckoview/features/browser/features/menu/domain/entities/menu_layout.dart';
import 'package:weblibre/features/geckoview/features/browser/features/menu/domain/providers/menu_layout.dart';
import 'package:weblibre/features/geckoview/features/browser/features/menu/presentation/utils/menu_layout_l10n.dart';
import 'package:weblibre/features/geckoview/features/browser/features/menu/presentation/widgets/menu_layout_slivers.dart';
import 'package:weblibre/features/settings/presentation/widgets/reset_to_defaults_menu.dart';
import 'package:weblibre/features/settings/presentation/widgets/settings_detail.dart';
import 'package:weblibre/features/settings/presentation/widgets/toolbar_layout_content.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';

/// Arranges the browser menu from Settings, editing the same saved layout as
/// the "Customize menu" button inside the menu itself.
///
/// The level in front is local state here rather than
/// [menuReorderModeProvider]: that provider exists to survive as long as the
/// menu sheet does, and this screen's lifetime is its own.
class MenuLayoutSettingsScreen extends HookConsumerWidget {
  const MenuLayoutSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final sections = ref.watch(editedMenuLayoutProvider);
    final focusedSection = useState<MenuSectionType?>(null);
    final focusedItem = useState<MenuItemType?>(null);

    final (:section, :item) = resolveMenuLayoutFocus(
      sections,
      focusedSection: focusedSection.value,
      focusedItem: focusedItem.value,
    );

    void stepBack() {
      if (focusedItem.value != null) {
        focusedItem.value = null;
        return;
      }
      focusedSection.value = null;
    }

    // Drilling into a section is navigation without a route, so both the app
    // bar's back button and the system gesture have to unwind it before they
    // leave the screen.
    return PopScope(
      canPop: section == null,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        stepBack();
      },
      child: SettingsCustomScrollScaffold(
        title:
            item?.type.label(context) ??
            section?.type.label(context) ??
            l10n.settings_menuLayoutTitle,
        actions: [
          if (section == null)
            ResetToDefaultsMenu(
              onReset: ref
                  .read(editedMenuLayoutProvider.notifier)
                  .resetToDefaults,
            ),
        ],
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Text(
                _hint(l10n, section: section, item: item),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
          MenuLayoutSlivers(
            focusedSection: section?.type,
            focusedItem: item?.type,
            onFocusSection: (type) => focusedSection.value = type,
            onFocusItem: (type) => focusedItem.value = type,
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }
}

/// What the level in front can be arranged as.
String _hint(
  AppLocalizations l10n, {
  required MenuSectionEntry? section,
  required MenuItemEntry? item,
}) => switch ((section, item)) {
  (null, _) => l10n.settings_menuLayoutHintSections,
  (_, null) => l10n.settings_menuLayoutHintSectionItems,
  _ => l10n.settings_menuLayoutHintSubItems,
};

/// The menu's arrangement inline, as the Toolbar & Layout editor shows it
/// beside its preview: what [MenuLayoutSettingsScreen] shows, as slivers.
///
/// Without an app bar of its own, it carries the screen's title, its way back
/// out of a section and its reset in a row above the list. The system back
/// gesture steps out of a section first, as on the screen.
class MenuLayoutEditor extends HookConsumerWidget {
  const MenuLayoutEditor({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final focusedSection = useState<MenuSectionType?>(null);
    final focusedItem = useState<MenuItemType?>(null);

    final (:section, :item) = resolveMenuLayoutFocus(
      ref.watch(editedMenuLayoutProvider),
      focusedSection: focusedSection.value,
      focusedItem: focusedItem.value,
    );

    void stepBack() {
      if (focusedItem.value != null) {
        focusedItem.value = null;
        return;
      }
      focusedSection.value = null;
    }

    return PopScope(
      canPop: section == null,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        stepBack();
      },
      child: SliverMainAxisGroup(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(4, 16, 8, 0),
            sliver: SliverToBoxAdapter(
              child: Row(
                children: [
                  if (section != null)
                    IconButton(
                      tooltip: MaterialLocalizations.of(
                        context,
                      ).backButtonTooltip,
                      onPressed: stepBack,
                      icon: const Icon(Icons.arrow_back),
                    )
                  else
                    const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item?.type.label(context) ??
                          section?.type.label(context) ??
                          l10n.settings_menuLayoutTitle,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  // Only for the whole menu, as on the screen.
                  if (section == null)
                    ResetToDefaultsMenu(
                      onReset: ref
                          .read(editedMenuLayoutProvider.notifier)
                          .resetToDefaults,
                      onOpenFullScreen: () => openToolbarLayoutEditorScreen(
                        context,
                        ToolbarLayoutEditor.menu,
                      ),
                    ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            sliver: SliverToBoxAdapter(
              child: Text(
                _hint(l10n, section: section, item: item),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
          MenuLayoutSlivers(
            focusedSection: section?.type,
            focusedItem: item?.type,
            onFocusSection: (type) => focusedSection.value = type,
            onFocusItem: (type) => focusedItem.value = type,
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }
}
