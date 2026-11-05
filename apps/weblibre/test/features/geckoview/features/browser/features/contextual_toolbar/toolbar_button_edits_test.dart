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
import 'package:weblibre/features/geckoview/features/browser/features/contextual_toolbar/data/providers/toolbar_button_configs.dart';
import 'package:weblibre/features/geckoview/features/browser/features/contextual_toolbar/domain/entities/toolbar_config_location.dart';
import 'package:weblibre/features/user/data/database/definitions.drift.dart';

void main() {
  final defaults = defaultToolbarButtonConfigsFor(
    ToolbarConfigLocation.contextual,
  ).value;

  List<String> section(
    List<ToolbarButtonConfig> configs, {
    required bool visible,
  }) => [
    for (final config in sortedToolbarButtons(configs))
      if (config.isVisible == visible) config.buttonId,
  ];

  test('a button switched on goes to the end of the shown ones', () {
    final hidden = section(defaults, visible: false).first;

    final updated = setToolbarButtonVisibility(defaults, hidden, visible: true);

    expect(section(updated, visible: true).last, hidden);
    expect(section(updated, visible: false), isNot(contains(hidden)));
  });

  test('a button switched off goes to the end of the hidden ones', () {
    final shown = section(defaults, visible: true).first;

    final updated = setToolbarButtonVisibility(defaults, shown, visible: false);

    expect(section(updated, visible: false).last, shown);
    expect(section(updated, visible: true), isNot(contains(shown)));
  });

  test('a move places the button between its new neighbours', () {
    final shown = section(defaults, visible: true);
    expect(shown.length, greaterThanOrEqualTo(3));

    // To the front.
    var updated = moveToolbarButton(defaults, shown, shown.length - 1, 0);
    expect(section(updated, visible: true), [
      shown.last,
      ...shown.sublist(0, shown.length - 1),
    ]);

    // Between the first two.
    var order = section(updated, visible: true);
    updated = moveToolbarButton(updated, order, order.length - 1, 1);
    expect(section(updated, visible: true).sublist(0, 2), [
      order[0],
      order.last,
    ]);

    // Past the last one.
    order = section(updated, visible: true);
    updated = moveToolbarButton(updated, order, 0, order.length - 1);
    expect(section(updated, visible: true).last, order.first);

    // Only the moved button changed its key each time, and hidden ones never
    // move.
    expect(section(updated, visible: false), section(defaults, visible: false));
  });

  test('a move in a filtered list keeps the others among their neighbours', () {
    final shown = section(defaults, visible: true);
    // A list that leaves out the second button.
    final filtered = [shown[0], ...shown.sublist(2)];

    final updated = moveToolbarButton(defaults, filtered, 0, 1);

    expect(section(updated, visible: true).sublist(0, 4), [
      shown[1],
      shown[2],
      shown[0],
      shown[3],
    ]);
  });

  // The editor listed the defaults while the store loaded; the stored
  // buttons it lands on have the dragged one in the other section.
  test('a move made on a list that no longer matches changes nothing', () {
    final shown = section(defaults, visible: true);
    final stored = setToolbarButtonVisibility(
      defaults,
      shown[1],
      visible: false,
    );

    expect(
      moveToolbarButton(stored, shown, 0, 1),
      sortedToolbarButtons(stored),
    );
    expect(
      moveToolbarButton(stored, shown, 1, 0),
      sortedToolbarButtons(stored),
    );
  });

  test('fallback and long press are set and cleared', () {
    final id = section(defaults, visible: true).first;

    var updated = setToolbarButtonFallback(defaults, id, null);
    updated = setToolbarButtonLongPress(
      updated,
      id,
      BrowserAction.values.first,
    );
    var config = updated.singleWhere((c) => c.buttonId == id);
    expect(config.fallbackId, isNull);
    expect(config.longPressAction, BrowserAction.values.first);

    updated = setToolbarButtonLongPress(updated, id, null);
    config = updated.singleWhere((c) => c.buttonId == id);
    expect(config.longPressAction, isNull);
  });

  test('edits return the set in order', () {
    final id = section(defaults, visible: true).first;
    final updated = setToolbarButtonFallback(
      defaults.reversed.toList(),
      id,
      null,
    );
    expect(updated.map((c) => c.buttonId), defaults.map((c) => c.buttonId));
  });
}
