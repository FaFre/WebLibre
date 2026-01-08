package eu.weblibre.flutter_tor

import eu.weblibre.flutter_tor.generated.TorConfiguration
import IPtProxy.IPtProxy
import java.io.File

/**
 * Generates Tor configuration (torrc) based on user settings
 */
class TorConfig(private val config: TorConfiguration) {

    /**
     * Generate torrc file content
     * @param socksPort SOCKS proxy port
     * @param dataDir Tor data directory
     * @param geoipFile GeoIP file (optional, for country selection)
     * @param geoip6File GeoIP6 file (optional, for IPv6 country selection)
     * @param transportPorts Map of transport name to port (from PluggableTransportManager)
     * @return torrc content as string
     *
     * Note: ControlPort is NOT set in torrc. The tor-android library automatically
     * uses ControlSocket (Unix domain socket) which is more secure than TCP ControlPort.
     * See SECURITY_CONTROL_PORT.md for details.
     */
    fun generateTorrc(
        socksPort: Int,
        dataDir: File,
        geoipFile: File?,
        geoip6File: File?,
        transportPorts: Map<String, Int>
    ): String = buildString {
        // Core Tor settings
        append("# Generated torrc for flutter_tor\n")
        append("SocksPort 127.0.0.1:$socksPort\n")
        // ControlPort is NOT set - tor-android uses ControlSocket (Unix domain socket)
        // This is more secure as it uses file permissions instead of TCP authentication
        append("DataDirectory ${dataDir.absolutePath}\n")
        append("\n")

        // GeoIP files for country-based node selection
        if (geoipFile != null && geoipFile.exists()) {
            append("GeoIPFile ${geoipFile.absolutePath}\n")
        }
        if (geoip6File != null && geoip6File.exists()) {
            append("GeoIPv6File ${geoip6File.absolutePath}\n")
        }
        append("\n")

        // Entry node countries
        config.entryNodeCountries?.let { countries ->
            if (countries.isNotBlank()) {
                val formatted = formatCountries(countries)
                append("EntryNodes $formatted\n")
            }
        }

        // Exit node countries
        config.exitNodeCountries?.let { countries ->
            if (countries.isNotBlank()) {
                val formatted = formatCountries(countries)
                append("ExitNodes $formatted\n")
            }
        }

        // Strict nodes (only use specified countries)
        if (config.strictNodes == true) {
            append("StrictNodes 1\n")
        }
        append("\n")

        // Pluggable transport configuration
        val transport = TransportType.fromPigeon(config.transport)
        when (transport) {
            TransportType.OBFS4 -> {
                transportPorts[IPtProxy.Obfs4]?.let { port ->
                    // Validate port is valid (like Orbot does)
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
                // Custom bridges - transport plugin defined in bridge line
                // We'll try to detect and configure based on bridge lines
                configureCustomTransports(transportPorts)
            }
            TransportType.NONE -> {
                // Direct connection, no pluggable transports
            }
        }
        append("\n")

        // Bridge configuration
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

        // Additional Tor settings (matching Orbot's configuration)
        append("# Additional settings\n")
        append("RunAsDaemon 1\n")
        append("AvoidDiskWrites 1\n")
        append("SafeSocks 0\n")
        append("TestSocks 0\n")
        append("VirtualAddrNetwork 10.192.0.0/10\n")
        append("AutomapHostsOnResolve 1\n")
        append("DormantClientTimeout 10 minutes\n")
        append("DormantCanceledByStartup 1\n")

        // CRITICAL: Set DisableNetwork 1 to prevent bootstrap before event listener is ready
        // This will be changed to 0 via control port AFTER we set up event listeners
        // This matches Orbot's approach and ensures we receive all bootstrap events
        append("DisableNetwork 1\n")

        append("Log notice stdout\n")  // Log to stdout for capture
        append("\n")
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
            .filter { it.length == 2 }  // ISO 3166-1 alpha-2 codes

        return codes.joinToString(",") { "{$it}" }
    }

    /**
     * Configure custom transports based on bridge lines
     * Detects transport type from bridge lines and configures accordingly
     */
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

    /**
     * Write torrc to file
     * @param torrcFile File to write to
     * @param content torrc content
     */
    fun writeTorrc(torrcFile: File, content: String) {
        torrcFile.parentFile?.mkdirs()
        torrcFile.writeText(content)
    }
}
