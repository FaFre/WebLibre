package eu.weblibre.flutter_singbox_proxy

import android.content.Context
import android.os.Handler
import android.os.Looper
import eu.weblibre.flutter_singbox_proxy.generated.SingboxProxyApi
import eu.weblibre.flutter_singbox_proxy.generated.SingboxProxyConfigResult
import eu.weblibre.flutter_singbox_proxy.generated.SingboxProxyLogLevel
import eu.weblibre.flutter_singbox_proxy.generated.SingboxProxyLogMessage
import eu.weblibre.flutter_singbox_proxy.generated.SingboxProxyProfile
import eu.weblibre.flutter_singbox_proxy.generated.SingboxProxyRuntimeOptions
import eu.weblibre.flutter_singbox_proxy.generated.SingboxProxyRuntimeEndpoint
import eu.weblibre.flutter_singbox_proxy.generated.SingboxProxyRuntimeState
import eu.weblibre.flutter_singbox_proxy.generated.SingboxProxyRuntimeStatus
import java.lang.reflect.InvocationTargetException
import java.util.concurrent.Executors
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.asCoroutineDispatcher
import kotlinx.coroutines.withContext

class SingboxRuntimeManager(
    context: Context,
    private val configBuilder: SingboxConfigBuilder = SingboxConfigBuilder(),
    private val libboxRuntime: LibboxRuntime = LibboxRuntime(context),
    private val onStateChanged: (SingboxProxyRuntimeState) -> Unit = {},
    private val onLogMessage: (SingboxProxyLogMessage) -> Unit = {},
    private val dispatchToMain: ((() -> Unit) -> Unit) = { action ->
        if (Looper.myLooper() == Looper.getMainLooper()) {
            action()
        } else {
            Handler(Looper.getMainLooper()).post(action)
        }
    }
) : SingboxProxyApi {
    // Pigeon dispatches Dart-side calls on the platform thread, but libbox
    // callbacks fire from native threads. Guard all state transitions with
    // a single lock so concurrent stop / start / event paths cannot tear
    // activeProfiles, activeOptions, or `state` against each other.
    private val stateLock = Any()
    private val runtimeExecutor = Executors.newSingleThreadExecutor { runnable ->
        Thread(runnable, "singbox-runtime").apply { isDaemon = true }
    }
    // The suspend entry points hop onto the same single thread, so start / stop
    // keep running one at a time in the order Dart issued them.
    private val runtimeDispatcher = runtimeExecutor.asCoroutineDispatcher()

    private var state = SingboxProxyRuntimeState(
        status = SingboxProxyRuntimeStatus.STOPPED,
        endpoints = emptyList(),
        message = null
    )
    private var activeProfiles = emptyList<SingboxProxyProfile>()

    /**
     * The endpoints of the last instance that ran, kept through a failed start
     * or stop and dropped once the runtime is stopped on purpose.
     *
     * A failed start leaves the runtime in ERROR with its instance closed, and
     * the app answers it by starting the profiles that were running again.
     * Reusing only a RUNNING state's endpoints gave those profiles new ports
     * and credentials on the way back, so everything Gecko still held for
     * them failed to authenticate (issue #671).
     */
    private var lastRunningEndpoints = emptyList<SingboxProxyRuntimeEndpoint>()
    private val oversizedPacketsExplained = java.util.concurrent.atomic.AtomicBoolean(false)

    /**
     * Highest libbox level forwarded to Dart (lower is more severe).
     *
     * The config's `log.level` does not do this job. sing-box applies it to its
     * own writer only — `log/observable.go` guards the early return with
     * `l.platformWriter == nil` and then writes to the platform writer
     * unconditionally — so under libbox every line reaches us regardless. This
     * is the gate that keeps a quiet setting quiet.
     *
     * Written on the runtime executor under [stateLock], read on libbox
     * callback threads.
     */
    @Volatile
    private var maxLogLevel: Int = LIBBOX_LEVEL_WARN
    private var activeOptions = defaultRuntimeOptions()

    init {
        // Forward every sing-box log entry to Dart. libbox levels follow
        // sing/common/logger: 0 = panic, 1 = fatal, 2 = error, 3 = warn,
        // 4 = info, 5 = debug, 6 = trace.
        libboxRuntime.setLogSink { level, message ->
            emitLogMessage(level, message)
        }
    }

    private fun libboxLogLevelName(level: Int): String = when (level) {
        0 -> "panic"
        1 -> "fatal"
        2 -> "error"
        3 -> "warn"
        4 -> "info"
        5 -> "debug"
        6 -> "trace"
        else -> "info"
    }

    private fun emitLogMessage(level: Int, message: String) {
        // Ahead of the gate: the wire error this looks for can arrive at any
        // level, and the explanation it emits is a warning either way.
        maybeExplainOversizedPackets(message)

        if (level > maxLogLevel) return

        emitLogMessage(
            SingboxProxyLogMessage(
                level = libboxLogLevelName(level),
                message = message,
                timestamp = System.currentTimeMillis(),
                profileId = null
            )
        )
    }

    /** libbox threshold for [level]. See [maxLogLevel]. */
    private fun libboxLevelThreshold(level: SingboxProxyLogLevel): Int = when (level) {
        SingboxProxyLogLevel.WARN -> LIBBOX_LEVEL_WARN
        SingboxProxyLogLevel.INFO -> LIBBOX_LEVEL_INFO
        SingboxProxyLogLevel.DEBUG -> LIBBOX_LEVEL_DEBUG
        SingboxProxyLogLevel.TRACE -> LIBBOX_LEVEL_TRACE
    }

    private fun applyLogLevel(level: SingboxProxyLogLevel) {
        val threshold = libboxLevelThreshold(level)
        maxLogLevel = threshold
        libboxRuntime.setMaxLogLevel(threshold)
    }

    /**
     * `sendmsg: message too long` means the encapsulated packet is bigger than
     * the path to the peer accepts, so every full-size packet is dropped at the
     * socket while small ones (a DNS query, a handshake) still go through. That
     * reads as "the tunnel connects but nothing loads", and the wire error says
     * nothing about the setting that fixes it. Said once per run, next to the
     * error it explains.
     */
    private fun maybeExplainOversizedPackets(message: String) {
        if (!message.contains(EMSGSIZE_MARKER, ignoreCase = true)) return
        if (!oversizedPacketsExplained.compareAndSet(false, true)) return

        emitLogMessage(
            SingboxProxyLogMessage(
                level = "warn",
                message = "Packets are too large for this network, and the " +
                    "profile does not allow them to be fragmented. Remove " +
                    "\"udp_fragment\": false from the profile, or lower its MTU " +
                    "(1200 fits almost any network, but below 1280 the tunnel " +
                    "carries no IPv6), and restart the profile.",
                timestamp = System.currentTimeMillis(),
                profileId = null
            )
        )
    }

    private fun emitLogMessage(logMessage: SingboxProxyLogMessage) {
        dispatchToMain {
            onLogMessage(logMessage)
        }
    }

    private fun emitStateChanged(nextState: SingboxProxyRuntimeState) {
        dispatchToMain {
            onStateChanged(nextState)
        }
    }

    private fun statusLogMessage(
        status: SingboxProxyRuntimeStatus,
        message: String
    ) = SingboxProxyLogMessage(
        level = if (status == SingboxProxyRuntimeStatus.ERROR) "warn" else "info",
        message = message,
        timestamp = System.currentTimeMillis(),
        profileId = null
    )

    /**
     * Whether [profile] can run: the builder's own checks first, then
     * sing-box's verdict on a config holding only this profile.
     *
     * The second half is what keeps a broken profile out of a start. Every
     * profile runs in one instance, and an instance whose config sing-box
     * refuses does not start at all — so one bad key or address used to take
     * every other profile down with it, and only at the moment of starting.
     */
    override suspend fun validateProfile(profile: SingboxProxyProfile): String? {
        configBuilder.validateProfile(profile)?.let { return it }
        if (!libboxRuntime.isAvailable()) return null

        return withContext(runtimeDispatcher) {
            val config = try {
                configBuilder.build(listOf(profile), validationOptions())
            } catch (error: IllegalArgumentException) {
                return@withContext error.message ?: error::class.java.simpleName
            }
            libboxRuntime.checkConfig(config.configJson)?.let(SingboxStartFailure::describe)
        }
    }

    /**
     * Resolves [profile]'s peer hostnames through the bootstrap resolver of the
     * running instance, without touching that instance.
     *
     * Every start rebuilds the one instance all profiles share, so a start
     * that fails cuts every working connection for nothing. An unattended
     * retry asks this first and leaves the runtime alone while the lookup that
     * failed it still fails.
     *
     * On the IO pool rather than the runtime thread: each lookup can take a
     * DoH exchange's full timeout, and starts must not queue behind it.
     */
    override suspend fun probeProfile(profile: SingboxProxyProfile): String? {
        val hosts = PeerHostProbe.hostsOf(profile)
        if (hosts.isEmpty()) return null

        return withContext(Dispatchers.IO) {
            hosts.firstOrNull { host ->
                libboxRuntime.resolvesViaBootstrap(host) == false
            }?.let { host -> "Peer address $host does not resolve" }
        }
    }

    /**
     * Options for checking a single profile: nothing optional, except the DNS
     * server every real start has.
     *
     * The app always starts the runtime with a bootstrap URL, which brings the
     * platform `local` server, and a profile may name that server as its
     * `domain_resolver`. Left out, sing-box refuses such a profile with
     * "domain resolver not found" although it runs fine. The URL itself is
     * never dialled: a check only builds the instance.
     */
    private fun validationOptions() = SingboxProxyRuntimeOptions(
        preferredBasePort = null,
        blockUnmatchedTraffic = true,
        bootstrapDohUrl = VALIDATION_BOOTSTRAP_DOH_URL,
        logLevel = SingboxProxyLogLevel.WARN
    )

    override suspend fun buildConfig(
        profiles: List<SingboxProxyProfile>,
        options: SingboxProxyRuntimeOptions
    ): SingboxProxyConfigResult =
        // Feed the running runtime's endpoints back in so the previewed
        // listen_ports match what is actually bound instead of allocating a
        // fresh throwaway set on every call.
        configBuilder.build(profiles, options, reusableEndpoints())

    override suspend fun start(
        profiles: List<SingboxProxyProfile>,
        options: SingboxProxyRuntimeOptions
    ): SingboxProxyRuntimeState {
        return withContext(runtimeDispatcher) {
            synchronized(stateLock) {
                val previousState = state
                runCatching {
                    updateStateLocked(
                        SingboxProxyRuntimeStatus.STARTING,
                        emptyList(),
                        "Building sing-box config"
                    )
                    if (!libboxRuntime.isAvailable()) {
                        val message = "sing-box libbox runtime is not linked"
                        updateStateLocked(
                            SingboxProxyRuntimeStatus.ERROR,
                            emptyList(),
                            message
                        )
                        throw IllegalStateException(message)
                    }

                    // Once per run, and this is where a run begins: the same
                    // profile started again on a network that still cannot
                    // carry its packets deserves the hint again.
                    oversizedPacketsExplained.set(false)

                    val previousBootstrapDohUrl = activeOptions.bootstrapDohUrl
                    val previousLogLevel = activeOptions.logLevel
                    libboxRuntime.setBootstrapDohUrl(options.bootstrapDohUrl)
                    // Applied before the start so the new level also covers the
                    // startup lines this very start produces.
                    applyLogLevel(options.logLevel)
                    val config: SingboxProxyConfigResult
                    try {
                        config = startWithConfigRetries(
                            profiles = profiles,
                            options = options,
                            reusableEndpoints = reusableEndpoints(previousState),
                        )
                    } catch (error: Throwable) {
                        libboxRuntime.setBootstrapDohUrl(previousBootstrapDohUrl)
                        applyLogLevel(previousLogLevel)
                        throw error
                    }
                    // Only commit profiles/options after start() returns without
                    // throwing, so a failed start leaves the previous active set
                    // intact rather than half-replaced.
                    activeProfiles = profiles
                    activeOptions = options
                    updateStateLocked(
                        SingboxProxyRuntimeStatus.RUNNING,
                        config.endpoints,
                        null
                    )
                    state
                }.getOrElse { error ->
                    val failure = SingboxStartFailure.from(error, profiles)
                    updateStateLocked(
                        SingboxProxyRuntimeStatus.ERROR,
                        previousState.endpoints,
                        failure.message
                    )
                    throw failure
                }
            }
        }
    }

    override suspend fun stop(profileIds: List<String>) {
        withContext(runtimeDispatcher) {
            synchronized(stateLock) {
                val previousState = state
                runCatching {
                    val remaining = activeProfiles.filterNot { profile ->
                        profile.id in profileIds
                    }
                    if (remaining.isEmpty()) {
                        libboxRuntime.stopService()
                        activeProfiles = emptyList()
                        activeOptions = defaultRuntimeOptions()
                        libboxRuntime.setBootstrapDohUrl(null)
                        updateStateLocked(
                            SingboxProxyRuntimeStatus.STOPPED,
                            emptyList(),
                            null
                        )
                    } else {
                        // The remaining profiles go down with the old instance
                        // and come back with the new one, exactly as on a
                        // start, so this is announced the same way: published
                        // endpoints would send requests into the reload, where
                        // they fail, instead of having them held for it.
                        updateStateLocked(
                            SingboxProxyRuntimeStatus.STARTING,
                            emptyList(),
                            "Building sing-box config"
                        )
                        // Partial stop keeps activeOptions.bootstrapDohUrl, so
                        // no setBootstrapDohUrl call is needed here — the
                        // libbox bridge already holds the right URL from the
                        // most recent start().
                        val remainingOptions = optionsWithoutProfiles(
                            activeOptions,
                            removedProfileIds = activeProfiles
                                .map { profile -> profile.id }
                                .filter { id -> id in profileIds },
                        )
                        val config = startWithConfigRetries(
                            profiles = remaining,
                            options = remainingOptions,
                            reusableEndpoints = reusableEndpoints(previousState),
                        )
                        activeProfiles = remaining
                        activeOptions = remainingOptions
                        updateStateLocked(
                            SingboxProxyRuntimeStatus.RUNNING,
                            config.endpoints,
                            null
                        )
                    }
                }.getOrElse { error ->
                    // A partial stop is a reload of the remaining profiles, and
                    // fails the way a start does — a WireGuard setup error
                    // carries the device's private key — so it is reported the
                    // same way.
                    val failure = SingboxStartFailure.from(error, activeProfiles)
                    updateStateLocked(
                        SingboxProxyRuntimeStatus.ERROR,
                        previousState.endpoints,
                        failure.message
                    )
                    throw failure
                }
            }
        }
    }

    override suspend fun stopAll() {
        withContext(runtimeDispatcher) {
            synchronized(stateLock) {
                runCatching {
                    libboxRuntime.stopService()
                    activeProfiles = emptyList()
                    activeOptions = defaultRuntimeOptions()
                    libboxRuntime.setBootstrapDohUrl(null)
                    updateStateLocked(
                        SingboxProxyRuntimeStatus.STOPPED,
                        emptyList(),
                        null
                    )
                }.getOrElse { error ->
                    val failure = SingboxStartFailure.stopFailure(error)
                    updateStateLocked(
                        SingboxProxyRuntimeStatus.ERROR,
                        state.endpoints,
                        failure.message
                    )
                    throw failure
                }
            }
        }
    }

    /**
     * [options] without the DNS resolvers bound to [removedProfileIds].
     *
     * The options are built for the profiles a start brings up, and the DNS
     * block routes a resolver through each of them — detoured via the
     * profile's outbound and matched on its inbound. Reused for a smaller set,
     * those resolvers name outbounds that no longer exist, and sing-box refuses
     * the whole config ("outbound detour not found") after the old instance is
     * already closed: stopping one profile took every other one down with it.
     */
    internal fun optionsWithoutProfiles(
        options: SingboxProxyRuntimeOptions,
        removedProfileIds: Collection<String>,
    ): SingboxProxyRuntimeOptions {
        val dnsConfig = options.dnsConfig ?: return options
        if (removedProfileIds.isEmpty()) return options

        val removedOutbounds = removedProfileIds.map(SingboxTagFormat::outboundTag).toSet()
        val removedInbounds = removedProfileIds.map(SingboxTagFormat::inboundTag).toSet()
        val keptServers = dnsConfig.servers.filterNot { server ->
            server.detourTag in removedOutbounds ||
                server.matchOutbounds.any { outbound -> outbound in removedOutbounds } ||
                server.matchInbounds.any { inbound -> inbound in removedInbounds }
        }
        if (keptServers.size == dnsConfig.servers.size) return options

        // With no servers left, the builder falls back to the bootstrap-only
        // block, which is what a start with no resolvers would have had.
        val keptDnsConfig = if (keptServers.isEmpty()) {
            null
        } else {
            dnsConfig.copy(
                servers = keptServers,
                finalServerTag = dnsConfig.finalServerTag?.takeIf { tag ->
                    keptServers.any { server -> server.tag == tag }
                },
            )
        }
        return options.copy(dnsConfig = keptDnsConfig)
    }

    override fun getState(): SingboxProxyRuntimeState = synchronized(stateLock) { state }

    /**
     * The endpoints a start from [from] tries to keep: the running ones, or
     * after a failed start or stop those of the last instance that ran
     * ([lastRunningEndpoints]).
     *
     * After a failure the ports are already released, and the OS may have
     * handed one to someone else since. That costs one attempt: binding it
     * fails, and [startWithConfigRetries] tries again on fresh ports.
     */
    private fun reusableEndpoints(
        from: SingboxProxyRuntimeState = getState(),
    ): List<SingboxProxyRuntimeEndpoint> = when (from.status) {
        SingboxProxyRuntimeStatus.RUNNING -> from.endpoints
        SingboxProxyRuntimeStatus.ERROR -> lastRunningEndpoints
        else -> emptyList()
    }

    private fun startWithConfigRetries(
        profiles: List<SingboxProxyProfile>,
        options: SingboxProxyRuntimeOptions,
        reusableEndpoints: List<SingboxProxyRuntimeEndpoint>,
    ): SingboxProxyConfigResult {
        val maxAttempts = if (options.preferredBasePort == null) 3 else 1
        var lastError: Throwable? = null

        repeat(maxAttempts) { attempt ->
            val config = configBuilder.build(
                profiles,
                options,
                reusableEndpoints = if (attempt == 0) reusableEndpoints else emptyList(),
            )

            try {
                libboxRuntime.start(config.configJson)
                return config
            } catch (error: Throwable) {
                lastError = error
                if (attempt == maxAttempts - 1 || !isLocalInboundBindFailure(error)) {
                    throw error
                }
            }
        }

        throw lastError ?: IllegalStateException("Failed to start sing-box runtime")
    }

    private fun isLocalInboundBindFailure(error: Throwable): Boolean {
        val text = errorChain(error)
            .mapNotNull { it.message }
            .joinToString(" ")
            .lowercase()

        // sing-box prefixes every inbound startup failure with
        // "start inbound/<type>[<tag>]:", so that phrase alone says nothing
        // about port conflicts — matching it would retry (and fully reload the
        // service) for errors no new port could fix.
        return text.contains("address already in use") ||
            (text.contains("bind") && text.contains("listen"))
    }

    private fun errorChain(error: Throwable): Sequence<Throwable> = sequence {
        val seen = mutableSetOf<Throwable>()
        var current: Throwable? = error
        while (current != null && seen.add(current)) {
            yield(current)
            current = when (current) {
                is InvocationTargetException -> current.targetException ?: current.cause
                else -> current.cause
            }
        }
    }

    fun close() {
        runtimeExecutor.execute {
            synchronized(stateLock) {
                runCatching { libboxRuntime.stopService() }
                activeProfiles = emptyList()
                activeOptions = defaultRuntimeOptions()
                libboxRuntime.setBootstrapDohUrl(null)
                libboxRuntime.close()
                lastRunningEndpoints = emptyList()
                state = SingboxProxyRuntimeState(
                    status = SingboxProxyRuntimeStatus.STOPPED,
                    endpoints = emptyList(),
                    message = null
                )
            }
        }
        runtimeExecutor.shutdown()
    }

    private fun updateStateLocked(
        status: SingboxProxyRuntimeStatus,
        endpoints: List<SingboxProxyRuntimeEndpoint>,
        message: String?
    ) {
        when (status) {
            SingboxProxyRuntimeStatus.RUNNING -> lastRunningEndpoints = endpoints
            SingboxProxyRuntimeStatus.STOPPED -> lastRunningEndpoints = emptyList()
            else -> Unit
        }
        state = SingboxProxyRuntimeState(
            status = status,
            endpoints = endpoints,
            message = message
        )
        val snapshot = state
        emitStateChanged(snapshot)
        message?.let { emitLogMessage(statusLogMessage(status, it)) }
    }

    private fun defaultRuntimeOptions() = SingboxProxyRuntimeOptions(
        preferredBasePort = null,
        blockUnmatchedTraffic = true,
        dnsConfig = null,
        bootstrapDohUrl = null,
        logLevel = SingboxProxyLogLevel.WARN
    )

    private companion object {
        // libbox log levels, from sing/common/logger: lower is more severe.
        const val LIBBOX_LEVEL_WARN = 3
        const val LIBBOX_LEVEL_INFO = 4
        const val LIBBOX_LEVEL_DEBUG = 5
        const val LIBBOX_LEVEL_TRACE = 6
        const val EMSGSIZE_MARKER = "message too long"
        const val VALIDATION_BOOTSTRAP_DOH_URL = "https://dns.quad9.net/dns-query"
    }
}
