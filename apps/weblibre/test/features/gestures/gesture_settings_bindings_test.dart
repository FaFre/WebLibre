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
import 'package:weblibre/features/gestures/data/models/gesture_settings.dart';

void main() {
  final defaults = GestureSettings.withDefaults();

  test('starts from the default bindings', () {
    expect(defaults.bindings, defaultGestureBindings);
    expect(defaults.hasCustomBindings, isFalse);
  });

  test('adding a gesture keeps the defaults beside it', () {
    final settings = defaults.withBinding('U-D', BrowserAction.newTab);

    expect(settings.bindings, {
      ...defaultGestureBindings,
      'U-D': BrowserAction.newTab,
    });
    expect(settings.bindingOverrides, {'U-D': BrowserAction.newTab});
  });

  test('removing a default binding records the removal', () {
    final settings = defaults.withBindingRemoved('D-L');

    expect(settings.bindings.containsKey('D-L'), isFalse);
    expect(settings.bindingOverrides, {'D-L': null});
  });

  test('removing an added binding leaves no trace', () {
    final settings = defaults
        .withBinding('U-D', BrowserAction.newTab)
        .withBindingRemoved('U-D');

    expect(settings.bindingOverrides, isEmpty);
  });

  test('editing a binding moves it to the new gesture', () {
    final settings = defaults.withBinding(
      'U-D',
      BrowserAction.forward,
      replacedKey: 'D-L',
    );

    expect(settings.bindings['U-D'], BrowserAction.forward);
    expect(settings.bindings.containsKey('D-L'), isFalse);
  });

  test('rebinding a gesture to its default stores nothing', () {
    final settings = defaults
        .withBinding('D-L', BrowserAction.reload)
        .withBinding('D-L', defaultGestureBindings['D-L']!);

    expect(settings.bindingOverrides, isEmpty);
  });

  test('reset drops every change', () {
    final settings = defaults
        .withBinding('U-D', BrowserAction.newTab)
        .withBindingRemoved('D-L')
        .withBindingsReset();

    expect(settings.bindings, defaultGestureBindings);
  });

  test('survives a JSON round trip, including a removed default', () {
    final settings = defaults
        .withBinding('U-D', BrowserAction.newTab)
        .withBindingRemoved('D-L');

    expect(GestureSettings.fromJson(settings.toJson()), settings);
  });
}
