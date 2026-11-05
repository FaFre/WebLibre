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
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/toolbar_button.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/entities/container_filter.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/providers.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/providers/selected_container.dart';

class TabsActionButtonView extends StatelessWidget {
  const TabsActionButtonView({
    super.key,
    required this.isActive,
    required this.tabCountText,
    this.showSkeleton = false,
    this.onTap,
    this.onDoubleTap,
    this.onLongPress,
  });

  final bool isActive;
  final String tabCountText;
  final bool showSkeleton;
  final VoidCallback? onTap;
  final VoidCallback? onDoubleTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconColor = isActive
        ? theme.colorScheme.primary
        : theme.colorScheme.onSurfaceVariant;

    final text = Text(
      tabCountText,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 14.0,
        color: iconColor,
      ),
    );

    return ToolbarButton(
      onTap: onTap,
      onDoubleTap: onDoubleTap,
      onLongPress: onLongPress,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(width: 2.0, color: iconColor),
          borderRadius: BorderRadius.circular(5.0),
        ),
        constraints: const BoxConstraints(minWidth: 25.0),
        child: Center(child: showSkeleton ? Skeletonizer(child: text) : text),
      ),
    );
  }
}

class TabsActionButton extends StatelessWidget {
  final bool isActive;
  final VoidCallback? onTap;
  final VoidCallback? onDoubleTap;
  final VoidCallback? onLongPress;

  const TabsActionButton({
    this.onTap,
    this.onDoubleTap,
    this.onLongPress,
    required this.isActive,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // Each variant watches only the count it shows: every tab while active,
    // the selected container's tabs otherwise.
    return isActive
        ? _AllTabsActionButton(
            onTap: onTap,
            onDoubleTap: onDoubleTap,
            onLongPress: onLongPress,
          )
        : _ContainerTabsActionButton(
            onTap: onTap,
            onDoubleTap: onDoubleTap,
            onLongPress: onLongPress,
          );
  }
}

class _AllTabsActionButton extends ConsumerWidget {
  final VoidCallback? onTap;
  final VoidCallback? onDoubleTap;
  final VoidCallback? onLongPress;

  const _AllTabsActionButton({
    required this.onTap,
    required this.onDoubleTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabCount = ref.watch(
      // ignore: provider_parameters
      containerTabCountProvider(ContainerFilterDisabled()),
    );

    return _buildTabsActionButtonView(
      tabCount,
      isActive: true,
      onTap: onTap,
      onDoubleTap: onDoubleTap,
      onLongPress: onLongPress,
    );
  }
}

class _ContainerTabsActionButton extends ConsumerWidget {
  final VoidCallback? onTap;
  final VoidCallback? onDoubleTap;
  final VoidCallback? onLongPress;

  const _ContainerTabsActionButton({
    required this.onTap,
    required this.onDoubleTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabCount = ref.watch(selectedContainerTabCountProvider);

    return _buildTabsActionButtonView(
      tabCount,
      isActive: false,
      onTap: onTap,
      onDoubleTap: onDoubleTap,
      onLongPress: onLongPress,
    );
  }
}

Widget _buildTabsActionButtonView(
  AsyncValue<int> tabCount, {
  required bool isActive,
  required VoidCallback? onTap,
  required VoidCallback? onDoubleTap,
  required VoidCallback? onLongPress,
}) {
  final tabCountText = tabCount.when(
    skipLoadingOnReload: true,
    data: (count) => count.toString(),
    loading: () => tabCount.hasValue ? tabCount.value.toString() : '0',
    error: (error, stackTrace) {
      logger.e(
        'Could not determine tab count',
        error: error,
        stackTrace: stackTrace,
      );
      return '-1';
    },
  );

  return TabsActionButtonView(
    isActive: isActive,
    tabCountText: tabCountText,
    showSkeleton: tabCount.isLoading && !tabCount.hasValue,
    onTap: onTap,
    onDoubleTap: onDoubleTap,
    onLongPress: onLongPress,
  );
}
