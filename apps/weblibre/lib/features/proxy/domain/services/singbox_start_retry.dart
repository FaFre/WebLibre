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

import 'package:fast_equatable/fast_equatable.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/features/proxy/domain/repositories/singbox_proxy_profiles.dart';
import 'package:weblibre/features/proxy/domain/repositories/singbox_proxy_runtime.dart';

part 'singbox_start_retry.g.dart';

/// A sing-box profile whose unattended start failed, and what happens next.
class SingboxStartRetry with FastEquatable {
  /// Attempts made so far, the one that first failed included.
  final int attempts;

  /// When the next attempt runs, or null once every attempt has been made.
  final DateTime? nextAttemptAt;

  SingboxStartRetry({required this.attempts, required this.nextAttemptAt});

  bool get exhausted => nextAttemptAt == null;

  @override
  List<Object?> get hashParameters => [attempts, nextAttemptAt];
}

/// The pauses before each automatic attempt after a failed one; their count
/// is how many attempts are made.
///
/// Spread out because the failures worth retrying are the ones that clear up
/// on their own — a WireGuard peer that does not resolve while the device has
/// no usable network yet, a server that is briefly down — and the ones that do
/// not should not be hammered.
@Riverpod(keepAlive: true)
List<Duration> singboxStartRetryDelays(Ref ref) => const [
  Duration(seconds: 5),
  Duration(seconds: 15),
  Duration(seconds: 45),
  Duration(minutes: 2),
  Duration(minutes: 5),
];

/// Tries again to start sing-box profiles that failed to start when nobody
/// was there to retry them: those startup brings up, those a Custom Tab or PWA
/// launch asked for, and running ones a failed start took down.
///
/// sing-box resolves a WireGuard peer's hostname exactly once, while it
/// starts, and a start that fails is never attempted again — so a profile that
/// could not come up at a cold start, before the network was usable, stayed
/// down until the user noticed and started it by hand (issue #669). A start
/// the user asked for is not retried here: they are told it failed and decide.
///
/// The state is keyed by profile id and is what the UI shows as "could not
/// start". An entry goes away when its profile runs, however that happened,
/// or when the profile no longer exists.
@Riverpod(keepAlive: true)
class SingboxStartRetries extends _$SingboxStartRetries {
  final _timers = <String, Timer>{};

  @override
  Map<String, SingboxStartRetry> build() {
    ref.onDispose(() {
      for (final timer in _timers.values) {
        timer.cancel();
      }
      _timers.clear();
    });

    ref.listen(runningSingboxProfileIdsProvider, (_, running) {
      final settled = state.keys.where(running.contains).toList();
      if (settled.isNotEmpty) _drop(settled);
    });

    // Running profiles a failed start took down for good: nobody was there
    // to start them again either.
    ref.listen(singboxProxyLostProfilesProvider, (_, lost) {
      if (lost != null) failed(lost.profileIds, permanent: lost.permanent);
    });

    return const {};
  }

  /// Records that starting [profileIds] failed and schedules their next
  /// attempt — or, when [permanent], records that there will be none: a
  /// config sing-box refuses does not fix itself by waiting.
  void failed(Iterable<String> profileIds, {bool permanent = false}) {
    final running = ref.read(runningSingboxProfileIdsProvider);

    for (final profileId in profileIds) {
      // The runtime puts back what was running before a failed start, so a
      // profile in a failed batch may well be up.
      if (running.contains(profileId)) continue;

      final attempts = (state[profileId]?.attempts ?? 0) + 1;
      if (permanent) {
        _giveUp(profileId, attempts: attempts);
      } else {
        _scheduleNext(profileId, attempts: attempts);
      }
    }
  }

  /// Forgets [profileIds] and calls off their next attempt: the user stopped
  /// them, and a profile they stopped must not come up by itself later.
  void cancel(Iterable<String> profileIds) => _drop(profileIds);

  /// [cancel] for every profile.
  void cancelAll() => _drop({...state.keys, ..._timers.keys});

  void _giveUp(String profileId, {required int attempts}) {
    _timers.remove(profileId)?.cancel();
    state = {
      ...state,
      profileId: SingboxStartRetry(attempts: attempts, nextAttemptAt: null),
    };
  }

  void _scheduleNext(String profileId, {required int attempts}) {
    final delays = ref.read(singboxStartRetryDelaysProvider);
    _timers.remove(profileId)?.cancel();

    if (attempts > delays.length) {
      logger.w(
        'Giving up on starting sing-box proxy profile $profileId after '
        '$attempts attempts',
      );
      _giveUp(profileId, attempts: attempts);
      return;
    }

    final delay = delays[attempts - 1];
    state = {
      ...state,
      profileId: SingboxStartRetry(
        attempts: attempts,
        nextAttemptAt: DateTime.now().add(delay),
      ),
    };
    _timers[profileId] = Timer(
      delay,
      () => unawaited(_attempt(profileId, attempts: attempts)),
    );
  }

  Future<void> _attempt(String profileId, {required int attempts}) async {
    _timers.remove(profileId);
    final entry = state[profileId];
    if (!ref.mounted || entry == null) return;

    // Cancelled since, and possibly failed again since — then the entry is a
    // new one, with its own timer, and this attempt is not the one it waits
    // for.
    bool stillWanted() => ref.mounted && identical(state[profileId], entry);

    try {
      final profile = await ref
          .read(singboxProxyProfilesRepositoryProvider.notifier)
          .findProfile(profileId);
      if (!stillWanted()) return;
      if (profile == null) {
        _drop([profileId]);
        return;
      }

      // Asks again under the runtime lock: a stop queued ahead of this
      // attempt has run by then, and [cancel] came before it.
      final started = await ref
          .read(singboxProxyRuntimeRepositoryProvider.notifier)
          .retryProfile(profileId, stillWanted: stillWanted);
      if (started == null || !ref.mounted) return;

      logger.i(
        'Started sing-box proxy profile $profileId on attempt ${attempts + 1}',
      );
      _drop([profileId]);
    } catch (error, stackTrace) {
      if (!stillWanted()) return;

      if (error is SingboxProfilesRejected) {
        logger.w('sing-box refuses sing-box proxy profile $profileId: $error');
        _giveUp(profileId, attempts: attempts + 1);
        return;
      }

      if (error is SingboxProbeFailed) {
        // The runtime was left alone, so there is no stack worth keeping.
        logger.w(
          'Attempt ${attempts + 1} to start sing-box proxy profile $profileId '
          'skipped: $error',
        );
      } else {
        logger.w(
          'Attempt ${attempts + 1} to start sing-box proxy profile '
          '$profileId failed',
          error: error,
          stackTrace: stackTrace,
        );
      }
      _scheduleNext(profileId, attempts: attempts + 1);
    }
  }

  void _drop(Iterable<String> profileIds) {
    final dropped = profileIds.toSet();
    for (final profileId in dropped) {
      _timers.remove(profileId)?.cancel();
    }
    state = {
      for (final entry in state.entries)
        if (!dropped.contains(entry.key)) entry.key: entry.value,
    };
  }
}
