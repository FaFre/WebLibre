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
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/features/geckoview/domain/providers/selected_tab.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/controllers/accordion_expansion.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/providers.dart';

class _FakeSelectedTab extends SelectedTab {
  _FakeSelectedTab(this._initial);

  final String? _initial;

  @override
  String? build() => _initial;

  // Mirrors the selection event the real notifier receives.
  // ignore: use_setters_to_change_properties
  void select(String? tabId) => state = tabId;
}

/// An unassigned tab `u` and a tab `a` in container `A`. Containers arrive
/// asynchronously, as they do from the database.
ProviderContainer createContainer({String? initialTab = 'u'}) {
  final container = ProviderContainer(
    overrides: [
      selectedTabProvider.overrideWith(() => _FakeSelectedTab(initialTab)),
      watchContainerTabIdProvider(
        'u',
      ).overrideWith((ref) => Stream.value(null)),
      watchContainerTabIdProvider('a').overrideWith((ref) => Stream.value('A')),
      watchContainerTabIdProvider(
        'a2',
      ).overrideWith((ref) => Stream.value('A')),
    ],
  );
  addTearDown(container.dispose);
  container.listen(accordionExpansionControllerProvider, (_, _) {});
  return container;
}

Set<String?> shown(ProviderContainer container, {required bool multiple}) =>
    container
        .read(accordionExpansionControllerProvider)
        .displayed(multiple: multiple);

void select(ProviderContainer container, String tabId) =>
    (container.read(selectedTabProvider.notifier) as _FakeSelectedTab).select(
      tabId,
    );

void main() {
  test("starts with the selected tab's group open", () async {
    final container = createContainer();
    await pumpEventQueue();

    expect(shown(container, multiple: false), {null});
  });

  test(
    'selecting a tab in the group just expanded keeps that group open',
    () async {
      // The reported bug, in the single row: with an unassigned tab selected,
      // expand container A and pick its tab. A collapsed again and the
      // unassigned group opened in its place.
      final container = createContainer();
      await pumpEventQueue();

      container
          .read(accordionExpansionControllerProvider.notifier)
          .toggle('A', multiple: false);
      expect(shown(container, multiple: false), {'A'});

      select(container, 'a');
      await pumpEventQueue();

      expect(shown(container, multiple: false), {'A'});
    },
  );

  test('selecting a tab elsewhere opens its group', () async {
    final container = createContainer();
    await pumpEventQueue();

    select(container, 'a');
    await pumpEventQueue();

    expect(shown(container, multiple: false), {'A'});
    expect(shown(container, multiple: true), {null, 'A'});
  });

  test(
    'a collapsed group stays collapsed while its tab stays selected',
    () async {
      final container = createContainer();
      await pumpEventQueue();

      container
          .read(accordionExpansionControllerProvider.notifier)
          .toggle(null, multiple: true);
      await pumpEventQueue();

      expect(shown(container, multiple: true), isEmpty);
    },
  );

  test('switching tabs inside one container keeps it open', () async {
    final container = createContainer(initialTab: 'a');
    await pumpEventQueue();

    select(container, 'a2');
    await pumpEventQueue();

    expect(shown(container, multiple: false), {'A'});
  });
}
