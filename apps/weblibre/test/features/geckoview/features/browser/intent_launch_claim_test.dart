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

import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/providers/intent.dart';

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer();
    addTearDown(container.dispose);
  });

  IntentLaunchClaim claims() =>
      container.read(intentLaunchClaimProvider.notifier);

  test('settles immediately when no launch is in flight', () async {
    await expectLater(claims().waitUntilSettled(), completes);
    expect(container.read(intentLaunchClaimProvider), isFalse);
  });

  test('holds until the launch it was taken for releases', () async {
    final claim = claims()..claim();
    expect(container.read(intentLaunchClaimProvider), isTrue);

    var settled = false;
    unawaited(claim.waitUntilSettled().then((_) => settled = true));

    // A microtask turn is all a completed future needs; the point is that this
    // one is not completed.
    await Future<void>.delayed(Duration.zero);
    expect(settled, isFalse);

    claim.release();
    await Future<void>.delayed(Duration.zero);

    expect(settled, isTrue);
    expect(container.read(intentLaunchClaimProvider), isFalse);
  });

  test('two launches at once settle only on the last release', () async {
    final claim = claims()
      ..claim()
      ..claim();

    var settled = false;
    unawaited(claim.waitUntilSettled().then((_) => settled = true));

    claim.release();
    await Future<void>.delayed(Duration.zero);
    expect(settled, isFalse);
    expect(container.read(intentLaunchClaimProvider), isTrue);

    claim.release();
    await Future<void>.delayed(Duration.zero);
    expect(settled, isTrue);
  });

  test('an unmatched release does not settle the claim that remains', () {
    final claim = claims()..claim();

    claim
      ..release()
      ..release();

    expect(container.read(intentLaunchClaimProvider), isFalse);

    // And the counter is not left negative, i.e. the next launch still holds.
    claim.claim();
    expect(container.read(intentLaunchClaimProvider), isTrue);
  });

  testWidgets('a claim that is never released expires', (tester) async {
    final claim = claims()..claim();

    var settled = false;
    unawaited(claim.waitUntilSettled().then((_) => settled = true));

    await tester.pump(const Duration(seconds: 14));
    expect(settled, isFalse);

    await tester.pump(const Duration(seconds: 2));
    expect(settled, isTrue);
    expect(container.read(intentLaunchClaimProvider), isFalse);
  });

  test('disposal releases whoever is waiting', () async {
    final claim = claims()..claim();

    var settled = false;
    unawaited(claim.waitUntilSettled().then((_) => settled = true));

    container.dispose();
    await Future<void>.delayed(Duration.zero);

    expect(settled, isTrue);
  });
}
