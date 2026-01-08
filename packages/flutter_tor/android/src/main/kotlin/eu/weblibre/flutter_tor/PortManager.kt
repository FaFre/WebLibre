package eu.weblibre.flutter_tor

import java.net.ServerSocket

/**
 * Manages random port allocation for Tor and pluggable transports
 */
object PortManager {

    /**
     * Find an available random port by binding to port 0
     * @return Available port number
     */
    fun findAvailablePort(): Int {
        return ServerSocket(0).use { socket ->
            socket.localPort
        }
    }

    /**
     * Check if a specific port is available
     * @param port Port to check
     * @return true if port is available
     */
    fun isPortAvailable(port: Int): Boolean {
        return try {
            ServerSocket(port).use { true }
        } catch (e: Exception) {
            false
        }
    }
}
