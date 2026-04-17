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
import 'dart:convert';
import 'dart:io';

import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/features/geckoview/domain/providers.dart';
import 'package:weblibre/features/geckoview/features/preferences/data/repositories/preference_observer.dart';

part 'browser_addon.g.dart';

const _signatureRequiredPref = 'xpinstall.signatures.required';

@Riverpod(keepAlive: true)
class AllowUnsignedExtensions extends _$AllowUnsignedExtensions {
  Future<void> setAllowUnsigned({required bool allow}) async {
    final fixator = ref.read(preferenceFixatorProvider.notifier);
    if (allow) {
      await fixator.register(_signatureRequiredPref, false);
    } else {
      await fixator.unregister(_signatureRequiredPref);
      await GeckoPrefService().applyPrefs({_signatureRequiredPref: true});
    }
    state = AsyncData(allow);
  }

  @override
  FutureOr<bool> build() async {
    final prefs = await GeckoPrefService().getPrefs([_signatureRequiredPref]);
    final pref = prefs[_signatureRequiredPref];
    final allowUnsigned = pref?.value == false;

    // Re-register with fixator to prevent Gecko from resetting
    if (allowUnsigned) {
      await ref
          .read(preferenceFixatorProvider.notifier)
          .register(_signatureRequiredPref, false);
    }

    return allowUnsigned;
  }
}

@Riverpod(keepAlive: true)
class AddonAutoUpdate extends _$AddonAutoUpdate {
  Future<void> setEnabled({required bool enabled}) async {
    final service = ref.read(addonServiceProvider);
    await service.setAddonAutoUpdateEnabled(enabled: enabled);

    state = AsyncData(enabled);
  }

  @override
  FutureOr<bool> build() {
    return ref.read(addonServiceProvider).isAddonAutoUpdateEnabled();
  }
}

@Riverpod(keepAlive: true)
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
      if (!ref.mounted) return false;

      await ref.read(addonServiceProvider).installAddon(xpiUrl);

      return true;
    } catch (e, s) {
      logger.e('Failed installing $addonGuid', error: e, stackTrace: s);

      return false;
    }
  }

  Future<bool> installFromFile(String filePath) async {
    try {
      // Validate file exists and has .xpi extension
      final file = File(filePath);
      if (!file.existsSync()) {
        throw Exception('File does not exist: $filePath');
      }

      final extension = filePath.toLowerCase();
      if (!extension.endsWith('.xpi')) {
        throw Exception('Invalid file type. Expected .xpi file');
      }

      // Create file:// URI and install
      final fileUri = Uri.file(filePath);
      if (!ref.mounted) return false;

      await ref.read(addonServiceProvider).installAddon(fileUri);

      return true;
    } catch (e, s) {
      logger.e(
        'Failed installing from file: $filePath',
        error: e,
        stackTrace: s,
      );
      rethrow;
    }
  }

  @override
  void build() {}
}
