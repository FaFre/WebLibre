package eu.weblibre.flutter_singbox_proxy

import eu.weblibre.flutter_singbox_proxy.generated.PigeonEventSink
import eu.weblibre.flutter_singbox_proxy.generated.SingboxProxyLogMessage
import eu.weblibre.flutter_singbox_proxy.generated.SingboxProxyRuntimeState
import eu.weblibre.flutter_singbox_proxy.generated.SingboxProxyRuntimeStatus
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
