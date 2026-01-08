package eu.weblibre.flutter_tor

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Intent
import android.os.Binder
import android.os.Build
import android.os.IBinder
import android.util.Log
import androidx.core.app.NotificationCompat
import eu.weblibre.flutter_tor.generated.IPtProxyController
import eu.weblibre.flutter_tor.generated.TorConfiguration
import eu.weblibre.flutter_tor.generated.TorStatus
import io.flutter.plugin.common.BinaryMessenger
import kotlinx.coroutines.*

/**
 * Foreground service for running Tor in the background
 * Keeps Tor running even when the app is backgrounded
 */
class TorService : Service() {

    companion object {
        private const val TAG = "TorService"
        private const val NOTIFICATION_ID = 1001
        private const val CHANNEL_ID = "flutter_tor_service"
        const val ACTION_START = "eu.weblibre.flutter_tor.START"
        const val ACTION_STOP = "eu.weblibre.flutter_tor.STOP"
        const val EXTRA_CONFIG = "config"
    }

    private val binder = LocalBinder()
    private var torManager: TorManager? = null
    private var logHandler: LogStreamHandler? = null
    private val scope = CoroutineScope(Dispatchers.Main + SupervisorJob())

    inner class LocalBinder : Binder() {
        fun getService(): TorService = this@TorService
    }

    override fun onBind(intent: Intent?): IBinder {
        return binder
    }

    override fun onCreate() {
        super.onCreate()
        Log.d(TAG, "Service created")
        createNotificationChannel()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        Log.d(TAG, "onStartCommand: ${intent?.action}")

        when (intent?.action) {
            ACTION_START -> {
                // Start in foreground immediately
                startForeground(NOTIFICATION_ID, createNotification("Starting Tor..."))
                // Actual start will be handled via binder methods
            }

            ACTION_STOP -> {
                scope.launch {
                    stopTor()
                    stopSelf()
                }
            }
        }

        return START_STICKY
    }

    /**
     * Initialize the service with Flutter messenger for log streaming
     */
    fun initialize(messenger: BinaryMessenger) {
        if (logHandler == null) {
            logHandler = LogStreamHandler(messenger)
            torManager = TorManager(applicationContext, logHandler!!)

            IPtProxyController.setUp(
                messenger,
                ProxyImpl(controller = torManager!!.pluggableTransportManager.controller)
            )

            Log.d(TAG, "Service initialized with messenger")
        }
    }

    /**
     * Start Tor with configuration
     */
    suspend fun startTor(config: TorConfiguration): Int {
        Log.d(TAG, "Starting Tor...")
        updateNotification("Starting Tor...")

        val manager = torManager ?: throw IllegalStateException("Service not initialized")

        try {
            val socksPort = manager.start(config)
            updateNotification("Tor is running (SOCKS: $socksPort)")
            return socksPort
        } catch (e: Exception) {
            Log.e(TAG, "Failed to start Tor", e)
            updateNotification("Failed to start Tor")
            throw e
        }
    }

    /**
     * Stop Tor
     */
    suspend fun stopTor() {
        Log.d(TAG, "Stopping Tor...")
        updateNotification("Stopping Tor...")

        torManager?.stop()
        updateNotification("Tor stopped")
    }

    /**
     * Get current Tor status
     */
    fun getStatus(): TorStatus {
        return torManager?.getStatus() ?: TorStatus(
            isRunning = false,
            socksPort = null,
            bootstrapProgress = 0,
            currentCircuit = null,
            exitNodeCountry = null
        )
    }

    /**
     * Request new Tor identity
     */
    fun requestNewIdentity() {
        torManager?.requestNewIdentity()
    }

    /**
     * Update notification text
     */
    private fun updateNotification(text: String) {
        val notification = createNotification(text)
        val notificationManager = getSystemService(NOTIFICATION_SERVICE) as NotificationManager
        notificationManager.notify(NOTIFICATION_ID, notification)
    }

    /**
     * Create notification for foreground service
     */
    private fun createNotification(text: String): Notification {
        val intent = packageManager.getLaunchIntentForPackage(packageName)
        val pendingIntent = PendingIntent.getActivity(
            this,
            0,
            intent,
            PendingIntent.FLAG_IMMUTABLE
        )

        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("Tor Service")
            .setContentText(text)
            .setSmallIcon(android.R.drawable.ic_dialog_info) // TODO: Use custom icon
            .setContentIntent(pendingIntent)
            .setOngoing(true)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .build()
    }

    /**
     * Create notification channel (required for Android 8+)
     */
    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "Tor Service",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "Keeps Tor running in the background"
                setShowBadge(false)
            }

            val notificationManager = getSystemService(NOTIFICATION_SERVICE) as NotificationManager
            notificationManager.createNotificationChannel(channel)
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        Log.d(TAG, "Service destroyed")

        scope.launch {
            torManager?.destroy()
        }
        scope.cancel()
    }
}
