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
import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:weblibre/features/user/data/models/engine_settings.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';

/// Display labels for [DohSettingsMode], the Secure DNS protection levels.
extension DohSettingsModeL10n on DohSettingsMode {
  String label(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return switch (this) {
      DohSettingsMode.geckoDefault => l10n.settings_defaultProtectionTitle,
      DohSettingsMode.increased => l10n.settings_increasedProtectionTitle,
      DohSettingsMode.max => l10n.settings_maxProtectionTitle,
      DohSettingsMode.off => l10n.settings_protectionOffTitle,
    };
  }
}

/// The name of the Secure DNS resolver [settings] select: a built-in
/// provider's name, a saved resolver's ([CustomDohProvider.displayName]), or
/// the address's host.
String dohProviderName(EngineSettings settings) {
  final url = settings.dohProviderUrl;
  if (BuiltInDohProviders.values.firstWhereOrNull((p) => p.url == url)
      case final builtIn?) {
    return builtIn.name;
  }
  final saved = settings.customDohProviders.firstWhereOrNull(
    (provider) => provider.url == url,
  );
  return (saved ?? CustomDohProvider(url: url)).displayName;
}
