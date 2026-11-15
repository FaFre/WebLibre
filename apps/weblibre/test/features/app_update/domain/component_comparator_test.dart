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
import 'package:weblibre/features/app_update/domain/entities/component_identity.dart';
import 'package:weblibre/features/app_update/domain/entities/update_assessment.dart';
import 'package:weblibre/features/app_update/domain/services/component_comparator.dart';

void main() {
  const comparator = ComponentComparator();

  ComponentChangeKind compare(
    ComponentId id,
    ComponentIdentity a,
    ComponentIdentity b,
  ) => comparator.compare(id, a, b);

  final unknown = ComponentUnknown();

  test('either side unknown is unknown', () {
    expect(
      compare(ComponentId.gecko, unknown, ComponentKnown('160.0')),
      ComponentChangeKind.unknown,
    );
    expect(
      compare(ComponentId.tor, ComponentKnown('0.4.9'), unknown),
      ComponentChangeKind.unknown,
    );
  });

  test('identical identities are unchanged', () {
    final v = ComponentKnown('160.0', buildId: '20261124093000');
    expect(compare(ComponentId.gecko, v, v), ComponentChangeKind.unchanged);
  });

  test('a segment longer than any integer type still orders', () {
    const big = '123456789012345678901234567890';
    expect(
      compare(
        ComponentId.tor,
        ComponentKnown('1.$big'),
        ComponentKnown('1.${big}1'),
      ),
      ComponentChangeKind.upgraded,
    );
    expect(
      compare(ComponentId.tor, ComponentKnown('2.0'), ComponentKnown('1.$big')),
      ComponentChangeKind.downgraded,
    );
    // Leading zeros are not magnitude.
    expect(
      compare(ComponentId.tor, ComponentKnown('1.010'), ComponentKnown('1.9')),
      ComponentChangeKind.downgraded,
    );
  });

  test('dotted versions order numerically', () {
    expect(
      compare(
        ComponentId.gecko,
        ComponentKnown('159.0'),
        ComponentKnown('160.0'),
      ),
      ComponentChangeKind.upgraded,
    );
    expect(
      compare(
        ComponentId.gecko,
        ComponentKnown('160.0'),
        ComponentKnown('159.0.1'),
      ),
      ComponentChangeKind.downgraded,
    );
    expect(
      compare(
        ComponentId.singbox,
        ComponentKnown('1.9.0'),
        ComponentKnown('1.14.4'),
      ),
      ComponentChangeKind.upgraded,
    );
  });

  test('equal Gecko versions fall to the build ID', () {
    expect(
      compare(
        ComponentId.gecko,
        ComponentKnown('160.0', buildId: '20261101000000'),
        ComponentKnown('160.0', buildId: '20261124093000'),
      ),
      ComponentChangeKind.upgraded,
    );
    expect(
      compare(
        ComponentId.gecko,
        ComponentKnown('160.0', buildId: '20261124093000'),
        ComponentKnown('160.0', buildId: '20261101000000'),
      ),
      ComponentChangeKind.downgraded,
    );
  });

  test('anything that does not parse cleanly is changed', () {
    expect(
      compare(
        ComponentId.tor,
        ComponentKnown('0.4.9.14'),
        ComponentKnown('0.4.9.15-rc'),
      ),
      ComponentChangeKind.changed,
    );
    expect(
      compare(
        ComponentId.gecko,
        ComponentKnown('160.0a1'),
        ComponentKnown('160.0'),
      ),
      ComponentChangeKind.changed,
    );
    expect(
      compare(
        ComponentId.singbox,
        ComponentKnown('1.14.4', revision: 'a'),
        ComponentKnown('1.14.4', revision: 'b'),
      ),
      ComponentChangeKind.changed,
    );
  });

  test(
    'compares installed against target directly across skipped releases',
    () {
      final changes = comparator.compareAll(
        {ComponentId.gecko: ComponentKnown('150.0')},
        {ComponentId.gecko: ComponentKnown('160.0')},
      );
      expect(changes.first.kind, ComponentChangeKind.upgraded);
      expect(changes, hasLength(ComponentId.values.length));
      expect(changes.last.kind, ComponentChangeKind.unknown);
    },
  );
}
