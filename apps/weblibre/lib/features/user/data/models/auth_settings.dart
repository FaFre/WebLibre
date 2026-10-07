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

enum AutoLockMode { background, timeout, startup }

/// What stands between a person holding the device and this profile.
enum ProfileLockMethod {
  none,

  /// Android's own prompt: an enrolled biometric or the device PIN, pattern or
  /// password. It proves the person can unlock the *device*, so on a shared
  /// phone it lets in everyone who can.
  device,

  /// A password that belongs to this profile alone. The device prompt never
  /// stands in for it.
  password,
}

/// Reads `lockMethod`, falling back to the boolean every older build wrote.
///
/// A profile locked before lock methods existed was always locked with the
/// device prompt, so `authenticationRequired: true` maps to [ProfileLockMethod.device].
Object? _readLockMethod(Map<dynamic, dynamic> json, String key) {
  final value = json[key];
  if (value != null) return value;

  return json['authenticationRequired'] == true
      ? ProfileLockMethod.device.name
      : ProfileLockMethod.none.name;
}

@CopyWith()
@JsonSerializable()
class AuthSettings with FastEquatable {
  @JsonKey(
    readValue: _readLockMethod,
    // An unknown value comes from a newer build. Failing closed keeps the
    // profile locked behind something this build can still answer, instead of
    // treating it as open.
    unknownEnumValue: ProfileLockMethod.device,
  )
  final ProfileLockMethod lockMethod;

  /// Proof of the profile password, never the password itself.
  ///
  /// See `createProfilePasswordVerifier`. Only meaningful while [lockMethod]
  /// is [ProfileLockMethod.password].
  final String? passwordVerifier;

  final AutoLockMode autoLockMode;
  final Duration timeout;

  AuthSettings({
    required this.lockMethod,
    this.passwordVerifier,
    required this.autoLockMode,
    required this.timeout,
  });

  AuthSettings.withDefaults({
    ProfileLockMethod? lockMethod,
    String? passwordVerifier,
    AutoLockMode? autoLockMode,
    Duration? timeout,
  }) : this(
         lockMethod: lockMethod ?? ProfileLockMethod.none,
         passwordVerifier: passwordVerifier,
         autoLockMode: autoLockMode ?? AutoLockMode.background,
         timeout: timeout ?? const Duration(minutes: 5),
       );

  /// Whether the profile asks for anything before it opens.
  bool get authenticationRequired => lockMethod != ProfileLockMethod.none;

  AuthSettings withBackgroundLock() {
    return copyWith(autoLockMode: AutoLockMode.background);
  }

  AuthSettings withTimeoutLock(Duration value) {
    return copyWith(autoLockMode: AutoLockMode.timeout, timeout: value);
  }

  AuthSettings withStartupLock() {
    return copyWith(autoLockMode: AutoLockMode.startup);
  }

  factory AuthSettings.fromJson(Map<String, dynamic> json) =>
      _$AuthSettingsFromJson(json);

  /// Also writes `authenticationRequired`, which older builds read.
  ///
  /// Downgrading must not open a password-locked profile: an older build that
  /// sees `true` still locks it, with the only method it knows.
  Map<String, dynamic> toJson() => {
    ..._$AuthSettingsToJson(this),
    'authenticationRequired': authenticationRequired,
  };

  @override
  List<Object?> get hashParameters => [
    lockMethod,
    passwordVerifier,
    autoLockMode,
    timeout,
  ];
}
