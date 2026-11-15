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
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:fast_equatable/fast_equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:weblibre/core/startup/models/json_read.dart';

part 'restart_request.g.dart';

const restartRequestVersion = 1;

enum RestartRequestState {
  /// Written before the alarm is armed. A request in this state whose process
  /// never died is stale and is ignored.
  pending,

  /// A new process has adopted the target and is bringing startup up.
  applied,
}

/// The durable half of the restart protocol.
///
/// `AtomicFile`, `AlarmManager`, and process termination are three separate
/// operations, so the request — not the alarm — is what a new process trusts.
/// The old process never writes `current_profile`; it only records the target
/// here, and the *next* process applies it through `ActiveProfile`.
@CopyWith()
@JsonSerializable(checked: true)
class RestartRequest with FastEquatable {
  @JsonKey(fromJson: _version)
  final int version;
  @CopyWithField(immutable: true)
  @JsonKey(fromJson: requiredString)
  final String requestId;

  /// The profile the next process should commit, or `null` to re-resolve the
  /// normal candidate (maintenance restarts do not force a profile).
  @JsonKey(fromJson: stringOrNull)
  final String? targetProfileId;

  /// The launch-broker entry the relaunch should replay, if any. Only a token
  /// travels through the `PendingIntent`; the payload stays in the broker.
  @JsonKey(fromJson: stringOrNull)
  final String? brokerEntryId;

  @JsonKey(fromJson: stringOrEmpty)
  final String reason;

  /// Identifies the process that wrote the request, so a `PendingIntent`
  /// delivered back into the still-live old process can be recognised and
  /// rescheduled instead of honoured.
  @JsonKey(fromJson: requiredString)
  final String processInstanceId;

  @JsonKey(name: 'state', fromJson: _state)
  final String stateId;
  @JsonKey(fromJson: requiredDateTime, toJson: utcIso)
  final DateTime createdAt;
  @JsonKey(fromJson: requiredDateTime, toJson: utcIso)
  final DateTime expiresAt;
  @JsonKey(fromJson: dateTimeOrNull, toJson: utcIsoOrNull)
  final DateTime? appliedAt;

  RestartRequest({
    required this.requestId,
    required this.reason,
    required this.processInstanceId,
    required this.stateId,
    required this.createdAt,
    required this.expiresAt,
    this.version = restartRequestVersion,
    this.targetProfileId,
    this.brokerEntryId,
    this.appliedAt,
  });

  RestartRequestState? get state =>
      RestartRequestState.values.tryByName(stateId);

  bool isExpiredAt(DateTime now) => !now.isBefore(expiresAt);

  /// A request is only actionable while it is pending, unexpired, and was
  /// written by a *different* process instance.
  bool isActionableFor(String currentProcessInstanceId, DateTime now) =>
      state == RestartRequestState.pending &&
      !isExpiredAt(now) &&
      processInstanceId != currentProcessInstanceId;

  /// Null when a field the request can't do without is missing; every
  /// other field degrades (`json_read.dart`).
  static RestartRequest? tryFromJson(Map<String, Object?> json) =>
      tryCheckedFromJson(json, _$RestartRequestFromJson);

  Map<String, Object?> toJson() => _$RestartRequestToJson(this);

  static int _version(Object? value) => intOr(value, restartRequestVersion);

  static String _state(Object? value) =>
      value is String ? value : RestartRequestState.pending.name;

  @override
  List<Object?> get hashParameters => [
    version,
    requestId,
    targetProfileId,
    brokerEntryId,
    reason,
    processInstanceId,
    stateId,
    createdAt,
    expiresAt,
    appliedAt,
  ];
}
