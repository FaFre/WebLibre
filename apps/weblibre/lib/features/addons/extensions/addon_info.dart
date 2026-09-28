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
import 'package:flutter/widgets.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';

extension AddonInfoUi on AddonInfo {
  bool get hasOptionsPage => optionsPageUrl?.isNotEmpty ?? false;

  bool get canUserToggleEnabled {
    return switch (disabledReason) {
      AddonDisabledReason.blocklisted ||
      AddonDisabledReason.notCorrectlySigned ||
      AddonDisabledReason.incompatible => false,
      _ => true,
    };
  }

  /// Takes [context] because the message is localized; there is no
  /// BuildContext-free equivalent, so both call sites resolve it there.
  String? statusBannerMessage(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return switch (disabledReason) {
      AddonDisabledReason.blocklisted => l10n.addons_statusBlocklisted,
      AddonDisabledReason.notCorrectlySigned =>
        l10n.addons_statusNotCorrectlySigned,
      AddonDisabledReason.incompatible => l10n.addons_statusIncompatible,
      AddonDisabledReason.softBlocked =>
        isEnabled
            ? l10n.addons_statusSoftBlockedEnabled
            : l10n.addons_statusSoftBlockedDisabled,
      AddonDisabledReason.unsupported => l10n.addons_statusUnsupported,
      _ => null,
    };
  }
}
