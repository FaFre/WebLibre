import 'dart:typed_data';

import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'tab_session.g.dart';

@Riverpod()
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

  @override
  void build({required String? tabId}) {
    _sessionService = (tabId != null)
        ? GeckoSessionService(tabId: tabId)
        : GeckoSessionService.forActiveTab();
  }
}

@Riverpod()
Raw<TabSession> selectedTabSessionNotifier(Ref ref) {
  return ref.watch(tabSessionProvider(tabId: null).notifier);
}
