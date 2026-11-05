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
import 'dart:ui';

import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/features/geckoview/domain/providers/selected_tab.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/providers.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';

part 'browser_bar_tint.g.dart';

/// The active container's color the browser chrome is tinted with.
typedef BrowserBarTint = ({Color color, bool useCustomColor});

/// The tint of the browser chrome: the selected tab's container color, or
/// null while no container is active or containers are hidden.
@Riverpod()
BrowserBarTint? browserBarTint(Ref ref) {
  final selectedTabId = ref.watch(selectedTabProvider);
  final showContainerUi = ref.watch(
    generalSettingsWithDefaultsProvider.select((s) => s.showContainerUi),
  );
  final containerColor = ref.watch(
    watchTabContainerDataProvider(
      selectedTabId,
    ).select((data) => data.value?.color),
  );
  final useCustomColor = ref.watch(
    watchTabContainerDataProvider(
      selectedTabId,
    ).select((data) => data.value?.metadata.useCustomColor ?? false),
  );

  if (!showContainerUi || containerColor == null) return null;
  return (color: containerColor, useCustomColor: useCustomColor);
}
