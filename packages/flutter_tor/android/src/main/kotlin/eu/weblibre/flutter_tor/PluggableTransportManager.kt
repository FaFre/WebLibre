package eu.weblibre.flutter_tor

import android.content.Context
import android.util.Log
import IPtProxy.Controller
import IPtProxy.IPtProxy
import IPtProxy.OnTransportStopped
import java.io.File

/**
 * Manages pluggable transports via IPtProxy
 * Supports: obfs4, snowflake, meek, webtunnel
 */
class PluggableTransportManager(private val context: Context) {

    companion object {
        private const val TAG = "PTManager"

        // Snowflake configuration
        private const val SNOWFLAKE_BROKER = "https://snowflake-broker.torproject.net/"
        private const val SNOWFLAKE_BROKER_AMP = "https://snowflake-broker.torproject.net.global.prod.fastly.net/"
        private const val SNOWFLAKE_AMP_CACHE = "https://cdn.ampproject.org/"
        private val SNOWFLAKE_FRONTS = listOf("foursquare.com", "github.githubassets.com")
        private val SNOWFLAKE_AMP_FRONTS = listOf("www.google.com")
        private const val SNOWFLAKE_ICE_SERVERS = "stun:stun.l.google.com:19302,stun:stun.antisip.com:3478,stun:stun.bluesip.net:3478,stun:stun.dus.net:3478,stun:stun.epygi.com:3478,stun:stun.sonetel.com:3478,stun:stun.uls.co.za:3478,stun:stun.voipgate.com:3478,stun:stun.voys.nl:3478"
    }

    private val stateDir = File(context.cacheDir, "iptproxy")
    private val activeTransports = mutableSetOf<String>()

    private val statusCallback = object : OnTransportStopped {
        override fun stopped(name: String?, exception: Exception?) {
            if (name != null) {
                activeTransports.remove(name)
                if (exception != null) {
                    Log.e(TAG, "$name stopped with error: ${exception.message}", exception)
                } else {
                    Log.d(TAG, "$name stopped normally")
                }
            }
        }
    }

    // Lazy singleton controller (like Orbot does)
    val controller: Controller by lazy {
        Controller(
            stateDir.absolutePath,
            true,  // enableLogging
            false, // unsafeLogging
            "INFO", // logLevel
            statusCallback
        )
    }

    init {
        stateDir.mkdirs()
    }

    /**
     * Start pluggable transport for the given type
     * @param type Transport type
     * @return Map of transport name to port (e.g., {"obfs4": 12345})
     */
    fun startTransport(type: TransportType): Map<String, Int> {
        Log.d(TAG, "Starting transport: $type")

        // Stop any currently running transports before starting new ones
        stopAll()

        val ports = mutableMapOf<String, Int>()

        try {
            when (type) {
                TransportType.OBFS4 -> {
                    val transportName = IPtProxy.Obfs4
                    controller.start(transportName, null) // null = no proxy
                    activeTransports.add(transportName)
                    val port = controller.port(transportName)
                    if (port > 0) {
                        ports[transportName] = port.toInt()
                        Log.d(TAG, "$transportName started on port $port")
                    }
                }

                TransportType.SNOWFLAKE -> {
                    val transportName = IPtProxy.Snowflake
                    configureSnowflake(useAmp = false)
                    controller.start(transportName, null)
                    activeTransports.add(transportName)
                    val port = controller.port(transportName)
                    if (port > 0) {
                        ports[transportName] = port.toInt()
                        Log.d(TAG, "$transportName started on port $port")
                    }
                }

                TransportType.SNOWFLAKE_AMP -> {
                    val transportName = IPtProxy.Snowflake
                    configureSnowflake(useAmp = true)
                    controller.start(transportName, null)
                    activeTransports.add(transportName)
                    val port = controller.port(transportName)
                    if (port > 0) {
                        ports[transportName] = port.toInt()
                        Log.d(TAG, "$transportName (AMP) started on port $port")
                    }
                }

                TransportType.MEEK, TransportType.MEEK_AZURE -> {
                    val transportName = IPtProxy.MeekLite
                    controller.start(transportName, null)
                    activeTransports.add(transportName)
                    val port = controller.port(transportName)
                    if (port > 0) {
                        ports[transportName] = port.toInt()
                        Log.d(TAG, "$transportName started on port $port")
                    }
                }

                TransportType.WEBTUNNEL -> {
                    val transportName = IPtProxy.Webtunnel
                    controller.start(transportName, null)
                    activeTransports.add(transportName)
                    val port = controller.port(transportName)
                    if (port > 0) {
                        ports[transportName] = port.toInt()
                        Log.d(TAG, "$transportName started on port $port")
                    }
                }

                TransportType.NONE, TransportType.CUSTOM -> {
                    // No pluggable transport needed
                }
            }
        } catch (e: Exception) {
            Log.e(TAG, "Failed to start transport $type: ${e.message}", e)
        }

        return ports
    }

    /**
     * Configure Snowflake-specific settings
     */
    private fun configureSnowflake(useAmp: Boolean) {
        controller.snowflakeIceServers = SNOWFLAKE_ICE_SERVERS

        if (useAmp) {
            controller.snowflakeBrokerUrl = SNOWFLAKE_BROKER_AMP
            controller.snowflakeFrontDomains = SNOWFLAKE_AMP_FRONTS.joinToString(",")
            controller.snowflakeAmpCacheUrl = SNOWFLAKE_AMP_CACHE
        } else {
            controller.snowflakeBrokerUrl = SNOWFLAKE_BROKER
            controller.snowflakeFrontDomains = SNOWFLAKE_FRONTS.joinToString(",")
            controller.snowflakeAmpCacheUrl = ""
        }

        controller.snowflakeSqsUrl = ""
        controller.snowflakeSqsCreds = ""

        Log.d(TAG, "Configured Snowflake: broker=${controller.snowflakeBrokerUrl}, amp=$useAmp")
    }

    /**
     * Stop all running pluggable transports
     */
    fun stopAll() {
        Log.d(TAG, "Stopping all transports")

        // Stop each active transport
        activeTransports.toList().forEach { transportName ->
            try {
                controller.stop(transportName)
                Log.d(TAG, "Stopped transport: $transportName")
            } catch (e: Exception) {
                Log.w(TAG, "Error stopping $transportName: ${e.message}")
            }
        }
        activeTransports.clear()

        Log.d(TAG, "All transports stopped")
    }

    /**
     * Get the port for a specific transport
     * @param transportName Transport name (e.g., "obfs4", "snowflake")
     * @return Port number or null
     */
    fun getPort(transportName: String): Int? {
        val port = controller.port(transportName)
        return if (port > 0) port.toInt() else null
    }

    /**
     * Check if a transport is currently running
     */
    fun isRunning(): Boolean {
        return activeTransports.isNotEmpty()
    }
}
