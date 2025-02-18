import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_mozilla_components/src/domain/entities/default_selection_actions.dart';
import 'package:flutter_mozilla_components/src/pigeons/gecko.g.dart';

final _apiInstance = GeckoSelectionActionController();

class GeckoSelectionActionService extends GeckoSelectionActionEvents {
  final GeckoSelectionActionController _api;

  List<BaseSelectionAction> _actions;

  List<BaseSelectionAction> get actions => _actions;

  Future<void> setActions(List<BaseSelectionAction> value) async {
    _actions = value;
    await _api.setActions(actions);
  }

  GeckoSelectionActionService.setUp({
    BinaryMessenger? binaryMessenger,
    String messageChannelSuffix = '',
    GeckoSelectionActionController? api,
  }) : _api = api ?? _apiInstance,
       _actions = [] {
    GeckoSelectionActionEvents.setUp(
      this,
      binaryMessenger: binaryMessenger,
      messageChannelSuffix: messageChannelSuffix,
    );
  }

  @override
  void performSelectionAction(String id, String selectedText) {
    _actions.firstWhere((x) => x.id == id).performAction(selectedText);
  }
}
