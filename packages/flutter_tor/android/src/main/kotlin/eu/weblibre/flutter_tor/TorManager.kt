package eu.weblibre.flutter_tor

import android.content.BroadcastReceiver
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.ServiceConnection
import android.os.IBinder
import android.util.Log
import androidx.localbroadcastmanager.content.LocalBroadcastManager
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
        private const val STATUS_OFF_TIMEOUT_MS = 10_000L
    }

    // GeoIP files live alongside other install assets. tor-android owns its own
    // DataDirectory/CacheDirectory under getDir("TorService"), so we don't define one.
    private val installDir = File(context.filesDir, "tor_install")
    private var torServiceConnection: ServiceConnection? = null

    @Volatile
    private var controlConnection: TorControlConnection? = null

    @Volatile
    private var torService: TorService? = null

    val pluggableTransportManager = PluggableTransportManager.getInstance(context)
    private val geoIpManager = GeoIpManager(context)

    private val scope = CoroutineScope(Dispatchers.IO + SupervisorJob())

    // Store event listener as a field to prevent garbage collection
    private var torEventListener: TorEventListener? = null

    var socksPort: Int = -1
        private set

    @Volatile
    private var isRunning = false
    @Volatile
    private var bootstrapProgress = 0

    private val statusLock = Any()

    // Latch awaited by stop() — completed when upstream broadcasts STATUS_OFF.
    @Volatile
    private var stopSignal: CompletableDeferred<Unit>? = null

    // Background bootstrap-progress poller — fallback for when NOTICE/STATUS_CLIENT
    // events are silently dropped by jtorctl/tor (observed intermittently in the wild).
    private var bootstrapPollJob: Job? = null

    // Mirror of upstream TorService's status — its own static `currentStatus` is package-private.
    @Volatile
    private var lastUpstreamStatus: String = TorService.STATUS_OFF

    private val statusReceiver = object : BroadcastReceiver() {
        override fun onReceive(ctx: Context?, intent: Intent?) {
            val status = intent?.getStringExtra(TorService.EXTRA_STATUS) ?: return
            Log.d(TAG, "TorService broadcast: $status")
            lastUpstreamStatus = status
            if (status == TorService.STATUS_OFF) {
                stopSignal?.complete(Unit)
            }
        }
    }

    private val errorReceiver = object : BroadcastReceiver() {
        override fun onReceive(ctx: Context?, intent: Intent?) {
            val msg = intent?.getStringExtra(Intent.EXTRA_TEXT) ?: "unknown"
            Log.e(TAG, "TorService error broadcast: $msg")
            logHandler.error("Tor service error: $msg")
        }
    }

    private var receiversRegistered = false

    private fun registerReceivers() {
        if (receiversRegistered) return
        val lbm = LocalBroadcastManager.getInstance(context)
        lbm.registerReceiver(statusReceiver, IntentFilter(TorService.ACTION_STATUS))
        lbm.registerReceiver(errorReceiver, IntentFilter(TorService.ACTION_ERROR))
        receiversRegistered = true
    }

    private fun unregisterReceivers() {
        if (!receiversRegistered) return
        val lbm = LocalBroadcastManager.getInstance(context)
        try { lbm.unregisterReceiver(statusReceiver) } catch (_: Exception) {}
        try { lbm.unregisterReceiver(errorReceiver) } catch (_: Exception) {}
        receiversRegistered = false
    }

    /**
     * Start Tor with the given configuration
     * @param config Tor configuration from Flutter
     * @return SOCKS port (discovered from tor via `getInfo net/listeners/socks`)
     */
    suspend fun start(config: TorConfiguration): Int = withContext(Dispatchers.IO) {
        if (isRunning) {
            Log.w(TAG, "Tor already running")
            return@withContext socksPort
        }

        try {
            logHandler.notice("Starting Tor...")

            installDir.mkdirs()
            lastUpstreamStatus = TorService.STATUS_STARTING
            registerReceivers()

            val transport = TransportType.fromPigeon(config.transport)
            val transportPorts = if (transport != TransportType.NONE && transport != TransportType.CUSTOM) {
                logHandler.notice("Starting pluggable transport: $transport")
                pluggableTransportManager.startTransport(transport)
            } else if (transport == TransportType.CUSTOM) {
                startCustomTransports(config.bridgeLines)
            } else {
                emptyMap()
            }

            val geoipFile = geoIpManager.getGeoIpFile(installDir)
            val geoip6File = geoIpManager.getGeoIp6File(installDir)

            val torConfig = TorConfig(config)
            val torrcContent = torConfig.generateTorrc(
                geoipFile = geoipFile,
                geoip6File = geoip6File,
                transportPorts = transportPorts
            )

            // Tor reads torrc from the location upstream TorService passes via -f.
            val torrcFile = TorService.getTorrc(context)
            torConfig.writeTorrc(torrcFile, torrcContent)

            Log.d(TAG, "Generated torrc at ${torrcFile.absolutePath}:\n$torrcContent")

            // Note: do NOT write defaults-torrc here. Upstream's setDefaultProxyPorts()
            // truncates and rewrites it on every start with `SOCKSPort/HTTPTunnelPort auto`.
            // We neutralise those listeners with `SOCKSPort 0` / `HTTPTunnelPort 0` in
            // the regular torrc instead (see TorConfig.kt).

            startTorService()

            socksPort
        } catch (e: Exception) {
            Log.e(TAG, "Failed to start Tor", e)
            logHandler.error("Failed to start Tor: ${e.message}")
            cleanup()
            unregisterReceivers()
            throw e
        }
    }

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
     * Start upstream tor-android TorService and bind to it.
     */
    private suspend fun startTorService() = suspendCancellableCoroutine<Unit> { continuation ->
        val connection = object : ServiceConnection {
            override fun onServiceConnected(name: ComponentName?, service: IBinder?) {
                Log.d(TAG, "TorService connected")
                val binder = service as? TorService.LocalBinder
                torService = binder?.service

                // Wait for control connection to be available AND for TorService's
                // own controlPortThread to have finished its setup (auth + addRawEventListener
                // + setEvents). TorService.torControlConnection becomes non-null immediately
                // after `new TorControlConnection(...)`, but TorService then calls
                // setEvents([EVENT_STATUS_CLIENT]) — if we race and call our setEvents first,
                // TorService overwrites it and we stop receiving NOTICE/BW/CIRC events.
                // TorService.socksPort is set AFTER its setEvents call, so polling for it
                // gives us a reliable "TorService is done initializing the control port" signal.
                scope.launch {
                    var conn: TorControlConnection? = null
                    var attempts = 0
                    while ((conn == null || TorService.socksPort == -1) && attempts < 60) {
                        delay(500)
                        conn = torService?.torControlConnection
                        attempts++
                        // Bail early if upstream gave up (typically due to a torrc
                        // parse error caught by `tor --verify-config`).
                        if (lastUpstreamStatus == TorService.STATUS_OFF ||
                            lastUpstreamStatus == TorService.STATUS_STOPPING) {
                            break
                        }
                    }

                    if (conn != null && TorService.socksPort != -1) {
                        controlConnection = conn
                        try {
                            setupControlConnection(conn)
                            if (continuation.isActive) {
                                continuation.resume(Unit)
                            }
                        } catch (e: Exception) {
                            if (continuation.isActive) {
                                continuation.resumeWithException(e)
                            }
                        }
                    } else {
                        val error = Exception(
                            "Failed to get fully-initialized control connection " +
                                "(conn=${conn != null}, torServiceSocksPort=${TorService.socksPort}, " +
                                "upstreamStatus=$lastUpstreamStatus). " +
                                "If upstreamStatus is STOPPING/OFF, tor likely rejected the torrc — check logcat for TorService."
                        )
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
                torEventListener = null
            }
        }

        torServiceConnection = connection

        val intent = Intent(context, org.torproject.jni.TorService::class.java)

        try {
            context.startService(intent)
            context.bindService(intent, connection, Context.BIND_AUTO_CREATE)
        } catch (e: Exception) {
            if (continuation.isActive) {
                continuation.resumeWithException(e)
            }
        }
    }

    /**
     * Setup control connection and event listeners.
     * Order: discover real SOCKS port → register listener → subscribe events → enable network.
     */
    private fun setupControlConnection(conn: TorControlConnection) {
        try {
            logHandler.notice("Connected to Tor control port")

            // Wire up event listener BEFORE enabling network so we don't miss bootstrap
            // notices. Created as a field to keep a strong reference (avoids GC).
            torEventListener = TorEventListener()
            conn.addRawEventListener(torEventListener)

            // EVENT_STATUS_CLIENT must be included — upstream TorService relies on it
            // internally to detect circuit-established and broadcast STATUS_ON.
            conn.setEvents(listOf(
                TorControlCommands.EVENT_OR_CONN_STATUS,
                TorControlCommands.EVENT_CIRCUIT_STATUS,
                TorControlCommands.EVENT_NOTICE_MSG,
                TorControlCommands.EVENT_WARN_MSG,
                TorControlCommands.EVENT_ERR_MSG,
                TorControlCommands.EVENT_BANDWIDTH_USED,
                TorControlCommands.EVENT_NEW_DESC,
                TorControlCommands.EVENT_ADDRMAP,
                TorControlCommands.EVENT_STATUS_CLIENT
            ))

            // Replace upstream's default SOCKS/HTTP listeners with our own. Upstream's
            // defaults-torrc binds `SOCKSPort 9050|auto` and `HTTPTunnelPort 8118|auto`;
            // a well-known port lets other apps on the device probe / use our SOCKS proxy,
            // so we want a random one. We can't disable these in torrc (tor rejects mixing
            // `SocksPort 0` with other SocksPort lines), so SETCONF here:
            //  - SETCONF replaces the listener list (closes prev, opens new).
            //  - `auto` is a bare-port token; SocksPort defaults to binding 127.0.0.1.
            //  - SETCONF is recorded immediately, but listeners only physically bind
            //    once DisableNetwork=0 (see GoLog: "DisableNetwork is set. ... Shutting
            //    down all existing connections.") — so we read the port back AFTER
            //    enabling network below.
            try {
                conn.setConf("HTTPTunnelPort", "0")
            } catch (e: Exception) {
                Log.w(TAG, "Could not disable HTTPTunnelPort", e)
            }
            conn.setConf("SocksPort", "auto")

            // Set isRunning=true BEFORE enabling network so status is consistent
            // when bootstrap events start arriving.
            synchronized(statusLock) {
                isRunning = true
            }
            logHandler.notice("Tor started successfully")
            sendStatusUpdate()

            Log.d(TAG, "Control connection setup complete, enabling network")
            conn.setConf("DisableNetwork", "0")

            // Now that listeners are physically bound, discover the random port tor
            // chose. Poll briefly — binding takes a few hundred ms after enabling net.
            socksPort = awaitSocksListener(conn)
            if (socksPort <= 0) {
                throw IllegalStateException("Failed to discover SOCKS listener after enabling network")
            }
            Log.d(TAG, "Bound random SOCKS port: $socksPort")
            logHandler.notice("SOCKS port: $socksPort")
            sendStatusUpdate()

            startBootstrapPoller(conn)
        } catch (e: Exception) {
            Log.e(TAG, "Failed to setup control connection", e)
            logHandler.error("Control connection error: ${e.message}")
            synchronized(statusLock) {
                isRunning = false
            }
            torEventListener = null
            throw e
        }
    }

    /**
     * Poll `getInfo("status/bootstrap-phase")` until progress reaches 100, the
     * connection is gone, or tor stops. This is a fallback for the intermittent
     * issue where NOTICE / STATUS_CLIENT events are silently not delivered to
     * our raw event listener even though tor accepted SETEVENTS for them.
     *
     * Reply format: `NOTICE BOOTSTRAP PROGRESS=85 TAG=loading_descriptors SUMMARY="..."`
     */
    private fun startBootstrapPoller(conn: TorControlConnection) {
        bootstrapPollJob?.cancel()
        bootstrapPollJob = scope.launch {
            try {
                while (isActive && isRunning && controlConnection === conn) {
                    val info = try {
                        conn.getInfo("status/bootstrap-phase")
                    } catch (e: Exception) {
                        Log.w(TAG, "bootstrap-phase poll failed", e)
                        null
                    }
                    if (info != null) {
                        val progress = Regex("""PROGRESS=(\d+)""").find(info)
                            ?.groupValues?.get(1)?.toIntOrNull() ?: -1
                        if (progress >= 0) {
                            val changed = synchronized(statusLock) {
                                if (progress > bootstrapProgress) {
                                    bootstrapProgress = progress
                                    true
                                } else false
                            }
                            if (changed) {
                                sendStatusUpdate()
                                if (progress == 100) {
                                    logHandler.notice("Tor is ready!")
                                    break
                                }
                            } else if (progress == 100) {
                                break
                            }
                        }
                    }
                    delay(750)
                }
            } finally {
                Log.d(TAG, "Bootstrap poller exiting")
            }
        }
    }

    private fun awaitSocksListener(conn: TorControlConnection): Int {
        val deadline = System.currentTimeMillis() + 5_000L
        while (System.currentTimeMillis() < deadline) {
            val port = parseSocksPort(conn.getInfo("net/listeners/socks"))
            if (port > 0) return port
            Thread.sleep(100)
        }
        return -1
    }

    /**
     * Parse `net/listeners/socks` reply, e.g. `"127.0.0.1:43251"` or
     * `"127.0.0.1:43251" "127.0.0.1:9050"`. Returns the first numeric port, or -1.
     */
    private fun parseSocksPort(reply: String?): Int {
        if (reply.isNullOrBlank()) return -1
        val match = Regex("""127\.0\.0\.1:(\d+)""").find(reply) ?: return -1
        return match.groupValues[1].toIntOrNull() ?: -1
    }

    /**
     * Stop Tor and cleanup
     */
    suspend fun stop() = withContext(Dispatchers.IO) {
        Log.d(TAG, "Stopping Tor")
        logHandler.notice("Stopping Tor...")

        val signal = CompletableDeferred<Unit>().also { stopSignal = it }

        try {
            // DON'T call shutdownTor() here - let upstream's onDestroy() handle it,
            // otherwise we get a broken pipe error.
            cleanup()

            // Wait for upstream to broadcast STATUS_OFF (which it does after releasing
            // its static runLock). Without this, the next start() can hang on runLock.lock().
            val arrived = withTimeoutOrNull(STATUS_OFF_TIMEOUT_MS) { signal.await(); true } ?: false
            if (!arrived) {
                Log.w(TAG, "Did not receive STATUS_OFF within ${STATUS_OFF_TIMEOUT_MS}ms — proceeding anyway")
            }

            logHandler.notice("Tor stopped")
        } catch (e: Exception) {
            Log.e(TAG, "Error stopping Tor", e)
            cleanup()
        } finally {
            stopSignal = null
            unregisterReceivers()
        }
    }

    /**
     * Cleanup resources. Safe to call from any thread.
     */
    private fun cleanup() {
        synchronized(statusLock) {
            isRunning = false
            bootstrapProgress = 0
            socksPort = -1
        }

        bootstrapPollJob?.cancel()
        bootstrapPollJob = null

        val conn = controlConnection
        val listener = torEventListener
        if (conn != null) {
            try { conn.setEvents(emptyList()) } catch (_: Exception) {}
            if (listener != null) {
                try { conn.removeRawEventListener(listener) } catch (_: Exception) {}
            }
        }
        torEventListener = null
        controlConnection = null

        // unbindService / stopService are safe from any thread; no need to hop to Main
        // (the previous runBlocking(Dispatchers.Main) wrapper risked deadlocking with
        // the IO-dispatcher caller chain in FlutterTorPlugin.stopTor).
        try {
            torServiceConnection?.let { context.unbindService(it) }
        } catch (e: Exception) {
            Log.w(TAG, "Error unbinding TorService", e)
        }
        torServiceConnection = null

        try {
            context.stopService(Intent(context, org.torproject.jni.TorService::class.java))
        } catch (e: Exception) {
            Log.w(TAG, "Error stopping TorService", e)
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

    fun getStatus(): TorStatus {
        synchronized(statusLock) {
            val status = TorStatus(
                isRunning = isRunning,
                socksPort = if (isRunning) socksPort.toLong() else null,
                bootstrapProgress = bootstrapProgress.toLong(),
                currentCircuit = null, // TODO: track current circuit
                exitNodeCountry = null // TODO: track exit node country
            )

            Log.d(TAG, "getStatus() returning: isRunning=$isRunning, socksPort=$socksPort, bootstrap=$bootstrapProgress")

            return status
        }
    }

    private fun sendStatusUpdate() {
        logHandler.sendStatusChange(getStatus())
    }

    /**
     * Event listener for Tor control port events
     */
    private inner class TorEventListener : RawEventListener {
        override fun onEvent(eventType: String, eventData: String) {
            Log.d(TAG, "ReceivedData: $eventType: $eventData")

            // Bootstrap progress can arrive in two formats:
            //   - EVENT_NOTICE_MSG: "Bootstrapped 85% (loading_descriptors): ..."
            //   - EVENT_STATUS_CLIENT: "NOTICE BOOTSTRAP PROGRESS=85 TAG=... SUMMARY=..."
            val progress = extractBootstrapProgress(eventData)
            if (progress >= 0) {
                val changed = synchronized(statusLock) {
                    if (progress > bootstrapProgress) {
                        bootstrapProgress = progress
                        true
                    } else false
                }
                if (changed) {
                    sendStatusUpdate()
                    if (progress == 100) {
                        logHandler.notice("Tor is ready!")
                    }
                }
            }

            logHandler.handleTorEvent(eventType, eventData)
        }

        private fun extractBootstrapProgress(eventData: String): Int {
            Regex("""Bootstrapped\s+(\d+)%""").find(eventData)?.let {
                return it.groupValues[1].toIntOrNull() ?: -1
            }
            Regex("""BOOTSTRAP\s+PROGRESS=(\d+)""").find(eventData)?.let {
                return it.groupValues[1].toIntOrNull() ?: -1
            }
            return -1
        }
    }

    fun destroy() {
        cleanup()
        unregisterReceivers()
        scope.cancel()
    }
}
