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
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod/experimental/persist.dart';
import 'package:weblibre/features/user/data/providers.dart';
import 'package:weblibre/features/user/domain/providers/backup_directory.dart';

void main() {
  final folder = Uri.parse(
    'content://com.android.externalstorage.documents/tree/primary%3ABackups',
  );

  ProviderContainer containerWithStorage() {
    final Storage<String, String> storage = Storage.inMemory();
    final container = ProviderContainer(
      overrides: [
        riverpodDatabaseStorageProvider.overrideWith((ref) => storage),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  test('choosing the folder that is already set reaches its dependents', () {
    // Picking it again renews the grant (#698), so whatever was read from the
    // folder under the old grant has to be read again.
    final container = containerWithStorage();
    final seen = <Uri?>[];
    container.listen(
      backupDirectoryUriProvider,
      (_, next) => seen.add(next),
      fireImmediately: false,
    );

    final notifier = container.read(backupDirectoryUriProvider.notifier);
    notifier.set(folder);
    notifier.set(folder);

    expect(seen, [folder, folder]);
  });
}
