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
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:path/path.dart' as p;
import 'package:secure_archive/secure_archive.dart';
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/features/user/data/models/auth_settings.dart';

/// Per-profile record of wrong password attempts, kept beside `metadata.json`.
///
/// On disk rather than in memory: a counter that resets when the app is killed
/// throttles nobody, because killing the app is one swipe.
const profileLockAttemptsFileName = 'lock_attempts.json';

/// Encrypted by the verifier and checked after decryption.
///
/// The MAC already proves the password; comparing the plaintext as well keeps a
/// verifier from some other `SecureData` blob from passing.
const _verifierPlaintext = 'weblibre-profile-lock-v1';

/// Wrong attempts allowed before each further one has to wait.
const _freeAttempts = 5;
const _firstDelay = Duration(seconds: 30);
const _maxDelay = Duration(hours: 1);

SecureData _secureData() =>
    SecureData(argon2Params: Argon2Params.memoryConstrained());

/// Creates the proof of [password] stored in [AuthSettings.passwordVerifier].
///
/// The password is stretched with the same Argon2id parameters as backups and
/// used to encrypt a fixed value, so a verifier opens only under the right
/// password and says nothing else about it. A copy of `metadata.json` is no
/// shortcut either: whoever can read that file can already read the profile's
/// data next to it.
Future<String> createProfilePasswordVerifier(String password) async {
  final blob = await _secureData().encrypt(
    utf8.encode(_verifierPlaintext),
    password,
  );
  return base64Encode(blob);
}

/// Whether [password] opens [verifier].
///
/// A damaged verifier answers false, like a wrong password: neither can be told
/// apart by the person typing, and both must keep the profile locked.
Future<bool> matchesProfilePassword(String verifier, String password) async {
  if (password.isEmpty) return false;

  try {
    final plaintext = await _secureData().decrypt(
      base64Decode(verifier),
      password,
    );
    return utf8.decode(plaintext) == _verifierPlaintext;
  } on ArchiveWrongPassword {
    return false;
  } catch (error, stackTrace) {
    logger.e(
      'Profile password verifier is unreadable',
      error: error,
      stackTrace: stackTrace,
    );
    return false;
  }
}

/// How long the next attempt has to wait after [failures] wrong ones in a row.
Duration? profilePasswordDelayAfter(int failures) {
  if (failures < _freeAttempts) return null;

  final delay = _firstDelay * pow(2, min(failures - _freeAttempts, 16)).toInt();
  return delay > _maxDelay ? _maxDelay : delay;
}

sealed class ProfilePasswordCheck {
  const ProfilePasswordCheck();
}

final class ProfilePasswordAccepted extends ProfilePasswordCheck {
  const ProfilePasswordAccepted();
}

/// The password was wrong. [retryAfter] is set when this attempt used up the
/// free ones and the next has to wait.
final class ProfilePasswordRejected extends ProfilePasswordCheck {
  final Duration? retryAfter;

  const ProfilePasswordRejected({this.retryAfter});
}

/// The password was right, but the app left the foreground before the answer
/// arrived, so it does not take effect. The person enters it again once they
/// are back.
///
/// Never returned by [ProfilePasswordGate]; the callers that know about the
/// app's lifecycle turn an accepted check into this.
final class ProfilePasswordInterrupted extends ProfilePasswordCheck {
  const ProfilePasswordInterrupted();
}

/// Not checked at all: an earlier run of wrong attempts is still being waited
/// out.
final class ProfilePasswordThrottled extends ProfilePasswordCheck {
  final Duration retryAfter;

  const ProfilePasswordThrottled(this.retryAfter);
}

/// Checks a profile's password and throttles repeated wrong attempts.
class ProfilePasswordGate {
  final Directory profileDir;
  final DateTime Function() _now;
  final Future<bool> Function(String verifier, String password) _matches;

  ProfilePasswordGate(
    this.profileDir, {
    DateTime Function()? now,
    Future<bool> Function(String verifier, String password)? matches,
  }) : _now = now ?? DateTime.now,
       _matches = matches ?? matchesProfilePassword;

  File get _attemptsFile =>
      File(p.join(profileDir.path, profileLockAttemptsFileName));

