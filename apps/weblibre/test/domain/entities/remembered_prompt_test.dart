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
import 'package:weblibre/domain/entities/remembered_prompt.dart';
import 'package:weblibre/features/user/data/database/database.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';
import 'package:weblibre/features/user/data/providers.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';

void main() {
  group('parseRememberedPrompts', () {
    test('keeps answers that belong to their prompt', () {
      expect(
        parseRememberedPrompts({
          'keepExternalTab': 'discard',
          'closeAllTabs': 'confirmed',
        }),
        {
          RememberedPrompt.keepExternalTab: 'discard',
          RememberedPrompt.closeAllTabs: 'confirmed',
        },
      );
    });

    test('drops unknown prompts and foreign answers instead of failing', () {
      // A downgrade can leave a prompt this version does not know, and an
      // answer that belongs to another prompt must never be handed out.
      expect(
        parseRememberedPrompts({
          'promptFromTheFuture': 'confirmed',
          'keepExternalTab': 'confirmed',
          'closeAllTabs': 'keep',
          'startTor': 42,
          'startProxyConnection': 'confirmed',
        }),
        {RememberedPrompt.startProxyConnection: 'confirmed'},
      );
    });

    test('a missing map reads as nothing remembered', () {
      expect(parseRememberedPrompts(null), isEmpty);
    });
  });

  group('GeneralSettings.rememberedAnswer', () {
    test('returns the typed answer, or null while it asks', () {
      final settings = GeneralSettings.withDefaults(
        rememberedPrompts: {RememberedPrompt.keepExternalTab: 'keep'},
      );

      expect(
        settings.rememberedAnswer<KeepTabAnswer>(
          RememberedPrompt.keepExternalTab,
        ),
        KeepTabAnswer.keep,
      );
      expect(
        settings.rememberedAnswer<PromptConfirmation>(
          RememberedPrompt.closeAllTabs,
        ),
        isNull,
      );
    });
  });

  test(
    'remembered answers survive a round trip through the settings DB',
    () async {
      final db = UserDatabase(
        NativeDatabase.memory(setup: registerLexorankFunctions),
      );
      addTearDown(db.close);

      final container = ProviderContainer(
        overrides: [userDatabaseProvider.overrideWith((ref) => db)],
      );
      addTearDown(container.dispose);

      final repository = container.read(
        generalSettingsRepositoryProvider.notifier,
      );
      await repository.updateSettings(
        (current) => current.copyWith.rememberedPrompts({
          RememberedPrompt.keepExternalTab: KeepTabAnswer.discard.name,
          RememberedPrompt.startTor: PromptConfirmation.confirmed.name,
        }),
      );

      final settings = await repository.fetchSettings();
      expect(
        settings.rememberedAnswer<KeepTabAnswer>(
          RememberedPrompt.keepExternalTab,
        ),
        KeepTabAnswer.discard,
      );
      expect(
        settings.rememberedAnswer<PromptConfirmation>(
          RememberedPrompt.startTor,
        ),
        PromptConfirmation.confirmed,
      );
    },
  );
}
