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
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:text_scroll/text_scroll.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_state.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/tab_icon.dart';

class AppBarTitle extends HookConsumerWidget {
  const AppBarTitle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    final tabState = ref.watch(selectedTabStateProvider);

    if (tabState == null) {
      return const SizedBox.shrink();
    }

    final icon = useMemoized(() {
      if (tabState.url.isScheme('http')) {
        return Icon(
          MdiIcons.lockOff,
          color: Theme.of(context).colorScheme.error,
          size: 14,
        );
      } else if (tabState.readerableState.active) {
        return const Icon(MdiIcons.lockMinus, size: 14);
      } else if (!tabState.securityInfoState.secure) {
        return Icon(
          MdiIcons.lockAlert,
          color: Theme.of(context).colorScheme.errorContainer,
          size: 14,
        );
      } else if (!tabState.isLoading) {
        return const Icon(MdiIcons.lock, size: 14);
      } else {
        return const Icon(MdiIcons.timerSand, size: 14);
      }
    }, [tabState]);

    return Row(
      children: [
        TabIcon(tabState: tabState),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Skeletonizer(
                enabled: tabState.title.isEmpty,
                child: Skeleton.replace(
                  replacement: const Padding(
                    padding: EdgeInsets.only(right: 4, top: 1, bottom: 1),
                    child: Bone.text(),
                  ),
                  child: TextScroll(
                    key: ValueKey(tabState.title),
                    tabState.title,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                    // mode: TextScrollMode.bouncing,
                    velocity: const Velocity(pixelsPerSecond: Offset(75, 0)),
                    delayBefore: const Duration(milliseconds: 500),
                    pauseBetween: const Duration(milliseconds: 5000),
                    fadedBorder: true,
                    fadeBorderSide: FadeBorderSide.right,
                    fadedBorderWidth: 0.05,
                    intervalSpaces: 4,
                    numberOfReps: 2,
                  ),
                ),
              ),
              Row(
                children: [
                  icon,
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      tabState.url.authority,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