  /// The tail of each profile's queue of checks, keyed by its directory.
  ///
  /// Static because gates are made per call: the lock screen, a dialog and a
  /// reopened dialog each hold their own. Two checks that overlap would both
  /// read the same count and both write the same increment — one wrong
  /// attempt free — and would share the temporary file the record is written
  /// through.
  static final _queues = <String, Future<void>>{};

  /// Checks [password], one check per profile at a time.
  ///
  /// The whole read, verify and record runs inside the queue, and the next
  /// check starts whether this one returned or threw.
  Future<ProfilePasswordCheck> check(
    AuthSettings settings,
    String password,
  ) async {
    final key = p.canonicalize(profileDir.path);
    final previous = _queues[key];
    final done = Completer<void>();
    // Claimed before the first await, so a check that starts while this one
    // waits queues behind it rather than beside it.
    _queues[key] = done.future;

    try {
      // Only ever completes normally: each `done` is completed in a finally.
      if (previous != null) await previous;
      return await _check(settings, password);
    } finally {
      done.complete();
      // Only while still the tail; a later check owns the entry otherwise.
      _queues.removeWhere(
        (k, tail) => k == key && identical(tail, done.future),
      );
    }
  }

  Future<ProfilePasswordCheck> _check(
    AuthSettings settings,
    String password,
  ) async {
    final attempts = await _readAttempts();
    final now = _now();

    final blockedUntil = attempts.blockedUntil;
    if (blockedUntil != null) {
      // A clock set back past the last failure would otherwise end the wait at
      // once. Restart it from now instead.
      if (now.isBefore(attempts.failedAt ?? now)) {
        final delay = profilePasswordDelayAfter(attempts.failures)!;
        await _writeAttempts(attempts.failures, failedAt: now, delay: delay);
        return ProfilePasswordThrottled(delay);
      }

      if (now.isBefore(blockedUntil)) {
        return ProfilePasswordThrottled(blockedUntil.difference(now));
      }
    }

    final verifier = settings.passwordVerifier;
    final matches = verifier != null && await _matches(verifier, password);

    if (matches) {
      await _clearAttempts();
      return const ProfilePasswordAccepted();
    }

    final failures = attempts.failures + 1;
    final delay = profilePasswordDelayAfter(failures);
    await _writeAttempts(failures, failedAt: _now(), delay: delay);

    return ProfilePasswordRejected(retryAfter: delay);
  }

  Future<_Attempts> _readAttempts() async {
    try {
      final file = _attemptsFile;
      if (!await file.exists()) return const _Attempts(0);

      final json =
          jsonDecode(await file.readAsString()) as Map<String, dynamic>;
      return _Attempts(
        json['failures'] as int? ?? 0,
        failedAt: DateTime.tryParse(json['failedAt'] as String? ?? ''),
        blockedUntil: DateTime.tryParse(json['blockedUntil'] as String? ?? ''),
      );
    } catch (error, stackTrace) {
      // Unreadable is treated as a full run of failures rather than as none,
      // so damaging the file cannot be used to skip a wait.
      logger.w(
        'Profile lock attempts are unreadable',
        error: error,
        stackTrace: stackTrace,
      );
      // Rewritten, so the wait it imposes is a real one that ends, and not a
      // fresh one on every read of the same damaged file.
      final now = _now();
      final delay = profilePasswordDelayAfter(_freeAttempts)!;
      try {
        await _writeAttempts(_freeAttempts, failedAt: now, delay: delay);
      } catch (_) {
        // Still blocked for this attempt; the next read tries again.
      }
      return _Attempts(
        _freeAttempts,
        failedAt: now,
        blockedUntil: now.add(delay),
      );
    }
  }

  Future<void> _writeAttempts(
    int failures, {
    required DateTime failedAt,
    required Duration? delay,
  }) async {
    final file = _attemptsFile;
    final temp = File('${file.path}.tmp');

    await temp.writeAsString(
      jsonEncode({
        'failures': failures,
        'failedAt': failedAt.toUtc().toIso8601String(),
        if (delay != null)
          'blockedUntil': failedAt.add(delay).toUtc().toIso8601String(),
      }),
      flush: true,
    );
    await temp.rename(file.path);
  }

  Future<void> _clearAttempts() async {
    final file = _attemptsFile;
    if (await file.exists()) {
      await file.delete();
    }
  }
}

class _Attempts {
  final int failures;
  final DateTime? failedAt;
  final DateTime? blockedUntil;

  const _Attempts(this.failures, {this.failedAt, this.blockedUntil});
}
