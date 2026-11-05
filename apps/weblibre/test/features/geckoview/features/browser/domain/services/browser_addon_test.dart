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
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/features/geckoview/domain/providers.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/services/browser_addon.dart';

const _guid = 'uBlock0@raymondhill.net';

AddonInfo _addon({required bool isInstalled}) => AddonInfo(
  id: _guid,
  displayName: 'uBlock Origin',
  description: '',
  downloadUrl: '',
  version: '1.0',
  translatedPermissions: const [],
  translatedRequiredDataCollectionPermissions: const [],
  homepageUrl: '',
  detailUrl: '',
  ratingUrl: '',
  createdAt: '',
  updatedAt: '',
  isInstalled: isInstalled,
  isEnabled: isInstalled,
  isSupported: true,
  isAllowedInPrivateBrowsing: false,
  isAutoUpdateEnabled: true,
  isLocalFileInstalled: false,
  openOptionsPageInTab: false,
  incognito: AddonIncognito.spanning,
);

/// Answers [getAddonById] like the native side: with the installed add-on,
/// else a catalog entry, else nothing.
class _FakeAddonService implements GeckoAddonService {
  _FakeAddonService(this._lookup);

  final Future<AddonInfo?> Function() _lookup;

  @override
  Future<AddonInfo?> getAddonById(String addonId, {bool allowCache = true}) =>
      _lookup();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<bool> _isInstalled(Future<AddonInfo?> Function() lookup) async {
  final container = ProviderContainer.test(
    overrides: [
      addonServiceProvider.overrideWithValue(_FakeAddonService(lookup)),
    ],
  );
  return await container
      .read(browserAddonServiceProvider.notifier)
      .isInstalled(_guid);
}

void main() {
  group('isInstalled', () {
    test('an installed add-on is', () async {
      expect(await _isInstalled(() async => _addon(isInstalled: true)), true);
    });

    test('a catalog entry is not', () async {
      expect(await _isInstalled(() async => _addon(isInstalled: false)), false);
    });

    test('an unknown add-on is not', () async {
      expect(await _isInstalled(() async => null), false);
    });

    test('a failed lookup is not, so installing decides', () async {
      expect(await _isInstalled(() async => throw Exception('offline')), false);
    });
  });
}
