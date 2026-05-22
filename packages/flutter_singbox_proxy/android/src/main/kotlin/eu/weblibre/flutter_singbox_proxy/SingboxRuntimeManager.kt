package eu.weblibre.flutter_singbox_proxy

import android.content.Context
import android.os.Handler
import android.os.Looper
import eu.weblibre.flutter_singbox_proxy.generated.SingboxProxyApi
import eu.weblibre.flutter_singbox_proxy.generated.SingboxProxyConfigResult
import eu.weblibre.flutter_singbox_proxy.generated.SingboxProxyLogMessage
import eu.weblibre.flutter_singbox_proxy.generated.SingboxProxyProfile
import eu.weblibre.flutter_singbox_proxy.generated.SingboxProxyRuntimeOptions
import eu.weblibre.flutter_singbox_proxy.generated.SingboxProxyRuntimeEndpoint
import eu.weblibre.flutter_singbox_proxy.generated.SingboxProxyRuntimeState
import eu.weblibre.flutter_singbox_proxy.generated.SingboxProxyRuntimeStatus
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
    private var activeOptions = SingboxProxyRuntimeOptions(
        preferredBasePort = null,
        blockUnmatchedTraffic = true
    )

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
        emitLogMessage(
            SingboxProxyLogMessage(
                level = libboxLogLevelName(level),
                message = message,
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
        runCatching { configBuilder.build(profiles, options) }
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
                    val config = configBuilder.build(profiles, options)

                    if (!libboxRuntime.isAvailable()) {
                        val message = "sing-box libbox runtime is not linked"
                        updateStateLocked(
                            SingboxProxyRuntimeStatus.ERROR,
                            emptyList(),
                            message
                        )
                        throw IllegalStateException(message)
                    }

                    val previousBootstrapDohUrl = activeOptions.bootstrapDohUrl
                    libboxRuntime.setBootstrapDohUrl(options.bootstrapDohUrl)
                    try {
                        libboxRuntime.start(config.configJson)
                    } catch (error: Throwable) {
                        libboxRuntime.setBootstrapDohUrl(previousBootstrapDohUrl)
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
                        val config = configBuilder.build(remaining, activeOptions)
                        // Partial stop keeps activeOptions.bootstrapDohUrl, so
                        // no setBootstrapDohUrl call is needed here — the
                        // libbox bridge already holds the right URL from the
                        // most recent start().
                        libboxRuntime.start(config.configJson)
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
        bootstrapDohUrl = null
    )
}
