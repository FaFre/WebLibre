/*
 * Copyright (c) 2024-2025 Fabian Freund.
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

part 'engine_settings.g.dart';

@CopyWith()
@JsonSerializable(includeIfNull: true, constructor: 'withDefaults')
class EngineSettings extends GeckoEngineSettings with FastEquatable {
  @override
  bool get javascriptEnabled => super.javascriptEnabled!;
  @override
  TrackingProtectionPolicy get trackingProtectionPolicy =>
      super.trackingProtectionPolicy!;
  @override
  HttpsOnlyMode get httpsOnlyMode => super.httpsOnlyMode!;
  @override
  ColorScheme get preferredColorScheme => super.preferredColorScheme!;
  @override
  bool get globalPrivacyControlEnabled => super.globalPrivacyControlEnabled!;
  @override
  CookieBannerHandlingMode get cookieBannerHandlingMode =>
      super.cookieBannerHandlingMode!;
  @override
  CookieBannerHandlingMode get cookieBannerHandlingModePrivateBrowsing =>
      super.cookieBannerHandlingModePrivateBrowsing!;
  @override
  bool get cookieBannerHandlingGlobalRules =>
      super.cookieBannerHandlingGlobalRules!;
  @override
  bool get cookieBannerHandlingGlobalRulesSubFrames =>
      super.cookieBannerHandlingGlobalRulesSubFrames!;
  @override
  WebContentIsolationStrategy get webContentIsolationStrategy =>
      super.webContentIsolationStrategy!;

  EngineSettings({
    required super.javascriptEnabled,
    required super.trackingProtectionPolicy,
    required super.httpsOnlyMode,
    required super.globalPrivacyControlEnabled,
    required super.preferredColorScheme,
    required super.cookieBannerHandlingMode,
    required super.cookieBannerHandlingModePrivateBrowsing,
    required super.cookieBannerHandlingGlobalRules,
    required super.cookieBannerHandlingGlobalRulesSubFrames,
    required super.webContentIsolationStrategy,
    required super.userAgent,
  });

  EngineSettings.withDefaults({
    bool? javascriptEnabled,
    TrackingProtectionPolicy? trackingProtectionPolicy,
    HttpsOnlyMode? httpsOnlyMode,
    bool? globalPrivacyControlEnabled,
    ColorScheme? preferredColorScheme,
    CookieBannerHandlingMode? cookieBannerHandlingMode,
    CookieBannerHandlingMode? cookieBannerHandlingModePrivateBrowsing,
    bool? cookieBannerHandlingGlobalRules,
    bool? cookieBannerHandlingGlobalRulesSubFrames,
    WebContentIsolationStrategy? webContentIsolationStrategy,
    super.userAgent,
  }) : super(
         javascriptEnabled: javascriptEnabled ?? true,
         trackingProtectionPolicy:
             trackingProtectionPolicy ?? TrackingProtectionPolicy.strict,
         httpsOnlyMode: httpsOnlyMode ?? HttpsOnlyMode.enabled,
         globalPrivacyControlEnabled: globalPrivacyControlEnabled ?? true,
         preferredColorScheme: preferredColorScheme ?? ColorScheme.system,
         cookieBannerHandlingMode:
             cookieBannerHandlingMode ?? CookieBannerHandlingMode.rejectAll,
         cookieBannerHandlingModePrivateBrowsing:
             cookieBannerHandlingModePrivateBrowsing ??
             CookieBannerHandlingMode.rejectAll,
         cookieBannerHandlingGlobalRules:
             cookieBannerHandlingGlobalRules ?? true,
         cookieBannerHandlingGlobalRulesSubFrames:
             cookieBannerHandlingGlobalRulesSubFrames ?? true,
         webContentIsolationStrategy:
             webContentIsolationStrategy ??
             WebContentIsolationStrategy.isolateHighValue,
       );

  factory EngineSettings.fromJson(Map<String, dynamic> json) =>
      _$EngineSettingsFromJson(json);

  Map<String, dynamic> toJson() => _$EngineSettingsToJson(this);

  @override
  List<Object?> get hashParameters => [
    super.javascriptEnabled,
    super.trackingProtectionPolicy,
    super.httpsOnlyMode,
    super.globalPrivacyControlEnabled,
    super.preferredColorScheme,
    super.cookieBannerHandlingMode,
    super.cookieBannerHandlingModePrivateBrowsing,
    super.cookieBannerHandlingGlobalRules,
    super.cookieBannerHandlingGlobalRulesSubFrames,
    super.webContentIsolationStrategy,
    super.userAgent,
  ];
}
