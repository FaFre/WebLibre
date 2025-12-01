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
package eu.weblibre.pluggable_transports_proxy

import eu.weblibre.pluggable_transports_proxy.pigeons.IPtProxyController
import eu.weblibre.pluggable_transports_proxy.pigeons.ProxyType

class ProxyImpl(val controller: IPtProxy.Controller) : IPtProxyController {
    override fun start(
        proxyType: ProxyType,
        proxy: String
    ): Long {
        val type = when (proxyType) {
            ProxyType.OBFS4 -> IPtProxy.IPtProxy.Obfs4
            ProxyType.MEEK_LITE -> IPtProxy.IPtProxy.MeekLite
            ProxyType.WEBTUNNEL -> IPtProxy.IPtProxy.Webtunnel
            ProxyType.SNOWFLAKE -> IPtProxy.IPtProxy.Snowflake
        };

        controller.start(type, proxy)

        return controller.port(type)
    }

    override fun stop(proxyType: ProxyType) {
        val type = when (proxyType) {
            ProxyType.OBFS4 -> IPtProxy.IPtProxy.Obfs4
            ProxyType.MEEK_LITE -> IPtProxy.IPtProxy.MeekLite
            ProxyType.WEBTUNNEL -> IPtProxy.IPtProxy.Webtunnel
            ProxyType.SNOWFLAKE -> IPtProxy.IPtProxy.Snowflake
        };

        controller.stop(type)
    }
}