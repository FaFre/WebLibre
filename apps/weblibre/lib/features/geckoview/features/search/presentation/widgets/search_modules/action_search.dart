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
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/core/filesystem.dart';
import 'package:weblibre/domain/entities/profile.dart';
import 'package:weblibre/features/browser_actions/data/models/browser_action.dart';
import 'package:weblibre/features/browser_actions/domain/services/browser_action_dispatcher.dart';
import 'package:weblibre/features/browser_actions/domain/services/browser_action_search.dart';
import 'package:weblibre/features/browser_actions/presentation/utils/browser_action_l10n.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_state.dart';
import 'package:weblibre/features/geckoview/features/pwa/domain/providers.dart';
import 'package:weblibre/features/geckoview/features/search/domain/providers/search_modules_view.dart';
import 'package:weblibre/features/geckoview/features/search/presentation/widgets/search_modules/search_module_section.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/models/container_data.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/providers.dart';
import 'package:weblibre/features/keyboard_shortcuts/presentation/widgets/keyboard_shortcut_hint.dart';
import 'package:weblibre/features/settings/presentation/screens/settings.dart';
import 'package:weblibre/features/user/domain/repositories/engine_settings.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/features/user/domain/repositories/profile.dart';
import 'package:weblibre/features/web_feed/data/database/definitions.drift.dart';
import 'package:weblibre/features/web_feed/domain/providers.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';

/// One row of the Actions section.
sealed class ActionSearchItem {
  const ActionSearchItem();
}

/// A browser action, run through `BrowserActionDispatcher`.
final class BrowserActionSearchItem extends ActionSearchItem {
  final BrowserAction action;

  const BrowserActionSearchItem(this.action);
}

/// Switches to one of the user's containers.
final class ContainerSearchItem extends ActionSearchItem {
  final ContainerDataWithCount container;

  const ContainerSearchItem(this.container);
}

/// Switches to another profile, which restarts the browser.
final class ProfileSearchItem extends ActionSearchItem {
  final Profile profile;

  const ProfileSearchItem(this.profile);
}

/// Opens one subscribed feed.
final class FeedSearchItem extends ActionSearchItem {
  final FeedData feed;

  const FeedSearchItem(this.feed);
}

/// Opens a settings screen, scrolled to one setting unless it is the screen
/// itself.
final class SettingSearchItem extends ActionSearchItem {
  final SettingsSearchTarget target;

  const SettingSearchItem(this.target);
}

/// Things to do rather than places to visit: browser actions, and — once
/// something is typed — the user's containers, other profiles, feeds and
/// settings whose names match.
///
/// A plain result list, not a command mode: nothing runs until a row is tapped,
/// and submitting the field still opens or searches the text as usual. No
/// prefix character is needed, since symbols are awkward to reach on many
/// phone keyboards.
///
/// Before anything is typed (the new-tab page) the section lists every
/// available browser action, paged like any other section. Only runnable
/// actions are offered: page actions need [pageTabId], so a search opened for a
/// new tab leaves them out, and an action the page cannot perform right now —
/// reader mode on a page without an article — is hidden too.
class ActionSearch extends HookConsumerWidget {
  /// The query to match. Null on the new-tab page, where the section lists
  /// every available action.
  final ValueListenable<TextEditingValue>? searchTextListenable;

  /// The tab page actions apply to, or null to offer browser-wide actions only.
  final String? pageTabId;

  final void Function(ActionSearchItem item) onItemSelected;

