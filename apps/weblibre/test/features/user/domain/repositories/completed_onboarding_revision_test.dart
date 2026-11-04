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
import 'package:weblibre/features/user/data/database/database.dart';
import 'package:weblibre/features/user/data/providers.dart';
import 'package:weblibre/features/user/domain/repositories/onboarding.dart';

void main() {
  // The router reads the revision this way: one subscription held for its
  // lifetime, then the first value awaited. Without the subscription Riverpod
  // pauses the stream and the first value never arrives.
  test(
    'a held subscription gets the first revision and every later one',
    () async {
      final db = UserDatabase(
        NativeDatabase.memory(setup: registerLexorankFunctions),
      );
      addTearDown(db.close);

      final container = ProviderContainer(
        overrides: [userDatabaseProvider.overrideWith((ref) => db)],
      );
      addTearDown(container.dispose);

      final seen = <int?>[];
      container.listen(completedOnboardingRevisionProvider, (_, next) {
        if (next.hasValue) seen.add(next.value);
      });

      final first = await container
          .read(completedOnboardingRevisionProvider.future)
          .timeout(const Duration(seconds: 5));
      expect(first, isNull);

      await container
          .read(onboardingRepositoryProvider.notifier)
          .pushRevision(OnboardingRepository.targetRevision);
      await container.pump();
      await Future<void>.delayed(Duration.zero);

      expect(seen.last, OnboardingRepository.targetRevision);
    },
  );
}
