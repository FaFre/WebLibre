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
import 'package:weblibre/features/app_update/domain/entities/update_assessment.dart';
import 'package:weblibre/features/app_update/domain/entities/update_failure.dart';

/// The updater's operation state (plan 3.6). Held in memory and derived at
/// start from the accepted catalogue, the staged files and the installer
/// journal (D19); never stored.
sealed class UpdateState with FastEquatable {
  UpdateState();

  UpdateAssessment? get assessment => null;

  /// Something the user started, which may need finding again (8.2).
  bool get userInitiated => false;

  /// What is still true beneath any failure shown on top of it. A failure
  /// over a waiting or running installation still holds the install slot.
  UpdateState get underlying => switch (this) {
    UpdateFailed(:final returnTo) => returnTo.underlying,
    _ => this,
  };
}

/// What an [UpdateFailed] came from. Retry repeats that, never whatever the
/// state it returns to would offer next.
enum UpdateOperation { check, download, install, cancelInstallation }

/// No check has succeeded in this installation yet.
final class UpdateIdle extends UpdateState {
  UpdateIdle();

  @override
  List<Object?> get hashParameters => [runtimeType];
}

final class UpdateChecking extends UpdateState {
  UpdateChecking();

  @override
  List<Object?> get hashParameters => [runtimeType];
}

/// When it was last confirmed is `UpdateSnapshot.lastSuccess`.
final class UpdateUpToDate extends UpdateState {
  UpdateUpToDate();

  @override
  List<Object?> get hashParameters => [runtimeType];
}

final class UpdateAvailable extends UpdateState {
  UpdateAvailable(this.assessment, {this.partialBytes = 0});

  @override
  final UpdateAssessment assessment;

  /// Bytes already downloaded; Download continues them.
  final int partialBytes;

  @override
  List<Object?> get hashParameters => [assessment, partialBytes];
}

final class UpdateDownloading extends UpdateState {
  UpdateDownloading(this.assessment, {required this.received, this.total});

  @override
  final UpdateAssessment assessment;
  final int received;
  final int? total;

  double? get progress =>
      (total == null || total == 0) ? null : (received / total!).clamp(0, 1);

  @override
  bool get userInitiated => true;

  @override
  List<Object?> get hashParameters => [assessment, received, total];
}

final class UpdateVerifying extends UpdateState {
  UpdateVerifying(this.assessment);

  @override
  final UpdateAssessment assessment;

  @override
  bool get userInitiated => true;

  @override
  List<Object?> get hashParameters => [assessment];
}

final class UpdateReadyToInstall extends UpdateState {
  UpdateReadyToInstall(this.assessment);

  @override
  final UpdateAssessment assessment;

  @override
  bool get userInitiated => true;

  @override
  List<Object?> get hashParameters => [assessment];
}

final class UpdateAwaitingPermission extends UpdateState {
  UpdateAwaitingPermission(this.assessment);

  @override
  final UpdateAssessment assessment;

  @override
  bool get userInitiated => true;

  @override
  List<Object?> get hashParameters => [assessment];
}

/// A session waits for the system confirmation.
final class UpdateAwaitingUserAction extends UpdateState {
  UpdateAwaitingUserAction(this.assessment);

  /// Null when the catalogue can't describe the session's target.
  @override
  final UpdateAssessment? assessment;

  @override
  bool get userInitiated => true;

  @override
  List<Object?> get hashParameters => [assessment];
}

final class UpdateInstalling extends UpdateState {
  UpdateInstalling(this.assessment, {this.foundAfterRestart = false});

  @override
  final UpdateAssessment? assessment;

  /// A restart found the session still in progress: only then is "Cancel
  /// installation" offered (8.1).
  final bool foundAfterRestart;

  @override
  bool get userInitiated => true;

  @override
  List<Object?> get hashParameters => [assessment, foundAfterRestart];
}

final class UpdateFailed extends UpdateState {
  UpdateFailed(this.failure, {required this.returnTo, required this.operation});

  final UpdateFailure failure;

  /// The state Retry or the next successful operation returns from.
  final UpdateState returnTo;

  /// The operation that failed, which Retry repeats.
  final UpdateOperation operation;

  UpdateFailureKind get kind => failure.kind;
  bool get retryable => failure.kind.retryable;

  @override
  UpdateAssessment? get assessment => returnTo.assessment;

  @override
  List<Object?> get hashParameters => [failure, returnTo, operation];
}
