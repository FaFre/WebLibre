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

  @override
  void onRemoveWebExtensionAction(
    int timestamp,
    String extensionId,
    WebExtensionActionType actionType,
  ) {
    switch (actionType) {
      case WebExtensionActionType.browser:
        _browserExtensionSubject.addWhenMoreRecent(timestamp, extensionId, (
          extensionId: extensionId,
          data: null,
        ),);
      case WebExtensionActionType.page:
        _pageExtensionSubject.addWhenMoreRecent(timestamp, extensionId, (
          extensionId: extensionId,
          data: null,
        ),);
    }
  }

  @override
  void onUpdateWebExtensionIcon(
    int timestamp,
    String extensionId,
    WebExtensionActionType actionType,
    Uint8List icon,
  ) {
    switch (actionType) {
      case WebExtensionActionType.browser:
        _browserIconSubject.addWhenMoreRecent(timestamp, extensionId, (
          extensionId: extensionId,
          bytes: icon,
        ),);
      case WebExtensionActionType.page:
        _pageIconSubject.addWhenMoreRecent(timestamp, extensionId, (
          extensionId: extensionId,
          bytes: icon,
        ),);
    }
  }

  @override
  void onUpsertWebExtensionAction(
    int timestamp,
    String extensionId,
    WebExtensionActionType actionType,
    WebExtensionData extensionData,
  ) {
    switch (actionType) {
      case WebExtensionActionType.browser:
        _browserExtensionSubject.addWhenMoreRecent(timestamp, extensionId, (
          extensionId: extensionId,
          data: extensionData,
        ),);
      case WebExtensionActionType.page:
        _pageExtensionSubject.addWhenMoreRecent(timestamp, extensionId, (
          extensionId: extensionId,
          data: extensionData,
        ),);
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

  void dispose() {
    unawaited(_browserExtensionSubject.close());
    unawaited(_pageExtensionSubject.close());
    unawaited(_browserIconSubject.close());
    unawaited(_pageIconSubject.close());
  }
}
