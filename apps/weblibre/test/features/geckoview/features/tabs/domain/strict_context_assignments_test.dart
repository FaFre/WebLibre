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
import 'dart:ui';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/data/database/functions/lexo_rank_functions.dart';
import 'package:weblibre/data/database/functions/url_functions.dart';
import 'package:weblibre/domain/feature_policy/feature_policy.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/database/database.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/models/container_data.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/providers.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/providers.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';

void main() {
  late TabDatabase db;

  setUp(() async {
    db = TabDatabase(
      NativeDatabase.memory(
        setup: (database) {
          registerLexorankFunctions(database);
          registerUrlFunctions(database);
        },
      ),
    );
    await db.containerDao.addContainer(
      ContainerData(
        id: 'strict',
        name: 'Strict',
        color: const Color(0xFF336699),
        orderKey: 'a',
        metadata: ContainerMetadata.withDefaults(
          contextualIdentity: 'context-strict',
          strictMode: true,
        ),
      ),
    );
  });

  tearDown(() => db.close());

  Future<Map<String, List<String>>> strictContexts(
    GeneralSettings settings,
  ) async {
    final container = ProviderContainer(
      overrides: [
        tabDatabaseProvider.overrideWith((ref) => db),
        generalSettingsWithDefaultsProvider.overrideWithValue(settings),
      ],
    );
    addTearDown(container.dispose);
    // Listened, as the replication services do: a bare read leaves a
    // keep-alive provider inactive in Riverpod 3.
    final subscription = container.listen(
      watchStrictContextAssignmentsProvider,
      (_, _) {},
    );
    addTearDown(subscription.close);
    return await container.read(watchStrictContextAssignmentsProvider.future);
  }

  test('a strict container is enforced while strict mode is shown', () async {
    expect(await strictContexts(GeneralSettings.withDefaults()), {
      'context-strict': ['context-strict'],
    });
  });

  test('nothing is enforced while strict mode is hidden; the container keeps '
      'the option', () async {
    final hidden = GeneralSettings.withDefaults().withVisibilitySwitch(
      VisibilitySwitch.expertDetails,
      enabled: false,
    );
    expect(await strictContexts(hidden), isEmpty);

    final stored = await db.containerDao
        .getContainerData('strict')
        .getSingleOrNull();
    expect(stored?.metadata.strictMode, isTrue);
  });
}
