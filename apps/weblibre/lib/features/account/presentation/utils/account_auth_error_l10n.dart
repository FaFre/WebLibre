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
import 'package:weblibre/features/account/data/models/account_auth_state.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';

/// Display text for [AccountAuthError].
extension AccountAuthErrorL10n on AccountAuthError {
  String describe(AppLocalizations l10n) {
    return switch (kind) {
      AccountAuthErrorKind.network => l10n.account_authNetworkError,
      AccountAuthErrorKind.sessionExpiredWithKey =>
        l10n.account_authSessionExpiredWithKey,
      AccountAuthErrorKind.sessionExpiredNoKey =>
        l10n.account_authSessionExpiredNoKey,
      AccountAuthErrorKind.restoreFailed =>
        l10n.account_authRestoreFailedFallback,
      AccountAuthErrorKind.signInTimedOut => l10n.account_authSignInTimedOut,
      AccountAuthErrorKind.signInOpenPageFailed =>
        l10n.account_authSignInOpenPageFailed,
      AccountAuthErrorKind.noPendingSignIn => l10n.account_authNoPendingSignIn,
      AccountAuthErrorKind.signInVerificationFailed =>
        l10n.account_authSignInVerificationFailed,
      AccountAuthErrorKind.signInNotCompleted =>
        l10n.account_authSignInNotCompleted,
      AccountAuthErrorKind.signInFailed =>
        l10n.account_authSignInFailedFallback,
      AccountAuthErrorKind.server =>
        serverMessage ?? l10n.account_authSignInFailedFallback,
    };
  }
}
