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
import 'package:weblibre/features/bangs/data/models/bang_data.dart';
import 'package:weblibre/features/bangs/data/models/bang_group.dart';
import 'package:weblibre/features/geckoview/features/search/presentation/widgets/bang_chip_menu.dart';
import 'package:weblibre/features/geckoview/features/search/presentation/widgets/bang_chip_strip.dart';
import 'package:weblibre/features/geckoview/features/search/presentation/widgets/empty_state/frequent_bangs_section.dart';

BangData _bang(
  String trigger,
  String name, {
  BangGroup group = BangGroup.general,
  int frequency = 0,
}) => BangData(
  websiteName: name,
  domain: '$trigger.example',
  trigger: trigger,
  urlTemplate: 'https://$trigger.example/?q={{{s}}}',
  group: group,
  searxngApi: false,
  frequency: frequency,
);

void main() {
  group('buildFrequentBangDisplayList', () {
    test('keeps selected bang first and default bang trailing', () {
      final selectedBang = _bang('ddg', 'DuckDuckGo');
      final defaultBang = _bang('wl', 'WebLibre Search');
      final frequentBangs = [defaultBang, _bang('g', 'Google')];

      final result = buildFrequentBangDisplayList(
        frequentBangs: frequentBangs,
        selectedBang: selectedBang,
        defaultBang: defaultBang,
      );

      expect(result.map((bang) => bang.trigger), ['ddg', 'g', 'wl']);
    });

    test('does not duplicate the same bang when default is selected', () {
      final defaultBang = _bang('wl', 'WebLibre Search');
      final frequentBangs = [defaultBang, _bang('g', 'Google')];

      final result = buildFrequentBangDisplayList(
        frequentBangs: frequentBangs,
        selectedBang: defaultBang,
        defaultBang: defaultBang,
      );

      expect(result.map((bang) => bang.trigger), ['wl', 'g']);
    });
  });

  group('pinned bangs', () {
    test('leads the frequency-ranked chips', () {
      final result = buildFrequentBangDisplayList(
        frequentBangs: [_bang('g', 'Google'), _bang('w', 'Wikipedia')],
        pinnedBangs: [_bang('sp', 'StartPage')],
      );

      expect(result.map((bang) => bang.trigger), ['sp', 'g', 'w']);
    });

    test('a pinned bang that is also frequent appears once, pinned', () {
      final google = _bang('g', 'Google');

      final result = buildFrequentBangDisplayList(
        frequentBangs: [_bang('w', 'Wikipedia'), google],
        pinnedBangs: [google],
      );

      expect(result.map((bang) => bang.trigger), ['g', 'w']);
    });

    test('keeps the selection and default anchors intact', () {
      final selectedBang = _bang('ddg', 'DuckDuckGo');
      final defaultBang = _bang('wl', 'WebLibre Search');

      final result = buildFrequentBangDisplayList(
        frequentBangs: [_bang('g', 'Google')],
        pinnedBangs: [_bang('sp', 'StartPage')],
        selectedBang: selectedBang,
        defaultBang: defaultBang,
      );

      expect(result.map((bang) => bang.trigger), ['ddg', 'sp', 'g', 'wl']);
    });

    test('an empty pin list changes nothing', () {
      final frequentBangs = [_bang('g', 'Google')];

      expect(
        buildFrequentBangDisplayList(frequentBangs: frequentBangs),
        frequentBangs,
      );
    });
  });

  group('BangChipStrip delete affordance', () {
    test('belongs to the selected bang alone', () {
      final selectedBang = _bang('ddg', 'DuckDuckGo');
      final otherBang = _bang('wl', 'WebLibre Search');

      expect(isSelectedBangChip(selectedBang, selectedBang), isTrue);
      expect(isSelectedBangChip(otherBang, selectedBang), isFalse);
      expect(isSelectedBangChip(otherBang, null), isFalse);
    });

    test('a bang selected in another group is a different chip', () {
      final syncedBang = _bang('ddg', 'DuckDuckGo');
      final userBang = _bang('ddg', 'DuckDuckGo', group: BangGroup.user);

      expect(isSelectedBangChip(userBang, syncedBang), isFalse);
    });
  });

  group('canResetBangFrequency', () {
    test('an unused bang has nothing to reset', () {
      expect(
        canResetBangFrequency(bang: _bang('g', 'Google'), defaultBang: null),
        isFalse,
      );
    });

    test('the default search bang stays anchored in quick select', () {
      final defaultBang = _bang('wl', 'WebLibre Search', frequency: 7);

      expect(
        canResetBangFrequency(bang: defaultBang, defaultBang: defaultBang),
        isFalse,
      );
    });

    test('any other used bang can be reset', () {
      expect(
        canResetBangFrequency(
          bang: _bang('g', 'Google', frequency: 3),
          defaultBang: _bang('wl', 'WebLibre Search', frequency: 7),
        ),
        isTrue,
      );
    });
  });
}
