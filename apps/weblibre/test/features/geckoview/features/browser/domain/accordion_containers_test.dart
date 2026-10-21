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
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/providers.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/models/container_data.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/providers.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';

ContainerDataWithCount _container(String id, {bool isPinned = false}) =>
    ContainerDataWithCount(
      id: id,
      name: id,
      color: Colors.blue,
      orderKey: id,
      isPinned: isPinned,
      metadata: ContainerMetadata.withDefaults(contextualIdentity: id),
      tabCount: 1,
    );

DateTime _minute(int minute) => DateTime(2026, 10, 21, 12, minute);

List<String> _ids(Iterable<ContainerData>? containers) => [
  for (final container in containers ?? const <ContainerData>[]) container.id,
];

/// The manual order the containers query returns: pinned first, then by
/// order key.
final _manual = [
  _container('pinned-a', isPinned: true),
  _container('pinned-b', isPinned: true),
  _container('work'),
  _container('shopping'),
  _container('news'),
];

ProviderContainer _providerContainer({
  required bool byRecentUse,
  required Stream<Map<String, DateTime>> lastUsed,
}) {
  final container = ProviderContainer(
    overrides: [
      generalSettingsWithDefaultsProvider.overrideWith(
        (ref) => GeneralSettings.withDefaults(
          quickTabSwitcherContainersByRecentUse: byRecentUse,
        ),
      ),
      watchContainersWithCountProvider.overrideWith(
        (ref) => Stream.value(_manual),
      ),
      watchContainerLastUsedProvider.overrideWith((ref) => lastUsed),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

/// Settles [future] whether its stream delivers a value or an error.
Future<void> _settled(Future<Object?> future) =>
    future.then<void>((_) {}, onError: (_) {});

/// Reads the accordion's containers once the overridden streams delivered;
/// without [awaitLastUsed], only the containers.
Future<List<String>?> _readAccordionIds(
  ProviderContainer container, {
  bool awaitLastUsed = true,
}) async {
  container.listen(
    accordionContainersProvider,
    (_, _) {},
    fireImmediately: true,
  );
  await container.read(watchContainersWithCountProvider.future);
  if (awaitLastUsed) {
    await _settled(container.read(watchContainerLastUsedProvider.future));
  }
  final containers = container.read(accordionContainersProvider);
  return containers == null ? null : _ids(containers.value);
}

void main() {
  group('orderContainersByRecentUse', () {
    test('puts the most recently used container first', () {
      final ordered = orderContainersByRecentUse(_manual, {
        'work': _minute(1),
        'shopping': _minute(9),
        'news': _minute(5),
      });

      expect(_ids(ordered), [
        'pinned-a',
        'pinned-b',
        'shopping',
        'news',
        'work',
      ]);
    });

    test(
      'keeps pinned containers ahead, in manual order, whatever their use',
      () {
        final ordered = orderContainersByRecentUse(_manual, {
          'pinned-a': _minute(1),
          'pinned-b': _minute(9),
          'work': _minute(30),
        });

        expect(_ids(ordered).take(3), ['pinned-a', 'pinned-b', 'work']);
      },
    );

    test('puts containers without tabs last, in manual order', () {
      final ordered = orderContainersByRecentUse(_manual, {'news': _minute(1)});

      expect(_ids(ordered), [
        'pinned-a',
        'pinned-b',
        'news',
        'work',
        'shopping',
      ]);
    });

    test('breaks ties by manual order', () {
      final ordered = orderContainersByRecentUse(_manual, {
        'work': _minute(3),
        'shopping': _minute(3),
        'news': _minute(3),
      });

      expect(_ids(ordered), _ids(_manual));
    });

    test('leaves its input untouched', () {
      final input = [..._manual];
      orderContainersByRecentUse(input, {'news': _minute(1)});

      expect(_ids(input), _ids(_manual));
    });
  });

  group('accordionContainers', () {
    test('keeps the manual order while the setting is off', () async {
      final container = _providerContainer(
        byRecentUse: false,
        lastUsed: Stream.value({'news': _minute(9)}),
      );

      // Off, the accordion never subscribes to the timestamps.
      expect(
        await _readAccordionIds(container, awaitLastUsed: false),
        _ids(_manual),
      );
      expect(container.exists(watchContainerLastUsedProvider), isFalse);
    });

    test('orders by recent use while the setting is on', () async {
      final container = _providerContainer(
        byRecentUse: true,
        lastUsed: Stream.value({'news': _minute(9), 'work': _minute(1)}),
      );

      expect(await _readAccordionIds(container), [
        'pinned-a',
        'pinned-b',
        'news',
        'work',
        'shopping',
      ]);
    });

    test(
      'shows nothing until the timestamps arrive, then the sorted order',
      () async {
        final lastUsed = StreamController<Map<String, DateTime>>();
        addTearDown(lastUsed.close);
        final container = _providerContainer(
          byRecentUse: true,
          lastUsed: lastUsed.stream,
        );

        expect(
          await _readAccordionIds(container, awaitLastUsed: false),
          isNull,
        );

        lastUsed.add({'shopping': _minute(2)});
        await container.read(watchContainerLastUsedProvider.future);

        expect(_ids(container.read(accordionContainersProvider)?.value), [
          'pinned-a',
          'pinned-b',
          'shopping',
          'work',
          'news',
        ]);
      },
    );

    test('falls back to the manual order when the timestamps fail', () async {
      final container = _providerContainer(
        byRecentUse: true,
        lastUsed: Stream.error(StateError('query failed')),
      );

      expect(await _readAccordionIds(container), _ids(_manual));
    });
  });
}
