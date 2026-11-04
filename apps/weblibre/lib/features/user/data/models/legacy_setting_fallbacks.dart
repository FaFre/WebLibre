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

/// A setting whose fallback (the value used while nothing is stored) changed,
/// with the fallback it had before.
///
/// [partition] is both the settings partition in the user database and the
/// key of the matching section in a settings snapshot (`general`, `engine`).
typedef LegacySettingFallback = ({String partition, String key, bool value});

/// Settings whose fallback changed with user database v12.
///
/// Data written before then means "the old fallback" by a missing row or
/// value, or a `null` one: a restored snapshot writes the `null` of an
/// untouched nullable field. Two places turn that back into the old value so
/// an existing profile keeps its behavior:
///
/// - the user database's v12 migration, once per existing profile;
/// - restoring a settings snapshot, which can come from before the change.
///
/// Builds since always store these explicitly: none of them is nullable after
/// construction. A missing or `null` value is therefore always old data.
const legacySettingFallbacks = <LegacySettingFallback>[
  (partition: 'general', key: 'enableLocalAiFeatures', value: true),
  (partition: 'general', key: 'urlCleanerAutoApply', value: false),
  (partition: 'engine', key: 'lnaBlocking', value: false),
];

/// Fills in [legacySettingFallbacks] where a settings snapshot's [payload]
/// has no value or `null`. Explicit values are kept.
void restoreLegacySettingFallbacks(Map<String, dynamic> payload) {
  for (final (:partition, :key, :value) in legacySettingFallbacks) {
    if (payload[partition] case final Map<String, dynamic> section) {
      section[key] ??= value;
    }
  }
}
