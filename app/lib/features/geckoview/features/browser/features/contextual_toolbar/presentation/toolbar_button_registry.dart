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
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/features/geckoview/domain/entities/states/readerable.dart';
import 'package:weblibre/features/geckoview/domain/providers.dart';
import 'package:weblibre/features/geckoview/domain/providers/desktop_mode.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_session.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_state.dart';
import 'package:weblibre/features/geckoview/domain/providers/web_extensions_state.dart';
import 'package:weblibre/features/geckoview/domain/repositories/tab.dart';
import 'package:weblibre/features/geckoview/features/bookmarks/domain/entities/bookmark_item.dart';
import 'package:weblibre/features/geckoview/features/bookmarks/domain/repositories/bookmarks.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/entities/font_size_constants.dart';
import 'package:weblibre/features/geckoview/features/browser/features/contextual_toolbar/domain/entities/toolbar_button_spec.dart';
import 'package:weblibre/features/geckoview/features/browser/features/contextual_toolbar/presentation/models/contextual_toolbar_scope.dart';
import 'package:weblibre/features/geckoview/features/browser/features/contextual_toolbar/presentation/widgets/contextual_bar_buttons.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/extension_shortcut_menu.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/font_size_bottom_sheet.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/navigation_buttons.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/tabs_action_button.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/translation_bottom_sheet.dart';
import 'package:weblibre/features/geckoview/features/find_in_page/presentation/controllers/find_in_page.dart';
import 'package:weblibre/features/geckoview/features/readerview/presentation/controllers/readerable.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/entities/tab_mode.dart';
import 'package:weblibre/features/settings/presentation/controllers/save_settings.dart';
import 'package:weblibre/features/user/data/models/engine_settings.dart';
import 'package:weblibre/features/user/domain/repositories/engine_settings.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/utils/move_to_background.dart';
import 'package:weblibre/utils/ui_helper.dart' as ui_helper;

class ToolbarButtonDefinition {
  final ToolbarButtonSpec spec;
  final String label;
  final IconData icon;
  final bool Function(ContextualToolbarScope scope, WidgetRef ref)?
  isPrimaryAvailable;
  final Widget Function(
    ContextualToolbarScope scope,
    BuildContext context,
    WidgetRef ref,
  )
  builder;

  const ToolbarButtonDefinition({
    required this.spec,
    required this.label,
    required this.icon,
    this.isPrimaryAvailable,
    required this.builder,
  });
}

