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
import 'dart:typed_data';

import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'tab_session.g.dart';

@Riverpod(keepAlive: true)
class TabSession extends _$TabSession {
  late GeckoSessionService _sessionService;

  Future<void> loadUrl({
    required Uri url,
    LoadUrlFlags flags = LoadUrlFlags.NONE,
    Map<String, String>? additionalHeaders,
  }) {
    return _sessionService.loadUrl(
      url: url,
      flags: flags,
      additionalHeaders: additionalHeaders,
    );
  }

  Future<void> stopLoading() {
    return _sessionService.stopLoading();
  }

  Future<void> reload() {
    return _sessionService.reload();
  }

  Future<void> goBack() {
    return _sessionService.goBack();
  }

  Future<void> goForward() {
    return _sessionService.goForward();
  }

  Future<void> exitFullscreen() {
    return _sessionService.exitFullscreen();
  }

  Future<Uint8List?> requestScreenshot({bool requireImageResult = true}) {
    return _sessionService.requestScreenshot(requireImageResult);
  }

  Future<void> requestDesktopSite(bool enable) {
    return _sessionService.requestDesktopSite(enable: enable);
  }

  Future<void> saveToPdf() {
    return _sessionService.saveToPdf();
  }

  @override
  void build({required String? tabId}) {
    _sessionService = (tabId != null)
        ? GeckoSessionService(tabId: tabId)
        : GeckoSessionService.forActiveTab();
  }
}

@Riverpod(keepAlive: true)
Raw<TabSession> selectedTabSessionNotifier(Ref ref) {
  return ref.watch(tabSessionProvider(tabId: null).notifier);
}
