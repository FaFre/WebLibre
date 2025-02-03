import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:lensai/features/user/domain/repositories/engine_settings.dart';
import 'package:lensai/features/user/domain/repositories/general_settings.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'engine_settings.g.dart';

@Riverpod(keepAlive: true)
class EngineSettingsReplicationService
    extends _$EngineSettingsReplicationService {
  final _service = GeckoEngineSettingsService();

  @override
  void build() {
    var initialSettingsSent = false;

    ref.listen(
      generalSettingsRepositoryProvider
          .select((settings) => settings.themeMode),
      (previous, next) async {
        final theme = switch (next) {
          ThemeMode.system => ColorScheme.system,
          ThemeMode.light => ColorScheme.light,
          ThemeMode.dark => ColorScheme.dark,
        };

        await _service.preferredColorScheme(theme);
      },
    );

    ref.listen(
      engineSettingsRepositoryProvider,
      (previous, next) async {
        if (initialSettingsSent && previous != null) {
          if (previous.javascriptEnabled != next.javascriptEnabled) {
            await _service.javascriptEnabled(next.javascriptEnabled);
          }
          if (previous.trackingProtectionPolicy !=
              next.trackingProtectionPolicy) {
            await _service
                .trackingProtectionPolicy(next.trackingProtectionPolicy);
          }
          if (previous.httpsOnlyMode != next.httpsOnlyMode) {
            await _service.httpsOnlyMode(next.httpsOnlyMode);
          }
          if (previous.globalPrivacyControlEnabled !=
              next.globalPrivacyControlEnabled) {
            await _service
                .globalPrivacyControlEnabled(next.globalPrivacyControlEnabled);
          }
          if (previous.preferredColorScheme != next.preferredColorScheme) {
            await _service.preferredColorScheme(next.preferredColorScheme);
          }
          if (previous.cookieBannerHandlingMode !=
              next.cookieBannerHandlingMode) {
            await _service
                .cookieBannerHandlingMode(next.cookieBannerHandlingMode);
          }
          if (previous.cookieBannerHandlingModePrivateBrowsing !=
              next.cookieBannerHandlingModePrivateBrowsing) {
            await _service.cookieBannerHandlingModePrivateBrowsing(
              next.cookieBannerHandlingModePrivateBrowsing,
            );
          }
          if (previous.cookieBannerHandlingGlobalRules !=
              next.cookieBannerHandlingGlobalRules) {
            await _service.cookieBannerHandlingGlobalRules(
              next.cookieBannerHandlingGlobalRules,
            );
          }
          if (previous.cookieBannerHandlingGlobalRulesSubFrames !=
              next.cookieBannerHandlingGlobalRulesSubFrames) {
            await _service.cookieBannerHandlingGlobalRulesSubFrames(
              next.cookieBannerHandlingGlobalRulesSubFrames,
            );
          }
          if (previous.webContentIsolationStrategy !=
              next.webContentIsolationStrategy) {
            await _service
                .webContentIsolationStrategy(next.webContentIsolationStrategy);
          }
        } else {
          await _service.setDefaultSettings(next);
          initialSettingsSent = true;
        }
      },
    );
  }
}
