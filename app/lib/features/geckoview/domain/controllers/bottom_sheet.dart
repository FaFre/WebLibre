import 'dart:async';

import 'package:lensai/features/geckoview/features/browser/domain/entities/sheet.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rxdart/rxdart.dart';

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

@Riverpod(keepAlive: true)
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
