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
import 'package:exceptions/exceptions.dart';
import 'package:nullability/nullability.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/core/filesystem.dart';
import 'package:weblibre/domain/entities/profile.dart';
import 'package:weblibre/features/user/data/providers.dart';
import 'package:weblibre/features/user/domain/entities/fingerprint_overrides.dart';
import 'package:weblibre/features/user/domain/repositories/engine_settings.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/features/user/domain/repositories/profile.dart';
import 'package:weblibre/features/user/domain/services/fingerprinting.dart';

part 'providers.g.dart';

@Riverpod()
Stream<double> iconCacheSizeMegabytes(Ref ref) {
  final repository = ref.watch(userDatabaseProvider);
  return repository.cacheDao.getIconCacheSize().watchSingle();
}

@Riverpod()
bool incognitoModeEnabled(Ref ref) {
  return ref.watch(
    generalSettingsWithDefaultsProvider.select(
      (value) => value.deleteBrowsingDataOnQuit != null,
    ),
  );
}

@Riverpod()
Future<Result<FingerprintOverrides>> fingerprintOverrideSettings(
  Ref ref,
) async {
  final fingerprintTargets = await ref.watch(fingerprintTargetsProvider.future);
  final fingerprintTargetSet = fingerprintTargets.map((e) => e.name).toSet();

  final overrides = ref.watch(
    engineSettingsWithDefaultsProvider.select(
      (settings) =>
          settings.fingerprintingProtectionOverrides.mapNotNull(
            (settings) =>
                FingerprintOverrides.parse(settings, fingerprintTargetSet),
          ) ??
          Result.success(FingerprintOverrides.defaults()),
    ),
  );

  return overrides;
}

@Riverpod(keepAlive: true)
Future<Profile> selectedProfile(Ref ref) async {
  final profiles = await ref.watch(profileRepositoryProvider.future);
  return profiles.firstWhere((p) => p.uuidValue == filesystem.selectedProfile);
}
