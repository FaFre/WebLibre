/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

import 'package:flutter_mozilla_components/src/pigeons/gecko.g.dart';

final _apiInstance = GeckoEngineSettingsApi();

class GeckoEngineSettingsService {
  final GeckoEngineSettingsApi _api;

  GeckoEngineSettingsService({GeckoEngineSettingsApi? api})
    : _api = api ?? _apiInstance;

  Future<void> setDefaultSettings(
    GeckoEngineSettings settings, {
    bool updateRuntime = true,
  }) {
    return updateRuntime
        ? _api.updateRuntimeSettings(settings)
        : _api.setDefaultSettings(settings);
  }

  Future<void> javascriptEnabled(bool state) {
    return _api.updateRuntimeSettings(
      GeckoEngineSettings(javascriptEnabled: state),
    );
  }

  Future<void> trackingProtectionPolicy(TrackingProtectionPolicy state) {
    return _api.updateRuntimeSettings(
      GeckoEngineSettings(trackingProtectionPolicy: state),
    );
  }

  /// Updates tracking protection policy with all custom settings.
  /// Use this when in CUSTOM mode and any custom setting changes.
  Future<void> customTrackingProtectionPolicy({
    required TrackingProtectionPolicy trackingProtectionPolicy,
    bool? blockCookies,
    CustomCookiePolicy? customCookiePolicy,
    bool? blockTrackingContent,
    TrackingScope? trackingContentScope,
    bool? blockCryptominers,
    bool? blockFingerprinters,
    bool? blockRedirectTrackers,
    bool? blockSuspectedFingerprinters,
    TrackingScope? suspectedFingerprintersScope,
    bool? allowListBaseline,
    bool? allowListConvenience,
  }) {
    return _api.updateRuntimeSettings(
      GeckoEngineSettings(
        trackingProtectionPolicy: trackingProtectionPolicy,
        blockCookies: blockCookies,
        customCookiePolicy: customCookiePolicy,
        blockTrackingContent: blockTrackingContent,
        trackingContentScope: trackingContentScope,
        blockCryptominers: blockCryptominers,
        blockFingerprinters: blockFingerprinters,
        blockRedirectTrackers: blockRedirectTrackers,
        blockSuspectedFingerprinters: blockSuspectedFingerprinters,
        suspectedFingerprintersScope: suspectedFingerprintersScope,
        allowListBaseline: allowListBaseline,
        allowListConvenience: allowListConvenience,
      ),
    );
  }

  Future<void> httpsOnlyMode(HttpsOnlyMode state) {
    return _api.updateRuntimeSettings(
      GeckoEngineSettings(httpsOnlyMode: state),
    );
  }

  Future<void> globalPrivacyControlEnabled(bool state) {
    return _api.updateRuntimeSettings(
      GeckoEngineSettings(globalPrivacyControlEnabled: state),
    );
  }

  Future<void> preferredColorScheme(ColorScheme state) {
    return _api.updateRuntimeSettings(
      GeckoEngineSettings(preferredColorScheme: state),
    );
  }

  Future<void> cookieBannerHandlingMode(CookieBannerHandlingMode state) {
    return _api.updateRuntimeSettings(
      GeckoEngineSettings(cookieBannerHandlingMode: state),
    );
  }

  Future<void> cookieBannerHandlingModePrivateBrowsing(
    CookieBannerHandlingMode state,
  ) {
    return _api.updateRuntimeSettings(
      GeckoEngineSettings(cookieBannerHandlingModePrivateBrowsing: state),
    );
  }

  Future<void> cookieBannerHandlingGlobalRules(bool state) {
    return _api.updateRuntimeSettings(
      GeckoEngineSettings(cookieBannerHandlingGlobalRules: state),
    );
  }

  Future<void> cookieBannerHandlingGlobalRulesSubFrames(bool state) {
    return _api.updateRuntimeSettings(
      GeckoEngineSettings(cookieBannerHandlingGlobalRulesSubFrames: state),
    );
  }

  Future<void> webContentIsolationStrategy(WebContentIsolationStrategy state) {
    return _api.updateRuntimeSettings(
      GeckoEngineSettings(webContentIsolationStrategy: state),
    );
  }

  Future<void> contentBlocking(ContentBlocking state) {
    return _api.updateRuntimeSettings(
      GeckoEngineSettings(contentBlocking: state),
    );
  }

  Future<void> dohSettings(DohSettings state) {
    return _api.updateRuntimeSettings(GeckoEngineSettings(dohSettings: state));
  }

  Future<void> fingerprintingProtectionOverrides(String? state) {
    return _api.updateRuntimeSettings(
      GeckoEngineSettings(fingerprintingProtectionOverrides: state),
    );
  }

  Future<void> setPullToRefreshEnabled(bool enabled) {
    return _api.setPullToRefreshEnabled(enabled);
  }
}
