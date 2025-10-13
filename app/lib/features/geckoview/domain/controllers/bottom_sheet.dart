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

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/entities/sheet.dart';

part 'bottom_sheet.g.dart';

@Riverpod(keepAlive: true)
class BottomSheetController extends _$BottomSheetController {
  @override
  Sheet? build() {
    return null;
  }

  ///We depend on a listener that updates/syncs UI to open the sheet
  // ignore: use_setters_to_change_properties api decision
  void show(Sheet sheet) {
    state = sheet;
  }

  ///We depend on a listener that updates/syncs UI to close the sheet
  void requestDismiss() {
    state = null;
  }

  ///This is called by UI when the sheet gets closed
  void closed(Sheet sheet) {
    if (sheet == stateOrNull) {
      state = null;
    }
  }
}
