package eu.weblibre.flutter_singbox_proxy

import eu.weblibre.flutter_singbox_proxy.generated.PigeonEventSink
import eu.weblibre.flutter_singbox_proxy.generated.SingboxProxyLogMessage
import eu.weblibre.flutter_singbox_proxy.generated.SingboxProxyRuntimeState
import eu.weblibre.flutter_singbox_proxy.generated.StreamLogsStreamHandler
import eu.weblibre.flutter_singbox_proxy.generated.StreamStateStreamHandler
import io.flutter.plugin.common.BinaryMessenger

/**
 * The runtime's state and log streams, as far as Dart is listening to them.
 *
 * An event only goes out while a listener is attached, and is dropped otherwise. The sinks
 * are touched on the main thread alone: Dart's listen and cancel arrive there, and
 * [SingboxRuntimeManager] posts every event there before it gets to [emitState] or [emitLog].
 */
internal class SingboxEventStreams {
    private var stateSink: PigeonEventSink<SingboxProxyRuntimeState>? = null
    private var logSink: PigeonEventSink<SingboxProxyLogMessage>? = null

    val stateHandler = object : StreamStateStreamHandler() {
        override fun onListen(p0: Any?, sink: PigeonEventSink<SingboxProxyRuntimeState>) {
            stateSink = sink
        }

        override fun onCancel(p0: Any?) {
            stateSink = null
        }
    }

    val logHandler = object : StreamLogsStreamHandler() {
        override fun onListen(p0: Any?, sink: PigeonEventSink<SingboxProxyLogMessage>) {
            logSink = sink
        }

        override fun onCancel(p0: Any?) {
            logSink = null
        }
    }

    /**
     * Expose the streams on [messenger]
     *
     * Must happen when the engine attaches: an event channel cannot be listened to before its
     * handler exists, and Dart may subscribe as soon as it runs.
     */
    fun register(messenger: BinaryMessenger) {
        StreamStateStreamHandler.register(messenger, stateHandler)
        StreamLogsStreamHandler.register(messenger, logHandler)
    }

    /** Drop the listeners of an engine that is going away. */
    fun detach() {
        stateSink = null
        logSink = null
    }

    fun emitState(state: SingboxProxyRuntimeState) {
        stateSink?.success(state)
    }

    fun emitLog(message: SingboxProxyLogMessage) {
        logSink?.success(message)
    }
}
