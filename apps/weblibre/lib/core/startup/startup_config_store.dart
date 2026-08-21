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

import 'package:synchronized/synchronized.dart';
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/core/startup/atomic_json_file.dart';
import 'package:weblibre/core/startup/models/startup_config.dart';
import 'package:weblibre/core/startup/startup_paths.dart';

/// The single writer for `startup_config.json`.
///
/// Atomic rename prevents torn files but not lost updates, so every
/// read-modify-write goes through [_lock]. Kotlin only ever reads this file;
/// it must never write it.
///
/// The lock and the cache belong to the *file*, not to the instance. Callers
/// construct this store ad hoc wherever they need it — queueing a backup, a
/// delete, reading the prompt mode — so an instance-scoped lock would serialize
/// nothing between two of them, and an instance-scoped cache would keep serving a
/// value another instance had already superseded. Both are therefore keyed by
/// path, which also keeps a test that points two stores at different temporary
/// directories independent.
///
/// Serialization is per isolate, which is all this can offer: a second isolate
/// writing the same file is prevented upstream, by the profile-access lease.
class StartupConfigStore {
  StartupConfigStore(this.paths)
    : _file = AtomicJsonFile(paths.startupConfigFile),
      _key = paths.startupConfigFile.path;

  final StartupPaths paths;
  final AtomicJsonFile _file;
  final String _key;

  static final _locks = <String, Lock>{};
  static final _caches = <String, StartupConfig>{};

  Lock get _lock => _locks.putIfAbsent(_key, Lock.new);

  /// Last successfully parsed value, so a read after a write does not have to
  /// touch the disk again. Replaced by every mutation.
  StartupConfig? get _cached => _caches[_key];

  set _cached(StartupConfig? value) {
    if (value == null) {
      _caches.remove(_key);
    } else {
      _caches[_key] = value;
    }
  }

  /// Reads the config, tolerating absence and corruption.
  ///
  /// A corrupt file is renamed aside and [StartupConfig.defaults] is returned.
  /// This deliberately does *not* touch maintenance journals or staging
  /// directories: losing the task list must never erase the evidence that a
  /// destructive operation was in flight, and the journal scanner reserves
  /// maintenance on its own.
  Future<StartupConfig> read({bool useCache = true}) async {
    if (useCache) {
      final cached = _cached;
      if (cached != null) return cached;
    }

    return _lock.synchronized(() => _readLocked());
  }

  Future<StartupConfig> _readLocked() async {
    final result = await _file.read();

    final config = switch (result) {
      AtomicJsonAbsent() => StartupConfig.defaults,
      AtomicJsonPresent(:final json) => StartupConfig.fromJson(json),
      AtomicJsonCorrupt(:final reason) => () {
        logger.w('startup_config.json was corrupt ($reason), using defaults');
        return StartupConfig.defaults;
      }(),
    };

    _cached = config;
    return config;
  }

  /// Serialized read-modify-write. [update] receives the current config and
  /// returns the replacement; returning the same instance skips the write.
  Future<StartupConfig> update(
    FutureOr<StartupConfig> Function(StartupConfig current) update,
  ) {
    return _lock.synchronized(() async {
      final current = await _readLocked();
      final next = await update(current);

      if (identical(next, current)) {
        return current;
      }

      await _file.write(next.toJson());
      _cached = next;
      return next;
    });
  }

  Future<StartupConfig> setProfilePrompt(ProfilePromptMode mode) => update(
    (current) => current.profilePrompt == mode
        ? current
        : current.copyWith(profilePrompt: mode),
  );

  Future<StartupConfig> setHonorShortcutProfile({required bool honor}) =>
      update(
        (current) => current.honorShortcutProfile == honor
            ? current
            : current.copyWith(honorShortcutProfile: honor),
      );

  /// Queues [task], dropping records that have already finished.
  ///
  /// Nothing reads a completed or failed task once the process that ran it has
  /// reported the outcome, and each one carries the SAF tree or source URI it was
  /// given — so keeping them would grow this file by one entry per backup,
  /// restore or delete for the lifetime of the install. They are pruned here
  /// rather than at completion so the finished record stays readable for the run
  /// that produced it.
  ///
  /// A quarantined task is never pruned: its state string is unknown to *this*
  /// build, not finished, and a newer build still has to be able to run it.
  Future<StartupConfig> enqueueTask(MaintenanceTask task) {
    return update((current) {
      if (current.taskById(task.id) != null) {
        return current;
      }

      final retained = current.pendingTasks
          .where(
            (existing) =>
                existing.isQuarantined || existing.state!.requiresMaintenance,
          )
          .toList();

      return current.copyWith(pendingTasks: [...retained, task]);
    });
  }

  /// Applies [transition] to one task. The new state must be reachable from the
  /// current one, otherwise the config is left untouched and the attempt is
  /// logged — an out-of-order transition means two owners are racing, and
  /// silently accepting it would hide that.
  Future<StartupConfig> transitionTask(
    String taskId,
    MaintenanceTaskState next, {
    String? error,
  }) {
    return update((current) {
      final task = current.taskById(taskId);
      if (task == null) {
        logger.w('No maintenance task $taskId to transition to ${next.name}');
        return current;
      }

      // An unknown *action* quarantines the task just as much as an unknown
      // state does: running a task whose operation this build cannot name is
      // exactly the case the quarantine exists to prevent.
      if (task.isQuarantined) {
        logger.w('Refusing to transition quarantined maintenance task $taskId');
        return current;
      }
      final state = task.state!;

      if (state == next) {
        // Through `withState` like the real transition below, so the message and
        // the failure kind move together. `copyWith(error: error)` left the kind
        // behind when the message was cleared, and the kind is what the
        // maintenance screen branches on — a re-entered task then still blamed
        // the password for a run that reported nothing.
        return error == task.error
            ? current
            : _replace(current, task.withState(next, error: error));
      }

      if (!state.canTransitionTo(next)) {
        logger.w(
          'Illegal maintenance transition ${state.name} -> ${next.name} '
          'for task $taskId',
        );
        return current;
      }

      return _replace(current, task.withState(next, error: error));
    });
  }

  /// Records a task-scoped mutation that is not a state change, such as the
  /// staged source path or digest discovered while preparing the operation.
  Future<StartupConfig> mutateTask(
    String taskId,
    MaintenanceTask Function(MaintenanceTask task) mutate,
  ) {
    return update((current) {
      final task = current.taskById(taskId);
      if (task == null) return current;

      final next = mutate(task);
      if (next.id != task.id) {
        throw ArgumentError('Maintenance task id must not change');
      }
      return next == task ? current : _replace(current, next);
    });
  }

  /// Removes a task. Only legal for a cancelled pre-barrier task or one that
  /// has been reconciled against durable evidence.
  Future<StartupConfig> removeTask(String taskId) {
    return update((current) {
      if (current.taskById(taskId) == null) return current;
      return current.copyWith(
        pendingTasks: current.pendingTasks
            .where((task) => task.id != taskId)
            .toList(growable: false),
      );
    });
  }

  StartupConfig _replace(StartupConfig config, MaintenanceTask task) {
    return config.copyWith(
      pendingTasks: [
        for (final existing in config.pendingTasks)
          if (existing.id == task.id) task else existing,
      ],
    );
  }
}