final List<ToolbarButtonDefinition> toolbarButtonRegistry = [
  ToolbarButtonDefinition(
    spec: backToolbarButtonSpec,
    label: 'Back',
    icon: Icons.arrow_back,
    isPrimaryAvailable: (scope, ref) =>
        scope.tabState?.historyState.canGoBack == true ||
        scope.tabState?.isLoading == true,
    builder: (scope, context, ref) {
      if (scope.isPreview) {
        return NavigateBackButtonView(
          canGoBack: true,
          isLoading: false,
          onPressed: () {},
          onLongPress: () {},
        );
      }
      return NavigateBackButton(
        selectedTabId: scope.selectedTabId,
        isLoading: scope.tabState?.isLoading ?? false,
      );
    },
  ),
  ToolbarButtonDefinition(
    spec: forwardToolbarButtonSpec,
    label: 'Forward',
    icon: Icons.arrow_forward,
    isPrimaryAvailable: (scope, ref) =>
        scope.tabState?.historyState.canGoForward == true,
    builder: (scope, context, ref) {
      if (scope.isPreview) {
        return NavigateForwardButtonView(
          canGoForward: true,
          onPressed: () {},
          onLongPress: () {},
        );
      }
      return NavigateForwardButton(selectedTabId: scope.selectedTabId);
    },
  ),
  ToolbarButtonDefinition(
    spec: bookmarksToolbarButtonSpec,
    label: 'Bookmarks',
    icon: MdiIcons.bookmarkMultiple,
    builder: (scope, context, ref) => _BookmarkToolbarButton(scope: scope),
  ),
  ToolbarButtonDefinition(
    spec: shareToolbarButtonSpec,
    label: 'Share',
    icon: Icons.share,
    builder: (scope, context, ref) => scope.isPreview
        ? ShareMenuButtonView(onPressed: () {})
        : ShareMenuButton(selectedTabId: scope.selectedTabId),
  ),
  ToolbarButtonDefinition(
    spec: addTabToolbarButtonSpec,
    label: 'New Tab',
    icon: MdiIcons.tabPlus,
    builder: (scope, context, ref) => scope.isPreview
        ? AddTabButtonView(onPressed: () {}, onLongPress: () {})
        : const AddTabButton(),
  ),
  ToolbarButtonDefinition(
    spec: tabsCountToolbarButtonSpec,
    label: 'Tabs',
    icon: MdiIcons.tab,
    builder: (scope, context, ref) => scope.isPreview
        ? TabsCountButtonView(
            isActive: false,
            onTap: () {},
            onLongPress: () {},
            buttonBuilder: (isActive, onTap, onLongPress) {
              return TabsActionButtonView(
                isActive: isActive,
                tabCountText: '5',
                onTap: onTap,
                onLongPress: onLongPress,
              );
            },
          )
        : TabsCountButton(
            selectedTabId: scope.selectedTabId,
            displayedSheet: scope.displayedSheet,
            showLongPressMenu: false,
          ),
  ),
  ToolbarButtonDefinition(
    spec: navigationMenuToolbarButtonSpec,
    label: 'Menu',
    icon: Icons.more_vert,
    builder: (scope, context, ref) => scope.isPreview
        ? NavigationMenuButtonView(onTap: () {})
        : NavigationMenuButton(selectedTabId: scope.selectedTabId),
  ),
  ToolbarButtonDefinition(
    spec: reloadToolbarButtonSpec,
    label: 'Reload',
    icon: Icons.refresh,
    builder: (scope, context, ref) => _ReloadToolbarButton(scope: scope),
  ),
  ToolbarButtonDefinition(
    spec: readerModeToolbarButtonSpec,
    label: 'Reader Mode',
    icon: MdiIcons.bookOpenOutline,
    isPrimaryAvailable: (scope, ref) {
      final readerableState =
          scope.tabState?.readerableState ?? ReaderableState.$default();
      final enableReadability = ref.read(
        generalSettingsWithDefaultsProvider.select(
          (value) => value.enableReadability,
        ),
      );
      final enforceReadability = ref.read(
        generalSettingsWithDefaultsProvider.select(
          (value) => value.enforceReadability,
        ),
      );
      return (readerableState.readerable &&
              (enableReadability || readerableState.active)) ||
          (enforceReadability && enableReadability);
    },
    builder: (scope, context, ref) {
      if (scope.isPreview) {
        return IconButton(
          onPressed: () {},
          icon: const Icon(MdiIcons.bookOpenOutline),
        );
      }
      return _ReaderModeToolbarButton(selectedTabId: scope.selectedTabId);
    },
  ),
  ToolbarButtonDefinition(
    spec: desktopToolbarButtonSpec,
    label: 'Desktop Site',
    icon: Icons.desktop_windows,
    builder: (scope, context, ref) {
      if (scope.isPreview) {
        return IconButton(
          onPressed: () {},
          icon: const Icon(Icons.desktop_windows_outlined),
        );
      }
      return _DesktopModeToolbarButton(selectedTabId: scope.selectedTabId);
    },
  ),
  ToolbarButtonDefinition(
    spec: translationToolbarButtonSpec,
    label: 'Translate',
    icon: Icons.translate,
    isPrimaryAvailable: (scope, ref) {
      final engineState = ref.read(translationEngineStateProvider);
      final readerActive = scope.tabState?.readerableState.active ?? false;
      return !readerActive && engineState?.isEngineSupported == true;
    },
    builder: (scope, context, ref) {
      if (scope.isPreview) {
        return IconButton(onPressed: () {}, icon: const Icon(Icons.translate));
      }
      return _TranslateToolbarButton(selectedTabId: scope.selectedTabId);
    },
  ),
  ToolbarButtonDefinition(
    spec: findInPageToolbarButtonSpec,
    label: 'Find in Page',
    icon: Icons.search,
    builder: (scope, context, ref) {
      return IconButton(
        onPressed: scope.isPreview
            ? () {}
            : () {
                final tabId = scope.selectedTabId;
                if (tabId != null) {
                  ref.read(findInPageControllerProvider(tabId).notifier).show();
                }
              },
        icon: const Icon(Icons.search),
      );
    },
  ),
  ToolbarButtonDefinition(
    spec: closeTabToolbarButtonSpec,
    label: 'Close Tab',
    icon: MdiIcons.tabMinus,
    builder: (scope, context, ref) => _CloseTabToolbarButton(scope: scope),
  ),
  ToolbarButtonDefinition(
    spec: inputUrlToolbarButtonSpec,
    label: 'Address Bar',
    icon: Icons.edit,
    builder: (scope, context, ref) {
      return IconButton(
        onPressed: scope.isPreview
            ? () {}
            : () async {
                final tabState = scope.tabState;
                if (tabState != null) {
                  final searchText = tabState.url.scheme == 'about'
                      ? SearchRoute.emptySearchText
                      : tabState.url.toString();
                  await SearchRoute(
                    tabId: tabState.id,
                    searchText: searchText.isEmpty
                        ? SearchRoute.emptySearchText
                        : searchText,
                    tabType: tabState.tabMode.toTabType(),
                  ).push(context);
                } else {
                  await const SearchRoute(
                    tabType: TabType.regular,
                  ).push(context);
                }
              },
        icon: const Icon(Icons.edit),
      );
    },
  ),
  ToolbarButtonDefinition(
    spec: duplicateTabToolbarButtonSpec,
    label: 'Duplicate Tab',
    icon: MdiIcons.contentDuplicate,
    builder: (scope, context, ref) {
      return scope.isPreview
          ? CloneTabButtonView(onPressed: () {}, onLongPress: () {})
          : CloneTabButton(selectedTabId: scope.selectedTabId);
    },
  ),
  ToolbarButtonDefinition(
    spec: increaseFontToolbarButtonSpec,
    label: 'Increase Font',
    icon: MdiIcons.formatFontSizeIncrease,
    builder: (scope, context, ref) {
      return IconButton(
        onPressed: scope.isPreview
            ? () {}
            : () => _adjustFontSize(context, ref, increase: true),
        icon: const Icon(MdiIcons.formatFontSizeIncrease),
      );
    },
  ),
  ToolbarButtonDefinition(
    spec: decreaseFontToolbarButtonSpec,
    label: 'Decrease Font',
    icon: MdiIcons.formatFontSizeDecrease,
    builder: (scope, context, ref) {
      return IconButton(
        onPressed: scope.isPreview
            ? () {}
            : () => _adjustFontSize(context, ref, increase: false),
        icon: const Icon(MdiIcons.formatFontSizeDecrease),
      );
    },
  ),
  ToolbarButtonDefinition(
    spec: moveToBackgroundToolbarButtonSpec,
    label: 'Background',
    icon: MdiIcons.arrowCollapseDown,
    builder: (scope, context, ref) {
      return IconButton(
        onPressed: scope.isPreview ? () {} : moveToBackground,
        icon: const Icon(MdiIcons.arrowCollapseDown),
      );
    },
  ),
  ToolbarButtonDefinition(
    spec: pageUpToolbarButtonSpec,
    label: 'Page Up',
    icon: MdiIcons.chevronDoubleUp,
    builder: (scope, context, ref) {
      return IconButton(
        onPressed: scope.isPreview
            ? () {}
            : () async {
                final tabId = scope.selectedTabId;
                if (tabId != null) {
                  await ref
                      .read(tabSessionProvider(tabId: tabId).notifier)
                      .pageUp();
                }
              },
        icon: const Icon(MdiIcons.chevronDoubleUp),
      );
    },
  ),
  ToolbarButtonDefinition(
    spec: pageDownToolbarButtonSpec,
    label: 'Page Down',
    icon: MdiIcons.chevronDoubleDown,
    builder: (scope, context, ref) {
      return IconButton(
        onPressed: scope.isPreview
            ? () {}
            : () async {
                final tabId = scope.selectedTabId;
                if (tabId != null) {
                  await ref
                      .read(tabSessionProvider(tabId: tabId).notifier)
                      .pageDown();
                }
              },
        icon: const Icon(MdiIcons.chevronDoubleDown),
      );
    },
  ),
  ToolbarButtonDefinition(
    spec: fontToolbarButtonSpec,
    label: 'Text Size',
    icon: MdiIcons.formatSize,
    builder: (scope, context, ref) {
      if (scope.isPreview) {
        return IconButton(
          onPressed: () {},
          icon: const Icon(MdiIcons.formatSize),
        );
      }
      return _FontToolbarButton(selectedTabId: scope.selectedTabId);
    },
  ),
  ToolbarButtonDefinition(
    spec: extensionShortcutToolbarButtonSpec,
    label: 'Extensions',
    icon: MdiIcons.puzzle,
    isPrimaryAvailable: (scope, ref) => ref
        .read(
          webExtensionsStateProvider(
            WebExtensionActionType.browser,
          ).select((value) => value.values),
        )
        .isNotEmpty,
    builder: (scope, context, ref) {
      if (scope.isPreview) {
        return IconButton(onPressed: () {}, icon: const Icon(MdiIcons.puzzle));
      }
      return const _ExtensionShortcutToolbarButton();
    },
  ),
];

