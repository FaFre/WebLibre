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
import 'package:fast_equatable/fast_equatable.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/repositories/container.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/repositories/tab.dart';

/// What ending this process discards, whichever profile the operation names.
///
/// Every profile maintenance action — backup, delete, replace — leaves through
/// `exitApp`, and it tears down the profile this process is *serving*. So the
/// counts here describe the session in front of the user, not the profile named
/// by the task: backing up an idle profile still costs the current one its
/// private tabs.
class RestartCost with FastEquatable {
  /// Private tabs open across every container, closed by `exitApp` step 1.
  final int privateTabs;

  /// Containers whose data `exitApp` clears because a restart is an exit.
  final int containersClearedOnExit;

  RestartCost({
    required this.privateTabs,
    required this.containersClearedOnExit,
  });

  // Not `const`: [FastEquatable] caches its hash in a mutable field, so nothing
  // mixing it in can have a const constructor.
  static final none = RestartCost(privateTabs: 0, containersClearedOnExit: 0);

  /// Nothing here is worth warning about.
  ///
  /// The distinction the callers exist for: a warning printed on every backup,
  /// most of which cost nothing, is one people learn to tap past — and then it
  /// goes unread on the run where it mattered.
  bool get isEmpty => privateTabs == 0 && containersClearedOnExit == 0;

  @override
  List<Object?> get hashParameters => [privateTabs, containersClearedOnExit];
}

/// Reads what a maintenance restart would discard from the running profile.
///
/// Resolved *before* a confirmation opens rather than watched inside it. Counts
/// that arrive a frame late land under the user's thumb, on a dialog they have
/// already started tapping through.
///
/// Fails soft, and deliberately: these numbers sharpen a warning that is worth
/// showing either way, and the first-run restore path reaches this before the
/// browser has opened much of anything. A missing count must not be able to
/// block the operation it only annotates.
Future<RestartCost> readRestartCost(WidgetRef ref) async {
  try {
    final privateTabs = await ref
        .read(tabDataRepositoryProvider.notifier)
        .countPrivateTabs();

    final containersToClear = await ref
        .read(containerRepositoryProvider.notifier)
        .getContainersToClearOnExit();

    return RestartCost(
      privateTabs: privateTabs,
      containersClearedOnExit: containersToClear.length,
    );
  } catch (error, stackTrace) {
    logger.w(
      'Could not read what a restart would discard',
      error: error,
      stackTrace: stackTrace,
    );

    return RestartCost.none;
  }
}
