package eu.weblibre.flutter_singbox_proxy

import android.content.Context
import eu.weblibre.flutter_singbox_proxy.generated.SingboxProxyLogLevel
import eu.weblibre.flutter_singbox_proxy.generated.SingboxProxyLogMessage
import eu.weblibre.flutter_singbox_proxy.generated.SingboxProxyProfile
import eu.weblibre.flutter_singbox_proxy.generated.SingboxProxyProfileType
import eu.weblibre.flutter_singbox_proxy.generated.SingboxProxyRuntimeOptions
import eu.weblibre.flutter_singbox_proxy.generated.SingboxProxyRuntimeState
import eu.weblibre.flutter_singbox_proxy.generated.SingboxProxyRuntimeStatus
import java.util.concurrent.CountDownLatch
import java.util.concurrent.TimeUnit
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertIs
import kotlin.test.assertTrue
import org.mockito.Mockito.mock

internal class SingboxRuntimeManagerTest {
    @Test
    fun startFailure_preservesPreviouslyRunningEndpoints() {
        val runtime = FakeLibboxRuntime(failOnStartAttempt = 2)
        val manager = SingboxRuntimeManager(
            context = mock(Context::class.java),
            libboxRuntime = runtime,
            dispatchToMain = { action -> action() }
        )

        val firstState = manager.awaitStart(listOf(profile(id = "profile-a"))).getOrThrow()
        val failedResult = manager.awaitStart(listOf(profile(id = "profile-b")))
        val stateAfterFailure = manager.getState()
        manager.close()

        assertTrue(failedResult.isFailure)
        assertIs<IllegalStateException>(failedResult.exceptionOrNull())
        assertEquals(SingboxProxyRuntimeStatus.ERROR, stateAfterFailure.status)
        assertEquals(firstState.endpoints, stateAfterFailure.endpoints)
        assertEquals("start failed", stateAfterFailure.message)
    }

    @Test
    fun start_reusesRunningProfilePortWhenAddingAnotherProfile() {
        val runtime = FakeLibboxRuntime()
        val manager = SingboxRuntimeManager(
            context = mock(Context::class.java),
            libboxRuntime = runtime,
            dispatchToMain = { action -> action() }
        )

        val firstState = manager.awaitStart(
            listOf(profile(id = "profile-a")),
            options = SingboxProxyRuntimeOptions(
                preferredBasePort = null,
                blockUnmatchedTraffic = true,
                logLevel = SingboxProxyLogLevel.WARN
            )
        ).getOrThrow()
        val secondState = manager.awaitStart(
            listOf(profile(id = "profile-a"), profile(id = "profile-b")),
            options = SingboxProxyRuntimeOptions(
                preferredBasePort = null,
                blockUnmatchedTraffic = true,
                logLevel = SingboxProxyLogLevel.WARN
            )
        ).getOrThrow()
        manager.close()

        val firstPort = firstState.endpoints.single().port
        assertEquals(firstPort, secondState.endpoints.first { it.profileId == "profile-a" }.port)
        assertTrue(secondState.endpoints.first { it.profileId == "profile-b" }.port != firstPort)
    }

    /**
     * The config's `log.level` cannot do this on its own: sing-box only applies
     * it to its own writer, and hands the platform writer — which is what feeds
     * us under libbox — every line regardless. A test that only checked the
     * generated JSON would pass while the log screen still filled up.
     */
    @Test
    fun logSink_dropsEntriesAboveTheConfiguredLevel() {
        val runtime = FakeLibboxRuntime()
        val messages = mutableListOf<SingboxProxyLogMessage>()
        val manager = SingboxRuntimeManager(
            context = mock(Context::class.java),
            libboxRuntime = runtime,
            onLogMessage = { messages += it },
            dispatchToMain = { action -> action() }
        )

        manager.awaitStart(listOf(profile(id = "profile-a"))).getOrThrow()
        messages.clear()

        val sink = runtime.logSink
        assertTrue(sink != null, "manager never installed a log sink")
        sink!!(4, "inbound connection to example.test")
        sink(5, "debug detail")
        sink(3, "something went wrong")
        sink(2, "an error")
        manager.close()

        assertEquals(
            listOf("something went wrong", "an error"),
            messages.map { it.message },
        )
        assertEquals(3, runtime.maxLogLevel)
    }