final Map<String, ToolbarButtonDefinition> toolbarButtonRegistryById = {
  for (final def in toolbarButtonRegistry) def.spec.id.name: def,
};

Future<void> _closeTab(
  BuildContext context,
  WidgetRef ref,
  String? selectedTabId,
) async {
  if (selectedTabId == null) return;

  final tabState = ref.read(tabStateProvider(selectedTabId));
  if (tabState != null && tabState.tabMode is IsolatedTabMode) {
    final allStates = ref.read(tabStatesProvider);
    final groupCount = allStates.values
        .where((s) => s.isolationContextId == tabState.isolationContextId)
        .length;
    if (groupCount <= 1 && context.mounted) {
      final confirmed = await ui_helper.confirmIsolatedTabClose(context);
      if (!confirmed) return;
    }
  }

  await ref.read(tabRepositoryProvider.notifier).closeTab(selectedTabId);

  if (context.mounted) {
    ui_helper.showTabUndoClose(
      context,
      ref.read(tabRepositoryProvider.notifier).undoClose,
    );
  }
}

class _ExtensionShortcutToolbarButton extends HookConsumerWidget {
  const _ExtensionShortcutToolbarButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final menuController = useMemoized(MenuController.new);

    return ExtensionShortcutMenu(
      controller: menuController,
      child: IconButton(
        onPressed: menuController.open,
        icon: const Icon(MdiIcons.puzzle),
      ),
    );
  }
}

