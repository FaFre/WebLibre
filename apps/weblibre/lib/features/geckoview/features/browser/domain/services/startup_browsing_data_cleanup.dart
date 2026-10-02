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

import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/services/browser_data.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';

part 'startup_browsing_data_cleanup.g.dart';

/// Deletes [GeneralSettings.autoDeleteBrowsingData] when the browser starts.
///
/// This is also what completes a Quit that died half way through its own
/// deletion, so a start must never skip it. Nothing it does may reach a tab
/// opened in this session, however late it runs:
///
/// - **Tabs are scoped to the previous session.** Native removes only the tabs
///   the session restore brought back, after that restore completed — never a
///   launch link or home page tab, even when this runs late or is retried.
/// - **Everything else runs only while new tabs are held back.** Cookie, cache
///   and the other deletions are global: one that runs after browsing began
///   would take this session's logins with it. So they are dispatched only
///   while [waitUntilDone] still holds new tabs — during the first run, and
///   never after a wait on it timed out. What did not get done is left for the
///   next start, which deletes it anyway.
/// - **Progress is kept per data type.** A retry (a remount of the browser after
///   a failure) repeats only the previous-session tab deletion, if that is what
///   failed, against the selection taken on the first run.
@Riverpod(keepAlive: true)
class StartupBrowsingDataCleanup extends _$StartupBrowsingDataCleanup {
  /// The timeout is test-only injection; production uses the default.
  StartupBrowsingDataCleanup({
    @visibleForTesting Duration waitTimeout = const Duration(seconds: 30),
  }) : _waitTimeout = waitTimeout;

  /// Safety valve for tab creation: a cleanup that hangs must not hold new
  /// tabs back for the rest of the session.
  final Duration _waitTimeout;

  /// The data types this process deletes, read once on the first run.
  Set<DeleteBrowsingDataType>? _selection;
  final _completed = <DeleteBrowsingDataType>{};

  Future<void>? _running;

  /// Completed when the first run finishes, or for good once a wait on it has
  /// timed out. Null until the first [start].
  Completer<void>? _gate;

  @override
  void build() {}

  /// Runs whatever part of the startup cleanup has not succeeded yet. Safe to
  /// call again: while one is running it returns that one, and once everything
  /// succeeded it does nothing.
  ///
  /// Call it before anything that could open a tab can run: [waitUntilDone]
  /// only waits for a cleanup that has already started. The returned future
  /// never fails.
  Future<void> start() {
    if (_isDone) return Future.value();

    _gate ??= Completer<void>();
    return _running ??= _run().whenComplete(() {
      _running = null;
      _releaseGate();
    });
  }

  /// Waits for the first run, if it is still going.
  Future<void> waitUntilDone() async {
    final gate = _gate;
    if (gate == null || gate.isCompleted) return;

    try {
      await gate.future.timeout(_waitTimeout);
    } on TimeoutException {
      logger.w(
        'Startup browsing data cleanup still running after '
        '${_waitTimeout.inSeconds}s; no longer holding new tabs back',
      );
      _releaseGate();
    }
  }

  bool get _isDone {
    final selection = _selection;
    return selection != null && !selection.any(_isOutstanding);
  }

  /// Whether new tabs have been let through: by the end of the first run, or by
  /// a wait on it timing out.
  bool get _gateReleased => _gate?.isCompleted ?? false;

  /// Only the previous-session tab deletion is scoped, so it alone may still run
  /// once browsing has begun.
  bool _mayRun(DeleteBrowsingDataType type) =>
      type == DeleteBrowsingDataType.tabs || !_gateReleased;

  bool _isOutstanding(DeleteBrowsingDataType type) =>
      !_completed.contains(type) && _mayRun(type);

  void _releaseGate() {
    final gate = _gate;
    if (gate != null && !gate.isCompleted) gate.complete();
  }

  Future<void> _run() async {
    try {
      _selection ??=
          (await ref
                  .read(generalSettingsRepositoryProvider.notifier)
                  .fetchSettings())
              .autoDeleteBrowsingData ??
          const {};
    } catch (e, st) {
      logger.e(
        'Could not read what to delete on start',
        error: e,
        stackTrace: st,
      );
      return;
    }

    final selection = _selection!;
    final browserData = ref.read(browserDataServiceProvider.notifier);

    // Tabs last: deleting them waits for the session restore, which must not
    // hold up the other types.
    final pending = [
      ...DeleteBrowsingDataType.values.where(
        (type) => type != DeleteBrowsingDataType.tabs,
      ),
      DeleteBrowsingDataType.tabs,
    ].where(selection.contains);

    for (final type in pending) {
      if (!ref.mounted) return;
      // Checked before each one, not once: the gate can time out in between.
      if (!_isOutstanding(type)) {
        if (!_completed.contains(type)) {
          logger.w(
            'Startup deletion of ${type.name} skipped: browsing has begun. '
            'The next start deletes it.',
          );
        }
        continue;
      }

      // One failing type does not stop the others.
      try {
        await browserData.deleteDataType(type, previousSessionTabsOnly: true);
        _completed.add(type);
      } catch (e, st) {
        logger.e(
          type == DeleteBrowsingDataType.tabs
              ? 'Startup deletion of tabs failed; it will be retried'
              : 'Startup deletion of ${type.name} failed; the next start '
                    'deletes it',
          error: e,
          stackTrace: st,
        );
      }
    }
  }
}
