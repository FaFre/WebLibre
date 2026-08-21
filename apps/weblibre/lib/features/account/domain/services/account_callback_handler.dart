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
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/core/filesystem.dart';
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/features/account/data/account_handoff_ledger.dart';
import 'package:weblibre/features/account/domain/repositories/account_auth.dart';
import 'package:weblibre/features/share_intent/domain/services/sharing_intent.dart';

part 'account_callback_handler.g.dart';

/// Parsed `weblibre://account/callback?code=...&state=...` deep link.
class AccountCallback {
  const AccountCallback({required this.handoffCode, this.state});

  final String handoffCode;

  /// The nonce this app sent with the authentication request, echoed back.
  ///
  /// Null for a callback produced by an account web app that predates the
  /// nonce. Such a callback cannot be authenticated at all — see
  /// [AccountHandoffLedger] — so it is accepted only under the legacy rule.
  final String? state;
}

/// Parses [data] as a WebLibre account callback URI. Returns `null` if it
/// isn't one (any other intent) or if the `code` query parameter is
/// missing/empty. Callers can check `!= null` instead of running two
/// passes (used-to-be `isAccountCallbackUri` then `extractHandoffCode`).
AccountCallback? tryParseAccountCallback(String data) {
  final uri = Uri.tryParse(data);
  if (uri == null) return null;
  if (uri.scheme != 'weblibre' ||
      uri.host != 'account' ||
      uri.path != '/callback') {
    return null;
  }
  final code = uri.queryParameters['code'];
  if (code == null || code.isEmpty) return null;

  final state = uri.queryParameters['state'];
  return AccountCallback(
    handoffCode: code,
    state: state != null && state.isNotEmpty ? state : null,
  );
}

/// Listens for account callback deep links and forwards handoff codes
/// to the account auth repository.
///
/// This provider must be watched during app initialization to activate
/// the callback listener.
@Riverpod(keepAlive: true)
void accountCallbackHandler(Ref ref) {
  final stream = ref.watch(accountCallbackStreamProvider);
  final ledger = AccountHandoffLedger(filesystem.startupPaths);

  final subscription = stream.listen((callback) async {
    if (!await _isOurs(ledger, callback)) return;

    logger.i('Received account handoff callback');
    await ref
        .read(accountAuthRepositoryProvider.notifier)
        .handleHandoffCode(callback.handoffCode);
  });

  ref.onDispose(subscription.cancel);
}

/// Whether [callback] answers an authentication this profile actually started.
///
/// The callback carries an opaque code and nothing else that identifies it, so
/// without the echoed nonce there is no way to tell a real callback from one any
/// app on the device fired at us. A pending sign-in is not proof of the
/// callback's authenticity — treating it as proof is how an unsolicited deep link
/// burns the user's real sign-in and shows them an error for it.
///
/// Refusal is silent by design. An unsolicited callback is not the user's doing,
/// and surfacing an error for it would hand any app on the device a way to
/// interrupt them.
Future<bool> _isOurs(
  AccountHandoffLedger ledger,
  AccountCallback callback,
) async {
  final state = callback.state;

  if (state == null) {
    // An account web app that predates the nonce. Accepted, because refusing
    // would break sign-in against a deployed backend that cannot echo one yet —
    // and logged, because while this branch is reachable the callback is
    // unauthenticated.
    logger.w(
      'Account callback carried no state nonce; accepting it unauthenticated',
    );
    return true;
  }

  // The owning profile is passed *in* rather than checked after the fact. The
  // record is one-time, so a callback that reaches the wrong profile must not be
  // able to spend it: consuming first and comparing afterwards left the profile
  // that actually started the sign-in with nothing to redeem, and no way back.
  final record = await ledger.consume(
    state,
    ownedBy: filesystem.selectedProfile.uuid,
  );
  if (record == null) {
    // Never issued, already used, expired, or another profile's. All of them
    // mean the same thing here and none may disturb a pending sign-in.
    logger.w('Ignoring an account callback that answers no sign-in we started');
    return false;
  }

  return true;
}
