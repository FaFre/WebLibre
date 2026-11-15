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

part 'update_preferences.g.dart';

/// `update_prefs.json` (plan 6). Installation-level: not a profile setting,
/// outside the settings layers and H1 (D10).
///
/// Read strictly ([tryFromJson]): a damaged file must never read as the
/// default, so a field of the wrong type rejects the whole file.
@JsonSerializable(checked: true)
class UpdatePreferences with FastEquatable {
  UpdatePreferences({
    required this.automaticChecks,
    required this.recoveryRequired,
  });

  /// On for every preset; never an onboarding choice (D7).
  static final defaults = UpdatePreferences(
    automaticChecks: true,
    recoveryRequired: false,
  );

  /// What a corrupt file is replaced with (6.2): off, and asking.
  static final recovered = UpdatePreferences(
    automaticChecks: false,
    recoveryRequired: true,
  );

  final bool automaticChecks;

  /// The file was damaged; automatic checks stay off until the user answers.
  @JsonKey(defaultValue: false)
  final bool recoveryRequired;

  Map<String, Object?> toJson() => _$UpdatePreferencesToJson(this);

  /// Null for anything that isn't exactly this shape.
  static UpdatePreferences? tryFromJson(Map<String, Object?> json) =>
      tryCheckedFromJson(json, _$UpdatePreferencesFromJson);

  @override
  List<Object?> get hashParameters => [automaticChecks, recoveryRequired];
}

/// `update_misc.json`: scheduler and once-only notices. Nothing else depends
/// on it, so a damaged file is simply replaced by an empty one (6.2).
@CopyWith()
@JsonSerializable(checked: true, includeIfNull: false)
class UpdateMiscState with FastEquatable {
  UpdateMiscState({
    this.lastAttempt,
    this.lastSuccess,
    this.backoffStep = 0,
    this.announcedSequence,
  });

  static final empty = UpdateMiscState();

  /// Only ever compared, never trusted (3.7). Unparseable reads as unset.
  @JsonKey(fromJson: dateTimeOrNull, toJson: utcIsoOrNull)
  final DateTime? lastAttempt;
  @JsonKey(fromJson: dateTimeOrNull, toJson: utcIsoOrNull)
  final DateTime? lastSuccess;
  @JsonKey(defaultValue: 0)
  final int backoffStep;

  /// The release last announced (8.4). "Updated to X" needs no record here:
  /// native retires the succeeded journal entry the first time recovery
  /// reports it.
  final int? announcedSequence;

  Map<String, Object?> toJson() => _$UpdateMiscStateToJson(this);

  /// Null when a counter has the wrong type.
  static UpdateMiscState? tryFromJson(Map<String, Object?> json) =>
      tryCheckedFromJson(json, _$UpdateMiscStateFromJson);

  @override
  List<Object?> get hashParameters => [
    lastAttempt,
    lastSuccess,
    backoffStep,
    announcedSequence,
  ];
}
