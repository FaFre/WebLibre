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
import 'package:weblibre/features/geckoview/domain/entities/tab_container_selection.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/controllers/home_target_controller.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/entities/home_target.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/models/container_data.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';

ContainerData _container(String id) =>
    ContainerData(id: id, color: const Color(0xFF000000), orderKey: 'a');

void main() {
  group('resolveHomeTargetContainer', () {
    final selected = _container('selected');
    final scoped = _container('scoped');

    test('unscoped follows the selected container', () {
      expect(
        resolveHomeTargetContainer(
          scopeToContainer: false,
          scopedContainer: null,
          selectedContainer: selected,
        ),
        isA<SpecificContainerTabSelection>().having(
          (s) => s.container.id,
          'container',
          'selected',
        ),
      );
    });

    test('unscoped with no selection is unassigned', () {
      expect(
        resolveHomeTargetContainer(
          scopeToContainer: false,
          scopedContainer: null,
          selectedContainer: null,
        ),
        isA<UnassignedContainerTabSelection>(),
      );
    });

    test('scoped uses its own container, not the selected one', () {
      expect(
        resolveHomeTargetContainer(
          scopeToContainer: true,
          scopedContainer: scoped,
          selectedContainer: selected,
        ),
        isA<SpecificContainerTabSelection>().having(
          (s) => s.container.id,
          'container',
          'scoped',
        ),
      );
    });

    test('scoped to the unassigned container stays unassigned', () {
      // The case a plain null-check gets wrong: closing the last unassigned tab
      // scopes to "unassigned", which is a real container, not the absence of
      // a scope — falling back to the selected container would move the user.
      expect(
        resolveHomeTargetContainer(
          scopeToContainer: true,
          scopedContainer: null,
          selectedContainer: selected,
        ),
        isA<UnassignedContainerTabSelection>(),
      );
    });
  });

  group('default', () {
    test('is home, so startup is unchanged for existing users', () {
      // Any other default would alter startup behaviour for everyone on
      // upgrade. Changing this needs a deliberate decision, not a drive-by.
      expect(GeneralSettings.withDefaults().homeTarget, HomeTarget.home);
      expect(GeneralSettings.withDefaults().homeTargetUrl, isNull);
      expect(GeneralSettings.withDefaults().homeTargetOnLastTabClosed, isFalse);
    });
  });

  group('resolveHomeTarget', () {
    test('home stays home', () {
      expect(
        resolveHomeTarget(target: HomeTarget.home, customUrl: null),
        HomeTarget.home,
      );
    });

    test(
      'resume is returned; the caller decides if there is anything to resume',
      () {
        expect(
          resolveHomeTarget(target: HomeTarget.resumeLastTab, customUrl: null),
          HomeTarget.resumeLastTab,
        );
      },
    );

    test('a configured address is used', () {
      expect(
        resolveHomeTarget(
          target: HomeTarget.customUrl,
          customUrl: 'https://example.com',
        ),
        HomeTarget.customUrl,
      );
    });

    test('an unset address falls back to home', () {
      expect(
        resolveHomeTarget(target: HomeTarget.customUrl, customUrl: null),
        HomeTarget.home,
      );
      expect(
        resolveHomeTarget(target: HomeTarget.customUrl, customUrl: '  '),
        HomeTarget.home,
      );
    });

    test('an unparseable address falls back to home', () {
      expect(
        resolveHomeTarget(
          target: HomeTarget.customUrl,
          customUrl: 'not a url at all',
        ),
        HomeTarget.home,
      );
    });

    group('custom-URL reopen loop', () {
      test('closing the configured page does not reopen it', () {
        expect(
          resolveHomeTarget(
            target: HomeTarget.customUrl,
            customUrl: 'https://example.com/start',
            closingTabUrl: Uri.parse('https://example.com/start'),
          ),
          HomeTarget.home,
        );
      });

      test('the URL guard ignores scheme and host case', () {
        expect(
          resolveHomeTarget(
            target: HomeTarget.customUrl,
            customUrl: 'https://Example.com/start',
            closingTabUrl: Uri.parse('http://example.com/start'),
          ),
          HomeTarget.home,
        );
      });

      test('closing a different page still opens the configured one', () {
        expect(
          resolveHomeTarget(
            target: HomeTarget.customUrl,
            customUrl: 'https://example.com/start',
            closingTabUrl: Uri.parse('https://example.com/other'),
          ),
          HomeTarget.customUrl,
        );
      });

      test('reopening within the guard window is suppressed', () {
        final now = DateTime(2026, 8, 1, 12);

        expect(
          resolveHomeTarget(
            target: HomeTarget.customUrl,
            customUrl: 'https://example.com',
            lastCustomUrlOpenedAt: now.subtract(const Duration(seconds: 1)),
            now: now,
          ),
          HomeTarget.home,
          reason:
              'a redirect away from the configured page would otherwise '
              'defeat the URL guard and loop',
        );
      });

      test('reopening after the window is allowed', () {
        final now = DateTime(2026, 8, 1, 12);

        expect(
          resolveHomeTarget(
            target: HomeTarget.customUrl,
            customUrl: 'https://example.com',
            lastCustomUrlOpenedAt: now.subtract(const Duration(seconds: 30)),
            now: now,
          ),
          HomeTarget.customUrl,
        );
      });
    });
  });
}
