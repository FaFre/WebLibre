package eu.weblibre.flutter_tor

import android.os.Handler
import android.os.Looper
import android.util.Log
import eu.weblibre.flutter_tor.generated.TorLogApi
import eu.weblibre.flutter_tor.generated.TorLogMessage
import eu.weblibre.flutter_tor.generated.TorStatus
import io.flutter.plugin.common.BinaryMessenger

/**
 * Handles streaming logs and status updates from Tor to Flutter
 * All Flutter API calls are posted to the main thread to avoid threading issues
 */
class LogStreamHandler(messenger: BinaryMessenger) {

    companion object {
        private const val TAG = "LogStreamHandler"
    }

    private val torLogApi = TorLogApi(messenger)
    private val mainHandler = Handler(Looper.getMainLooper())

    /**
     * Send a log message to Flutter
     * @param severity Log severity (NOTICE, WARN, ERR, DEBUG)
     * @param message Log message
     */
    fun sendLog(severity: String, message: String) {
        mainHandler.post {
            try {
                val logMessage = TorLogMessage(
                    severity = severity,
                    message = message,
                    timestamp = System.currentTimeMillis()
                )

                torLogApi.onLogMessage(logMessage) { }
            } catch (e: Exception) {
                Log.e(TAG, "Error sending log to Flutter: ${e.message}", e)
            }
        }
    }

    /**
     * Send status change to Flutter
     * @param status Current Tor status
     */
    fun sendStatusChange(status: TorStatus) {
        Log.d(TorManager.Companion.TAG, "sendStatusChange() returning: isRunning=${status.isRunning}, socksPort=${status.socksPort}, bootstrap=${status.bootstrapProgress}")

        mainHandler.post {
            try {
                torLogApi.onStatusChanged(status) { }
            } catch (e: Exception) {
                Log.e(TAG, "Error sending status to Flutter: ${e.message}", e)
            }
        }
    }

    /**
     * Parse and send Tor control port event
     * @param eventType Event type from TorControlConnection (e.g., "NOTICE", "WARN", "ERR", "CIRC", "BW")
     * @param eventData Event data
     */
    fun handleTorEvent(eventType: String, eventData: String) {
        when (eventType) {
            "NOTICE" -> sendLog("NOTICE", eventData)
            "WARN" -> sendLog("WARN", eventData)
            "ERR" -> sendLog("ERR", eventData)
            "DEBUG" -> sendLog("DEBUG", eventData)
            "INFO" -> sendLog("INFO", eventData)
            // Don't log circuit/bandwidth events to UI, they're too verbose
            "CIRC", "ORCONN", "BW", "STREAM", "ADDRMAP", "NEWDESC" -> {
                // These are logged to logcat by TorManager for debugging,
                // but not sent to Flutter UI
            }
            else -> {
                // Unknown event types, log for debugging
                sendLog("DEBUG", "$eventType: $eventData")
            }
        }
    }

    /**
     * Helper to send notice logs
     */
    fun notice(message: String) {
        sendLog("NOTICE", message)
    }

    /**
     * Helper to send warning logs
     */
    fun warn(message: String) {
        sendLog("WARN", message)
    }

    /**
     * Helper to send error logs
     */
    fun error(message: String) {
        sendLog("ERR", message)
    }

    /**
     * Helper to send debug logs
     */
    fun debug(message: String) {
        sendLog("DEBUG", message)
    }
}
