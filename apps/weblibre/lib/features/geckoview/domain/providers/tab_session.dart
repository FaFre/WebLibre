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
import 'dart:typed_data';

import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/features/geckoview/domain/providers.dart';
import 'package:weblibre/features/geckoview/domain/repositories/tab.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/services/container_freeze.dart';

part 'tab_session.g.dart';

/// Commands to one tab's page, or the selected tab's.
///
/// The navigations here are the ones a user asks for, so each wakes a
/// sleeping tab first (5.2.1 of `plans/TAB_LOCK_AND_FREEZE_IMPLEMENTATION_PLAN.md`):
/// the engine drops any load into a sleeping tab, and the navigation would
/// otherwise do nothing. A tab whose routing is not ready stays asleep, and
/// the navigation does not run. In a frozen container's tab the user is asked
/// "Resume {container} and open?" instead, and the navigation runs once the
/// container is resumed.
@Riverpod(keepAlive: true)
class TabSession extends _$TabSession {
  late GeckoSessionService _sessionService;
  final _tabsService = GeckoTabService();

  /// The session a navigation goes to, its tab woken when it sleeps; null
  /// when it stays asleep and the navigation must not run. A tab of a frozen
  /// container is never woken by a navigation alone: the user is asked
  /// whether to resume its container first.
  ///
  /// For the selected tab, native's selection is read once and both the wake
  /// and the navigation go to that tab: Dart's selection follows native's
  /// with a delay, so a navigation right after selecting a sleeping tab would
  /// wake the tab selected before while the load went to the sleeping one,
  /// which drops it. The tab's hold and freeze are native's now too, not
  /// the last event's: one placed a moment ago has not reached Dart yet.
  Future<GeckoSessionService?> _sessionForNavigation() async {
    final targetId = tabId ?? await _tabsService.getSelectedTabId();
    if (targetId == null) return _sessionService;
    final lifecycle = await ref
        .read(geckoTabLifecycleServiceProvider)
        .tabLifecycleState(targetId);
    final mayRun = lifecycle?.contextFrozen ?? false
        ? await ref
              .read(containerFreezeServiceProvider.notifier)
              .resumeForNavigation(targetId)
        : await ref
              .read(tabRepositoryProvider.notifier)
              .wakeForNavigation(targetId, lifecycle?.sleepHold);
    if (!mayRun) return null;
    return tabId == null
        ? GeckoSessionService(tabId: targetId)
        : _sessionService;
  }

  Future<void> loadUrl({
    required Uri url,
    LoadUrlFlags flags = LoadUrlFlags.NONE,
    Map<String, String>? additionalHeaders,
  }) async {
    await (await _sessionForNavigation())?.loadUrl(
      url: url,
      flags: flags,
      additionalHeaders: additionalHeaders,
    );
  }

  Future<void> stopLoading() {
    return _sessionService.stopLoading();
  }

  Future<void> reload({LoadUrlFlags flags = LoadUrlFlags.NONE}) async {
    await (await _sessionForNavigation())?.reload(flags: flags);
  }

  Future<void> goBack() async {
    await (await _sessionForNavigation())?.goBack();
  }

  Future<void> goForward() async {
    await (await _sessionForNavigation())?.goForward();
  }

  Future<void> goToHistoryIndex({required int index}) async {
    await (await _sessionForNavigation())?.goToHistoryIndex(index: index);
  }

  Future<void> exitFullscreen() {
    return _sessionService.exitFullscreen();
  }

  Future<Uint8List?> requestScreenshot({bool requireImageResult = true}) {
    return _sessionService.requestScreenshot(requireImageResult);
  }

  /// Does not wake a sleeping tab: the per-site desktop rule calls this on
  /// its own (`DesktopMode`), and nothing automatic may wake a tab. For a
  /// sleeping tab the engine drops the reload.
  Future<void> requestDesktopSite(bool enable) {
    return _sessionService.requestDesktopSite(enable: enable);
  }

  /// [requestDesktopSite] for a choice the user made (the Desktop Site menu
  /// item or quick toggle, its browser action, a site rule added in the site
  /// sheet): a reload they asked for, so it goes as a navigation does. A
  /// sleeping tab is woken first, and a frozen container's tab asks
  /// "Resume {container} and open?". Returns whether it reached the page;
  /// false when the tab stays asleep or frozen.
  Future<bool> requestDesktopSiteExplicitly(bool enable) async {
    final session = await _sessionForNavigation();
    if (session == null) return false;
    await session.requestDesktopSite(enable: enable);
    return true;
  }

  Future<void> saveToPdf() {
    return _sessionService.saveToPdf();
  }

  Future<void> printContent() {
    return _sessionService.printContent();
  }

  Future<void> translate({
    required String fromLanguage,
    required String toLanguage,
    bool? downloadModel,
  }) {
    return _sessionService.translate(
      fromLanguage: fromLanguage,
      toLanguage: toLanguage,
      options: TranslationOptions(downloadModel: downloadModel ?? true),
    );
  }

  Future<void> translateRestore() {
    return _sessionService.translateRestore();
  }

  Future<void> pageUp() {
    // Android KeyEvent.KEYCODE_PAGE_UP = 92
    return _sessionService.dispatchKeyEvent(keyCode: 92);
  }

  Future<void> pageDown() {
    // Android KeyEvent.KEYCODE_PAGE_DOWN = 93
    return _sessionService.dispatchKeyEvent(keyCode: 93);
  }

  Future<void> scrollToTop() {
    // Android KeyEvent.KEYCODE_MOVE_HOME = 122
    return _sessionService.dispatchKeyEvent(keyCode: 122);
  }

  Future<void> scrollToBottom() {
    // Android KeyEvent.KEYCODE_MOVE_END = 123
    return _sessionService.dispatchKeyEvent(keyCode: 123);
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
