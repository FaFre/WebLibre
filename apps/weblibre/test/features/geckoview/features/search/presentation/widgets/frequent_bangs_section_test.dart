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
import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weblibre/features/bangs/data/models/bang_data.dart';
import 'package:weblibre/features/bangs/data/models/bang_group.dart';
import 'package:weblibre/features/geckoview/features/search/presentation/widgets/bang_chip_strip.dart';
import 'package:weblibre/features/geckoview/features/search/presentation/widgets/empty_state/frequent_bangs_section.dart';

BangData _bang(String trigger, String name) => BangData(
  websiteName: name,
  domain: '$trigger.example',
  trigger: trigger,
  urlTemplate: 'https://$trigger.example/?q={{{s}}}',
  group: BangGroup.general,
  searxngApi: false,
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

  group('canDeleteFrequentBang', () {
    test('implicit default bang is not deletable', () {
      final defaultBang = _bang('wl', 'WebLibre Search');

      expect(
        canDeleteFrequentBang(bang: defaultBang, defaultBang: defaultBang),
        isFalse,
      );
    });

    test('explicitly selected default bang remains clearable', () {
      final defaultBang = _bang('wl', 'WebLibre Search');

      expect(
        canDeleteFrequentBang(
          bang: defaultBang,
          selectedBang: defaultBang,
          defaultBang: defaultBang,
        ),
        isTrue,
      );
    });
  });

  group('BangChipStrip delete affordances', () {
    test('only selected bang keeps clear when frequency reset is disabled', () {
      final selectedBang = _bang('ddg', 'DuckDuckGo');
      final otherBang = _bang('wl', 'WebLibre Search');

      expect(
        canDeleteBangChip(
          selectedBang,
          selectedBang: selectedBang,
          allowFrequencyResetAction: false,
        ),
        isTrue,
      );
      expect(
        canDeleteBangChip(
          otherBang,
          selectedBang: selectedBang,
          allowFrequencyResetAction: false,
        ),
        isFalse,
      );
      expect(
        bangChipDeleteIcon(
          selectedBang,
          selectedBang: selectedBang,
          allowFrequencyResetAction: false,
        ),
        Icons.clear,
      );
      expect(
        bangChipDeleteIcon(
          otherBang,
          selectedBang: selectedBang,
          allowFrequencyResetAction: false,
        ),
        isNull,
      );
    });

    test('non-selected bangs use restore when frequency reset is enabled', () {
      final selectedBang = _bang('ddg', 'DuckDuckGo');
      final otherBang = _bang('wl', 'WebLibre Search');

      expect(
        canDeleteBangChip(
          otherBang,
          selectedBang: selectedBang,
          allowFrequencyResetAction: true,
        ),
        isTrue,
      );
      expect(
        bangChipDeleteIcon(
          selectedBang,
          selectedBang: selectedBang,
          allowFrequencyResetAction: true,
        ),
        Icons.clear,
      );
      expect(
        bangChipDeleteIcon(
          otherBang,
          selectedBang: selectedBang,
          allowFrequencyResetAction: true,
        ),
        MdiIcons.restore,
      );
    });

    test('selected bangs always use clear even when restore is enabled', () {
      final selectedBang = _bang('wl', 'WebLibre Search');

      expect(
        bangChipDeleteIcon(
          selectedBang,
          selectedBang: selectedBang,
          allowFrequencyResetAction: true,
        ),
        Icons.clear,
      );
    });
  });
}
