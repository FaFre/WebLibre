package eu.weblibre.flutter_tor

import eu.weblibre.flutter_tor.generated.TorConfiguration
import io.nekohasekai.IPtProxy.IPtProxy
import java.io.File

/**
 * Generates Tor configuration (torrc) based on user settings.
 *
 * Notes on what we deliberately do NOT set here:
 *  - DataDirectory, ControlSocket, CookieAuthentication, RunAsDaemon, CacheDirectory,
 *    SyslogIdentityTag — upstream org.torproject.jni.TorService passes these on the
 *    `tor` command line. Setting them here causes duplicate-option warnings or contradicts
 *    the values upstream needs (e.g. RunAsDaemon must be 0 in-process).
 *  - SocksPort / HTTPTunnelPort — upstream rewrites defaults-torrc on every start with
 *    `SOCKSPort 9050|auto` and `HTTPTunnelPort 8118|auto`. tor REJECTS mixing
 *    `SocksPort 0` with any other SocksPort line ("Invalid SocksPort configuration"),
 *    so we cannot override these from torrc. Instead we just consume what upstream
 *    binds — read it from the static `TorService.socksPort` field (or via
 *    `getInfo net/listeners/socks`).
 *  - DNSPort / TransPort default to 0 in tor; no need to set them.
 */
class TorConfig(private val config: TorConfiguration) {

    fun generateTorrc(
        geoipFile: File?,
        geoip6File: File?,
        transportPorts: Map<String, Int>
    ): String = buildString {
        append("# Generated torrc for flutter_tor\n")

        // Start with networking disabled. Re-enabled via control port
        // (setConf DisableNetwork 0) AFTER our event listener is wired up so we
        // don't miss bootstrap events.
        append("DisableNetwork 1\n")
        append("\n")

        if (geoipFile != null && geoipFile.exists()) {
            append("GeoIPFile ${geoipFile.absolutePath}\n")
        }
        if (geoip6File != null && geoip6File.exists()) {
            append("GeoIPv6File ${geoip6File.absolutePath}\n")
        }
        append("\n")

        config.entryNodeCountries?.let { countries ->
            if (countries.isNotBlank()) {
                append("EntryNodes ${formatCountries(countries)}\n")
            }
        }

        config.exitNodeCountries?.let { countries ->
            if (countries.isNotBlank()) {
                append("ExitNodes ${formatCountries(countries)}\n")
            }
        }

        if (config.strictNodes == true) {
            append("StrictNodes 1\n")
        }
        append("\n")

        val transport = TransportType.fromPigeon(config.transport)
        when (transport) {
            TransportType.OBFS4 -> {
                transportPorts[IPtProxy.Obfs4]?.let { port ->
                    if (port > 0) {
                        append("ClientTransportPlugin ${IPtProxy.Obfs4} socks5 127.0.0.1:$port\n")
                    }
                }
            }
            TransportType.SNOWFLAKE, TransportType.SNOWFLAKE_AMP -> {
                transportPorts[IPtProxy.Snowflake]?.let { port ->
                    if (port > 0) {
                        append("ClientTransportPlugin ${IPtProxy.Snowflake} socks5 127.0.0.1:$port\n")
                    }
                }
            }
            TransportType.MEEK, TransportType.MEEK_AZURE -> {
                transportPorts[IPtProxy.MeekLite]?.let { port ->
                    if (port > 0) {
                        append("ClientTransportPlugin ${IPtProxy.MeekLite} socks5 127.0.0.1:$port\n")
                    }
                }
            }
            TransportType.WEBTUNNEL -> {
                transportPorts[IPtProxy.Webtunnel]?.let { port ->
                    if (port > 0) {
                        append("ClientTransportPlugin ${IPtProxy.Webtunnel} socks5 127.0.0.1:$port\n")
                    }
                }
            }
            TransportType.CUSTOM -> {
                configureCustomTransports(transportPorts)
            }
            TransportType.NONE -> {}
        }
        append("\n")

        if (transport != TransportType.NONE) {
            val normalizedBridges = BridgeParser.normalize(config.bridgeLines)
            if (normalizedBridges.isNotEmpty()) {
                append("UseBridges 1\n")
                normalizedBridges.forEach { bridge ->
                    append("Bridge $bridge\n")
                }
                append("\n")
            }
        }

        append("AvoidDiskWrites 1\n")
        append("SafeSocks 0\n")
        append("TestSocks 0\n")
        append("VirtualAddrNetwork 10.192.0.0/10\n")
        append("AutomapHostsOnResolve 1\n")
        append("DormantClientTimeout 10 minutes\n")
        append("DormantCanceledByStartup 1\n")
    }

    /**
     * Format country codes for Tor configuration
     * Input: "de,fr,nl" or "{de},{fr},{nl}" or "de, fr, nl"
     * Output: "{de},{fr},{nl}"
     */
    private fun formatCountries(countries: String): String {
        val codes = countries
            .replace("{", "")
            .replace("}", "")
            .split(",")
            .map { it.trim().uppercase() }
            .filter { it.isNotEmpty() }
            .filter { it.length == 2 }

        return codes.joinToString(",") { "{$it}" }
    }

    private fun StringBuilder.configureCustomTransports(transportPorts: Map<String, Int>) {
        val bridgeTransports = config.bridgeLines
            .mapNotNull { BridgeParser.extractTransportType(it) }
            .distinct()

        bridgeTransports.forEach { transportName ->
            when (transportName) {
                "obfs4" -> transportPorts[IPtProxy.Obfs4]?.let { port ->
                    if (port > 0) {
                        append("ClientTransportPlugin obfs4 socks5 127.0.0.1:$port\n")
                    }
                }
                "snowflake" -> transportPorts[IPtProxy.Snowflake]?.let { port ->
                    if (port > 0) {
                        append("ClientTransportPlugin snowflake socks5 127.0.0.1:$port\n")
                    }
                }
                "meek_lite" -> transportPorts[IPtProxy.MeekLite]?.let { port ->
                    if (port > 0) {
                        append("ClientTransportPlugin meek_lite socks5 127.0.0.1:$port\n")
                    }
                }
                "webtunnel" -> transportPorts[IPtProxy.Webtunnel]?.let { port ->
                    if (port > 0) {
                        append("ClientTransportPlugin webtunnel socks5 127.0.0.1:$port\n")
                    }
                }
            }
        }
    }

    fun writeTorrc(torrcFile: File, content: String) {
        torrcFile.parentFile?.mkdirs()
        torrcFile.writeText(content)
    }
}
