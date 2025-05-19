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
