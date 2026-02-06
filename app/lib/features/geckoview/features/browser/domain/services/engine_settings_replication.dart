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
import 'package:collection/collection.dart';
import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/features/geckoview/features/preferences/data/repositories/preference_observer.dart';
import 'package:weblibre/features/user/domain/repositories/engine_settings.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';

part 'engine_settings_replication.g.dart';

/// Checks if any Custom ETP setting changed between two EngineSettings instances.
bool _customEtpSettingsChanged(
  GeckoEngineSettings? previous,
  GeckoEngineSettings current,
) {
  if (previous == null) return true;
  return previous.blockCookies != current.blockCookies ||
      previous.customCookiePolicy != current.customCookiePolicy ||
      previous.blockTrackingContent != current.blockTrackingContent ||
      previous.trackingContentScope != current.trackingContentScope ||
      previous.blockCryptominers != current.blockCryptominers ||
      previous.blockFingerprinters != current.blockFingerprinters ||
      previous.blockRedirectTrackers != current.blockRedirectTrackers ||
      previous.blockSuspectedFingerprinters !=
          current.blockSuspectedFingerprinters ||
      previous.suspectedFingerprintersScope !=
          current.suspectedFingerprintersScope ||
      previous.allowListBaseline != current.allowListBaseline ||
      previous.allowListConvenience != current.allowListConvenience;
}

