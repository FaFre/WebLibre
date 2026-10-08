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
import 'package:weblibre/features/user/domain/services/local_authentication.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';

/// Display text for a device prompt that did not pass.
extension DeviceAuthFailureL10n on DeviceAuthFailure {
  String describe(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return switch (this) {
      DeviceAuthFailure.noScreenLock => l10n.user_deviceAuthNoScreenLock,
      DeviceAuthFailure.lockedOut => l10n.user_deviceAuthLockedOut,
      DeviceAuthFailure.unavailable => l10n.user_deviceAuthUnavailable,
    };
  }
}
