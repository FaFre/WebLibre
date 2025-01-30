import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:json_annotation/json_annotation.dart';

part 'engine_settings.g.dart';

@CopyWith()
@JsonSerializable(includeIfNull: true, constructor: 'withDefaults')
class EngineSettings extends GeckoEngineSettings {
  EngineSettings({
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
          webContentIsolationStrategy: webContentIsolationStrategy ??
              WebContentIsolationStrategy.isolateHighValue,
        );
}