class _ReloadToolbarButton extends HookConsumerWidget {
  final ContextualToolbarScope scope;

  const _ReloadToolbarButton({required this.scope});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final menuController = useMemoized(MenuController.new);

    return MenuAnchor(
      controller: menuController,
      builder: (context, controller, child) => child!,
      menuChildren: [
        MenuItemButton(
          leadingIcon: const Icon(Icons.refresh),
          onPressed: () async {
            final tabId = scope.selectedTabId;
            if (tabId != null) {
              await ref
                  .read(tabSessionProvider(tabId: tabId).notifier)
                  .reload(flags: LoadUrlFlags.BYPASS_CACHE);
            }
          },
          child: const Text('Hard Refresh'),
        ),
      ],
      child: IconButton(
        onPressed: scope.isPreview
            ? () {}
            : () async {
                final tabId = scope.selectedTabId;
                if (tabId != null) {
                  await ref
                      .read(tabSessionProvider(tabId: tabId).notifier)
                      .reload();
                }
              },
        onLongPress: scope.isPreview ? null : menuController.open,
        icon: const Icon(Icons.refresh),
      ),
    );
  }
}

class _CloseTabToolbarButton extends HookConsumerWidget {
  final ContextualToolbarScope scope;

  const _CloseTabToolbarButton({required this.scope});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final menuController = useMemoized(MenuController.new);
    final host = ref.watch(
      tabStateProvider(scope.selectedTabId).select((s) => s?.url.host),
    );

