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
import 'dart:io';
import 'dart:typed_data';

import 'package:http/io_client.dart';
import 'package:socks5_proxy/socks_client.dart';

enum FaviconResolveStatus { hit, missing, error }

class FaviconResolveResult {
  final FaviconResolveStatus status;
  final Uint8List? bytes;

  const FaviconResolveResult._({required this.status, this.bytes});

  const FaviconResolveResult.hit(Uint8List bytes)
    : this._(status: FaviconResolveStatus.hit, bytes: bytes);

  const FaviconResolveResult.missing()
    : this._(status: FaviconResolveStatus.missing);

  const FaviconResolveResult.error()
    : this._(status: FaviconResolveStatus.error);
}

abstract class FaviconResolver {
  Future<FaviconResolveResult> resolve(Uri url, {int? proxyPort});
}

final class DdgFaviconResolver implements FaviconResolver {
  static const _timeout = Duration(seconds: 15);

  @override
  Future<FaviconResolveResult> resolve(Uri url, {int? proxyPort}) async {
    final host = url.host.trim().toLowerCase();
    if (host.isEmpty) {
      return const FaviconResolveResult.error();
    }

    final httpClient = HttpClient();
    if (proxyPort != null) {
      SocksTCPClient.assignToHttpClient(httpClient, [
        ProxySettings(InternetAddress.loopbackIPv4, proxyPort),
      ]);
    }

    final client = IOClient(httpClient);
    try {
      final response = await client
          .get(Uri.https('icons.duckduckgo.com', '/ip2/$host.ico'))
          .timeout(_timeout);

      if (response.statusCode == 200 && response.bodyBytes.isNotEmpty) {
        return FaviconResolveResult.hit(response.bodyBytes);
      }

      if (response.statusCode == 404) {
        return const FaviconResolveResult.missing();
      }

      return const FaviconResolveResult.error();
    } on SocketException {
      return const FaviconResolveResult.error();
    } on HttpException {
      return const FaviconResolveResult.error();
    } on HandshakeException {
      return const FaviconResolveResult.error();
    } on TlsException {
      return const FaviconResolveResult.error();
    } catch (_) {
      return const FaviconResolveResult.error();
    } finally {
      client.close();
    }
  }
}
