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
import 'package:fast_equatable/fast_equatable.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/features/geckoview/domain/entities/states/tab.dart';
import 'package:weblibre/features/geckoview/domain/repositories/tab.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/providers.dart';
import 'package:weblibre/features/geckoview/features/split_view/domain/entities/split_pair.dart';
import 'package:weblibre/features/geckoview/features/split_view/domain/providers/split_view.dart';
import 'package:weblibre/features/geckoview/features/split_view/presentation/utils/split_view_actions.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/entities/tab_mode.dart';

/// Records what the toggle asks for, and forms the pair at once.
class _FakeController extends SplitViewController {
  final SplitPair? initial;
  final calls = <String>[];

  _FakeController(this.initial);

  @override
  SplitPair? build() => initial;

  @override
  SplitPair? lastPairOf(String tabId) => null;

  @override
  Future<void> pair(
    String first,
    String second, {
    SplitPair? arrangement,
  }) async {
    calls.add('pair:$first,$second');
    state = SplitPair(pairId: 'new', firstTabId: first, secondTabId: second);
  }

  @override
  void end() {
    calls.add('end');
    state = null;
  }

  @override
  void setFocusedOnly(bool focusedOnly) {
    calls.add('focusedOnly:$focusedOnly');
    super.setFocusedOnly(focusedOnly);
  }
}

class _FakeTabRepository extends TabRepository {
  @override
  void build() {}

  @override
  Future<bool> selectTab(String tabId) async => true;
}

TabState _tab(String tabId, [TabMode tabMode = TabMode.regular]) =>
    TabState.$default(tabId).copyWith(tabMode: tabMode);

void main() {
  late _FakeController controller;
  late ProviderContainer container;
  final errors = <SplitViewError>[];

  void setUpContainer({SplitPair? pair, List<TabState>? openTabs}) {
    controller = _FakeController(pair);
    final open = openTabs ?? [_tab('a'), _tab('c'), _tab('b')];
    container = ProviderContainer(
      overrides: [
        splitViewControllerProvider.overrideWith(() => controller),
        tabRepositoryProvider.overrideWith(_FakeTabRepository.new),
        fifoTabStatesProvider.overrideWith(
          (ref) => EquatableValue([for (final tab in open) (tab, null)]),
        ),
      ],
    );
    addTearDown(container.dispose);
    errors.clear();
  }

  Future<bool> toggle() => toggleSplitView(
    container.read,
    tabId: 'a',
    state: splitToggleStateOf(container.read(splitViewControllerProvider)),
    onError: errors.add,
  );

  group('splitToggleStateOf', () {
    test('no pair is off', () {
      expect(splitToggleStateOf(null), SplitToggleState.off);
    });

    test('a pair with both pages shown is shown', () {
      expect(
        splitToggleStateOf(
          SplitPair(pairId: 'p', firstTabId: 'a', secondTabId: 'b'),
        ),
        SplitToggleState.shown,
      );
    });

    test('a pair showing only one page is collapsed', () {
      expect(
        splitToggleStateOf(
          SplitPair(
            pairId: 'p',
            firstTabId: 'a',
            secondTabId: 'b',
            focusedOnly: true,
          ),
        ),
        SplitToggleState.collapsed,
      );
    });
  });

  group('toggleSplitView', () {
    test('off: pairs with the tab used before, keeping the order', () async {
      setUpContainer();

      expect(await toggle(), isTrue);

      expect(controller.calls, ['pair:a,c']);
      expect(errors, isEmpty);
    });

    test(
      'off with no tab to show beside it does nothing and says so',
      () async {
        setUpContainer(openTabs: [_tab('a'), _tab('p', TabMode.private)]);

        expect(await toggle(), isFalse);

        expect(controller.calls, isEmpty);
      },
    );

    test('shown: ends the split', () async {
      setUpContainer(
        pair: SplitPair(pairId: 'p', firstTabId: 'a', secondTabId: 'b'),
      );

      expect(await toggle(), isTrue);

      expect(controller.calls, ['end']);
      expect(container.read(splitViewControllerProvider), isNull);
    });

    test('collapsed: shows both pages again instead of ending', () async {
      setUpContainer(
        pair: SplitPair(
          pairId: 'p',
          firstTabId: 'a',
          secondTabId: 'b',
          focusedOnly: true,
        ),
      );

      expect(await toggle(), isTrue);

      expect(controller.calls, ['focusedOnly:false']);
      final pair = container.read(splitViewControllerProvider);
      expect(pair?.pairId, 'p');
      expect(pair?.focusedOnly, isFalse);
    });
  });
}
