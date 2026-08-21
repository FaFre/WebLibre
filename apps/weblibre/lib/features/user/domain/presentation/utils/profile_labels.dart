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
import 'package:weblibre/domain/entities/profile.dart';

/// Naming profiles in lists the user picks from.
///
/// A profile name is not an identity. `validateProfileName` checks only that a
/// name is present and well-formed, so two users can share one — and every
/// screen that offers a choice between users offers it by name. Where that
/// choice is destructive (replace, delete), two indistinguishable rows are a
/// coin flip over whose data survives.

/// Display labels for [profiles], keyed by profile id.
///
/// Computed over the whole list rather than per profile, because a
/// distinguishing fragment is only distinguishing relative to the others it has
/// to be told apart from.
Map<String, String> profileLabels(Iterable<Profile> profiles) {
  final byName = <String, List<Profile>>{};
  for (final profile in profiles) {
    byName.putIfAbsent(profile.name, () => []).add(profile);
  }

  final labels = <String, String>{};
  for (final entry in byName.entries) {
    final group = entry.value;
    if (group.length == 1) {
      // The suffix appears only where it is needed. Beside every name it would
      // be noise that teaches the user to skip past it; beside two identical
      // ones it is the only thing carrying the difference.
      labels[group.single.id] = group.single.name;
      continue;
    }

    final fragment = _distinguishingLength(group);
    for (final profile in group) {
      labels[profile.id] = '${profile.name} (${_tail(profile.id, fragment)})';
    }
  }

  return labels;
}

/// The label for [profile], or its plain name if it was not in the list.
String labelOfProfile(Profile profile, Map<String, String> labels) =>
    labels[profile.id] ?? profile.name;

/// How much of the id to show so that no two in [group] read the same.
///
/// From the **end**, not the start. `Profile.getNewProfileId()` returns a UUIDv7,
/// whose leading 48 bits are a millisecond timestamp — so two profiles created in
/// the same session share a long prefix, and the first eight characters of one
/// are very often the first eight of the other. The tail is the random part.
int _distinguishingLength(List<Profile> group) {
  for (final length in const [4, 6, 8, 12]) {
    final seen = <String>{};
    if (group.every((profile) => seen.add(_tail(profile.id, length)))) {
      return length;
    }
  }

  // Two ids that agree on their last twelve characters are not something this
  // should paper over with a longer guess.
  return 36;
}

String _tail(String id, int length) =>
    id.length <= length ? id : id.substring(id.length - length);
