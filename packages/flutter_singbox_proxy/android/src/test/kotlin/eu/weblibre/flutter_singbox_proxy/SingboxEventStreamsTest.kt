package eu.weblibre.flutter_singbox_proxy

import eu.weblibre.flutter_singbox_proxy.generated.PigeonEventSink
import eu.weblibre.flutter_singbox_proxy.generated.SingboxProxyLogMessage
import eu.weblibre.flutter_singbox_proxy.generated.SingboxProxyRuntimeState
import eu.weblibre.flutter_singbox_proxy.generated.SingboxProxyRuntimeStatus
import eu.weblibre.flutter_singbox_proxy.generated.SingboxProxyTunnelState
import io.flutter.plugin.common.EventChannel
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertTrue

internal class SingboxEventStreamsTest {
    @Test
    fun events_areDroppedUntilDartListens() {
        val streams = SingboxEventStreams()
        streams.emitState(state("early"))
        streams.emitLog(log("early"))

        val states = RecordingSink()
        val logs = RecordingSink()
        streams.stateHandler.onListen(null, PigeonEventSink(states))
        streams.logHandler.onListen(null, PigeonEventSink(logs))

        assertTrue(states.events.isEmpty())
        assertTrue(logs.events.isEmpty())
    }

    /**
     * The tunnel state is a standing verdict, not news: a runtime that started
     * before Dart listened (a headless launch, an autostart) must not leave a
     * dead tunnel reading as up because its one report went nowhere.
     */
    @Test
    fun tunnelState_reachesAListenerThatComesLate() {
        val streams = SingboxEventStreams()
        streams.emitTunnel(tunnels("wg-a"))
        streams.emitTunnel(tunnels("wg-a", "wg-b"))

        val first = RecordingSink()
        streams.tunnelHandler.onListen(null, PigeonEventSink(first))
        streams.tunnelHandler.onCancel(null)
        val second = RecordingSink()
        streams.tunnelHandler.onListen(null, PigeonEventSink(second))

        assertEquals(listOf<Any?>(tunnels("wg-a", "wg-b")), first.events)
        assertEquals(listOf<Any?>(tunnels("wg-a", "wg-b")), second.events)
    }

    @Test
    fun tunnelState_isNotSentBeforeThereIsOne() {
        val streams = SingboxEventStreams()
        val sink = RecordingSink()

        streams.tunnelHandler.onListen(null, PigeonEventSink(sink))

        assertTrue(sink.events.isEmpty())
    }

    @Test
    fun stateAndLogs_reachOnlyTheirOwnListener() {
        val streams = SingboxEventStreams()
        val states = RecordingSink()
        val logs = RecordingSink()
        streams.stateHandler.onListen(null, PigeonEventSink(states))
        streams.logHandler.onListen(null, PigeonEventSink(logs))

        streams.emitState(state("up"))
        streams.emitLog(log("hello"))

        assertEquals(listOf<Any?>(state("up")), states.events)
        assertEquals(listOf<Any?>(log("hello")), logs.events)
    }

    @Test
    fun events_stopOnceDartCancels() {
        val streams = SingboxEventStreams()
        val states = RecordingSink()
        val logs = RecordingSink()
        streams.stateHandler.onListen(null, PigeonEventSink(states))
        streams.logHandler.onListen(null, PigeonEventSink(logs))

        streams.stateHandler.onCancel(null)
        streams.logHandler.onCancel(null)
        streams.emitState(state("late"))
        streams.emitLog(log("late"))

        assertTrue(states.events.isEmpty())
        assertTrue(logs.events.isEmpty())
    }

    @Test
    fun aNewListener_takesOverFromTheOldOne() {
        val streams = SingboxEventStreams()
        val first = RecordingSink()
        val second = RecordingSink()
        streams.stateHandler.onListen(null, PigeonEventSink(first))
        streams.stateHandler.onListen(null, PigeonEventSink(second))

        streams.emitState(state("up"))

        assertTrue(first.events.isEmpty())
        assertEquals(listOf<Any?>(state("up")), second.events)
    }

    @Test
    fun detach_dropsBothListeners() {
        val streams = SingboxEventStreams()
        val states = RecordingSink()
        val logs = RecordingSink()
        streams.stateHandler.onListen(null, PigeonEventSink(states))
        streams.logHandler.onListen(null, PigeonEventSink(logs))

        streams.detach()
        streams.emitState(state("late"))
        streams.emitLog(log("late"))

        assertTrue(states.events.isEmpty())
        assertTrue(logs.events.isEmpty())
    }
}

private class RecordingSink : EventChannel.EventSink {
    val events = mutableListOf<Any?>()

    override fun success(event: Any?) {
        events += event
    }

    override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) = Unit

    override fun endOfStream() = Unit
}

private fun state(message: String) = SingboxProxyRuntimeState(
    status = SingboxProxyRuntimeStatus.STOPPED,
    endpoints = emptyList(),
    message = message
)

private fun log(message: String) = SingboxProxyLogMessage(
    level = "info",
    message = message,
    timestamp = 1L,
    profileId = null
)

private fun tunnels(vararg profileIds: String) =
    SingboxProxyTunnelState(unansweredProfileIds = profileIds.toList())
