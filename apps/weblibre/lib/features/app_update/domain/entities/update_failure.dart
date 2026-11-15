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

/// Why an update operation failed (plan 3.6). Translated only where shown.
enum UpdateFailureKind {
  network(retryable: true),
  routingUnavailable(retryable: true),
  metadataInvalid(retryable: false),

  /// The catalogue uses a schema newer than this build reads.
  metadataClientTooOld(retryable: false),
  metadataExpired(retryable: true),
  metadataRollback(retryable: false),

  /// The catalogue was signed before the installed build: normal right after
  /// a release, until the updates repository signs the next one.
  metadataPredatesBuild(retryable: true),
  clockSuspect(retryable: true),
  noCompatibleTarget(retryable: false),
  insufficientStorage(retryable: true),
  downloadTooLarge(retryable: false),
  downloadMismatch(retryable: true),
  apkInvalid(retryable: false),
  apkIdentityMismatch(retryable: false),
  signerUntrusted(retryable: false),
  authorizationStale(retryable: true),
  targetWithdrawn(retryable: false),
  stateCorrupt(retryable: false),
  installPermissionDenied(retryable: true),
  installCancelled(retryable: true),
  installConflict(retryable: true),
  installIncompatible(retryable: false),
  installStorage(retryable: true),
  installBlocked(retryable: true),
  installUnknown(retryable: true),
  playNotOwned(retryable: false),
  playUnavailable(retryable: true),
  playError(retryable: true);

  const UpdateFailureKind({required this.retryable});

  final bool retryable;
}

class UpdateFailure with FastEquatable implements Exception {
  UpdateFailure(this.kind, [this.detail]);

  /// [error] itself when it is an [UpdateFailure], otherwise [fallback]
  /// with the error as detail.
  factory UpdateFailure.from(Object error, UpdateFailureKind fallback) =>
      error is UpdateFailure
      ? error
      : UpdateFailure(fallback, error.toString());

  final UpdateFailureKind kind;

  /// Raw detail for logs and diagnostics. Never shown as is.
  final String? detail;

  @override
  List<Object?> get hashParameters => [kind, detail];

  @override
  String toString() =>
      'UpdateFailure(${kind.name}${detail == null ? '' : ': $detail'})';
}
