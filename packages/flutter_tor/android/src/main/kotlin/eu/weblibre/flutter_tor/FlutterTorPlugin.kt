package eu.weblibre.flutter_tor

import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.ServiceConnection
import android.os.IBinder
import android.util.Log
import androidx.core.content.ContextCompat
import eu.weblibre.flutter_tor.generated.IPtProxyController
import eu.weblibre.flutter_tor.generated.TorApi
import eu.weblibre.flutter_tor.generated.TorConfiguration
import eu.weblibre.flutter_tor.generated.TorStatus
import io.flutter.embedding.engine.plugins.FlutterPlugin
import kotlinx.coroutines.*
import java.io.File

/**
 * FlutterTorPlugin - Main plugin class
 * Implements Pigeon-generated TorApi and manages TorService
 */
class FlutterTorPlugin : FlutterPlugin, TorApi {

    companion object {
        private const val TAG = "FlutterTorPlugin"
        // Increased timeout to 60 seconds to account for native TorService binding
        // which can take 30+ seconds during initial setup
        private const val SERVICE_CONNECTION_TIMEOUT_MS = 60000L
    }

    private var context: Context? = null
    private var binaryMessenger: io.flutter.plugin.common.BinaryMessenger? = null
    private var torService: TorService? = null
    private var serviceConnection: ServiceConnection? = null
    private val scope = CoroutineScope(Dispatchers.Main + SupervisorJob())

    // Service connection state
    @Volatile
    private var serviceConnected = CompletableDeferred<Unit>()

    private fun startTorService(ctx: Context) {
        val intent = Intent(ctx, TorService::class.java).apply {
            action = TorService.ACTION_START
        }
        ContextCompat.startForegroundService(ctx, intent)
    }

    private fun rebindTorService(createIfNeeded: Boolean) {
        Log.w(TAG, "Rebinding TorService (createIfNeeded=$createIfNeeded)")
        unbindTorService()
        serviceConnected = CompletableDeferred()
        bindTorService(createIfNeeded)
    }

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        Log.d(TAG, "onAttachedToEngine")
        val appContext = flutterPluginBinding.applicationContext
        context = appContext
        binaryMessenger = flutterPluginBinding.binaryMessenger

        // Setup Pigeon API
        TorApi.setUp(flutterPluginBinding.binaryMessenger, this)
        // PT control is needed before TorService is bound (for MOAT bridge
        // discovery), so expose it at engine attach time using the process-wide
        // singleton controller.
        IPtProxyController.setUp(
            flutterPluginBinding.binaryMessenger,
            ProxyImpl(
                controller = PluggableTransportManager.getInstance(appContext).controller,
            ),
        )

        // Reconnect to an already-running TorService without creating a new idle instance.
        bindTorService(createIfNeeded = false)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        Log.d(TAG, "onDetachedFromEngine")

        // Cleanup Pigeon API
        TorApi.setUp(binding.binaryMessenger, null)
        IPtProxyController.setUp(binding.binaryMessenger, null)

        // Unbind service
        unbindTorService()

        // Cancel coroutines
        scope.cancel()

