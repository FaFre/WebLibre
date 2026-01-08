package eu.weblibre.flutter_tor

import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.ServiceConnection
import android.os.IBinder
import android.util.Log
import eu.weblibre.flutter_tor.generated.TorConfiguration
import eu.weblibre.flutter_tor.generated.TorStatus
import kotlinx.coroutines.*
import kotlin.coroutines.resume
import kotlin.coroutines.resumeWithException
import net.freehaven.tor.control.RawEventListener
import net.freehaven.tor.control.TorControlCommands
import net.freehaven.tor.control.TorControlConnection
import org.torproject.jni.TorService
import java.io.File

/**
 * Core Tor lifecycle manager
 * Handles starting/stopping Tor, control port connection, and event listening
 */
class TorManager(
    private val context: Context,
    private val logHandler: LogStreamHandler
) {
    companion object {
        const val TAG = "TorManager"
    }

    private val dataDir = File(context.filesDir, "tor_data")
    private val installDir = File(context.filesDir, "tor_install")
    private var torServiceConnection: ServiceConnection? = null
    private var controlConnection: TorControlConnection? = null
    private var torService: TorService? = null

    val pluggableTransportManager = PluggableTransportManager(context)
    private val geoIpManager = GeoIpManager(context)

    private val scope = CoroutineScope(Dispatchers.IO + SupervisorJob())

    var socksPort: Int = -1
        private set
    // Note: No controlPort - tor-android uses ControlSocket (Unix domain socket) instead
    // This is more secure than TCP ControlPort as it uses file permissions for access control
    private var isRunning = false
    private var bootstrapProgress = 0

    /**
     * Start Tor with the given configuration
     * @param config Tor configuration from Flutter
     * @return SOCKS port
     */
    suspend fun start(config: TorConfiguration): Int = withContext(Dispatchers.IO) {
        if (isRunning) {
            Log.w(TAG, "Tor already running")
            return@withContext socksPort
        }

        try {
            logHandler.notice("Starting Tor...")

            // Create directories
            dataDir.mkdirs()
            installDir.mkdirs()

            // Allocate random SOCKS port
            // Note: We don't allocate a control port - tor-android uses ControlSocket instead
            socksPort = PortManager.findAvailablePort()

            Log.d(TAG, "Allocated SOCKS port: $socksPort")
            Log.d(TAG, "Control connection will use ControlSocket (Unix domain socket)")
            logHandler.notice("SOCKS port: $socksPort")

            // Start pluggable transports if needed
            val transport = TransportType.fromPigeon(config.transport)
            val transportPorts = if (transport != TransportType.NONE && transport != TransportType.CUSTOM) {
                logHandler.notice("Starting pluggable transport: $transport")
                pluggableTransportManager.startTransport(transport)
            } else if (transport == TransportType.CUSTOM) {
                // For custom, we need to detect and start appropriate transports
                startCustomTransports(config.bridgeLines)
            } else {
                emptyMap()
            }

            // Generate torrc
            val geoipFile = geoIpManager.getGeoIpFile(installDir)
            val geoip6File = geoIpManager.getGeoIp6File(installDir)

            val torConfig = TorConfig(config)
            val torrcContent = torConfig.generateTorrc(
                socksPort = socksPort,
                // controlPort removed - tor-android uses ControlSocket (Unix domain socket) for security
                dataDir = dataDir,
                geoipFile = geoipFile,
                geoip6File = geoip6File,
                transportPorts = transportPorts
            )

            // Write torrc to the correct location (like Orbot does)
            // CRITICAL: Must use TorService.getTorrc() so TorService can find it!
            val torrcFile = TorService.getTorrc(context)
            torConfig.writeTorrc(torrcFile, torrcContent)

            Log.d(TAG, "Generated torrc at ${torrcFile.absolutePath}:\n$torrcContent")

            // Write defaults torrc (required by tor-android)
            // Set DisableNetwork 1 initially like Orbot does, will be enabled via control port
            // Also disable DNSPort and TransPort (matching Orbot)
            val defaultsTorrcFile = TorService.getDefaultsTorrc(context)
            defaultsTorrcFile.writeText("""
                DNSPort 0
                TransPort 0
                DisableNetwork 1
            """.trimIndent())

            // Start TorService
            // Note: torrcFile is now written to the correct location via TorService.getTorrc()
            // so TorService will automatically find and use it
            startTorService()

            isRunning = true
            logHandler.notice("Tor started successfully")
            sendStatusUpdate()

            socksPort
        } catch (e: Exception) {
            Log.e(TAG, "Failed to start Tor", e)
            logHandler.error("Failed to start Tor: ${e.message}")
            cleanup()
            throw e
        }
    }

    /**
     * Start custom transports based on bridge lines
     */
    private fun startCustomTransports(bridgeLines: List<String>): Map<String, Int> {
        val transports = bridgeLines
            .mapNotNull { BridgeParser.extractTransportType(it) }
            .distinct()

        val ports = mutableMapOf<String, Int>()

        transports.forEach { transportName ->
            val transportType = when (transportName) {
                "obfs4" -> TransportType.OBFS4
                "snowflake" -> TransportType.SNOWFLAKE
                "meek_lite" -> TransportType.MEEK
                "webtunnel" -> TransportType.WEBTUNNEL
                else -> null
            }

            transportType?.let { type ->
                ports.putAll(pluggableTransportManager.startTransport(type))
            }
        }

        return ports
    }

    /**
     * Start the native TorService and bind to it
     * TorService will automatically use the torrc written to TorService.getTorrc(context)
     */
    private suspend fun startTorService() = suspendCancellableCoroutine<Unit> { continuation ->
        val connection = object : ServiceConnection {
            override fun onServiceConnected(name: ComponentName?, service: IBinder?) {
                Log.d(TAG, "TorService connected")
                val binder = service as? TorService.LocalBinder
                torService = binder?.service

                // Wait for control connection to be available
                scope.launch {
                    var conn: TorControlConnection? = null
                    var attempts = 0
                    while (conn == null && attempts < 60) { // 30 seconds timeout
                        delay(500)
                        conn = torService?.torControlConnection
                        attempts++
                    }

                    if (conn != null) {
                        // Wait an additional second before setting up event listener
                        // This matches Orbot's behavior and ensures Tor is fully initialized
                        delay(1000)

                        controlConnection = conn
                        setupControlConnection(conn)
                        if (continuation.isActive) {
                            continuation.resume(Unit) {}
                        }
                    } else {
                        val error = Exception("Failed to get control connection after 30 seconds")
                        if (continuation.isActive) {
                            continuation.resumeWithException(error)
                        }
                    }
                }
            }

            override fun onServiceDisconnected(name: ComponentName?) {
                Log.w(TAG, "TorService disconnected")
                torService = null
                controlConnection = null
            }
        }

        torServiceConnection = connection

        val intent = Intent(context, org.torproject.jni.TorService::class.java)

        try {
            // Start the service first (like Orbot does) before binding
            context.startService(intent)
            context.bindService(intent, connection, Context.BIND_AUTO_CREATE)
        } catch (e: Exception) {
            if (continuation.isActive) {
                continuation.resumeWithException(e)
            }
        }
    }

    /**
     * Setup control connection and event listeners
     */
    private fun setupControlConnection(conn: TorControlConnection) {
        try {
            // Add event listener
            conn.addRawEventListener(TorEventListener())

            // Subscribe to events (matching Orbot's event subscriptions)
            conn.setEvents(listOf(
                TorControlCommands.EVENT_OR_CONN_STATUS,
                TorControlCommands.EVENT_CIRCUIT_STATUS,
                TorControlCommands.EVENT_NOTICE_MSG,
                TorControlCommands.EVENT_WARN_MSG,
                TorControlCommands.EVENT_ERR_MSG,
                TorControlCommands.EVENT_BANDWIDTH_USED,
                TorControlCommands.EVENT_NEW_DESC,
                TorControlCommands.EVENT_ADDRMAP
            ))

            // Enable network now that configuration is complete (like Orbot does)
            conn.setConf("DisableNetwork", "0")

            Log.d(TAG, "Control connection setup complete")
            logHandler.notice("Connected to Tor control port")
        } catch (e: Exception) {
            Log.e(TAG, "Failed to setup control connection", e)
            logHandler.error("Control connection error: ${e.message}")
        }
    }

    /**
     * Stop Tor and cleanup
     */
    suspend fun stop() = withContext(Dispatchers.IO) {
        Log.d(TAG, "Stopping Tor")
        logHandler.notice("Stopping Tor...")

        try {
            // Shutdown Tor gracefully
            controlConnection?.shutdownTor("SHUTDOWN")
            delay(1000) // Give Tor time to shutdown

            cleanup()
            logHandler.notice("Tor stopped")
        } catch (e: Exception) {
            Log.e(TAG, "Error stopping Tor", e)
            cleanup()
        }
    }

    /**
     * Cleanup resources
     */
    private fun cleanup() {
        isRunning = false
        bootstrapProgress = 0
        socksPort = -1

        try {
            controlConnection?.let {
                // Don't shutdown again, just close
            }
            controlConnection = null
        } catch (e: Exception) {
            Log.w(TAG, "Error closing control connection", e)
        }

        try {
            torServiceConnection?.let {
                context.unbindService(it)
            }
            torServiceConnection = null
        } catch (e: Exception) {
            Log.w(TAG, "Error unbinding TorService", e)
        }

        torService = null

        pluggableTransportManager.stopAll()

        sendStatusUpdate()
    }

    /**
     * Request a new Tor identity (new circuit)
     */
    fun requestNewIdentity() {
        scope.launch {
            try {
                controlConnection?.signal(TorControlCommands.SIGNAL_NEWNYM)
                logHandler.notice("Requested new Tor identity")
            } catch (e: Exception) {
                Log.e(TAG, "Failed to request new identity", e)
                logHandler.error("Failed to request new identity: ${e.message}")
            }
        }
    }

    /**
     * Get current Tor status
     */
    fun getStatus(): TorStatus {
        val status = TorStatus(
            isRunning = isRunning,
            socksPort = if (isRunning) socksPort.toLong() else null,
            bootstrapProgress = bootstrapProgress.toLong(),
            currentCircuit = null, // TODO: track current circuit
            exitNodeCountry = null // TODO: track exit node country
        )

        Log.d(TAG, "getStatus() returning: isRunning=$isRunning, socksPort=$socksPort, bootstrap=$bootstrapProgress")
//        logHandler.sendStatusChange(status)

        return status
    }

    /**
     * Send status update to Flutter
     */
    private fun sendStatusUpdate() {
        logHandler.sendStatusChange(getStatus())
    }

    /**
     * Event listener for Tor control port events
     */
    private inner class TorEventListener : RawEventListener {
        override fun onEvent(eventType: String, eventData: String) {
            Log.d(TAG, "Tor event: $eventType - $eventData")

            // Handle bootstrap progress (comes in NOTICE events)
            if (eventData.contains("Bootstrapped")) {
                val progress = extractBootstrapProgress(eventData)
                if (progress >= 0) {
                    bootstrapProgress = progress
                    sendStatusUpdate()

                    if (progress == 100) {
                        logHandler.notice("Tor is ready!")
                    }
                }
            }

            // Forward to log handler
            logHandler.handleTorEvent(eventType, eventData)
        }

        private fun extractBootstrapProgress(eventData: String): Int {
            // Extract from format like "Bootstrapped 85% (loading_descriptors): ..."
            val regex = "Bootstrapped\\s+(\\d+)%".toRegex()
            return regex.find(eventData)?.groupValues?.get(1)?.toIntOrNull() ?: -1
        }
    }

    /**
     * Cleanup when manager is destroyed
     */
    fun destroy() {
        scope.cancel()
        runBlocking {
            if (isRunning) {
                stop()
            }
        }
    }
}