    return MenuAnchor(
      controller: menuController,
      builder: (context, controller, child) => child!,
      menuChildren: [
        MenuItemButton(
          leadingIcon: const Icon(Icons.tab),
          onPressed: () async {
            final tabStates = ref.read(tabStatesProvider);
            final otherIds = tabStates.keys
                .where((id) => id != scope.selectedTabId)
                .toList();
            if (otherIds.isNotEmpty) {
              await ref
                  .read(tabRepositoryProvider.notifier)
                  .closeTabs(otherIds);
            }
          },
          child: const Text('Close Others'),
        ),
        if (host != null && host.isNotEmpty)
          MenuItemButton(
            leadingIcon: const Icon(Icons.language),
            onPressed: () async {
              final tabStates = ref.read(tabStatesProvider);
              final sameHostIds = tabStates.entries
                  .where((e) => e.value.url.host == host)
                  .map((e) => e.key)
                  .toList();
              if (sameHostIds.isNotEmpty) {
                await ref
                    .read(tabRepositoryProvider.notifier)
                    .closeTabs(sameHostIds);
              }
            },
            child: const Text('Close from Same Host'),
          ),
      ],
      child: IconButton(
        onPressed: scope.isPreview
            ? () {}
            : () => _closeTab(context, ref, scope.selectedTabId),
        onLongPress: scope.isPreview ? null : menuController.open,
        icon: const Icon(MdiIcons.tabMinus),
      ),
    );
  }
}

class _BookmarkToolbarButton extends HookConsumerWidget {
  final ContextualToolbarScope scope;

  const _BookmarkToolbarButton({required this.scope});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final menuController = useMemoized(MenuController.new);

    final tabUrl = scope.tabState?.url;
    final bookmarkable = tabUrl != null && !scope.isPreview;

    // Walk the in-memory bookmark tree to find GUIDs for the current URL.
    final existingGuids = ref.watch(
      bookmarksRepositoryProvider.select((async) {
        final result = <String>[];

        if (!bookmarkable) return const <String>[];

        final root = async.value;
        if (root == null) return const <String>[];

        void collect(BookmarkItem item) {
          if (item is BookmarkEntry && item.url == tabUrl) {
            result.add(item.guid);
          }

          if (item is BookmarkFolder) {
            for (final child in item.children ?? const <BookmarkItem>[]) {
              collect(child);
            }
          }
        }

        collect(root);

        return result;
      }),
    );

    final isBookmarked = existingGuids.isNotEmpty;

    return MenuAnchor(
      controller: menuController,
      builder: (context, controller, child) => child!,
      menuChildren: [
        if (isBookmarked)
          MenuItemButton(
            leadingIcon: const Icon(MdiIcons.bookmarkRemove),
            onPressed: () async {
              for (final guid in existingGuids) {
                await ref
                    .read(bookmarksRepositoryProvider.notifier)
                    .delete(guid);
              }
              if (context.mounted) {
                ui_helper.showInfoMessage(context, 'Bookmark removed');
              }
            },
            child: const Text('Remove Bookmark'),
          )
        else
          MenuItemButton(
            leadingIcon: const Icon(MdiIcons.bookmarkPlus),
            onPressed: !bookmarkable
                ? null
                : () async {
                    await ref
                        .read(bookmarksRepositoryProvider.notifier)
                        .addBookmark(
                          parentGuid: BookmarkRoot.mobile.id,
                          url: tabUrl,
                          title: scope.tabState!.titleOrAuthority,
                        );

                    if (context.mounted) {
                      ui_helper.showInfoMessage(context, 'Bookmark added');
                    }
                  },
            child: const Text('Add Bookmark'),
          ),
      ],
      child: IconButton(
        onPressed: scope.isPreview
            ? () {}
            : () async {
                await BookmarkListRoute(
                  entryGuid: BookmarkRoot.root.id,
                ).push(context);
              },
        onLongPress: scope.isPreview ? null : menuController.open,
        icon: const Icon(MdiIcons.bookmarkMultiple),
      ),
    );
  }
}

