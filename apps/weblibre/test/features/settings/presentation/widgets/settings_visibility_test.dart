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
import 'package:flutter_test/flutter_test.dart';
import 'package:weblibre/domain/feature_policy/feature_policy.dart';
import 'package:weblibre/features/settings/presentation/widgets/settings_detail.dart';

SettingsEntryDefinition _entry(String title, {FeatureId? feature}) =>
    SettingsEntryDefinition(
      title: title,
      feature: feature,
      child: const SizedBox(),
    );

List<String> _titles(List<SettingsSectionDefinition> sections) => [
  for (final section in sections)
    for (final entry in section.entries) entry.title,
];

void main() {
  test('a hidden entry stays on its screen; the gate grays it out', () {
    final sections = [
      SettingsSectionDefinition(
        title: 'Section',
        entries: [
          _entry('plain'),
          _entry('hidden', feature: FeatureId.syncCustomServer),
        ],
      ),
    ];

    expect(_titles(visibleSettingsSections(sections)), ['plain', 'hidden']);
  });

  test('an entry is gated by its section and its own feature', () {
    final section = SettingsSectionDefinition(
      title: 'Overrides',
      feature: FeatureId.connectionsTorBasic,
      entries: [_entry('a', feature: FeatureId.syncCustomServer)],
    );

    expect(
      [
        for (final condition in settingsEntryConditions(
          section,
          section.entries.single,
        ))
          condition.feature,
      ],
      [FeatureId.connectionsTorBasic, FeatureId.syncCustomServer],
    );
  });

  test('a search-only entry is never drawn on its screen', () {
    final sections = [
      SettingsSectionDefinition(
        title: 'Section',
        entries: [
          _entry('drawn'),
          const SettingsEntryDefinition.searchOnly(title: 'search only'),
        ],
      ),
    ];

    expect(_titles(visibleSettingsSections(sections)), ['drawn']);
    // The search filter still finds it.
    expect(
      _titles(filterSettingsSections(sections: sections, query: 'search')),
      ['search only'],
    );
  });
}
