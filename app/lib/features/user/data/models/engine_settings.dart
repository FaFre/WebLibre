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
  ];
}