@Riverpod(keepAlive: true)
class EngineSettingsReplicationService
    extends _$EngineSettingsReplicationService {
  final _service = GeckoEngineSettingsService();

  @override
  void build() {
    var initialSettingsSent = false;

    ref.listen(
      fireImmediately: true,
      generalSettingsWithDefaultsProvider.select(
        (settings) => settings.themeMode,
      ),
      (previous, next) async {
        final theme = switch (next) {
          ThemeMode.system => ColorScheme.system,
          ThemeMode.light => ColorScheme.light,
          ThemeMode.dark => ColorScheme.dark,
        };

        await _service.preferredColorScheme(theme);
      },
      onError: (error, stackTrace) {
        logger.e(
          'Error listening to generalSettingsRepositoryProvider',
          error: error,
          stackTrace: stackTrace,
        );
      },
    );

    ref.listen(
      fireImmediately: true,
      generalSettingsWithDefaultsProvider.select(
        (settings) => settings.pullToRefreshEnabled,
      ),
      (previous, next) async {
        await _service.setPullToRefreshEnabled(next);
      },
      onError: (error, stackTrace) {
        logger.e(
          'Error listening to pullToRefreshEnabled',
          error: error,
          stackTrace: stackTrace,
        );
      },
    );

    ref.listen(
      fireImmediately: true,
      generalSettingsWithDefaultsProvider.select(
        (settings) => settings.useExternalDownloadManager,
      ),
      (previous, next) async {
        await _service.setUseExternalDownloadManager(next);
      },
      onError: (error, stackTrace) {
        logger.e(
          'Error listening to useExternalDownloadManager',
          error: error,
          stackTrace: stackTrace,
        );
      },
    );

    ref.listen(
      fireImmediately: true,
      engineSettingsRepositoryProvider,
      (previous, next) async {
        final settings = next.value;

        if (settings != null) {
          if (initialSettingsSent && previous != null) {
            if (previous.value?.javascriptEnabled !=
                settings.javascriptEnabled) {
              await _service.javascriptEnabled(settings.javascriptEnabled);
            }
            // Check if tracking protection policy mode changed OR any custom ETP setting changed
            final policyModeChanged =
                previous.value?.trackingProtectionPolicy !=
                settings.trackingProtectionPolicy;
            final customSettingsChanged =
                settings.trackingProtectionPolicy ==
                    TrackingProtectionPolicy.custom &&
                _customEtpSettingsChanged(previous.value, settings);

            if (policyModeChanged || customSettingsChanged) {
              // Always send full custom settings when in CUSTOM mode
              if (settings.trackingProtectionPolicy ==
                  TrackingProtectionPolicy.custom) {
                await _service.customTrackingProtectionPolicy(
                  trackingProtectionPolicy: settings.trackingProtectionPolicy,
                  blockCookies: settings.blockCookies,
                  customCookiePolicy: settings.customCookiePolicy,
                  blockTrackingContent: settings.blockTrackingContent,
                  trackingContentScope: settings.trackingContentScope,
                  blockCryptominers: settings.blockCryptominers,
                  blockFingerprinters: settings.blockFingerprinters,
                  blockRedirectTrackers: settings.blockRedirectTrackers,
                  blockSuspectedFingerprinters:
                      settings.blockSuspectedFingerprinters,
                  suspectedFingerprintersScope:
                      settings.suspectedFingerprintersScope,
                  allowListBaseline: settings.allowListBaseline,
                  allowListConvenience: settings.allowListConvenience,
                );
              } else {
                await _service.trackingProtectionPolicy(
                  settings.trackingProtectionPolicy,
                );
              }
            }
            if (previous.value?.httpsOnlyMode != settings.httpsOnlyMode) {
              await _service.httpsOnlyMode(settings.httpsOnlyMode);
            }
            if (previous.value?.globalPrivacyControlEnabled !=
                settings.globalPrivacyControlEnabled) {
              await _service.globalPrivacyControlEnabled(
                settings.globalPrivacyControlEnabled,
              );
            }
            if (previous.value?.preferredColorScheme !=
                settings.preferredColorScheme) {
              await _service.preferredColorScheme(
                settings.preferredColorScheme,
              );
            }
            if (previous.value?.cookieBannerHandlingMode !=
                settings.cookieBannerHandlingMode) {
              await _service.cookieBannerHandlingMode(
                settings.cookieBannerHandlingMode,
              );
            }
            if (previous.value?.cookieBannerHandlingModePrivateBrowsing !=
                settings.cookieBannerHandlingModePrivateBrowsing) {
              await _service.cookieBannerHandlingModePrivateBrowsing(
                settings.cookieBannerHandlingModePrivateBrowsing,
              );
            }
            if (previous.value?.cookieBannerHandlingGlobalRules !=
                settings.cookieBannerHandlingGlobalRules) {
              await _service.cookieBannerHandlingGlobalRules(
                settings.cookieBannerHandlingGlobalRules,
              );
            }
            if (previous.value?.cookieBannerHandlingGlobalRulesSubFrames !=
                settings.cookieBannerHandlingGlobalRulesSubFrames) {
              await _service.cookieBannerHandlingGlobalRulesSubFrames(
                settings.cookieBannerHandlingGlobalRulesSubFrames,
              );
            }
            if (previous.value?.webContentIsolationStrategy !=
                settings.webContentIsolationStrategy) {
              await _service.webContentIsolationStrategy(
                settings.webContentIsolationStrategy,
              );
            }
            if (previous.value?.contentBlocking != settings.contentBlocking) {
              await _service.contentBlocking(settings.contentBlocking);
            }
            if (previous.value?.dohSettings != settings.dohSettings) {
              await _service.dohSettings(settings.dohSettings);
            }
            if (previous.value?.fingerprintingProtectionOverrides !=
                settings.fingerprintingProtectionOverrides) {
              await _service.fingerprintingProtectionOverrides(
                settings.fingerprintingProtectionOverrides,
              );
            }
            if (previous.value?.enablePdfJs != settings.enablePdfJs) {
              // ignore: only_use_keep_alive_inside_keep_alive
              await ref
                  .read(preferenceFixatorProvider.notifier)
                  .register('pdfjs.disabled', !settings.enablePdfJs);
            }
            if (!const DeepCollectionEquality.unordered().equals(
              previous.value?.locales,
              settings.locales,
            )) {
              // ignore: only_use_keep_alive_inside_keep_alive
              await ref
                  .read(preferenceFixatorProvider.notifier)
                  .register(
                    'intl.accept_languages',
                    settings.locales.join(','),
                  );
            }
          } else {
            await _service.setDefaultSettings(settings);

            // ignore: only_use_keep_alive_inside_keep_alive
            await ref
                .read(preferenceFixatorProvider.notifier)
                .register('pdfjs.disabled', !settings.enablePdfJs);

            // ignore: only_use_keep_alive_inside_keep_alive
            await ref
                .read(preferenceFixatorProvider.notifier)
                .register('intl.accept_languages', settings.locales.join(','));

            initialSettingsSent = true;
          }
        }
      },
      onError: (error, stackTrace) {
        logger.e(
          'Error listening to engineSettingsRepositoryProvider',
          error: error,
          stackTrace: stackTrace,
        );
      },
    );
  }
}
