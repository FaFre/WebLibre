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
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/features/settings/domain/providers/pending_settings_highlight.dart';
import 'package:weblibre/features/settings/presentation/widgets/settings_detail.dart';

void main() {
  group('filterSettingsSections', () {
    const sections = [
      SettingsSectionDefinition(
        title: 'Appearance',
        entries: [
          SettingsEntryDefinition(
            title: 'Theme',
            subtitle: 'Choose system, light, or dark mode',
            child: SizedBox.shrink(),
          ),
          SettingsEntryDefinition(
            title: 'User Interface Zoom',
            subtitle: 'Make the user interface smaller or larger',
            child: SizedBox.shrink(),
          ),
        ],
      ),
      SettingsSectionDefinition(
        title: 'Downloads',
        entries: [
          SettingsEntryDefinition(
            title: 'Use external download manager',
            subtitle: 'Manage downloads with another app',
            child: SizedBox.shrink(),
          ),
        ],
      ),
    ];

    test('returns a single matching entry when query targets an item', () {
      final filtered = filterSettingsSections(
        sections: sections,
        query: 'zoom',
      );

      expect(filtered, hasLength(1));
      expect(filtered.first.title, 'Appearance');
      expect(filtered.first.entries, hasLength(1));
      expect(filtered.first.entries.first.title, 'User Interface Zoom');
    });

    test('returns the full section when query matches the section title', () {
      final filtered = filterSettingsSections(
        sections: sections,
        query: 'downloads',
      );

      expect(filtered, hasLength(1));
      expect(filtered.first.title, 'Downloads');
      expect(filtered.first.entries, hasLength(1));
      expect(
        filtered.first.entries.first.title,
        'Use external download manager',
      );
    });
  });

  testWidgets('clears a pending highlight after the target entry handles it', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container.read(pendingSettingsHighlightProvider.notifier).set('Theme');

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: SettingsDetailScaffold(
            title: 'Appearance',
            subtitle: 'Configure app appearance',
            icon: Icons.palette,
            sections: [
              SettingsSectionDefinition(
                title: 'Display',
                entries: [
                  SettingsEntryDefinition(
                    title: 'Theme',
                    child: SizedBox(height: 48, child: Text('Theme')),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    await tester.pump();
    expect(container.read(pendingSettingsHighlightProvider), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();

    expect(container.read(pendingSettingsHighlightProvider), isNull);
  });
}
