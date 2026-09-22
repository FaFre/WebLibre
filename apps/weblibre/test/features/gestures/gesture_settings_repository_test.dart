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
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/data/database/functions/lexo_rank_functions.dart';
import 'package:weblibre/features/browser_actions/data/models/browser_action.dart';
import 'package:weblibre/features/gestures/data/models/built_in_gesture.dart';
import 'package:weblibre/features/gestures/data/models/gesture_settings.dart';
import 'package:weblibre/features/gestures/domain/repositories/gesture_settings.dart';
import 'package:weblibre/features/user/data/database/database.dart';
import 'package:weblibre/features/user/data/providers.dart';

void main() {
  late UserDatabase db;
  late ProviderContainer container;

  setUp(() {
    db = UserDatabase(
      NativeDatabase.memory(
        setup: (database) {
          registerLexorankFunctions(database);
        },
      ),
    );
    container = ProviderContainer(
      overrides: [userDatabaseProvider.overrideWith((ref) => db)],
    );
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  // The read side lists every key by hand, so a new field that is only added
  // to the model is written but never read back.
  test('built-in gesture overrides are read back after a write', () async {
    final repository = container.read(
      gestureSettingsRepositoryProvider.notifier,
    );

    await repository.updateSettings(
      (current) => current.copyWith.builtInOverrides({
        BuiltInGesture.tabSwipeRight: BrowserAction.sharePage,
        BuiltInGesture.tabSwipeLeft: null,
      }),
    );

    final settings = await repository.fetchSettings();
    expect(settings.builtInOverrides, {
      BuiltInGesture.tabSwipeRight: BrowserAction.sharePage,
      BuiltInGesture.tabSwipeLeft: null,
    });
  });
}
