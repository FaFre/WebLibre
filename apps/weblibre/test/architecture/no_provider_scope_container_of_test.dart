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
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// `ProviderScope.containerOf(context)` returns the container of whichever
/// scope is nearest the context, not the one the caller's providers live in.
/// Handing that container to another route is how the onboarding draft got
/// shared across routes, and refreshed from inside the wrong route's build.
/// Widgets pass their `ref` (`ref.read`, `ref.container`) instead; see
/// `lib/core/providers/provider_read.dart`.
void main() {
  test('lib never calls ProviderScope.containerOf', () {
    final offenders = [
      for (final file in Directory('lib').listSync(recursive: true))
        if (file is File &&
            file.path.endsWith('.dart') &&
            !file.path.endsWith('.g.dart'))
          for (final (index, line) in file.readAsLinesSync().indexed)
            if (line.contains('ProviderScope.containerOf(') &&
                !line.trimLeft().startsWith('//'))
              '${file.path}:${index + 1}',
    ];

    expect(offenders, isEmpty);
  });
}
