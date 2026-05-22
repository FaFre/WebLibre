package eu.weblibre.flutter_singbox_proxy

import android.content.Context
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
}

private fun profile(id: String) = SingboxProxyProfile(
    id = id,
    name = id,
    type = SingboxProxyProfileType.SOCKS,
    configJson = """{"server":"127.0.0.1","server_port":1080}""",
    secretJson = null
)

private fun SingboxRuntimeManager.awaitStart(
    profiles: List<SingboxProxyProfile>
): Result<SingboxProxyRuntimeState> {
    val latch = CountDownLatch(1)
    var result: Result<SingboxProxyRuntimeState>? = null

    start(profiles, SingboxProxyRuntimeOptions(preferredBasePort = 12080, blockUnmatchedTraffic = true)) {
        result = it
        latch.countDown()
    }

    assertTrue(latch.await(5, TimeUnit.SECONDS), "Timed out waiting for start callback")
    return result!!
}

private class FakeLibboxRuntime(
    private val failOnStartAttempt: Int,
) : LibboxRuntime(mock(Context::class.java)) {
    private var startAttempts = 0

    override fun isAvailable(): Boolean = true

    override fun start(configJson: String) {
        startAttempts += 1
        if (startAttempts == failOnStartAttempt) {
            throw IllegalStateException("start failed")
        }
    }

    override fun stopService() {}

    override fun close() {}

    override fun setLogSink(sink: ((Int, String) -> Unit)?) {}

    override fun setBootstrapDohUrl(url: String?) {}
}
