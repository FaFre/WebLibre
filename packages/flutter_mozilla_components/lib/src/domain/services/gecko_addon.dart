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
typedef ExtensionPopupEvent = ({String extensionId, String extensionName});

final _apiInstance = GeckoAddonsApi();

class GeckoAddonService extends GeckoAddonEvents {
  final GeckoAddonsApi _api;

  final _browserExtensionSubject = ReplaySubject<ExtensionDataEvent>();
  final _pageExtensionSubject = ReplaySubject<ExtensionDataEvent>();

  final _browserIconSubject = ReplaySubject<ExtensionIconEvent>();
  final _pageIconSubject = ReplaySubject<ExtensionIconEvent>();
  final _popupSubject = PublishSubject<ExtensionPopupEvent>();
  final _openAddonSettingsSubject = PublishSubject<String>();

  Stream<ExtensionDataEvent> get browserExtensionStream =>
      _browserExtensionSubject.stream;
  Stream<ExtensionDataEvent> get pageExtensionStream =>
      _pageExtensionSubject.stream;

  Stream<ExtensionIconEvent> get browserIconStream =>
      _browserIconSubject.stream;
  Stream<ExtensionIconEvent> get pageIconStream => _pageIconSubject.stream;
  Stream<ExtensionPopupEvent> get popupStream => _popupSubject.stream;
  Stream<String> get openAddonSettingsStream =>
      _openAddonSettingsSubject.stream;

  Future<List<AddonInfo>> getAddons({bool allowCache = true}) {
    return _api.getAddons(allowCache);
  }

  Future<AddonInfo?> getAddonById(String addonId, {bool allowCache = true}) {
    return _api.getAddonById(addonId, allowCache);
  }

  Future<AddonStoreInfo?> getAddonStoreInfo(String addonId) {
    return _api.getAddonStoreInfo(addonId);
  }

  Future<List<AddonListing>> searchAddonListings({
    required String query,
    required AddonStoreApp app,
    int page = 1,
    int pageSize = 25,
  }) {
    return _api.searchAddonListings(query, app, page, pageSize);
  }

  Future<List<AddonListing>> getFeaturedAddonListings({
    required AddonStoreApp app,
    int pageSize = 25,
  }) {
    return _api.getFeaturedAddonListings(app, pageSize);
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

  Future<AddonInfo> enableAddon(String addonId) {
    return _api.enableAddon(addonId);
  }

  Future<AddonInfo> disableAddon(String addonId) {
    return _api.disableAddon(addonId);
  }

  Future<AddonInfo> setAddonAllowedInPrivateBrowsing(
    String addonId,
    bool allowed,
  ) {
    return _api.setAddonAllowedInPrivateBrowsing(addonId, allowed);
  }

  Future<AddonInfo> setAddonAutoUpdateEnabledForAddon(
    String addonId,
    bool enabled,
  ) {
    return _api.setAddonAutoUpdateEnabledForAddon(addonId, enabled);
  }

  Future<void> uninstallAddon(String addonId) {
    return _api.uninstallAddon(addonId);
  }

  Future<AddonUpdateAttemptInfo?> triggerAddonUpdate(String addonId) {
    return _api.triggerAddonUpdate(addonId);
  }

  Future<void> triggerAllAddonUpdates() {
    return _api.triggerAllAddonUpdates();
  }

  Future<AddonUpdateAttemptInfo?> getLastAddonUpdateAttempt(String addonId) {
    return _api.getLastAddonUpdateAttempt(addonId);
  }

  Future<bool> isAddonAutoUpdateEnabled() {
    return _api.isAddonAutoUpdateEnabled();
  }

  Future<void> setAddonAutoUpdateEnabled({required bool enabled}) {
    return _api.setAddonAutoUpdateEnabled(enabled);
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

  @override
  void onWebExtensionPopupRequested(String extensionId, String extensionName) {
    _popupSubject.add((extensionId: extensionId, extensionName: extensionName));
  }

  @override
  void onOpenAddonSettingsRequested(String addonId) {
    _openAddonSettingsSubject.add(addonId);
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
    await _popupSubject.close();
    await _openAddonSettingsSubject.close();
  }
}
