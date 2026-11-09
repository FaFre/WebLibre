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
import 'package:weblibre/domain/feature_policy/feature_policy.dart';
import 'package:weblibre/features/browser_actions/domain/entities/browser_action_policy.dart';
import 'package:weblibre/features/geckoview/features/browser/features/contextual_toolbar/domain/entities/toolbar_button_id.dart';
import 'package:weblibre/features/geckoview/features/browser/features/contextual_toolbar/domain/services/toolbar_button_resolution.dart';
import 'package:weblibre/features/geckoview/features/browser/features/contextual_toolbar/presentation/toolbar_button_registry.dart';
import 'package:weblibre/features/user/data/database/definitions.drift.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';

ToolbarButtonConfig _config(String id, {String? fallback}) =>
    ToolbarButtonConfig(
      buttonId: id,
      orderKey: id,
      isVisible: true,
      fallbackId: fallback,
    );

void main() {
  const known = {'split', 'share', 'gestures', 'back'};

  /// What a toolbar draws for [configs]: `id` for a usable button, `(id)` for
  /// a greyed-out one.
  List<String> resolve(
    List<ToolbarButtonConfig> configs, {
    Set<String> unavailable = const {},
    Set<String> hidden = const {},
  }) => [
    for (final button in resolveVisibleContextualToolbarButtons(
      configs: configs,
      knownButtonIds: known,
      isPrimaryAvailable: (id) => !unavailable.contains(id),
      isHidden: hidden.contains,
    ))
      if (button.isEnabled) button.buttonId else '(${button.buttonId})',
  ];

  test('an unavailable button without a fallback is greyed out', () {
    expect(
      resolve([_config('back'), _config('split')], unavailable: {'split'}),
      ['back', '(split)'],
    );
  });

  test('a hidden button without a fallback is left out', () {
    expect(resolve([_config('back'), _config('split')], hidden: {'split'}), [
      'back',
    ]);
  });

  test('a hidden button gives its slot to its fallback', () {
    expect(resolve([_config('split', fallback: 'share')], hidden: {'split'}), [
      'share',
    ]);
  });

  test('a hidden button is left out even when it would be available', () {
    // Hidden decides before availability: the button is not greyed out
    // either.
    expect(resolve([_config('gestures')], hidden: {'gestures'}), isEmpty);
  });

  test('an unavailable button whose fallback is hidden is greyed out', () {
    expect(
      resolve(
        [_config('back', fallback: 'split'), _config('split')],
        unavailable: {'back'},
        hidden: {'split'},
      ),
      ['(back)'],
    );
  });

  test('a fallback that is hidden and not configured is not used', () {
    expect(
      resolve(
        [_config('back', fallback: 'split')],
        unavailable: {'back'},
        hidden: {'split'},
      ),
      ['(back)'],
    );
  });

  group('hiddenToolbarButtonIds', () {
    GeneralSettings settings({required bool shown}) =>
        GeneralSettings.withDefaults(
          visibilitySwitches: {
            VisibilitySwitch.splitView: shown,
            VisibilitySwitch.gestures: shown,
          },
        );

    test('names the split and gestures buttons while their features are '
        'hidden', () {
      expect(hiddenToolbarButtonIds(settings(shown: false)), {
        'splitView',
        'toggleGestures',
      });
    });

    test('names neither while both are shown', () {
      final hidden = hiddenToolbarButtonIds(settings(shown: true));
      expect(hidden, isNot(contains('splitView')));
      expect(hidden, isNot(contains('toggleGestures')));
    });

    test('follows the action of each button, as the toolbar settings and the '
        'action pickers do', () {
      for (final shown in [true, false]) {
        final general = settings(shown: shown);
        expect(hiddenToolbarButtonIds(general), {
          for (final id in ToolbarButtonId.values)
            if (id.action case final action? when !action.isShownIn(general))
              id.name,
        });
      }
    });
  });
}
