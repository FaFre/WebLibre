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
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'pending_settings_highlight.g.dart';

/// Holds the [SettingsEntryDefinition.title] that a destination settings
/// screen should auto-scroll to and briefly pulse after navigation. Set by
/// the global settings search before pushing the destination route; consumed
/// (and cleared) by the matching entry once it has been highlighted.
@Riverpod(keepAlive: true)
class PendingSettingsHighlight extends _$PendingSettingsHighlight {
  @override
  String? build() => null;

  // ignore: use_setters_to_change_properties
  void set(String? title) {
    state = title;
  }

  void clear() {
    state = null;
  }
}