Future<void> _adjustFontSize(
  BuildContext context,
  WidgetRef ref, {
  required bool increase,
}) async {
  final settings = ref.read(engineSettingsWithDefaultsProvider);

  if (settings.automaticFontSizeAdjustment) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Disable automatic font size in settings to adjust manually',
          ),
          duration: Duration(seconds: 2),
        ),
      );
    }
    return;
  }

  final current = settings.fontSizeFactor;
  final newValue = increase
      ? (current + fontSizeStep).clamp(fontSizeMin, fontSizeMax)
      : (current - fontSizeStep).clamp(fontSizeMin, fontSizeMax);
  final rounded = (newValue * 10).round() / 10;

  if (rounded == current) return;

  await ref
      .read(saveEngineSettingsControllerProvider.notifier)
      .save(
        (currentSettings) => currentSettings.copyWith.fontSizeFactor(rounded),
      );
}

class _ReaderModeToolbarButton extends ConsumerWidget {
  final String? selectedTabId;

  const _ReaderModeToolbarButton({required this.selectedTabId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final readerableState = ref.watch(
      tabStateProvider(
        selectedTabId,
      ).select((state) => state?.readerableState ?? ReaderableState.$default()),
    );
    final isReaderLoading = ref.watch(
      readerableScreenControllerProvider.select((state) => state.isLoading),
    );

    return IconButton(
      onPressed: isReaderLoading
          ? null
          : () async {
              await ref
                  .read(readerableScreenControllerProvider.notifier)
                  .toggleReaderView(!readerableState.active);
            },
      icon: Icon(
        readerableState.active ? MdiIcons.bookOpen : MdiIcons.bookOpenOutline,
        color: readerableState.active
            ? Theme.of(context).colorScheme.primary
            : null,
      ),
    );
  }
}

class _DesktopModeToolbarButton extends ConsumerWidget {
  final String? selectedTabId;

  const _DesktopModeToolbarButton({required this.selectedTabId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (selectedTabId == null) {
      return IconButton(
        onPressed: () {},
        icon: const Icon(Icons.desktop_windows),
      );
    }

    final desktopEnabled = ref.watch(desktopModeProvider(selectedTabId!));

    return IconButton(
      onPressed: () {
        ref.read(desktopModeProvider(selectedTabId!).notifier).toggle();
      },
      icon: Icon(
        desktopEnabled ? Icons.desktop_windows : Icons.desktop_windows_outlined,
        color: desktopEnabled ? Theme.of(context).colorScheme.primary : null,
      ),
    );
  }
}

class _TranslateToolbarButton extends ConsumerWidget {
  final String? selectedTabId;

  const _TranslateToolbarButton({required this.selectedTabId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isTranslated = ref.watch(
      tabStateProvider(
        selectedTabId,
      ).select((s) => s?.translationState.isTranslated ?? false),
    );

    return IconButton(
      onPressed: () async {
        final tabId = selectedTabId;
        if (tabId != null) {
          if (isTranslated) {
            await ref
                .read(tabSessionProvider(tabId: tabId).notifier)
                .translateRestore();
          } else {
            await showTranslationBottomSheet(context, selectedTabId: tabId);
          }
        }
      },
      onLongPress: () async {
        final tabId = selectedTabId;
        if (tabId != null) {
          await showTranslationBottomSheet(context, selectedTabId: tabId);
        }
      },
      icon: Icon(
        isTranslated ? MdiIcons.translateOff : Icons.translate,
        color: isTranslated ? Theme.of(context).colorScheme.primary : null,
      ),
    );
  }
}

class _FontToolbarButton extends ConsumerWidget {
  final String? selectedTabId;

  const _FontToolbarButton({required this.selectedTabId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isCustom = ref.watch(
      engineSettingsWithDefaultsProvider.select(
        (s) => !s.automaticFontSizeAdjustment && s.fontSizeFactor != 1.0,
      ),
    );

    return IconButton(
      onPressed: () => showFontSizeBottomSheet(context),
      icon: Icon(
        MdiIcons.formatSize,
        color: isCustom ? Theme.of(context).colorScheme.primary : null,
      ),
    );
  }
}