  const ActionSearch({
    super.key,
    required this.searchTextListenable,
    required this.pageTabId,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final query = useListenableSelector(
      searchTextListenable,
      () => searchTextListenable?.value.text,
    );

    final readerable = ref.watch(
      tabStateProvider(pageTabId).select((state) => state?.readerableState),
    );
    final showContainerUi = ref.watch(
      generalSettingsWithDefaultsProvider.select((s) => s.showContainerUi),
    );
    final automaticFontSize = ref.watch(
      engineSettingsWithDefaultsProvider.select(
        (s) => s.automaticFontSizeAdjustment,
      ),
    );
    final canAddToHomeScreen =
        ref.watch(isTabInstallableProvider(pageTabId)) ||
        ref.watch(isTabShortcutableProvider(pageTabId));

    bool isAvailable(BrowserAction action) {
      if (pageTabId == null && BrowserActionDispatcher.requiresTab(action)) {
        return false;
      }

      return switch (action) {
        BrowserAction.toggleReaderMode =>
          readerable != null && (readerable.readerable || readerable.active),
        BrowserAction.addToHomeScreen => canAddToHomeScreen,
        BrowserAction.showContainers ||
        BrowserAction.newContainer ||
        BrowserAction.moveTabToContainer => showContainerUi,
        BrowserAction.increaseFontSize ||
        BrowserAction.decreaseFontSize ||
        BrowserAction.resetFontSize => !automaticFontSize,
        _ => true,
      };
    }

    final available = [
      for (final action in searchableBrowserActions)
        if (isAvailable(action)) action,
    ];

    // Built once per language: the index spans every settings screen.
    final settingsTargets = useMemoized(() => settingsSearchTargets(context), [
      Localizations.localeOf(context),
    ]);

    final List<ActionSearchItem> items;
    if (query == null) {
      items = [for (final action in available) BrowserActionSearchItem(action)];
    } else {
      final containers = showContainerUi
          ? ref.watch(watchContainersWithCountProvider).value ?? const []
          : const <ContainerDataWithCount>[];
      final profiles = ref.watch(profileRepositoryProvider).value ?? const [];
      final feeds = ref.watch(feedListProvider).value ?? const [];

      items = rankActionSearchEntries<ActionSearchItem>(query, [
        for (final action in available)
          (
            item: BrowserActionSearchItem(action),
            label: action.label(context),
            description: action.description(context),
            category: action.category.label(context),
            keywords: action.keywords(context),
          ),
        for (final container in containers)
          (
            item: ContainerSearchItem(container),
            label: _containerName(l10n, container),
            description: l10n.search_actionSwitchToContainer,
            category: l10n.search_moduleLabelContainers,
            keywords: const [],
          ),
        for (final profile in profiles)
          // Switching to the profile already in use would only restart.
          if (profile.uuidValue != filesystem.selectedProfile)
            (
              item: ProfileSearchItem(profile),
              label: profile.name,
              description: l10n.search_actionSwitchToProfile,
              category: l10n.browserActions_showProfilesTitle,
              keywords: const [],
            ),
        for (final feed in feeds)
          (
            item: FeedSearchItem(feed),
            label: _feedTitle(l10n, feed),
            description: l10n.search_actionOpenFeed,
            category: l10n.browserActions_showFeedsTitle,
            keywords: const [],
          ),
        for (final target in settingsTargets)
          (
            item: SettingSearchItem(target),
            label: target.title,
            description: target.subtitle ?? '',
            category: [
              l10n.browserActions_openSettingsTitle,
              target.category,
              ?target.section,
            ].join(' '),
            keywords: target.keywords,
          ),
      ]);
    }

    return SearchModuleSection(
      title: l10n.search_moduleLabelActions,
      moduleType: SearchModuleType.actions,
      totalCount: items.length,
      // An empty header under every search would be noise; the section is
      // still configurable from "Customize sections". The full list on the
      // new-tab page is never empty.
      hideWhenEmpty: true,
      contentSliverBuilder:
          ({required bool isCollapsed, required int visibleCount}) => [
            SliverList.builder(
              itemCount: visibleCount,
              itemBuilder: (context, index) {
                final item = items[index];
                return _ActionSearchTile(
                  item: item,
                  onTap: () => onItemSelected(item),
                );
              },
            ),
          ],
    );
  }
}

String _containerName(AppLocalizations l10n, ContainerData container) =>
    switch (container.name?.trim()) {
      final String name when name.isNotEmpty => name,
      _ => l10n.search_actionUnnamedContainer,
    };

String _feedTitle(AppLocalizations l10n, FeedData feed) =>
    switch (feed.title?.trim()) {
      final String title when title.isNotEmpty => title,
      _ => l10n.search_actionUntitledFeed,
    };

class _ActionSearchTile extends StatelessWidget {
  final ActionSearchItem item;
  final VoidCallback onTap;

  const _ActionSearchTile({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final (key, icon, title, subtitle, trailing) = switch (item) {
      BrowserActionSearchItem(:final action) => (
        ValueKey(action),
        Icon(action.icon),
        action.label(context),
        action.description(context),
        KeyboardShortcutHint(action) as Widget?,
      ),
      ContainerSearchItem(:final container) => (
        ValueKey('container:${container.id}'),
        Icon(MdiIcons.folder, color: container.color),
        _containerName(l10n, container),
        l10n.search_actionSwitchToContainer,
        null,
      ),
      ProfileSearchItem(:final profile) => (
        ValueKey('profile:${profile.id}'),
        const Icon(Icons.person_outline),
        profile.name,
        l10n.search_actionSwitchToProfile,
        null,
      ),
      FeedSearchItem(:final feed) => (
        ValueKey('feed:${feed.url}'),
        const Icon(MdiIcons.rss),
        _feedTitle(l10n, feed),
        l10n.search_actionOpenFeed,
        null,
      ),
      SettingSearchItem(:final target) => (
        ValueKey(
          'setting:${target.category}/${target.section}/${target.title}',
        ),
        Icon(target.icon),
        target.title,
        switch (target.section) {
          final String section => l10n.search_actionSettingLocation(
            target.category,
            section,
          ),
          null => l10n.search_actionSettingCategory(target.category),
        },
        null,
      ),
    };

    return ListTile(
      key: key,
      leading: icon,
      title: Text(title),
      subtitle: Text(subtitle, maxLines: 2, overflow: TextOverflow.ellipsis),
      trailing: trailing,
      onTap: onTap,
    );
  }
}
