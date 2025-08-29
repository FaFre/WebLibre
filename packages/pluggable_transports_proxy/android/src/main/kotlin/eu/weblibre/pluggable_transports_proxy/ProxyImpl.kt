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