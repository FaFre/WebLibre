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
import 'dart:isolate';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/repositories/gecko_inference.dart';

/// [count] random embeddings of the size the engine produces.
List<List<double>> _embeddings(int count) {
  final random = Random(1);
  return List.generate(
    count,
    (_) => Float64List.fromList(List.generate(384, (_) => random.nextDouble())),
  );
}

void main() {
  test('clusters every embedding', () async {
    final clusters = await clusterInBackground(_embeddings(20));

    expect(
      clusters!.expand((cluster) => cluster).toList()..sort(),
      List.generate(20, (index) => index),
    );
  });

  test('a cancelled clustering is stopped, not left to finish', () async {
    // Takes seconds to cluster in full.
    final cancel = Completer<void>();
    final watch = Stopwatch()..start();
    final clusters = clusterInBackground(
      _embeddings(400),
      cancelled: cancel.future,
    );

    await Future<void>.delayed(const Duration(milliseconds: 100));
    cancel.complete();

    expect(await clusters, isNull);
    expect(watch.elapsed, lessThan(const Duration(seconds: 1)));
  });

  test('an error in the isolate reaches the caller', () async {
    // There is no cluster count to try for nothing at all.
    await expectLater(clusterInBackground([]), throwsA(isA<RemoteError>()));
  });
}
