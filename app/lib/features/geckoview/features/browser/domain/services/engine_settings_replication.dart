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
      generalSettingsRepositoryProvider.select(
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
        if (initialSettingsSent && previous != null) {
          if (previous.javascriptEnabled != next.javascriptEnabled) {
            await _service.javascriptEnabled(next.javascriptEnabled);
          }
          if (previous.trackingProtectionPolicy !=
              next.trackingProtectionPolicy) {
            await _service.trackingProtectionPolicy(
              next.trackingProtectionPolicy,
            );
          }
          if (previous.httpsOnlyMode != next.httpsOnlyMode) {
            await _service.httpsOnlyMode(next.httpsOnlyMode);
          }
          if (previous.globalPrivacyControlEnabled !=
              next.globalPrivacyControlEnabled) {
            await _service.globalPrivacyControlEnabled(
              next.globalPrivacyControlEnabled,
            );
          }
          if (previous.preferredColorScheme != next.preferredColorScheme) {
            await _service.preferredColorScheme(next.preferredColorScheme);
          }
          if (previous.cookieBannerHandlingMode !=
              next.cookieBannerHandlingMode) {
            await _service.cookieBannerHandlingMode(
              next.cookieBannerHandlingMode,
            );
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
            await _service.webContentIsolationStrategy(
              next.webContentIsolationStrategy,
            );
          }
        } else {
          await _service.setDefaultSettings(next);
          initialSettingsSent = true;
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
