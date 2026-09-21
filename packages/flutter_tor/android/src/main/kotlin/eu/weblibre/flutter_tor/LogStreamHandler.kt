package eu.weblibre.flutter_tor

import android.os.Handler
import android.os.Looper
import android.util.Log
import eu.weblibre.flutter_tor.generated.PigeonEventSink
import eu.weblibre.flutter_tor.generated.StreamLogsStreamHandler
import eu.weblibre.flutter_tor.generated.StreamStatusStreamHandler
import eu.weblibre.flutter_tor.generated.TorLogMessage
import eu.weblibre.flutter_tor.generated.TorStatus
import io.flutter.plugin.common.BinaryMessenger

/**
 * Handles streaming logs and status updates from Tor to Flutter
 * Events only go out while Dart is listening, and are always posted to the main thread
 * to avoid threading issues
 */
class LogStreamHandler {

    companion object {
        private const val TAG = "LogStreamHandler"
    }

    private val mainHandler = Handler(Looper.getMainLooper())

    // Dart's listen and cancel arrive on the main thread, and every send is posted
    // there, so the sinks need no locking.
    private var logSink: PigeonEventSink<TorLogMessage>? = null
    private var statusSink: PigeonEventSink<TorStatus>? = null

    /**
     * Expose the log and status streams on [messenger]
     *
     * Must happen when the engine attaches: an event channel cannot be listened to before
     * its handler exists, and Dart may subscribe long before TorService has connected.
     */
    fun register(messenger: BinaryMessenger) {
        StreamLogsStreamHandler.register(messenger, object : StreamLogsStreamHandler() {
            override fun onListen(p0: Any?, sink: PigeonEventSink<TorLogMessage>) {
                logSink = sink
            }

            override fun onCancel(p0: Any?) {
                logSink = null
            }
        })
        StreamStatusStreamHandler.register(messenger, object : StreamStatusStreamHandler() {
            override fun onListen(p0: Any?, sink: PigeonEventSink<TorStatus>) {
                statusSink = sink
            }

            override fun onCancel(p0: Any?) {
                statusSink = null
            }
        })
    }

    /**
     * Drop the listeners of an engine that is going away
     */
    fun detach() {
        logSink = null
        statusSink = null
    }

    /**
     * Send a log message to Flutter
     * @param severity Log severity (NOTICE, WARN, ERR, DEBUG)
     * @param message Log message
     */
    fun sendLog(severity: String, message: String) {
        mainHandler.post {
            val sink = logSink ?: return@post
            try {
                val logMessage = TorLogMessage(
                    severity = severity,
                    message = message,
                    timestamp = System.currentTimeMillis()
                )

                sink.success(logMessage)
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
        mainHandler.post {
            val sink = statusSink ?: return@post
            try {
                sink.success(status)
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
