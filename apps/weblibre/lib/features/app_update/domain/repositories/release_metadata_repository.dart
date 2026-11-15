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
import 'package:weblibre/features/app_update/domain/entities/release_metadata.dart';
import 'package:weblibre/features/app_update/domain/services/update_backend.dart';

/// The signed release catalogue (plan 5).
abstract interface class ReleaseMetadataRepository {
  /// Reads the stored copies once (6.1).
  Future<void> open();

  bool get recoveryRequired;

  /// The highest accepted catalogue, verified on read.
  AcceptedCatalogue? get accepted;

  /// Fetches, verifies, applies freshness and stores. Throws `UpdateFailure`.
  Future<AcceptedCatalogue> fetchAndAccept({CancelToken? cancel});

  /// The accepted catalogue if it is fresh right now, else null.
  ReleaseCatalogue? usable();

  /// "Reset and check again": the one way to lower the revision floor.
  Future<void> reset();
}
