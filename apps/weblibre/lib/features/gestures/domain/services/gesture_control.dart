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
import 'dart:async';
import 'dart:math';

import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/features/browser_actions/domain/services/browser_action_dispatcher.dart';
import 'package:weblibre/features/geckoview/domain/providers.dart';
import 'package:weblibre/features/geckoview/domain/providers/selected_tab.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_state.dart';
import 'package:weblibre/features/gestures/data/models/gesture_settings.dart';
import 'package:weblibre/features/gestures/data/models/gesture_stroke.dart';
import 'package:weblibre/features/gestures/domain/repositories/gesture_settings.dart';
import 'package:weblibre/utils/host_rules.dart';

part 'gesture_control.g.dart';

/// Bridges gesture settings and recognized-gesture events to app actions.
///
/// On build it (1) keeps the native recognizer's [GestureConfig] in sync with
/// the user's [GestureSettings], and (2) subscribes to recognized gestures and
/// hands the bound [BrowserAction] to [BrowserActionDispatcher].
///
/// Must be kept alive (eagerly listened to from the browser view) for the
/// lifetime of the browser so the subscription stays active.
@Riverpod(keepAlive: true)
class GestureControlService extends _$GestureControlService {
  /// Timestamp (ms since epoch) of the last fired gesture, for cooldown.
  int _lastDispatchMs = 0;

  @override
  void build() {
    final service = ref.read(gestureServiceProvider);

    // Keep the native recognizer in sync with the effective configuration
    // (settings folded together with the current site's exclusion state).
    ref.listen(
      fireImmediately: true,
      gestureNativeConfigProvider,
      (previous, next) async {
        await service.setGestureConfig(next);
      },
      onError: (error, stackTrace) {
        logger.e(
          'Error syncing gesture configuration',
          error: error,
          stackTrace: stackTrace,
        );
      },
    );

    final subscription = service.recognizedGestures.listen(
      (gestureKey) {
        unawaited(_dispatch(gestureKey));
      },
      onError: (Object error, StackTrace stackTrace) {
        logger.e(
          'Error handling recognized gesture',
          error: error,
          stackTrace: stackTrace,
        );
      },
    );
    ref.onDispose(subscription.cancel);
  }

  Future<void> _dispatch(String gestureKey) async {
    final settings = ref.read(gestureSettingsWithDefaultsProvider);
    final action = settings.bindings[gestureKey];
    if (action == null) return;

    // Cooldown: ignore gestures fired within intervalMs of the previous one.
    final now = DateTime.now().millisecondsSinceEpoch;
    if (settings.intervalMs > 0 &&
        now - _lastDispatchMs < settings.intervalMs) {
      return;
    }
    _lastDispatchMs = now;

    // Feedback is handled live by the gesture overlay while the stroke is
    // drawn (driven by the native progress events), so nothing to show here.
    await ref.read(browserActionDispatcherProvider.notifier).run(action);
  }
}

/// Whether gestures are currently disabled because the selected tab's site is
/// on the user's exclusion list.
@Riverpod(keepAlive: true)
bool gestureSiteExcluded(Ref ref) {
  final excludedSites = ref.watch(
    gestureSettingsWithDefaultsProvider.select((s) => s.excludedSites),
  );
  if (excludedSites.isEmpty) return false;

  final tabId = ref.watch(selectedTabProvider);
  if (tabId == null) return false;

  // Kept alive on purpose: the native recognizer config has to follow the
  // selected tab's site even with no gesture UI on screen, and the tab-state
  // selector it holds open is a cheap projection of the keep-alive state map.
  // ignore: riverpod_lint/only_use_keep_alive_inside_keep_alive
  final url = ref.watch(tabStateProvider(tabId).select((state) => state?.url));
  if (url == null) return false;

  return hostMatchesRule(url, excludedSites);
}

/// The effective native recognizer configuration: the user's settings with the
/// recognizer disabled while the current site is excluded.
@Riverpod(keepAlive: true)
GestureConfig gestureNativeConfig(Ref ref) {
  final settings = ref.watch(gestureSettingsWithDefaultsProvider);
  final excluded = ref.watch(gestureSiteExcludedProvider);

  // Recognize as many fingers as any bound gesture requires, so multi-finger
  // bindings work without a separate finger setting.
  final requiredFingers = settings.bindings.keys
      .map((key) => GestureStroke.fromKey(key).fingers)
      .fold(settings.maxFingers, max);

  return GestureConfig(
    enabled: settings.effectiveEnabled && !excluded,
    strokeSize: settings.strokeSize,
    timeoutMs: settings.timeoutMs,
    maxFingers: requiredFingers,
    minStrokeIntervalMs: settings.minStrokeIntervalMs,
    activeGestureKeys: settings.bindings.keys.toList(),
  );
}

/// The in-progress stroke shown by the live feedback overlay.
///
/// Emits the current partial canonical key (e.g. `R:D`) while a stroke is being
/// drawn, and null when nothing should be shown — driven by the native gesture
/// progress/reset events.
@riverpod
Stream<String?> gestureProgress(Ref ref) {
  return ref.watch(gestureServiceProvider).gestureProgress;
}
