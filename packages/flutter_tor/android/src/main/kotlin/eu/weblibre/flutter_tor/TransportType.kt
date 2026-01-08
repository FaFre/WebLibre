package eu.weblibre.flutter_tor

/**
 * Transport types for Tor connections
 * Maps to Pigeon-generated enum
 */
enum class TransportType {
    NONE,           // Direct Tor connection (no bridges)
    OBFS4,          // obfs4 pluggable transport
    SNOWFLAKE,      // Snowflake (default broker)
    SNOWFLAKE_AMP,  // Snowflake via AMP cache
    MEEK,           // Meek pluggable transport
    MEEK_AZURE,     // Meek via Azure CDN
    WEBTUNNEL,      // WebTunnel pluggable transport
    CUSTOM;         // Custom bridge lines (passthrough)

    companion object {
        /**
         * Convert from Pigeon-generated enum
         */
        fun fromPigeon(pigeon: eu.weblibre.flutter_tor.generated.TransportType): TransportType {
            return when (pigeon) {
                eu.weblibre.flutter_tor.generated.TransportType.NONE -> NONE
                eu.weblibre.flutter_tor.generated.TransportType.OBFS4 -> OBFS4
                eu.weblibre.flutter_tor.generated.TransportType.SNOWFLAKE -> SNOWFLAKE
                eu.weblibre.flutter_tor.generated.TransportType.SNOWFLAKE_AMP -> SNOWFLAKE_AMP
                eu.weblibre.flutter_tor.generated.TransportType.MEEK -> MEEK
                eu.weblibre.flutter_tor.generated.TransportType.MEEK_AZURE -> MEEK_AZURE
                eu.weblibre.flutter_tor.generated.TransportType.WEBTUNNEL -> WEBTUNNEL
                eu.weblibre.flutter_tor.generated.TransportType.CUSTOM -> CUSTOM
            }
        }
    }
}
