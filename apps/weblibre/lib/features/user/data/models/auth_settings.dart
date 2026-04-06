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

part 'auth_settings.g.dart';

enum AutoLockMode { background, timeout }

@CopyWith()
@JsonSerializable()
class AuthSettings with FastEquatable {
  final bool authenticationRequired;
  final AutoLockMode autoLockMode;
  final Duration timeout;

  AuthSettings({
    required this.authenticationRequired,
    required this.autoLockMode,
    required this.timeout,
  });

  AuthSettings.withDefaults({
    bool? authenticationRequired,
    AutoLockMode? autoLockMode,
    Duration? timeout,
  }) : this(
         authenticationRequired: authenticationRequired ?? false,
         autoLockMode: autoLockMode ?? AutoLockMode.background,
         timeout: timeout ?? const Duration(minutes: 5),
       );

  AuthSettings withBackgroundLock() {
    return copyWith(autoLockMode: AutoLockMode.background);
  }

  AuthSettings withTimeoutLock(Duration value) {
    return copyWith(autoLockMode: AutoLockMode.timeout, timeout: value);
  }

  factory AuthSettings.fromJson(Map<String, dynamic> json) =>
      _$AuthSettingsFromJson(json);

  Map<String, dynamic> toJson() => _$AuthSettingsToJson(this);

  @override
  List<Object?> get hashParameters => [
    authenticationRequired,
    autoLockMode,
    timeout,
  ];
}
