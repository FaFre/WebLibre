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
package eu.weblibre.flutter_tor

import IPtProxy.IPtProxy
import eu.weblibre.flutter_tor.generated.IPtProxyController
import eu.weblibre.flutter_tor.generated.TransportType

class ProxyImpl(val controller: IPtProxy.Controller) : IPtProxyController {
    override fun start(proxyType: TransportType, proxy: String): Long {
        val type = when (proxyType) {
            TransportType.SNOWFLAKE -> IPtProxy.Snowflake
            TransportType.MEEK -> IPtProxy.MeekLite
            TransportType.WEBTUNNEL -> IPtProxy.Webtunnel
            TransportType.OBFS4 -> IPtProxy.Obfs4
            TransportType.NONE -> null
            else -> {
                throw Exception("Unsupported transport type")
            }
        }

        controller.start(type, proxy)

        return controller.port(type)
    }

    override fun stop(proxyType: TransportType) {
        val type = when (proxyType) {
            TransportType.SNOWFLAKE -> IPtProxy.Snowflake
            TransportType.MEEK -> IPtProxy.MeekLite
            TransportType.WEBTUNNEL -> IPtProxy.Webtunnel
            TransportType.OBFS4 -> IPtProxy.Obfs4
            TransportType.NONE -> null
            else -> {
                throw Exception("Unsupported transport type")
            }
        }

        controller.stop(type)
    }
}