    /**
     * The oversized-packet hint is the one diagnostic that explains "the tunnel
     * connects but nothing loads", and it keys off text in a line the quiet
     * level does not forward. Today that wire error arrives at error level, but
     * nothing in sing-box promises it stays there — wireguard-go routes some
     * send failures through `Verbosef`, which maps to debug. So the hint must
     * survive a line that is filtered out, not merely a line that happens to be
     * severe enough today.
     */
    @Test
    fun logSink_explainsOversizedPacketsFromAFilteredEntry() {
        val runtime = FakeLibboxRuntime()
        val messages = mutableListOf<SingboxProxyLogMessage>()
        val manager = SingboxRuntimeManager(
            context = mock(Context::class.java),
            libboxRuntime = runtime,
            onLogMessage = { messages += it },
            dispatchToMain = { action -> action() }
        )

        manager.awaitStart(listOf(profile(id = "profile-a"))).getOrThrow()
        messages.clear()

        // Debug level, well above the WARN threshold this started at.
        runtime.logSink!!(5, "peer(abc) - failed to send data packets: sendmsg: message too long")
        manager.close()

        // The offending line itself stays dropped; the explanation it triggers
        // does not.
        assertEquals(1, messages.size)
        assertEquals("warn", messages.single().level)
        assertTrue(
            messages.single().message.contains("MTU"),
            "expected the MTU explanation, got: ${messages.single().message}",
        )
    }

    @Test
    fun logSink_forwardsVerboseEntriesWhenTheLevelAsksForThem() {
        val runtime = FakeLibboxRuntime()
        val messages = mutableListOf<SingboxProxyLogMessage>()
        val manager = SingboxRuntimeManager(
            context = mock(Context::class.java),
            libboxRuntime = runtime,
            onLogMessage = { messages += it },
            dispatchToMain = { action -> action() }
        )

        manager.awaitStart(
            listOf(profile(id = "profile-a")),
            options = SingboxProxyRuntimeOptions(
                preferredBasePort = 12080,
                blockUnmatchedTraffic = true,
                logLevel = SingboxProxyLogLevel.DEBUG
            )
        ).getOrThrow()
        messages.clear()

        val sink = runtime.logSink!!
        sink(4, "inbound connection to example.test")
        sink(5, "debug detail")
        sink(6, "trace detail")
        manager.close()

        assertEquals(
            listOf("inbound connection to example.test", "debug detail"),
            messages.map { it.message },
        )
        assertEquals(5, runtime.maxLogLevel)
    }
}

private fun profile(id: String) = SingboxProxyProfile(
    id = id,
    name = id,
    type = SingboxProxyProfileType.SOCKS,
    configJson = """{"server":"127.0.0.1","server_port":1080}""",
    secretJson = null
)

private fun SingboxRuntimeManager.awaitStart(
    profiles: List<SingboxProxyProfile>,
    options: SingboxProxyRuntimeOptions = SingboxProxyRuntimeOptions(
        preferredBasePort = 12080,
        blockUnmatchedTraffic = true,
        logLevel = SingboxProxyLogLevel.WARN
    ),
): Result<SingboxProxyRuntimeState> {
    val latch = CountDownLatch(1)
    var result: Result<SingboxProxyRuntimeState>? = null

    start(profiles, options) {
        result = it
        latch.countDown()
    }

    assertTrue(latch.await(5, TimeUnit.SECONDS), "Timed out waiting for start callback")
    return result!!
}

private class FakeLibboxRuntime(
    private val failOnStartAttempt: Int = Int.MAX_VALUE,
) : LibboxRuntime(mock(Context::class.java), mock(PlatformDohResolver::class.java)) {
    private var startAttempts = 0

    /** The sink the manager installed, so tests can push lines through it. */
    var logSink: ((Int, String) -> Unit)? = null
        private set

    /** Last threshold handed down, i.e. what the runtime's own filter uses. */
    var maxLogLevel: Int? = null
        private set

    override fun setMaxLogLevel(level: Int) {
        maxLogLevel = level
    }

    override fun isAvailable(): Boolean = true

    override fun start(configJson: String) {
        startAttempts += 1
        if (startAttempts == failOnStartAttempt) {
            throw IllegalStateException("start failed")
        }
    }

    override fun stopService() {}

    override fun close() {}

    override fun setLogSink(sink: ((Int, String) -> Unit)?) {
        logSink = sink
    }

    override fun setBootstrapDohUrl(url: String?) {}
}
