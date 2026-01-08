package eu.weblibre.flutter_tor

/**
 * Parses and validates bridge lines
 */
object BridgeParser {

    /**
     * Parse a bridge line and extract transport type
     * Examples:
     *   "obfs4 192.0.2.4:443 cert=..."
     *   "snowflake 192.0.2.3:1 fingerprint=..."
     *   "webtunnel [2001:db8::1]:443 url=..."
     *
     * @param bridgeLine Bridge line to parse
     * @return Transport type or null if invalid
     */
    fun extractTransportType(bridgeLine: String): String? {
        val trimmed = bridgeLine.trim()
        if (trimmed.isEmpty()) return null

        // Bridge line format: <transport> <address:port> [<key=value>...]
        val parts = trimmed.split("\\s+".toRegex(), limit = 2)
        if (parts.isEmpty()) return null

        return parts[0].lowercase()
    }

    /**
     * Validate if a bridge line is properly formatted
     * @param bridgeLine Bridge line to validate
     * @return true if valid
     */
    fun isValid(bridgeLine: String): Boolean {
        val trimmed = bridgeLine.trim()
        if (trimmed.isEmpty()) return false

        // Must have at least transport and address:port
        val parts = trimmed.split("\\s+".toRegex())
        if (parts.size < 2) return false

        // Second part should contain a colon (address:port)
        return parts[1].contains(":")
    }

    /**
     * Normalize bridge lines (trim, remove empty lines)
     * @param bridgeLines List of bridge lines
     * @return Normalized list
     */
    fun normalize(bridgeLines: List<String>): List<String> {
        return bridgeLines
            .map { it.trim() }
            .filter { it.isNotEmpty() }
            .filter { !it.startsWith("#") } // Remove comments
    }
}
