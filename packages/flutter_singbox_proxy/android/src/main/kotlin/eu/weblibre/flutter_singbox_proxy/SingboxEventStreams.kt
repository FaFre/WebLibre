package eu.weblibre.flutter_singbox_proxy

import eu.weblibre.flutter_singbox_proxy.generated.PigeonEventSink
import eu.weblibre.flutter_singbox_proxy.generated.SingboxProxyLogMessage
import eu.weblibre.flutter_singbox_proxy.generated.SingboxProxyRuntimeState
import eu.weblibre.flutter_singbox_proxy.generated.SingboxProxyTunnelState
import eu.weblibre.flutter_singbox_proxy.generated.StreamLogsStreamHandler
import eu.weblibre.flutter_singbox_proxy.generated.StreamStateStreamHandler
import eu.weblibre.flutter_singbox_proxy.generated.StreamTunnelsStreamHandler
import io.flutter.plugin.common.BinaryMessenger

/**
 * The runtime's state, log and tunnel streams, as far as Dart is listening to them.
 *
 * An event only goes out while a listener is attached, and is dropped otherwise — except the
 * tunnel state, which is a standing verdict rather than news: the latest one is kept and
 * handed to each listener as it attaches, so a runtime started before Dart listened (a
 * headless launch, an autostart) does not leave a dead tunnel reading as up. The sinks are
 * touched on the main thread alone: Dart's listen and cancel arrive there, and
 * [SingboxRuntimeManager] posts every event there before it gets to [emitState], [emitLog]
 * or [emitTunnel].
 */
internal class SingboxEventStreams {
    private var stateSink: PigeonEventSink<SingboxProxyRuntimeState>? = null
    private var logSink: PigeonEventSink<SingboxProxyLogMessage>? = null
    private var tunnelSink: PigeonEventSink<SingboxProxyTunnelState>? = null

    /** The last tunnel state sent, or that would have been, for the next listener. */
    private var tunnelState: SingboxProxyTunnelState? = null

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

    val tunnelHandler = object : StreamTunnelsStreamHandler() {
        override fun onListen(p0: Any?, sink: PigeonEventSink<SingboxProxyTunnelState>) {
            tunnelSink = sink
            tunnelState?.let(sink::success)
        }

        override fun onCancel(p0: Any?) {
            tunnelSink = null
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
        StreamTunnelsStreamHandler.register(messenger, tunnelHandler)
    }

    /** Drop the listeners of an engine that is going away. */
    fun detach() {
        stateSink = null
        logSink = null
        tunnelSink = null
    }

    fun emitState(state: SingboxProxyRuntimeState) {
        stateSink?.success(state)
    }

    fun emitLog(message: SingboxProxyLogMessage) {
        logSink?.success(message)
    }

    fun emitTunnel(state: SingboxProxyTunnelState) {
        tunnelState = state
        tunnelSink?.success(state)
    }
}
