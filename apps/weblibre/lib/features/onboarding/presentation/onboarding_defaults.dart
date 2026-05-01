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
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/features/geckoview/features/preferences/data/repositories/preference_settings.dart';
import 'package:weblibre/features/geckoview/features/tabs/utils/setting_groups_serializer.dart';
import 'package:weblibre/features/user/data/models/engine_settings.dart';
import 'package:weblibre/features/user/data/models/ublock_filter_list_settings.dart';
import 'package:weblibre/features/user/data/providers/ublock_assets.dart';
import 'package:weblibre/features/user/domain/repositories/engine_settings.dart';

Future<void> applyOnboardingOptimizedUBlockDefaults(WidgetRef ref) async {
  try {
    final registry = await ref.read(ublockAssetsRegistryProvider.future);
    final optimized = UBlockFilterListSettings.optimizedDefaults(registry);

    await ref
        .read(engineSettingsRepositoryProvider.notifier)
        .updateSettings(
          (current) => current.copyWith.ublockFilterListSettings(optimized),
        );
  } catch (e, s) {
    logger.w(
      'Failed applying optimized uBlock defaults during onboarding',
      error: e,
      stackTrace: s,
    );
  }
}

Future<void> applyOnboardingPrivacyDefaults(WidgetRef ref) async {
  try {
    await ref
        .read(
          unifiedPreferenceSettingsRepositoryProvider(
            PreferencePartition.user,
          ).notifier,
        )
        .apply();

    await ref
        .read(engineSettingsRepositoryProvider.notifier)
        .updateSettings(
          (current) => current.copyWith(lnaEnabled: true, lnaBlocking: true),
        );
  } catch (e, s) {
    logger.w(
      'Failed applying privacy defaults during onboarding',
      error: e,
      stackTrace: s,
    );
  }
}
