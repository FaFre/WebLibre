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
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/features/user/data/providers.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';

part 'providers.g.dart';

const _authKey = 'pb_auth';

@Riverpod()
Future<String?> _storedAuthData(Ref ref) {
  const secureStorage = FlutterSecureStorage();
  return secureStorage.read(key: _authKey);
}

@Riverpod()
Stream<double> iconCacheSizeMegabytes(Ref ref) {
  final repository = ref.watch(userDatabaseProvider);
  return repository.cacheDao.getIconCacheSize().watchSingle();
}

@Riverpod()
bool incognitoModeEnabled(Ref ref) {
  return ref.watch(
    generalSettingsRepositoryProvider.select(
      (value) => value.deleteBrowsingDataOnQuit != null,
    ),
  );
}
