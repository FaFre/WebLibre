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
import 'package:exceptions/exceptions.dart';
import 'package:nullability/nullability.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:saf_util/saf_util_platform_interface.dart';
import 'package:weblibre/core/filesystem.dart';
import 'package:weblibre/domain/entities/profile.dart';
import 'package:weblibre/features/user/data/providers.dart';
import 'package:weblibre/features/user/domain/entities/fingerprint_overrides.dart';
import 'package:weblibre/features/user/domain/providers/backup_directory.dart';
import 'package:weblibre/features/user/domain/repositories/cache.dart';
import 'package:weblibre/features/user/domain/repositories/engine_settings.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/features/user/domain/repositories/profile.dart';
import 'package:weblibre/features/user/domain/services/fingerprinting.dart';
import 'package:weblibre/features/user/domain/services/user_backup.dart';

part 'providers.g.dart';

@Riverpod()
Stream<double> iconCacheSizeMegabytes(Ref ref) {
  final repository = ref.watch(userDatabaseProvider);
  return repository.cacheDao.getIconCacheSize().watchSingle();
}

/// A change signal for [origin]'s entry in the favicon cache.
///
/// Emits the cache's revision number whenever that origin's icon changes or the
/// whole cache is cleared, so a widget can key its icon lookup on this and be
/// rebuilt when — and only when — the icon actually changes.
///
/// This exists instead of a provider that watches the icon row itself. Every
/// row of every list renders a `UrlIcon`, so a reactive query here meant one
/// live SQLite watch per visible row, created and destroyed on every scroll
/// pass — against a table written only when a favicon is fetched. What is
/// emitted is deliberately just a number: the icon itself comes from
/// `GenericWebsiteService`'s in-memory cache, which this same signal evicts, so
/// a warm icon costs no database read at all.
///
/// Not an `async*` generator, and with no initial value: a generator suspends
/// on its first `yield` before it reaches the subscription, and an invalidation
/// arriving in that window would be dropped. Returning the stream directly has
/// Riverpod subscribe while the provider is being built; readers treat "no
/// value yet" as "nothing has changed since I started looking".
///
/// See https://github.com/FaFre/WebLibre/issues/599.
@Riverpod()
Stream<int> iconCacheRevision(Ref ref, String origin) {
  final repository = ref.watch(cacheRepositoryProvider.notifier);

  return repository.iconInvalidations
      .where((event) => event.origin == null || event.origin == origin)
      .map((event) => event.revision);
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

@Riverpod()
Future<List<SafDocumentFile>> backupList(Ref ref) async {
  final dirUri = ref.watch(backupDirectoryUriProvider);
  if (dirUri == null) return [];

  return ref.watch(userBackupServiceProvider.notifier).getBackupList(dirUri);
}
