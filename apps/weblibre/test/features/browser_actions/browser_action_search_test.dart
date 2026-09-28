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
import 'package:weblibre/features/browser_actions/data/models/browser_action.dart';
import 'package:weblibre/features/browser_actions/domain/services/browser_action_search.dart';

ActionSearchEntry<BrowserAction> _entry(
  BrowserAction action,
  String label, {
  String description = '',
  String category = '',
  List<String> keywords = const [],
}) => (
  item: action,
  label: label,
  description: description,
  category: category,
  keywords: keywords,
);

final _entries = [
  _entry(
    BrowserAction.findInPage,
    'Find in Page',
    description: 'Open find in page',
    category: 'Page',
  ),
  _entry(
    BrowserAction.newContainer,
    'New Container',
    description: 'Create a container',
    category: 'Create',
  ),
  _entry(
    BrowserAction.showHistory,
    'History',
    description: 'Open browsing history',
    category: 'Open',
  ),
  _entry(
    BrowserAction.showContainers,
    'Containers',
    description: 'Open the container list',
    category: 'Open',
  ),
  _entry(
    BrowserAction.openSettings,
    'Settings',
    description: 'Open settings',
    category: 'Open',
    keywords: const ['preferences', 'options'],
  ),
];

void main() {
  group('rankActionSearchEntries', () {
    test('matches nothing below the minimum length', () {
      expect(rankActionSearchEntries('c', _entries), isEmpty);
      expect(rankActionSearchEntries('  ', _entries), isEmpty);
    });

    test('ranks a label that starts with the query first', () {
      expect(rankActionSearchEntries('cont', _entries), [
        BrowserAction.showContainers,
        BrowserAction.newContainer,
      ]);
    });

    test('an exact label beats a description match', () {
      expect(rankActionSearchEntries('history', _entries), [
        BrowserAction.showHistory,
      ]);
    });

    test('is case-insensitive', () {
      expect(rankActionSearchEntries('SETT', _entries), [
        BrowserAction.openSettings,
      ]);
    });

    test('requires every word to match somewhere', () {
      expect(rankActionSearchEntries('new cont', _entries), [
        BrowserAction.newContainer,
      ]);
      expect(rankActionSearchEntries('container nonsense', _entries), isEmpty);
    });

    test('counts short fragments only in labels and categories', () {
      // "th" occurs inside description words ("the") but no label word starts
      // with it, so it must not pull in every action.
      expect(rankActionSearchEntries('th', _entries), isEmpty);
    });

    test('finds a row by a keyword it never shows', () {
      expect(rankActionSearchEntries('prefer', _entries), [
        BrowserAction.openSettings,
      ]);
    });

    test('matches a category', () {
      expect(rankActionSearchEntries('create', _entries), [
        BrowserAction.newContainer,
      ]);
    });
  });

  test('the searchable set leaves out menu navigation, repeat-press and '
      'app-level actions', () {
    for (final action in [
      BrowserAction.back,
      BrowserAction.forward,
      BrowserAction.reload,
      BrowserAction.hardReload,
      BrowserAction.newTab,
      BrowserAction.newPrivateTab,
      BrowserAction.focusAddressBar,
      BrowserAction.nextTab,
      BrowserAction.scrollTop,
      BrowserAction.findNext,
      BrowserAction.quitBrowser,
      BrowserAction.moveToBackground,
    ]) {
      expect(searchableBrowserActions, isNot(contains(action)));
    }
  });
}
