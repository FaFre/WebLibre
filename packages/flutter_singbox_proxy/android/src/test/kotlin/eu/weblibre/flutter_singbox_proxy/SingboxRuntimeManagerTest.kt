package eu.weblibre.flutter_singbox_proxy

import android.content.Context
import eu.weblibre.flutter_singbox_proxy.generated.FlutterError
import eu.weblibre.flutter_singbox_proxy.generated.SingboxProxyDnsConfig
import eu.weblibre.flutter_singbox_proxy.generated.SingboxProxyDnsServerConfig
import eu.weblibre.flutter_singbox_proxy.generated.SingboxProxyLogLevel
import eu.weblibre.flutter_singbox_proxy.generated.SingboxProxyLogMessage
import eu.weblibre.flutter_singbox_proxy.generated.SingboxProxyProfile
import eu.weblibre.flutter_singbox_proxy.generated.SingboxProxyProfileType
import eu.weblibre.flutter_singbox_proxy.generated.SingboxProxyRuntimeOptions
import eu.weblibre.flutter_singbox_proxy.generated.SingboxProxyRuntimeState
import eu.weblibre.flutter_singbox_proxy.generated.SingboxProxyRuntimeStatus
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertIs
import kotlin.test.assertTrue
import kotlinx.coroutines.runBlocking
import kotlinx.coroutines.withTimeout
import org.json.JSONObject
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
        // Handed to Dart as a start failure carrying sing-box's own reason.
        val failure = assertIs<FlutterError>(failedResult.exceptionOrNull())
        assertEquals(SingboxStartFailure.CODE, failure.code)
        assertEquals("start failed", failure.message)
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
     * Issue #671: starting a second profile rebuilds the whole config. Gecko
     * may still be holding the first profile's endpoint — in requests already
     * resolved, and in transactions it restarts after the reload drops their
     * connection — so that endpoint has to come out of the reload unchanged,
     * credentials included, or every one of them fails authentication.
     */
    @Test
    fun start_keepsRunningProfileCredentialsWhenAddingAnotherProfile() {
        val manager = SingboxRuntimeManager(
            context = mock(Context::class.java),
            libboxRuntime = FakeLibboxRuntime(),
            dispatchToMain = { action -> action() }
        )

        val firstState = manager.awaitStart(
            listOf(profile(id = "profile-a")),
            options = randomPortOptions(),
        ).getOrThrow()
        val secondState = manager.awaitStart(
            listOf(profile(id = "profile-a"), profile(id = "profile-b")),
            options = randomPortOptions(),
        ).getOrThrow()
        manager.close()

        val first = firstState.endpoints.single()
        assertEquals(first, secondState.endpoints.first { it.profileId == "profile-a" })
        val added = secondState.endpoints.first { it.profileId == "profile-b" }
        assertTrue(added.username != first.username)
        assertTrue(added.password != first.password)
    }

    /**
     * A failed start closes the instance and leaves the runtime in ERROR. The
     * app then starts the profiles that were running again, and Gecko is still
     * holding their endpoints — so those must come back unchanged, as they do
     * across a start that works.
     */
    @Test
    fun start_keepsLastRunningEndpointsAcrossAFailedStart() {
        val manager = SingboxRuntimeManager(
            context = mock(Context::class.java),
            libboxRuntime = FakeLibboxRuntime(failOnStartAttempt = 2),
            dispatchToMain = { action -> action() }
        )

        val firstState = manager.awaitStart(
            listOf(profile(id = "profile-a")),
            options = randomPortOptions(),
        ).getOrThrow()
        val failed = manager.awaitStart(
            listOf(profile(id = "profile-a"), profile(id = "profile-b")),
            options = randomPortOptions(),
        )
        val restored = manager.awaitStart(
            listOf(profile(id = "profile-a")),
            options = randomPortOptions(),
        ).getOrThrow()
        manager.close()

        assertTrue(failed.isFailure)
        assertEquals(firstState.endpoints, restored.endpoints)
    }

    @Test
    fun probeProfile_reportsAWireGuardPeerThatDoesNotResolve() {
        val runtime = FakeLibboxRuntime().apply {
            resolvable = mapOf("peer.example" to false, "ok.example" to true)
        }
        val manager = SingboxRuntimeManager(
            context = mock(Context::class.java),
            libboxRuntime = runtime,
            dispatchToMain = { action -> action() }
        )

        val unresolved = runBlocking { manager.probeProfile(wireguard("peer.example")) }
        val resolved = runBlocking { manager.probeProfile(wireguard("ok.example")) }
        val literal = runBlocking { manager.probeProfile(wireguard("192.0.2.1")) }
        val other = runBlocking { manager.probeProfile(profile(id = "profile-a")) }
        manager.close()

        assertEquals("Peer address peer.example does not resolve", unresolved)
        assertEquals(null, resolved)
        // Nothing to look up, and nothing a start would look up either.
        assertEquals(null, literal)
        assertEquals(null, other)
        assertEquals(listOf("peer.example", "ok.example"), runtime.resolvedHosts)
    }

    @Test
    fun start_issuesFreshCredentialsAfterTheRuntimeStopped() {
        val manager = SingboxRuntimeManager(
            context = mock(Context::class.java),
            libboxRuntime = FakeLibboxRuntime(),
            dispatchToMain = { action -> action() }
        )

        val firstState = manager.awaitStart(
            listOf(profile(id = "profile-a")),
            options = randomPortOptions(),
        ).getOrThrow()
        runBlocking { manager.stopAll() }
        val secondState = manager.awaitStart(
            listOf(profile(id = "profile-a")),
            options = randomPortOptions(),
        ).getOrThrow()
        manager.close()

        // Nothing was holding the old endpoint open, so there is nothing to
        // keep it for.
        assertTrue(
            firstState.endpoints.single().password != secondState.endpoints.single().password
        )
    }

    /**
     * Issue #671: stopping one of several profiles reused the last start's
     * options, whose DNS block still routed a resolver through the stopped
     * profile's outbound. sing-box refused that config ("outbound detour not
     * found") after closing the old instance, taking every profile down.
     */
    @Test
    fun stop_dropsTheStoppedProfilesResolvers() {
        val runtime = FakeLibboxRuntime()
        val manager = SingboxRuntimeManager(
            context = mock(Context::class.java),
            libboxRuntime = runtime,
            dispatchToMain = { action -> action() }
        )

        manager.awaitStart(
            listOf(profile(id = "profile-a"), profile(id = "profile-b")),
            options = optionsWithResolversFor("profile-a", "profile-b"),
        ).getOrThrow()
        runBlocking { withTimeout(5_000) { manager.stop(listOf("profile-b")) } }
        val stateAfterStop = manager.getState()
        manager.close()

        assertEquals(SingboxProxyRuntimeStatus.RUNNING, stateAfterStop.status)
        val servers = JSONObject(runtime.lastConfigJson!!)
            .getJSONObject("dns")
            .getJSONArray("servers")
        val tags = (0 until servers.length()).map { servers.getJSONObject(it).getString("tag") }
        assertTrue("browser-doh-profile-a" in tags, "the remaining profile keeps its resolver: $tags")
        assertTrue("browser-doh-profile-b" !in tags, "the stopped profile's resolver must go: $tags")
        assertTrue("browser-doh" in tags)
    }

    /**
     * sing-box's verdict is what keeps a broken profile out of a start: every
     * profile runs in one instance, and one sing-box refuses stops them all.
     */
    @Test
    fun validateProfile_reportsWhatSingboxRefuses() {
        val runtime = FakeLibboxRuntime().apply {
            checkConfigResult = "decode config: invalid key"
        }
        val manager = SingboxRuntimeManager(
            context = mock(Context::class.java),
            libboxRuntime = runtime,
            dispatchToMain = { action -> action() }
        )

        val message = runBlocking { manager.validateProfile(profile(id = "profile-a")) }
        manager.close()

        assertEquals("decode config: invalid key", message)
        assertTrue(runtime.checkedConfigs.single().contains("in-profile-a"))
    }

    @Test
    fun validateProfile_passesWhatSingboxAccepts() {
        val runtime = FakeLibboxRuntime()
        val manager = SingboxRuntimeManager(
            context = mock(Context::class.java),
            libboxRuntime = runtime,
            dispatchToMain = { action -> action() }
        )

        val message = runBlocking { manager.validateProfile(profile(id = "profile-a")) }
        manager.close()

        assertEquals(null, message)
        assertEquals(1, runtime.checkedConfigs.size)
    }

    /**
     * Every real start has the platform `local` DNS server, and a profile may
     * name it as its `domain_resolver` — the check has to have it too.
     */
    @Test
    fun validateProfile_checksWithTheLocalDnsServer() {
        val runtime = FakeLibboxRuntime()
        val manager = SingboxRuntimeManager(
            context = mock(Context::class.java),
            libboxRuntime = runtime,
            dispatchToMain = { action -> action() }
        )

        runBlocking { manager.validateProfile(profile(id = "profile-a")) }
        manager.close()

        val servers = JSONObject(runtime.checkedConfigs.single())
            .getJSONObject("dns")
            .getJSONArray("servers")
        assertEquals("local", servers.getJSONObject(0).getString("tag"))
    }

    @Test
    fun validateProfile_doesNotAskSingboxAboutWhatTheBuilderRejects() {
        val runtime = FakeLibboxRuntime()
        val manager = SingboxRuntimeManager(
            context = mock(Context::class.java),
            libboxRuntime = runtime,
            dispatchToMain = { action -> action() }
        )

        val message = runBlocking {
            manager.validateProfile(profile(id = "profile-a").copy(name = ""))
        }
        manager.close()

        assertEquals("Profile name is required.", message)
        assertTrue(runtime.checkedConfigs.isEmpty())
    }

    @Test
    fun optionsWithoutProfiles_keepsOptionsWithNothingToDrop() {
        val manager = SingboxRuntimeManager(
            context = mock(Context::class.java),
            libboxRuntime = FakeLibboxRuntime(),
            dispatchToMain = { action -> action() }
        )
        val options = optionsWithResolversFor("profile-a")

        assertEquals(options, manager.optionsWithoutProfiles(options, listOf("profile-x")))
        assertEquals(options, manager.optionsWithoutProfiles(options, emptyList()))
        manager.close()
    }

    @Test
    fun stop_keepsRemainingEndpointAndAnnouncesTheReload() {
        val states = mutableListOf<SingboxProxyRuntimeState>()
        val manager = SingboxRuntimeManager(
            context = mock(Context::class.java),
            libboxRuntime = FakeLibboxRuntime(),
            onStateChanged = { states += it },
            dispatchToMain = { action -> action() }
        )

        val runningState = manager.awaitStart(
            listOf(profile(id = "profile-a"), profile(id = "profile-b")),
            options = randomPortOptions(),
        ).getOrThrow()
        states.clear()
        runBlocking { withTimeout(5_000) { manager.stop(listOf("profile-b")) } }
        val stateAfterStop = manager.getState()
        manager.close()

        // The remaining profile restarts with the reload, so the routing has to
        // hold its requests for it rather than send them into the restart.
        assertEquals(
            listOf(SingboxProxyRuntimeStatus.STARTING, SingboxProxyRuntimeStatus.RUNNING),
            states.map { it.status },
        )
        assertEquals(
            listOf(runningState.endpoints.first { it.profileId == "profile-a" }),
            stateAfterStop.endpoints,
        )
    }

    /**
     * A partial stop reloads the remaining profiles, and a WireGuard setup
     * error from that reload carries the device's IPC config, private key
     * included — it must not reach Dart any more than a start's would.
     */
    @Test
    fun stop_redactsTheReasonOfAFailedReload() {
        val manager = SingboxRuntimeManager(
            context = mock(Context::class.java),
            libboxRuntime = FakeLibboxRuntime(
                failOnStartAttempt = 2,
                failureMessage = "setup wireguard: \nprivate_key=0123456789abcdef\n: invalid argument",
            ),
            dispatchToMain = { action -> action() }
        )

        manager.awaitStart(
            listOf(profile(id = "profile-a"), profile(id = "profile-b")),
            options = randomPortOptions(),
        ).getOrThrow()
        val error = runBlocking {
            withTimeout(5_000) { runCatching { manager.stop(listOf("profile-b")) } }
        }.exceptionOrNull()
        val stateAfterStop = manager.getState()
        manager.close()

        val failure = assertIs<FlutterError>(error)
        assertEquals(SingboxStartFailure.CODE, failure.code)
        assertEquals("setup wireguard: invalid argument", failure.message)
        assertEquals(SingboxProxyRuntimeStatus.ERROR, stateAfterStop.status)
        assertEquals("setup wireguard: invalid argument", stateAfterStop.message)
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

private fun wireguard(server: String) = SingboxProxyProfile(
    id = "wireguard",
    name = "wireguard",
    type = SingboxProxyProfileType.WIREGUARD,
    configJson = JSONObject().put("server", server).put("server_port", 51820).toString(),
    secretJson = null
)

/**
 * Options as Dart builds them: a resolver per running profile, detoured
 * through that profile's outbound and matched on its inbound.
 */
private fun optionsWithResolversFor(vararg profileIds: String) = SingboxProxyRuntimeOptions(
    preferredBasePort = null,
    blockUnmatchedTraffic = true,
    dnsConfig = SingboxProxyDnsConfig(
        servers = listOf(
            SingboxProxyDnsServerConfig(
                tag = "browser-doh",
                address = "https://dns.example/dns-query",
                matchDomainSuffixes = emptyList(),
                matchGeosites = emptyList(),
                matchOutbounds = emptyList(),
                matchInbounds = emptyList(),
            ),
        ) + profileIds.map { id ->
            SingboxProxyDnsServerConfig(
                tag = "browser-doh-$id",
                address = "https://dns.example/dns-query",
                detourTag = SingboxTagFormat.outboundTag(id),
                matchDomainSuffixes = emptyList(),
                matchGeosites = emptyList(),
                matchOutbounds = emptyList(),
                matchInbounds = listOf(SingboxTagFormat.inboundTag(id)),
            )
        },
        finalServerTag = "browser-doh",
        domainStrategy = "prefer_ipv4",
    ),
    bootstrapDohUrl = "https://dns.example/dns-query",
    logLevel = SingboxProxyLogLevel.WARN
)

/** Ports picked at random, the only mode in which running ports are reused. */
private fun randomPortOptions() = SingboxProxyRuntimeOptions(
    preferredBasePort = null,
    blockUnmatchedTraffic = true,
    logLevel = SingboxProxyLogLevel.WARN
)

private fun SingboxRuntimeManager.awaitStart(
    profiles: List<SingboxProxyProfile>,
    options: SingboxProxyRuntimeOptions = SingboxProxyRuntimeOptions(
        preferredBasePort = 12080,
        blockUnmatchedTraffic = true,
        logLevel = SingboxProxyLogLevel.WARN
    ),
): Result<SingboxProxyRuntimeState> = runBlocking {
    withTimeout(5_000) { runCatching { start(profiles, options) } }
}

private class FakeLibboxRuntime(
    private val failOnStartAttempt: Int = Int.MAX_VALUE,
    private val failureMessage: String = "start failed",
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

    /** What [checkConfig] answers: null accepts, a message refuses. */
    var checkConfigResult: String? = null

    /** Every config handed to [checkConfig]. */
    val checkedConfigs = mutableListOf<String>()

    override fun checkConfig(configJson: String): String? {
        checkedConfigs += configJson
        return checkConfigResult
    }

    /** The config of the last start attempt, as libbox was handed it. */
    var lastConfigJson: String? = null
        private set

    override fun start(configJson: String) {
        lastConfigJson = configJson
        startAttempts += 1
        if (startAttempts == failOnStartAttempt) {
            throw IllegalStateException(failureMessage)
        }
    }

    override fun stopService() {}

    override fun close() {}

    override fun setLogSink(sink: ((Int, String) -> Unit)?) {
        logSink = sink
    }

    override fun setBootstrapDohUrl(url: String?) {}

    /** What [resolvesViaBootstrap] answers, by host; absent hosts are null. */
    var resolvable: Map<String, Boolean> = emptyMap()

    val resolvedHosts = mutableListOf<String>()

    override fun resolvesViaBootstrap(host: String): Boolean? {
        resolvedHosts += host
        return resolvable[host]
    }
}
