/*
 * Copyright (c) 2024-2025 Fabian Freund.
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
import 'package:pigeon/pigeon.dart';

enum ProxyType { obfs4, meekLite, webtunnel, snowflake }

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/pigeons/proxy.g.dart',
    dartOptions: DartOptions(),
    kotlinOut:
        'android/src/main/kotlin/eu/weblibre/pluggable_transports_proxy/pigeons/Proxy.g.kt',
    kotlinOptions: KotlinOptions(
      package: 'eu.weblibre.pluggable_transports_proxy.pigeons',
    ),
    dartPackageName: 'pluggable_transports_proxy',
  ),
)
@HostApi()
abstract class IPtProxyController {
  int start(ProxyType proxyType, String proxy);
  void stop(ProxyType proxyType);
}