        context = null
        binaryMessenger = null
    }

    /**
     * Bind to TorService. Idempotent — used both for initial bind and rebind on disconnect.
     */
    private fun bindTorService(createIfNeeded: Boolean) {
        val ctx = context ?: return
        val messenger = binaryMessenger ?: return
        if (serviceConnection != null) {
            if (createIfNeeded && torService == null) {
                try {
                    Log.d(TAG, "TorService bind pending; requesting foreground start")
                    startTorService(ctx)
                } catch (e: Exception) {
                    Log.e(TAG, "startForegroundService failed during pending bind", e)
                    serviceConnection = null
                }
            }
            return
        }

        val connection = object : ServiceConnection {
            override fun onServiceConnected(name: ComponentName?, service: IBinder?) {
                Log.d(TAG, "TorService connected")
                val binder = service as? TorService.LocalBinder
                torService = binder?.getService()
                torService?.initialize(messenger)

                serviceConnected.complete(Unit)
            }

            override fun onServiceDisconnected(name: ComponentName?) {
                Log.w(TAG, "TorService disconnected — will rebind")
                torService = null
                serviceConnected = CompletableDeferred()
                // Drop the stale ServiceConnection reference so bindTorService() reattempts.
                serviceConnection = null
                scope.launch {
                    delay(500)
                    bindTorService(createIfNeeded = true)
                }
            }
        }

        serviceConnection = connection

        val intent = Intent(ctx, TorService::class.java).apply {
            if (createIfNeeded) {
                action = TorService.ACTION_START
            }
        }

        try {
            if (createIfNeeded) {
                startTorService(ctx)
            }

            val flags = if (createIfNeeded) Context.BIND_AUTO_CREATE else 0
            if (!ctx.bindService(intent, connection, flags)) {
                Log.w(TAG, "bindService returned false (createIfNeeded=$createIfNeeded)")
                serviceConnection = null
            }
        } catch (e: Exception) {
            Log.e(TAG, "bindService failed", e)
            serviceConnection = null
        }
    }

    /**
     * Unbind from TorService
     */
    private fun unbindTorService() {
        serviceConnection?.let { conn ->
            try {
                context?.unbindService(conn)
            } catch (e: Exception) {
                Log.w(TAG, "Error unbinding service", e)
            }
        }
        serviceConnection = null
        torService = null
    }

    /**
     * Wait for service to be connected. Triggers a rebind if needed.
     */
    private suspend fun waitForService(): TorService {
        torService?.let { return it }

        if (serviceConnection == null) {
            bindTorService(createIfNeeded = true)
        } else if (torService == null) {
            Log.d(TAG, "TorService not connected yet; escalating lazy bind")
            bindTorService(createIfNeeded = true)
        }

        val connected = withTimeoutOrNull(5_000L) {
            serviceConnected.await()
            torService
        }
        if (connected != null) {
            return connected
        }

        rebindTorService(createIfNeeded = true)
        return withTimeoutOrNull(SERVICE_CONNECTION_TIMEOUT_MS) {
            serviceConnected.await()
            torService
        } ?: throw Exception("TorService connection timeout")
    }

    // ========== Pigeon TorApi Implementation ==========
    // Note: These methods are now async with callbacks to avoid blocking the main thread

    override fun startTor(config: TorConfiguration, callback: (Result<Long>) -> Unit) {
        Log.d(TAG, "startTor called with transport: ${config.transport}")

        scope.launch {
            try {
                // Wait for service to be connected
                val service = waitForService()

                val socksPort = withContext(Dispatchers.IO) {
                    service.startTor(config)
                }

                val result = socksPort.toLong()
                Log.d(TAG, "Returning SOCKS port to Flutter: $socksPort")
                callback(Result.success(result))
            } catch (e: Exception) {
                Log.e(TAG, "Failed to start Tor", e)
                callback(Result.failure(e))
            }
        }
    }

    override fun stopTor(callback: (Result<Unit>) -> Unit) {
        Log.d(TAG, "stopTor called")

        val service = torService
        if (service == null) {
            callback(Result.success(Unit))
            return
        }

        scope.launch {
            try {
                withContext(Dispatchers.IO) {
                    service.stopTor()
                }
                callback(Result.success(Unit))
            } catch (e: Exception) {
                Log.e(TAG, "Failed to stop Tor", e)
                callback(Result.failure(e))
            }
        }
    }

    override fun getStatus(): TorStatus {
        val service = torService
            ?: return TorStatus(
                isRunning = false,
                socksPort = null,
                bootstrapProgress = 0,
                currentCircuit = null,
                exitNodeCountry = null
            )

        return try {
            service.getStatus()
        } catch (e: Exception) {
            Log.e(TAG, "Failed to get status", e)
            throw e
        }
    }

    override fun requestNewIdentity() {
        Log.d(TAG, "requestNewIdentity called")

        val service = torService
            ?: throw Exception("TorService not initialized")

        try {
            service.requestNewIdentity()
        } catch (e: Exception) {
            Log.e(TAG, "Failed to request new identity", e)
            throw e
        }
    }
}
