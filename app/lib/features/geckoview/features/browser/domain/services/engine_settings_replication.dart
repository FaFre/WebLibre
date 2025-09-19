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
import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/features/user/domain/repositories/engine_settings.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';

part 'engine_settings_replication.g.dart';

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
      engineSettingsRepositoryProvider,
      (previous, next) async {
        final settings = next.value;

        if (settings != null) {
          if (initialSettingsSent && previous != null) {
            if (previous.value?.javascriptEnabled !=
                settings.javascriptEnabled) {
              await _service.javascriptEnabled(settings.javascriptEnabled);
            }
            if (previous.value?.trackingProtectionPolicy !=
                settings.trackingProtectionPolicy) {
              await _service.trackingProtectionPolicy(
                settings.trackingProtectionPolicy,
              );
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
          } else {
            await _service.setDefaultSettings(settings);
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
