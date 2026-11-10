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
import 'dart:convert';

import 'package:fading_scroll/fading_scroll.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:uuid/enums.dart';
import 'package:weblibre/core/design/app_colors.dart';
import 'package:weblibre/core/design/display_features.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/features/geckoview/domain/entities/tab_container_selection.dart';
import 'package:weblibre/features/geckoview/domain/repositories/tab.dart';
import 'package:weblibre/features/geckoview/features/contextmenu/extensions/hit_result.dart';
import 'package:weblibre/features/geckoview/features/contextmenu/presentation/utils/context_menu_source.dart';
import 'package:weblibre/features/geckoview/features/search/presentation/widgets/animated_tab_type_switcher.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/entities/tab_mode.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/models/container_data.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/providers.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/repositories/container.dart';
import 'package:weblibre/features/geckoview/features/tabs/presentation/widgets/container_list_tile.dart';
import 'package:weblibre/features/geckoview/features/tabs/utils/background_tab_open.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';
import 'package:weblibre/presentation/widgets/failure_widget.dart';

sealed class _PickerResult {}

class _SelectedContainer extends _PickerResult {
  final ContainerData container;
  _SelectedContainer(this.container);
}

class _CreateNewContainer extends _PickerResult {}

/// What the picker returns: where the tab goes, and as which kind of tab.
typedef _PickerChoice = ({_PickerResult target, TabType tabType});

class OpenInContainer extends HookConsumerWidget {
  final HitResult hitResult;

  /// The tab the long press happened in.
  final String sourceTabId;

  const OpenInContainer({
    super.key,
    required this.hitResult,
    required this.sourceTabId,
  });

  static bool isSupported(HitResult hitResult) {
    return hitResult.isHttpLink();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final settings = ref.watch(generalSettingsWithDefaultsProvider);
    if (!settings.containerEntryPointsShown) {
      return const SizedBox.shrink();
    }

    return ListTile(
      leading: const Icon(MdiIcons.selectGroup),
      title: Text(l10n.contextmenu_openInContainer),
      onTap: () async {
        final pageTabMode =
            readContextMenuSourceTab(ref, sourceTabId)?.tabMode ??
            TabMode.fromTabType(settings.effectiveDefaultCreateTabType);
        final pageTabType = pageTabMode.toTabType();

        final choice = await showModalBottomSheet<_PickerChoice?>(
          context: context,
          anchorPoint: preferredAnchorPoint(MediaQuery.of(context)),
          builder: (context) => _ContainerPickerSheet(
            initialTabType: pageTabType,
            showIsolated:
                settings.isolatedTabEntryPointsShown ||
                pageTabType == TabType.isolated,
          ),
        );

        if (choice == null || !context.mounted) return;

        // The page's own kind keeps the page's mode, an isolated page's group
        // included; another kind is a new tab of that kind.
        final tabMode = choice.tabType == pageTabType
            ? pageTabMode
            : TabMode.fromTabType(choice.tabType);

        final selectedContainer = switch (choice.target) {
          _SelectedContainer(:final container) => container,
          _CreateNewContainer() => await () async {
            final draft = await ref
                .read(containerRepositoryProvider.notifier)
                .createNewContainer();

            if (!context.mounted) return null;

            return await ContainerCreateRoute(
              containerData: jsonEncode(draft.toJson()),
            ).push<ContainerData?>(context);
          }(),
        };

        if (selectedContainer == null || !context.mounted) return;

        final currentTab = readContextMenuSourceTab(ref, sourceTabId);

        final tabId = await ref
            .read(tabRepositoryProvider.notifier)
            .addTab(
              url: hitResult.tryGetLink(),
              parentId: currentTab?.id,
              selectTab: false,
              tabMode: tabMode,
              containerSelection: TabContainerSelection.specific(
                selectedContainer,
              ),
            );

        if (context.mounted) {
          handleBackgroundTabOpened(context, ref, tabId);

          context.pop();
        }
      },
    );
  }
}

/// The kind of tab to open, starting on the page's, above the containers to
/// open the link in: one step instead of a type menu and a container menu.
class _ContainerPickerSheet extends HookConsumerWidget {
  final TabType initialTabType;
  final bool showIsolated;

  const _ContainerPickerSheet({
    required this.initialTabType,
    required this.showIsolated,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final containersAsync = ref.watch(watchContainersWithCountProvider);
    final tabType = useState(initialTabType);
    final colors = AppColors.of(context);

    void pick(_PickerResult target) => Navigator.pop<_PickerChoice>(context, (
      target: target,
      tabType: tabType.value,
    ));

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              l10n.contextmenu_selectContainerTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: AnimatedTabTypeSwitcher(
              selected: tabType.value,
              onChanged: (value) => tabType.value = value,
              showIsolatedOption: showIsolated,
              selectedBackgroundColor: switch (tabType.value) {
                TabType.private => colors.privateSelectionOverlay,
                TabType.isolated => colors.isolatedSelectionOverlay,
                TabType.regular || TabType.child => null,
              },
            ),
          ),
          Flexible(
            child: Skeletonizer(
              enabled: containersAsync.isLoading,
              child: containersAsync.when(
                skipLoadingOnReload: true,
                data: (containers) => FadingScroll(
                  fadingSize: 25,
                  builder: (context, controller) {
                    return ListView.builder(
                      controller: controller,
                      shrinkWrap: true,
                      itemCount: containers.length,
                      itemBuilder: (context, index) {
                        final container = containers[index];
                        return ContainerListTile(
                          container,
                          isSelected: false,
                          onTap: () => pick(_SelectedContainer(container)),
                        );
                      },
                    );
                  },
                ),
                error: (error, stackTrace) => Center(
                  child: FailureWidget(
                    title: l10n.contextmenu_loadContainersFailedTitle,
                    exception: error,
                    onRetry: () =>
                        ref.invalidate(watchContainersWithCountProvider),
                  ),
                ),
                loading: () => ListView.builder(
                  shrinkWrap: true,
                  itemCount: 3,
                  itemBuilder: (context, index) => ContainerListTile(
                    ContainerData(
                      id: Namespace.nil.value,
                      color: Theme.of(context).colorScheme.primary,
                      orderKey: '',
                    ),
                    isSelected: false,
                    onTap: null,
                  ),
                ),
              ),
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.add),
            title: Text(l10n.contextmenu_newContainer),
            onTap: () => pick(_CreateNewContainer()),
          ),
        ],
      ),
    );
  }
}
