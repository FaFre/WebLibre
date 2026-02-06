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
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:json_annotation/json_annotation.dart';

part 'preference_setting.g.dart';

@CopyWith()
class PreferenceSettingGroup with FastEquatable {
  final String? description;

  final Map<String, PreferenceSetting> settings;

  bool get isActiveOrOptional => settings.values.every(
    (setting) => setting.requireUserOptIn || setting.isActive,
  );

  bool get showMasterSwitch =>
      settings.values.length >
      settings.values.where((setting) => setting.requireUserOptIn).length;

  bool get isPartlyActive => settings.values.any((setting) => setting.isActive);

  bool get hasInactiveOptional => settings.values.any(
    (setting) => !setting.isActive && setting.requireUserOptIn,
  );

  PreferenceSettingGroup({required this.description, required this.settings});

  @override
  List<Object?> get hashParameters => [description, settings];
}

@JsonSerializable()
@CopyWith()
class PreferenceSetting with FastEquatable {
  final Object value;

  @JsonKey(includeFromJson: false, includeToJson: false)
  final GeckoPref? current;

  bool get isActive => value == current?.value;

  final String? title;
  final String? description;

  final bool requireUserOptIn;
  final bool shouldBeDefault;

  PreferenceSetting({
    required this.value,
    required this.title,
    required this.description,
    this.current,
    this.requireUserOptIn = false,
    this.shouldBeDefault = false,
  });

  factory PreferenceSetting.fromJson(Map<String, dynamic> json) =>
      _$PreferenceSettingFromJson(json);

  Map<String, dynamic> toJson() => _$PreferenceSettingToJson(this);

  @override
  List<Object?> get hashParameters => [
    value,
    current,
    title,
    description,
    requireUserOptIn,
    shouldBeDefault,
  ];
}
