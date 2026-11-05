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
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/features/geckoview/domain/providers.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_state.dart';
import 'package:weblibre/features/geckoview/features/pwa/domain/providers.dart';

part 'page_action_availability.g.dart';

/// Which conditional rows of the menu's page actions apply to
/// [selectedTabId].
typedef PageActionAvailability = ({
  bool translate,
  bool installable,
  bool shortcutable,
});

/// Whether the Translate and Add to home screen rows apply.
///
/// Only the rows in the layout are checked ([translateInLayout],
/// [addToHomeScreenInLayout]): a row the user removed watches nothing, so
/// translation and install state changes do not rebuild the menu.
@Riverpod()
PageActionAvailability pageActionAvailability(
  Ref ref,
  String selectedTabId, {
  required bool translateInLayout,
  required bool addToHomeScreenInLayout,
}) {
  var translate = false;
  if (translateInLayout) {
    // Hidden while reader mode is active (Fenix-aligned).
    final readerActive = ref.watch(
      tabStateProvider(
        selectedTabId,
      ).select((s) => s?.readerableState.active ?? false),
    );
    final engineSupported = ref.watch(
      translationEngineStateProvider.select(
        (state) => state?.isEngineSupported == true,
      ),
    );
    translate = !readerActive && engineSupported;
  }

  final installable =
      addToHomeScreenInLayout && ref.watch(isCurrentTabInstallableProvider);
  final shortcutable =
      addToHomeScreenInLayout && ref.watch(isCurrentTabShortcutableProvider);

  return (
    translate: translate,
    installable: installable,
    shortcutable: shortcutable,
  );
}
