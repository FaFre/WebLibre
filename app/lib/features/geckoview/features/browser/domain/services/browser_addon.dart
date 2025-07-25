/*
 * Copyright (c) 2024-2025 Fabian Freund.
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
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/features/geckoview/domain/providers.dart';

part 'browser_addon.g.dart';

@Riverpod()
class BrowserAddonService extends _$BrowserAddonService {
  Future<Uri> getAddonXpiUrl(String guid) async {
    final url = 'https://addons.mozilla.org/api/v5/addons/addon/$guid/';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;

        // ignore: avoid_dynamic_calls
        final xpiUrl = data['current_version']['file']['url'] as String;

        return Uri.parse(xpiUrl);
      } else {
        throw Exception('Failed to load addon data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching addon data: $e');
    }
  }

  Future<bool> install(String addonGuid) async {
    try {
      final xpiUrl = await getAddonXpiUrl(addonGuid);
      await ref.read(addonServiceProvider).installAddon(xpiUrl);

      return true;
    } catch (e, s) {
      logger.e('Failed installing $addonGuid', error: e, stackTrace: s);

      return false;
    }
  }

  @override
  void build() {
    return;
  }
}
