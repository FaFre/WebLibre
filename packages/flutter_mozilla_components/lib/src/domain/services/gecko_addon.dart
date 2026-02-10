/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_mozilla_components/src/extensions/subject.dart';
import 'package:flutter_mozilla_components/src/pigeons/gecko.g.dart';
import 'package:rxdart/rxdart.dart';

typedef ExtensionDataEvent = ({String extensionId, WebExtensionData? data});
typedef ExtensionIconEvent = ({String extensionId, Uint8List bytes});

final _apiInstance = GeckoAddonsApi();

class GeckoAddonService extends GeckoAddonEvents {
  final GeckoAddonsApi _api;

  final _browserExtensionSubject = ReplaySubject<ExtensionDataEvent>();
  final _pageExtensionSubject = ReplaySubject<ExtensionDataEvent>();

  final _browserIconSubject = ReplaySubject<ExtensionIconEvent>();
  final _pageIconSubject = ReplaySubject<ExtensionIconEvent>();

  Stream<ExtensionDataEvent> get browserExtensionStream =>
      _browserExtensionSubject.stream;
  Stream<ExtensionDataEvent> get pageExtensionStream =>
      _pageExtensionSubject.stream;

  Stream<ExtensionIconEvent> get browserIconStream =>
      _browserIconSubject.stream;
  Stream<ExtensionIconEvent> get pageIconStream => _pageIconSubject.stream;

  Future<void> startAddonManagerActivity() {
    return _api.startAddonManagerActivity();
  }

  Future<void> invokeAddonAction(
    String extensionId,
    WebExtensionActionType actionType,
  ) {
    return _api.invokeAddonAction(extensionId, actionType);
  }

  Future<void> installAddon(Uri url) {
    return _api.installAddon(url.toString());
  }

  @override
  void onRemoveWebExtensionAction(
    int sequence,
    String extensionId,
    WebExtensionActionType actionType,
  ) {
    switch (actionType) {
      case WebExtensionActionType.browser:
        _browserExtensionSubject.addWhenMoreRecent(sequence, extensionId, (
          extensionId: extensionId,
          data: null,
        ));
      case WebExtensionActionType.page:
        _pageExtensionSubject.addWhenMoreRecent(sequence, extensionId, (
          extensionId: extensionId,
          data: null,
        ));
    }
  }

  @override
  void onUpdateWebExtensionIcon(
    int sequence,
    String extensionId,
    WebExtensionActionType actionType,
    Uint8List icon,
  ) {
    switch (actionType) {
      case WebExtensionActionType.browser:
        _browserIconSubject.addWhenMoreRecent(sequence, extensionId, (
          extensionId: extensionId,
          bytes: icon,
        ));
      case WebExtensionActionType.page:
        _pageIconSubject.addWhenMoreRecent(sequence, extensionId, (
          extensionId: extensionId,
          bytes: icon,
        ));
    }
  }

  @override
  void onUpsertWebExtensionAction(
    int sequence,
    String extensionId,
    WebExtensionActionType actionType,
    WebExtensionData extensionData,
  ) {
    switch (actionType) {
      case WebExtensionActionType.browser:
        _browserExtensionSubject.addWhenMoreRecent(sequence, extensionId, (
          extensionId: extensionId,
          data: extensionData,
        ));
      case WebExtensionActionType.page:
        _pageExtensionSubject.addWhenMoreRecent(sequence, extensionId, (
          extensionId: extensionId,
          data: extensionData,
        ));
    }
  }

  GeckoAddonService.setUp({
    BinaryMessenger? binaryMessenger,
    GeckoAddonsApi? api,
    String messageChannelSuffix = '',
  }) : _api = api ?? _apiInstance {
    GeckoAddonEvents.setUp(
      this,
      binaryMessenger: binaryMessenger,
      messageChannelSuffix: messageChannelSuffix,
    );
  }

  Future<void> dispose() async {
    await _browserExtensionSubject.close();
    await _pageExtensionSubject.close();
    await _browserIconSubject.close();
    await _pageIconSubject.close();
  }
}
