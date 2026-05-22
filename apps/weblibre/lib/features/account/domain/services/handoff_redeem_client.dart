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
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/features/account/data/supabase_config.dart';

part 'handoff_redeem_client.g.dart';

/// Thrown by [HandoffRedeemClient.redeem] when we want to surface a
/// specific, already-safe message to the user (e.g. a server-supplied error
/// string). Distinguishes "messages we trust to show verbatim" from
/// arbitrary `Exception.toString()` output, which may carry HTTP bodies,
/// tokens, or stack frames.
class AccountAuthFlowException implements Exception {
  final String userMessage;
  AccountAuthFlowException(this.userMessage);

  @override
  String toString() => userMessage;
}

/// Successful response from the `handoff-redeem` Supabase function. Holds
/// the raw `session` and `account` payloads so the caller decides how to
/// persist them.
class HandoffRedeemResult {
  final Map<String, dynamic> session;
  final Map<String, dynamic> account;

  const HandoffRedeemResult({required this.session, required this.account});
}

/// Stateless client for the account web app's `handoff-redeem` endpoint.
/// Owns the HTTP transport and the response parsing so the auth repository
/// only orchestrates state transitions around it.
class HandoffRedeemClient {
  final http.Client _client;

  HandoffRedeemClient({http.Client? client})
    : _client = client ?? http.Client();

  void close() => _client.close();

  /// Exchange a one-time `handoff_code` plus the matching PKCE
  /// `code_verifier` for a Supabase session. Throws
  /// [AccountAuthFlowException] on a non-200 status with the server's error
  /// message when available, or a generic fallback otherwise.
  Future<HandoffRedeemResult> redeem({
    required String handoffCode,
    required String codeVerifier,
  }) async {
    const redeemUrl =
        '${SupabaseConfig.supabaseUrl}/functions/v1/handoff-redeem';
    final response = await _client.post(
      Uri.parse(redeemUrl),
      headers: {
        'Content-Type': 'application/json',
        'apikey': SupabaseConfig.supabaseAnonKey,
      },
      body: jsonEncode({
        'handoff_code': handoffCode,
        'code_verifier': codeVerifier,
      }),
    );

    if (response.statusCode != 200) {
      // Try to extract the server's error field. The full response body
      // is logged by the caller — we only surface the trusted message
      // field to the UI to avoid leaking response detail.
      String? serverMessage;
      try {
        final error = jsonDecode(response.body) as Map<String, dynamic>;
        serverMessage = error['error'] as String?;
      } catch (_) {
        // Body wasn't JSON — fall back to a generic message so we don't
        // echo HTML/HTTP detail to the user.
      }
      throw AccountAuthFlowException(
        serverMessage ?? 'Sign-in failed. Please try again.',
      );
    }

    final responseData = jsonDecode(response.body) as Map<String, dynamic>;
    return HandoffRedeemResult(
      session: responseData['session'] as Map<String, dynamic>,
      account: responseData['account'] as Map<String, dynamic>,
    );
  }
}

@Riverpod(keepAlive: true)
HandoffRedeemClient handoffRedeemClient(Ref ref) {
  final client = HandoffRedeemClient();
  ref.onDispose(client.close);
  return client;
}
