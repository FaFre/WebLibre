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
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/features/geckoview/domain/entities/states/readerable.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_state.dart';
import 'package:weblibre/features/geckoview/features/readerview/presentation/controllers/readerable.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/presentation/widgets/animate_gradient_shader.dart';

class ReaderButton extends HookConsumerWidget {
  final Widget Function(bool isLoading, bool readerActive, Widget icon)
  buttonBuilder;

  const ReaderButton({super.key, required this.buttonBuilder});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    final readerChanging = ref.watch(readerableScreenControllerProvider);

    final enableReadability = ref.watch(
      generalSettingsWithDefaultsProvider.select(
        (value) => value.enableReadability,
      ),
    );

    final enforceReadability = ref.watch(
      generalSettingsWithDefaultsProvider.select(
        (value) => value.enforceReadability,
      ),
    );

    final readerabilityState = ref.watch(
      selectedTabStateProvider.select(
        (state) => state?.readerableState ?? ReaderableState.$default(),
      ),
    );

    final icon = readerabilityState.active
        ? Icon(MdiIcons.bookOpen, color: Theme.of(context).colorScheme.primary)
        : Icon(
            MdiIcons.bookOpenOutline,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          );

    return Visibility(
      visible:
          (readerabilityState.readerable &&
              (enableReadability || readerabilityState.active)) ||
          (enforceReadability && enableReadability),
      child: readerChanging.when(
        skipLoadingOnReload: true,
        data: (_) => buttonBuilder(
          readerChanging.isLoading,
          readerabilityState.active,
          icon,
        ),
        error: (error, stackTrace) => SizedBox.shrink(),
        loading: () => AnimateGradientShader(
          duration: const Duration(milliseconds: 500),
          primaryEnd: Alignment.bottomLeft,
          secondaryEnd: Alignment.topRight,
          primaryColors: [colorScheme.primary, colorScheme.primaryContainer],
          secondaryColors: [
            colorScheme.secondary,
            colorScheme.secondaryContainer,
          ],
          child: buttonBuilder(true, readerabilityState.active, icon),
        ),
      ),
    );
  }
}
