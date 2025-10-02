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
import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rxdart/rxdart.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/entities/sheet.dart';

part 'bottom_sheet.g.dart';

@Riverpod()
class BottomSheetController extends _$BottomSheetController {
  @override
  Sheet? build() {
    return null;
  }

  // ignore: use_setters_to_change_properties api decision
  void show(Sheet sheet) {
    state = sheet;
  }

  void dismiss() {
    state = null;
  }
}

@Riverpod()
class BottomSheetExtend extends _$BottomSheetExtend {
  late StreamController<double> _extentStreamController;

  void add(double extent) {
    if (!_extentStreamController.isClosed) {
      _extentStreamController.add(extent);
    }
  }

  @override
  Stream<double> build() {
    _extentStreamController = StreamController();

    ref.onDispose(() async {
      await _extentStreamController.close();
    });

    return _extentStreamController.stream.sampleTime(
      const Duration(milliseconds: 50),
    );
  }
}
