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
import 'package:weblibre/features/account/data/account_adoption.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';

/// Display label for [UnclaimedAccountRecord].
extension UnclaimedAccountRecordL10n on UnclaimedAccountRecord {
  /// What to call the account on screen. Never a bare "an account": a choice
  /// about a credential the user cannot identify is not a choice.
  String label(BuildContext context) =>
      email ??
      displayName ??
      AppLocalizations.of(context).account_previousSignInFallback;
}
