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
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'tracking_protection.g.dart';

/// Repository for managing per-site Enhanced Tracking Protection exceptions
///
/// Wraps the GeckoTrackingProtectionApi and handles state invalidation
/// automatically after mutations.
@Riverpod(keepAlive: true)
class TrackingProtectionRepository extends _$TrackingProtectionRepository {
  final _api = GeckoTrackingProtectionApi();

  /// Check if a tab has a tracking protection exception
  ///
  /// Returns true if ETP is disabled for this site
  Future<bool> containsException(String tabId) {
    return _api.containsException(tabId);
  }

  /// Add tracking protection exception for a tab (disable ETP for this site)
  Future<void> addException(String tabId) async {
    await _api.addException(tabId);
    await _invalidateWithDelay();
  }

  /// Remove tracking protection exception for a tab (enable ETP for this site)
  Future<void> removeException(String tabId) async {
    await _api.removeException(tabId);
    await _invalidateWithDelay();
  }

  /// Remove a specific exception by URL and refresh the exceptions list
  Future<void> removeExceptionByUrl(String url) async {
    await _api.removeExceptionByUrl(url);
    await _invalidateWithDelay();
  }

  /// Remove all tracking protection exceptions
  Future<void> removeAllExceptions() async {
    await _api.removeAllExceptions();
    await _invalidateWithDelay();
  }

  /// Helper method to invalidate repository state after mutations with delay
  Future<void> _invalidateWithDelay() async {
    await Future.delayed(const Duration(milliseconds: 100)).whenComplete(() {
      if (ref.mounted) {
        ref.invalidateSelf();
      }
    });
  }

  @override
  Future<List<TrackingProtectionException>> build() {
    return _api.fetchExceptions();
  }
}
