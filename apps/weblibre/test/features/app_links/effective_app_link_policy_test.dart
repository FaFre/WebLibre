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
import 'package:weblibre/features/app_links/domain/services/effective_app_link_policy.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/models/container_data.dart';

ContainerDataWithCount _container(
  String id, {
  String? contextId,
  bool isolatedAppLinkSettings = false,
}) {
  return ContainerDataWithCount(
    id: id,
    name: 'Container $id',
    color: const Color(0xFF336699),
    orderKey: 'a',
    metadata: ContainerMetadata.withDefaults(
      contextualIdentity: contextId,
      isolatedAppLinkSettings: isolatedAppLinkSettings,
    ),
    tabCount: 0,
  );
}

void main() {
  group('resolveAppLinkOverrideKey', () {
    test('null contextId resolves to the global bucket', () {
      final key = resolveAppLinkOverrideKey(
        liveContextId: null,
        containers: [
          _container('1', contextId: 'ctx-1', isolatedAppLinkSettings: true),
        ],
        isolationContextContainerMap: const {},
      );
      expect(key, isNull);
    });

    test('regular tab in a non-isolated container resolves globally', () {
      final key = resolveAppLinkOverrideKey(
        liveContextId: 'ctx-1',
        containers: [_container('1', contextId: 'ctx-1')],
        isolationContextContainerMap: const {},
      );
      expect(key, isNull);
    });

    test(
      'regular tab in an isolated-app-link container resolves to its base',
      () {
        final key = resolveAppLinkOverrideKey(
          liveContextId: 'ctx-1',
          containers: [
            _container('1', contextId: 'ctx-1', isolatedAppLinkSettings: true),
          ],
          isolationContextContainerMap: const {},
        );
        expect(key, 'ctx-1');
      },
    );

    test('isolated tab resolves via the isolation map', () {
      final key = resolveAppLinkOverrideKey(
        liveContextId: 'iso-1',
        containers: [
          _container('1', contextId: 'ctx-1', isolatedAppLinkSettings: true),
        ],
        isolationContextContainerMap: const {
          'iso-1': {'1'},
        },
      );
      expect(key, 'ctx-1');
    });

    test(
      'isolated tab of a non-isolated-app-link container resolves globally',
      () {
        final key = resolveAppLinkOverrideKey(
          liveContextId: 'iso-1',
          containers: [_container('1', contextId: 'ctx-1')],
          isolationContextContainerMap: const {
            'iso-1': {'1'},
          },
        );
        expect(key, isNull);
      },
    );

    test('shared isolation context picks the lowest sorted base contextId', () {
      final key = resolveAppLinkOverrideKey(
        liveContextId: 'iso-1',
        containers: [
          _container('1', contextId: 'ctx-b', isolatedAppLinkSettings: true),
          _container('2', contextId: 'ctx-a', isolatedAppLinkSettings: true),
        ],
        isolationContextContainerMap: const {
          'iso-1': {'1', '2'},
        },
      );
      expect(key, 'ctx-a');
    });

    test(
      'shared isolation context skips containers without isolated settings',
      () {
        final key = resolveAppLinkOverrideKey(
          liveContextId: 'iso-1',
          containers: [
            _container('1', contextId: 'ctx-a'),
            _container('2', contextId: 'ctx-b', isolatedAppLinkSettings: true),
          ],
          isolationContextContainerMap: const {
            'iso-1': {'1', '2'},
          },
        );
        expect(key, 'ctx-b');
      },
    );

    test('unknown contextId resolves globally', () {
      final key = resolveAppLinkOverrideKey(
        liveContextId: 'ctx-unknown',
        containers: [
          _container('1', contextId: 'ctx-1', isolatedAppLinkSettings: true),
        ],
        isolationContextContainerMap: const {},
      );
      expect(key, isNull);
    });
  });
}
