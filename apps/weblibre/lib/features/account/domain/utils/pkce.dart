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
import 'dart:math';

import 'package:crypto/crypto.dart';

/// A PKCE code-verifier / code-challenge pair tied to a single sign-in
/// attempt. The verifier stays on the device; the challenge is sent to the
/// account web app and later redeemed alongside the verifier to prove the
/// app instance that started the flow is the one finishing it.
///
/// **Encoding deviates from RFC 7636.** The reference spec mandates
/// base64url for both verifier and `S256` challenge; this implementation
/// uses lowercase hex on both sides:
///   - verifier: 32 random bytes encoded as 64 hex characters (within the
///     43–128 range allowed by RFC 7636 §4.1).
///   - challenge: hex digest of `SHA-256(UTF-8(verifier))`.
///
/// Both sides of the flow are owned (this client and the `handoff-redeem`
/// Supabase function), so the wire format is internally consistent. The
/// deviation matters only if the redeem endpoint is ever replaced with a
/// standards-compliant OAuth server — in which case both `_generateCodeVerifier`
/// and `_challengeFor` must switch to base64url to interoperate.
class PkceCodes {
  final String verifier;
  final String challenge;

  const PkceCodes({required this.verifier, required this.challenge});

  factory PkceCodes.generate() {
    final verifier = _generateCodeVerifier();
    return PkceCodes(verifier: verifier, challenge: _challengeFor(verifier));
  }

  static String _generateCodeVerifier() {
    final random = Random.secure();
    final bytes = List<int>.generate(32, (_) => random.nextInt(256));
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  static String _challengeFor(String verifier) {
    return sha256.convert(utf8.encode(verifier)).toString();
  }
}
