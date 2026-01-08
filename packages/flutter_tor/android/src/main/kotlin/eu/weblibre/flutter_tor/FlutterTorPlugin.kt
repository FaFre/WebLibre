package eu.weblibre.flutter_tor

import IPtProxy.Controller
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.ServiceConnection
import android.os.IBinder
import android.util.Log
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
    private var torService: TorService? = null
    private var serviceConnection: ServiceConnection? = null
    private val scope = CoroutineScope(Dispatchers.Main + SupervisorJob())

    // Service connection state
    private var serviceConnected = CompletableDeferred<Unit>()

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        Log.d(TAG, "onAttachedToEngine")
        context = flutterPluginBinding.applicationContext

        // Setup Pigeon API
        TorApi.setUp(flutterPluginBinding.binaryMessenger, this)

        // Bind to TorService
        bindTorService(flutterPluginBinding)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        Log.d(TAG, "onDetachedFromEngine")

        // Cleanup Pigeon API
        TorApi.setUp(binding.binaryMessenger, null)

        // Unbind service
        unbindTorService()

        // Cancel coroutines
        scope.cancel()

        context = null
    }

    /**
     * Bind to TorService
     */
    private fun bindTorService(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        val ctx = context ?: return

        val connection = object : ServiceConnection {
            override fun onServiceConnected(name: ComponentName?, service: IBinder?) {
                Log.d(TAG, "TorService connected")
                val binder = service as? TorService.LocalBinder
                torService = binder?.getService()
                torService?.initialize(flutterPluginBinding.binaryMessenger)

                // Signal that service is connected
                serviceConnected.complete(Unit)
            }

            override fun onServiceDisconnected(name: ComponentName?) {
                Log.w(TAG, "TorService disconnected")
                torService = null

                // Reset connection deferred for potential reconnection
                serviceConnected = CompletableDeferred()
            }
        }

        serviceConnection = connection

        val intent = Intent(ctx, TorService::class.java)
        intent.action = TorService.ACTION_START
        ctx.startService(intent)
        ctx.bindService(intent, connection, Context.BIND_AUTO_CREATE)
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
     * Wait for service to be connected
     */
    private suspend fun waitForService(): TorService {
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
