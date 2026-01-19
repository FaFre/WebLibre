/*
 * Copyright (c) 2024-2025 Fabian Freund.
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
import 'package:nullability/nullability.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/toolbar_button.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/entities/container_filter.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/providers.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/providers/selected_container.dart';
import 'package:weblibre/features/geckoview/features/tabs/utils/container_colors.dart';

class TabsActionButton extends HookConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    final tabCount = isActive
        // ignore: provider_parameters
        ? ref.watch(containerTabCountProvider(ContainerFilterDisabled()))
        : ref.watch(selectedContainerTabCountProvider);

    final containerColor = isActive
        ? null
        : ref.watch(
            selectedContainerDataProvider.select((value) => value.value?.color),
          );

    return ToolbarButton(
      onTap: onTap,
      onDoubleTap: onDoubleTap,
      onLongPress: onLongPress,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            width: 2.0,
            color: isActive
                ? theme.colorScheme.primary
                : DefaultTextStyle.of(context).style.color!,
          ),
          borderRadius: BorderRadius.circular(5.0),
          color: containerColor.mapNotNull(ContainerColors.forAppBar),
        ),
        constraints: const BoxConstraints(minWidth: 25.0),
        child: Center(
          child: tabCount.when(
            skipLoadingOnReload: true,
            data: (count) {
              return Text(
                count.toString(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14.0,
                  color: isActive ? theme.colorScheme.primary : null,
                ),
              );
            },
            loading: () => (tabCount.hasValue)
                ? Text(
                    tabCount.value.toString(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14.0,
                      color: isActive ? theme.colorScheme.primary : null,
                    ),
                  )
                : const Skeletonizer(child: Text('00')),
            error: (error, stackTrace) {
              logger.e(
                'Could not determine tab count',
                error: error,
                stackTrace: stackTrace,
              );

              return Text(
                '-1',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14.0,
                  color: isActive ? theme.colorScheme.primary : null,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
