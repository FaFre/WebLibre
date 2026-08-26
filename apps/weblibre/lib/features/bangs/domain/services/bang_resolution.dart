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
import 'package:weblibre/features/bangs/data/models/bang_data.dart';

/// Picks the bang that `!$trigger` runs, out of everything that answers to
/// that word.
///
/// In order:
///  1. A bang's own trigger beats another bang's alias for the same word.
///     `!yt` belongs to the bang actually called `yt`.
///  2. `BangGroup.precedence` — a user bang overrides a synced one, which is
///     the whole point of being able to write your own.
///  3. Whichever the user reaches for more often.
///
/// Returns null for an empty [candidates].
BangData? pickBangByPrecedence(Iterable<BangData> candidates, String trigger) {
  final normalizedTrigger = trigger.toLowerCase();

  bool isPrimary(BangData bang) =>
      bang.trigger.toLowerCase() == normalizedTrigger;

  BangData? best;

  for (final candidate in candidates) {
    if (best == null || _outranks(candidate, best, isPrimary)) {
      best = candidate;
    }
  }

  return best;
}

bool _outranks(
  BangData candidate,
  BangData incumbent,
  bool Function(BangData bang) isPrimary,
) {
  final candidatePrimary = isPrimary(candidate);
  if (candidatePrimary != isPrimary(incumbent)) {
    return candidatePrimary;
  }

  final precedence = candidate.group.precedence.compareTo(
    incumbent.group.precedence,
  );
  if (precedence != 0) {
    return precedence < 0;
  }

  return candidate.frequency > incumbent.frequency;
}
