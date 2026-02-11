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

import 'package:drift/drift.dart' hide Column;
import 'package:fading_scroll/fading_scroll.dart';
import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:uuid/enums.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_state.dart';
import 'package:weblibre/features/geckoview/domain/repositories/tab.dart';
import 'package:weblibre/features/geckoview/features/contextmenu/extensions/hit_result.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/models/container_data.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/providers.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/repositories/container.dart';
import 'package:weblibre/features/geckoview/features/tabs/presentation/widgets/container_list_tile.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/presentation/widgets/failure_widget.dart';
import 'package:weblibre/utils/ui_helper.dart';

sealed class _PickerResult {}

class _SelectedContainer extends _PickerResult {
  final ContainerData container;
  _SelectedContainer(this.container);
}

class _CreateNewContainer extends _PickerResult {}

class OpenInContainer extends HookConsumerWidget {
  final HitResult hitResult;

  const OpenInContainer({super.key, required this.hitResult});

  static bool isSupported(HitResult hitResult) {
    return hitResult.isHttpLink();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: const Icon(MdiIcons.selectGroup),
      title: const Text('Open in container'),
      onTap: () async {
        final result = await showModalBottomSheet<_PickerResult?>(
          context: context,
          builder: (context) => _ContainerPickerSheet(),
        );

        if (result == null || !context.mounted) return;

        final selectedContainer = switch (result) {
          _SelectedContainer(:final container) => container,
          _CreateNewContainer() => await () async {
            final draft = await ref
                .read(containerRepositoryProvider.notifier)
                .createNewContainer();

            if (!context.mounted) return null;

            return ContainerCreateRoute(
              containerData: jsonEncode(draft.toJson()),
            ).push<ContainerData?>(context);
          }(),
        };

        if (selectedContainer == null || !context.mounted) return;

        final currentTab = ref.read(selectedTabStateProvider);
        final isPrivate =
            currentTab?.isPrivate ??
            ref
                    .read(generalSettingsWithDefaultsProvider)
                    .defaultCreateTabType ==
                TabType.private;

        final tabId = await ref
            .read(tabRepositoryProvider.notifier)
            .addTab(
              url: hitResult.tryGetLink(),
              parentId: currentTab?.id,
              selectTab: false,
              private: isPrivate,
              container: Value(selectedContainer),
            );

        if (context.mounted) {
          final repo = ref.read(tabRepositoryProvider.notifier);

          showTabSwitchMessage(
            context,
            onSwitch: () async {
              await repo.selectTab(tabId);
            },
          );

          context.pop();
        }
      },
    );
  }
}

class _ContainerPickerSheet extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final containersAsync = ref.watch(watchContainersWithCountProvider);

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Select Container',
              style: Theme.of(context).textTheme.titleMedium,
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
                          onTap: () => Navigator.pop(
                            context,
                            _SelectedContainer(container),
                          ),
                        );
                      },
                    );
                  },
                ),
                error: (error, stackTrace) => Center(
                  child: FailureWidget(
                    title: 'Failed to load containers',
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
                      color: Colors.transparent,
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
            title: const Text('New Container'),
            onTap: () => Navigator.pop(context, _CreateNewContainer()),
          ),
        ],
      ),
    );
  }
}
