import 'package:flutter_test/flutter_test.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/features/geckoview/domain/entities/states/tab.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/providers.dart';
import 'package:weblibre/features/geckoview/features/split_view/domain/entities/split_pair.dart';
import 'package:weblibre/features/geckoview/features/split_view/presentation/utils/split_view_actions.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/entities/tab_mode.dart';

void main() {
  group('splitPickerExcludedTabIds', () {
    final modes = <String, TabMode>{
      'a': TabMode.regular,
      'b': TabMode.regular,
      'i': TabMode.isolated('ctx'),
      'p': TabMode.private,
      'q': TabMode.private,
    };

    test('beside a regular tab: the source and private tabs', () {
      expect(splitPickerExcludedTabIds(sourceTabId: 'a', modes: modes), {
        'a',
        'p',
        'q',
      });
    });

    test('beside a private tab: the source and every non-private tab', () {
      expect(splitPickerExcludedTabIds(sourceTabId: 'p', modes: modes), {
        'p',
        'a',
        'b',
        'i',
      });
    });

    test('a source that is gone excludes only itself (and private tabs, '
        'as for a regular source)', () {
      expect(splitPickerExcludedTabIds(sourceTabId: 'x', modes: modes), {
        'x',
        'p',
        'q',
      });
    });
  });

  group('splitPickerTabTypes', () {
    test('beside a regular tab: regular, isolated and child', () {
      expect(
        splitPickerTabTypes(
          sourcePrivate: false,
          selectedTabType: TabType.regular,
        ),
        {TabType.regular, TabType.isolated, TabType.child},
      );
    });

    test('beside a private tab: private, and child from a private tab', () {
      expect(
        splitPickerTabTypes(
          sourcePrivate: true,
          selectedTabType: TabType.private,
        ),
        {TabType.private, TabType.child},
      );
      expect(
        splitPickerTabTypes(
          sourcePrivate: true,
          selectedTabType: TabType.regular,
        ),
        {TabType.private},
      );
    });
  });

  group('splitPartnerCandidates', () {
    TabStateWithContainer tab(String id, TabMode mode) =>
        (TabState.$default(id).copyWith(tabMode: mode), null);

    // Most recently used first, as the tab list hands them over.
    final tabs = [
      tab('a', TabMode.regular),
      tab('c', TabMode.regular),
      tab('p', TabMode.private),
      tab('i', TabMode.isolated('ctx')),
      tab('b', TabMode.regular),
      tab('q', TabMode.private),
    ];

    List<String> ids(List<TabStateWithContainer> entries) => [
      for (final (state, _) in entries) state.id,
    ];

    test('beside a regular tab: the other regular and isolated tabs, in the '
        'given order, so the first is the one used before it', () {
      expect(ids(splitPartnerCandidates(tabs: tabs, sourceTabId: 'a')), [
        'c',
        'i',
        'b',
      ]);
    });

    test('replacing the other page: neither member', () {
      expect(
        ids(
          splitPartnerCandidates(
            tabs: tabs,
            sourceTabId: 'a',
            excludedTabIds: {'a', 'b'},
          ),
        ),
        ['c', 'i'],
      );
    });

    test('beside a private tab: only the other private tabs', () {
      expect(ids(splitPartnerCandidates(tabs: tabs, sourceTabId: 'p')), ['q']);
    });

    test('a source that is gone offers nothing', () {
      expect(splitPartnerCandidates(tabs: tabs, sourceTabId: 'x'), isEmpty);
    });
  });

  group('splitToggleTarget', () {
    TabStateWithContainer tab(String id, [TabMode mode = TabMode.regular]) =>
        (TabState.$default(id).copyWith(tabMode: mode), null);

    // 'c' is the most recently used tab after 'a'.
    final tabs = [tab('a'), tab('c'), tab('b'), tab('p', TabMode.private)];
    final last = SplitPair(
      pairId: 'old',
      firstTabId: 'b',
      secondTabId: 'a',
      layout: SplitLayoutPreference.stacked,
      stackedRatio: 0.3,
    );

    test("the tab's last partner, as that split was arranged", () {
      final target = splitToggleTarget(tabs: tabs, tabId: 'a', lastPair: last);

      expect(target?.first, 'b');
      expect(target?.second, 'a');
      expect(target?.arrangement, same(last));
    });

    test('without a last pair: the tab used before it, this tab first', () {
      final target = splitToggleTarget(tabs: tabs, tabId: 'a', lastPair: null);

      expect(target?.first, 'a');
      expect(target?.second, 'c');
      expect(target?.arrangement, isNull);
    });

    test('a last partner that closed falls back to the tab used before', () {
      final target = splitToggleTarget(
        tabs: [tab('a'), tab('c')],
        tabId: 'a',
        lastPair: last,
      );

      expect(target?.second, 'c');
      expect(target?.arrangement, isNull);
    });

    test('nothing to show beside it', () {
      expect(
        splitToggleTarget(
          tabs: [tab('a'), tab('p', TabMode.private)],
          tabId: 'a',
          lastPair: null,
        ),
        isNull,
      );
    });
  });
}
