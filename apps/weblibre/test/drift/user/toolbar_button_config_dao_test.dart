import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weblibre/data/database/functions/lexo_rank_functions.dart';
import 'package:weblibre/features/geckoview/features/browser/features/contextual_toolbar/data/providers/toolbar_button_configs.dart';
import 'package:weblibre/features/user/data/database/database.dart';

void main() {
  late UserDatabase db;

  setUp(() {
    db = UserDatabase(
      NativeDatabase.memory(
        setup: (database) {
          registerLexorankFunctions(database);
        },
      ),
    );
  });

  tearDown(() async {
    await db.close();
  });

  group('ToolbarButtonConfigDao', () {
    test(
      'seedMissing inserts self-referential fallback rows in two phases',
      () async {
        await db.toolbarButtonConfigDao.seedMissing([
          (
            buttonId: 'back',
            defaultVisible: true,
            defaultFallback: 'bookmarks',
          ),
          (buttonId: 'bookmarks', defaultVisible: false, defaultFallback: null),
          (buttonId: 'forward', defaultVisible: true, defaultFallback: 'share'),
          (buttonId: 'share', defaultVisible: false, defaultFallback: null),
        ]);

        final configs = await db.toolbarButtonConfigDao.getAll();
        final configsById = {
          for (final config in configs) config.buttonId: config,
        };

        expect(configsById['back']?.fallbackId, 'bookmarks');
        expect(configsById['forward']?.fallbackId, 'share');
      },
    );

    test(
      'replaceAll persists default toolbar fallbacks without FK failures',
      () async {
        await expectLater(
          db.toolbarButtonConfigDao.replaceAll(
            buildDefaultToolbarButtonConfigs(),
          ),
          completes,
        );

        final configs = await db.toolbarButtonConfigDao.getAll();
        final configsById = {
          for (final config in configs) config.buttonId: config,
        };

        expect(configsById['back']?.fallbackId, 'bookmarks');
        expect(configsById['forward']?.fallbackId, 'share');
      },
    );
  });
}
