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
import 'package:weblibre/features/app_update/domain/entities/component_identity.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';

extension ComponentIdentityL10n on ComponentIdentity {
  /// A version for display. Unknown is never shown as a version.
  String label(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return switch (this) {
      ComponentKnown(:final version) => version,
      ComponentUnknown() => l10n.appUpdate_componentVersionUnknown,
      ComponentNotBundled() => l10n.appUpdate_componentNotBundled,
    };
  }
}
