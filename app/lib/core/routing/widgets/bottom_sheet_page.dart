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

/// A bottom sheet page with Material entrance and exit animations.
/// Similar to DialogPage but displays content as a modal bottom sheet.
class BottomSheetPage<T> extends Page<T> {
  final WidgetBuilder builder;
  final Color? barrierColor;
  final bool barrierDismissible;
  final String? barrierLabel;
  final bool isScrollControlled;
  final bool useSafeArea;

  const BottomSheetPage({
    required this.builder,
    this.barrierColor,
    this.barrierDismissible = true,
    this.barrierLabel,
    this.isScrollControlled = true,
    this.useSafeArea = true,
    super.key,
    super.name,
    super.arguments,
    super.restorationId,
  });

  @override
  Route<T> createRoute(BuildContext context) => ModalBottomSheetRoute<T>(
        settings: this,
        builder: builder,
        barrierLabel: barrierLabel ??
            MaterialLocalizations.of(context).modalBarrierDismissLabel,
        backgroundColor:
            Theme.of(context).bottomSheetTheme.modalBackgroundColor,
        elevation: Theme.of(context).bottomSheetTheme.modalElevation,
        shape: Theme.of(context).bottomSheetTheme.shape,
        clipBehavior: Clip.antiAlias,
        constraints: Theme.of(context).bottomSheetTheme.constraints,
        isScrollControlled: isScrollControlled,
        isDismissible: barrierDismissible,
        useSafeArea: useSafeArea,
      );
}
