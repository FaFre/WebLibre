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
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/features/account/domain/repositories/account_auth.dart';
import 'package:weblibre/features/share_intent/domain/services/sharing_intent.dart';

part 'account_callback_handler.g.dart';

/// Parsed `weblibre://account/callback?code=...` deep link.
class AccountCallback {
  final String handoffCode;

  const AccountCallback({required this.handoffCode});
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
  return AccountCallback(handoffCode: code);
}

/// Listens for account callback deep links and forwards handoff codes
/// to the account auth repository.
///
/// This provider must be watched during app initialization to activate
/// the callback listener.
@Riverpod(keepAlive: true)
void accountCallbackHandler(Ref ref) {
  final stream = ref.watch(accountCallbackStreamProvider);

  final subscription = stream.listen((code) async {
    logger.i('Received account handoff callback');
    await ref
        .read(accountAuthRepositoryProvider.notifier)
        .handleHandoffCode(code);
  });

  ref.onDispose(subscription.cancel);
}
