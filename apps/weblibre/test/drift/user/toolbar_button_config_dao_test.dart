import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weblibre/data/database/functions/lexo_rank_functions.dart';
import 'package:weblibre/features/browser_actions/data/models/browser_action.dart';
import 'package:weblibre/features/geckoview/features/browser/features/contextual_toolbar/data/providers/toolbar_button_configs.dart';
import 'package:weblibre/features/geckoview/features/browser/features/contextual_toolbar/domain/entities/toolbar_config_location.dart';
import 'package:weblibre/features/user/data/database/database.dart';
import 'package:weblibre/features/user/data/database/definitions.drift.dart';

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
      'writeChanged persists default toolbar fallbacks without FK failures',
      () async {
        await expectLater(
          db.toolbarButtonConfigDao.writeChanged(
            defaultToolbarButtonConfigsFor(
              ToolbarConfigLocation.contextual,
            ).value,
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

    test('writeChanged stores and clears a long press binding', () async {
      final dao = db.toolbarButtonConfigDao;
      const back = ToolbarButtonConfig(
        buttonId: 'back',
        orderKey: '0|hzzzzz:',
        isVisible: true,
      );
      await dao.writeChanged([
        back.copyWith(longPressAction: const Value(BrowserAction.showHistory)),
      ]);
      expect(
        (await dao.getAll()).single.longPressAction,
        BrowserAction.showHistory,
      );

      await dao.writeChanged([back]);
      expect((await dao.getAll()).single.longPressAction, isNull);
    });

    // A newer version's button, say, kept after a downgrade: an edit of the
    // known buttons must neither delete it nor fail on the fallback that
    // points at it.
    test('writeChanged keeps rows and fallbacks of unlisted buttons', () async {
      final dao = db.toolbarButtonConfigDao;
      await dao.seedMissing([
        (buttonId: 'future', defaultVisible: false, defaultFallback: null),
        (buttonId: 'back', defaultVisible: true, defaultFallback: 'future'),
        (buttonId: 'forward', defaultVisible: true, defaultFallback: null),
      ]);
      final known = [
        for (final config in await dao.getAll())
          if (config.buttonId != 'future') config,
      ];

      await dao.writeChanged([
        for (final config in known)
          config.buttonId == 'forward'
              ? config.copyWith(isVisible: false)
              : config,
      ]);

      final byId = {for (final c in await dao.getAll()) c.buttonId: c};
      expect(byId.keys, containsAll(['future', 'back', 'forward']));
      expect(byId['back']?.fallbackId, 'future');
      expect(byId['forward']?.isVisible, isFalse);
    });
  });

  group('QuickSwitcherButtonConfigDao', () {
    test('writeChanged keeps long press bindings', () async {
      final dao = db.quickSwitcherButtonConfigDao;
      await dao.writeChanged([
        const QuickSwitcherButtonConfig(
          buttonId: 'back',
          orderKey: '0|hzzzzz:',
          isVisible: true,
          longPressAction: BrowserAction.reopenClosedTab,
        ),
      ]);

      expect(
        (await dao.getAll()).single.longPressAction,
        BrowserAction.reopenClosedTab,
      );
    });
  });
}
