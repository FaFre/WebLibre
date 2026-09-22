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
      'replaceAll persists default toolbar fallbacks without FK failures',
      () async {
        await expectLater(
          db.toolbarButtonConfigDao.replaceAll(
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

    test('assignLongPressAction stores and clears a binding', () async {
      final dao = db.toolbarButtonConfigDao;
      await dao.seedMissing([
        (buttonId: 'back', defaultVisible: true, defaultFallback: null),
      ]);

      await dao.assignLongPressAction('back', BrowserAction.newPrivateTab);
      expect(
        (await dao.getAll()).single.longPressAction,
        BrowserAction.newPrivateTab,
      );

      await dao.assignLongPressAction('back', null);
      expect((await dao.getAll()).single.longPressAction, isNull);
    });

    test('replaceAll keeps long press bindings', () async {
      final dao = db.toolbarButtonConfigDao;
      await dao.replaceAll([
        ToolbarButtonConfig(
          buttonId: 'back',
          orderKey: '0|hzzzzz:',
          isVisible: true,
          longPressAction: BrowserAction.showHistory,
        ),
      ]);

      expect(
        (await dao.getAll()).single.longPressAction,
        BrowserAction.showHistory,
      );
    });
  });

  group('QuickSwitcherButtonConfigDao', () {
    test('replaceAll keeps long press bindings', () async {
      final dao = db.quickSwitcherButtonConfigDao;
      await dao.replaceAll([
        QuickSwitcherButtonConfig(
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
