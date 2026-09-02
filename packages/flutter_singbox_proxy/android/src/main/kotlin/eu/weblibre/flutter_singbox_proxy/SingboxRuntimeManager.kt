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

    private var state = SingboxProxyRuntimeState(
        status = SingboxProxyRuntimeStatus.STOPPED,
        endpoints = emptyList(),
        message = null
    )
    private var activeProfiles = emptyList<SingboxProxyProfile>()
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
                message = "Packets are too large for this network. Lower the " +
                    "profile's MTU (1280 is safe almost everywhere; go lower, " +
                    "around 1200, when this device is already on another VPN) " +
                    "and restart the profile.",
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

    override fun validateProfile(
        profile: SingboxProxyProfile,
        callback: (Result<String?>) -> Unit
    ) {
        callback(Result.success(configBuilder.validateProfile(profile)))
    }

    override fun buildConfig(
        profiles: List<SingboxProxyProfile>,
        options: SingboxProxyRuntimeOptions,
        callback: (Result<SingboxProxyConfigResult>) -> Unit
    ) {
        // Feed the running runtime's endpoints back in so the previewed
        // listen_ports match what is actually bound instead of allocating a
        // fresh throwaway set on every call.
        runCatching { configBuilder.build(profiles, options, reusableEndpoints()) }
            .onSuccess { callback(Result.success(it)) }
            .onFailure { callback(Result.failure(it)) }
    }

    override fun start(
        profiles: List<SingboxProxyProfile>,
        options: SingboxProxyRuntimeOptions,
        callback: (Result<SingboxProxyRuntimeState>) -> Unit
    ) {
        runtimeExecutor.execute {
            val result = synchronized(stateLock) {
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
                }.onFailure { error ->
                    updateStateLocked(
                        SingboxProxyRuntimeStatus.ERROR,
                        previousState.endpoints,
                        error.message ?: error::class.java.simpleName
                    )
                }
            }
            dispatchToMain { callback(result) }
        }
    }

    override fun stop(profileIds: List<String>, callback: (Result<Unit>) -> Unit) {
        runtimeExecutor.execute {
            val result = synchronized(stateLock) {
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
                        // Partial stop keeps activeOptions.bootstrapDohUrl, so
                        // no setBootstrapDohUrl call is needed here — the
                        // libbox bridge already holds the right URL from the
                        // most recent start().
                        val config = startWithConfigRetries(
                            profiles = remaining,
                            options = activeOptions,
                            reusableEndpoints = reusableEndpoints(state),
                        )
                        activeProfiles = remaining
                        updateStateLocked(
                            SingboxProxyRuntimeStatus.RUNNING,
                            config.endpoints,
                            null
                        )
                    }
                }.onFailure { error ->
                    updateStateLocked(
                        SingboxProxyRuntimeStatus.ERROR,
                        state.endpoints,
                        error.message ?: error::class.java.simpleName
                    )
                }
            }
            dispatchToMain { callback(result) }
        }
    }

    override fun stopAll(callback: (Result<Unit>) -> Unit) {
        runtimeExecutor.execute {
            val result = synchronized(stateLock) {
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
                }.onFailure { error ->
                    updateStateLocked(
                        SingboxProxyRuntimeStatus.ERROR,
                        state.endpoints,
                        error.message ?: error::class.java.simpleName
                    )
                }
            }
            dispatchToMain { callback(result) }
        }
    }

    override fun getState(): SingboxProxyRuntimeState = synchronized(stateLock) { state }

    /**
     * Ports may only be reused while we still hold them, which is exactly the
     * RUNNING state. The ERROR path deliberately keeps the last endpoints
     * around for reporting, but those ports are already released — reusing
     * them risks binding a port the OS has since handed to someone else.
     */
    private fun reusableEndpoints(
        from: SingboxProxyRuntimeState = getState(),
    ): List<SingboxProxyRuntimeEndpoint> =
        if (from.status == SingboxProxyRuntimeStatus.RUNNING) from.endpoints else emptyList()

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
    }
}
