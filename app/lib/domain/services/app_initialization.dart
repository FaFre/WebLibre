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
import 'dart:async';

import 'package:exceptions/exceptions.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/core/providers/format.dart';
import 'package:weblibre/features/about/data/repositories/package_info_repository.dart';
import 'package:weblibre/features/bangs/data/models/bang_group.dart';
import 'package:weblibre/features/bangs/domain/repositories/sync.dart';

part 'app_initialization.g.dart';

@Riverpod(keepAlive: true)
class AppInitializationService extends _$AppInitializationService {
  /// Will de facto restart the app
  Future<void> reinitialize() {
    ref.invalidateSelf();
    return initialize();
  }

  Future<void> _initPackageInfo() {
    //Ensure Package info is loaded
    state = Result.success((
      initialized: false,
      stage: 'Loading Package Info...',
      errors: List.empty(),
    ));

    return ref.read(packageInfoProvider.future);
  }

  Future<Map<BangGroup, Result<void>>> _initBangs() {
    state = Result.success((
      initialized: false,
      stage: 'Synchronizing Bangs...',
      errors: List.empty(),
    ));

    return ref
        .read(bangSyncRepositoryProvider.notifier)
        .syncBundledBangGroups();
  }

  Future<void> initialize() async {
    state = await Result.fromAsync(() async {
      final errors = <ErrorMessage>[];

      await ref.read(formatProvider.future);

      await _initPackageInfo();

      final bangSyncResults = await _initBangs();
      for (final MapEntry(value: result) in bangSyncResults.entries) {
        result.onFailure(errors.add);
      }

      return (initialized: true, stage: null, errors: errors);
    });
  }

  @override
  Result<({bool initialized, String? stage, List<ErrorMessage> errors})>
  build() {
    return Result.success((
      initialized: false,
      stage: null,
      errors: List.empty(),
    ));
  }
}
