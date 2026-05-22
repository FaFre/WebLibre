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

import 'package:path/path.dart' as p;
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/features/account/domain/utils/user_js_parser.dart';
import 'package:weblibre/utils/filesystem.dart';

/// Reads persisted Gecko user prefs directly from the active profile's
/// `prefs.js` file.
///
/// Gecko writes `user_pref(...)` entries only for prefs with a user-set value,
/// so reading this file gives us the syncable modified-prefs view without
/// needing a native bridge.
class PrefsJsReader {
  final Directory selectedProfileDir;

  PrefsJsReader({required this.selectedProfileDir});

  /// Returns a map of user-set prefs parsed from `prefs.js`, or an empty map
  /// if no `prefs.js` file exists for the active profile.
  Future<Map<String, Object>> readUserPrefs() async {
    final file = _resolvePrefsJsFile();
    if (file == null || !await file.exists()) {
      return const {};
    }

    final text = await file.readAsString();
    return parseUserJs(text).prefs;
  }

  File? _resolvePrefsJsFile() {
    final profileIds = getMozillaProfileIds(selectedProfileDir);
    if (profileIds.isEmpty) {
      return null;
    }

    final candidates = profileIds
        .map(
          (id) => File(
            p.join(selectedProfileDir.path, 'files', 'mozilla', id, 'prefs.js'),
          ),
        )
        .where((f) => f.existsSync())
        .toList();

    if (candidates.isEmpty) {
      return null;
    }

    if (candidates.length == 1) {
      return candidates.first;
    }

    logger.w(
      'Multiple Gecko profiles with prefs.js found (${candidates.length}); '
      'selecting newest by modification time',
    );

    candidates.sort(
      (a, b) => b.statSync().modified.compareTo(a.statSync().modified),
    );
    return candidates.first;
  }
}
