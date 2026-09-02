package eu.weblibre.flutter_singbox_proxy

import android.content.Context
import java.lang.reflect.InvocationHandler
import java.lang.reflect.Method
import java.lang.reflect.Proxy
import java.util.concurrent.ConcurrentHashMap
import java.util.concurrent.atomic.AtomicBoolean

open class LibboxRuntime(
    private val context: Context,
    private val dohResolver: PlatformDohResolver = PlatformDohResolver(),
) {
    private var setupComplete = false
    private var commandServer: Any? = null
    private var commandServerStarted = false
    private var commandClient: Any? = null
    private var logSink: ((Int, String) -> Unit)? = null
    private var logClientThread: Thread? = null

    // Read by the LocalDNSTransport proxy on libbox worker threads, written
    // from the platform thread via setBootstrapDohUrl(). Volatile so the
    // bridge sees the URL configured by the most recent start() call.
    @Volatile
    private var bootstrapDohUrl: String? = null

    private val bootstrapAnnounced = AtomicBoolean(false)

    /**
     * Highest libbox log level worth synthesizing *our own* entries for. Lower
     * numbers are more severe (0 panic … 6 trace).
     *
     * Scoped to [forwardConnectionEvents], which invents info-level lines out
     * of the connection stream — there is no point walking that list when
     * nothing downstream would keep the result. sing-box's own entries are
     * forwarded unfiltered; [SingboxRuntimeManager] is the single gate for
     * those, because it inspects lines it does not forward.
     *
     * Written from the platform thread on start, read on libbox worker
     * threads.
     */
    @Volatile
    private var maxLogLevel: Int = LOG_LEVEL_WARN

    /** See [maxLogLevel]. */
    open fun setMaxLogLevel(level: Int) {
        maxLogLevel = level
    }

    /**
     * Set the DoH endpoint the platform LocalDNSTransport will use for
     * bootstrap lookups. Pass null to disable the bridge (sing-box's broken
     * /etc/resolv.conf path will run, which is rarely what you want on
     * Android).
     */
    open fun setBootstrapDohUrl(url: String?) {
        bootstrapDohUrl = url?.takeIf { it.isNotBlank() }
        bootstrapAnnounced.set(false)
    }

    open fun isAvailable(): Boolean = runCatching {
        Class.forName(LIBBOX_CLASS)
    }.isSuccess

    /**
     * Register a callback that receives every log message emitted by sing-box
     * (level: int, message: String). Pass null to clear. The callback is
     * invoked from a background thread; the receiver must be thread-safe.
     */
    @Synchronized
    open fun setLogSink(sink: ((Int, String) -> Unit)?) {
        logSink = sink
        if (sink == null) {
            disconnectLogClient()
        } else if (commandServer != null) {
            ensureLogClientConnected()
        }
    }

    @Synchronized
    open fun start(configJson: String) {
        ensureSetup()
        val server = commandServer ?: newCommandServer().also { commandServer = it }
        ensureCommandServerStarted(server)
        val overrideOptions = newInstance(OVERRIDE_OPTIONS_CLASS)
        invoke(overrideOptions, "setAutoRedirect", false)
        invoke(overrideOptions, "setIncludePackage", emptyStringIterator())
        invoke(overrideOptions, "setExcludePackage", emptyStringIterator())
        invoke(server, "startOrReloadService", configJson, overrideOptions)
        if (logSink != null) {
            ensureLogClientConnected()
        }
    }

    @Synchronized
    open fun stopService() {
        commandServer?.let { server ->
            runCatching { invoke(server, "closeService") }
        }
        disconnectLogClient()
    }

    @Synchronized
    open fun close() {
        disconnectLogClient()
        commandServer?.let { server ->
            runCatching { invoke(server, "close") }
        }
        commandServer = null
        commandServerStarted = false
    }

    private fun ensureSetup() {
        if (setupComplete) return
        val baseDir = context.filesDir.resolve("singbox_proxy")
        val workingDir = baseDir.resolve("working")
        val tempDir = baseDir.resolve("tmp")
        workingDir.mkdirs()
        tempDir.mkdirs()

        val options = newInstance(SETUP_OPTIONS_CLASS)
        invoke(options, "setBasePath", baseDir.absolutePath)
        invoke(options, "setWorkingPath", workingDir.absolutePath)
        invoke(options, "setTempPath", tempDir.absolutePath)
        invoke(options, "setFixAndroidStack", true)
        invoke(options, "setCommandServerListenPort", 0)
        invoke(options, "setCommandServerSecret", "")
        invoke(options, "setLogMaxLines", 300L)
        invoke(options, "setDebug", false)
        invokeIfAvailable(options, "setCrashReportSource", "flutter_singbox_proxy")
        // sing-box renamed the OOM killer toggle between releases; only one of
        // these exists on the linked libbox AAR, so call whichever responds.
        // The two names say opposite things, so they take opposite arguments —
        // one `true` for both would ask for the killer on half the time.
        if (!invokeIfAvailable(options, "setOomKillerDisabled", true)) {
            invokeIfAvailable(options, "setOomKillerEnabled", false)
        }
        invokeIfAvailable(options, "setOomMemoryLimit", 0L)

        val libbox = Class.forName(LIBBOX_CLASS)
        libbox.getMethod("setup", Class.forName(SETUP_OPTIONS_CLASS)).invoke(null, options)
        setupComplete = true
    }

    private fun newCommandServer(): Any {
        val handlerInterface = Class.forName(COMMAND_SERVER_HANDLER_CLASS)
        val platformInterface = Class.forName(PLATFORM_INTERFACE_CLASS)
        val handler = Proxy.newProxyInstance(
            handlerInterface.classLoader,
            arrayOf(handlerInterface),
            commandServerHandler()
        )
        val platform = Proxy.newProxyInstance(
            platformInterface.classLoader,
            arrayOf(platformInterface),
            platformHandler()
        )
        return Class.forName(COMMAND_SERVER_CLASS)
            .getConstructor(handlerInterface, platformInterface)
            .newInstance(handler, platform)
    }

    private fun ensureCommandServerStarted(server: Any) {
        if (commandServerStarted) return
        invoke(server, "start")
        commandServerStarted = true
    }

    private fun commandServerHandler(): InvocationHandler {
        return InvocationHandler { _, method, args ->
            when (method.name) {
                "getSystemProxyStatus" -> newInstance(SYSTEM_PROXY_STATUS_CLASS).also { status ->
                    invoke(status, "setAvailable", false)
                    invoke(status, "setEnabled", false)
                }
                "serviceReload", "serviceStop", "setSystemProxyEnabled", "writeDebugMessage" -> null
                "triggerNativeCrash" -> throw UnsupportedOperationException("Native crash trigger is disabled")
                else -> defaultValue(method.returnType, args)
            }
        }
    }

    private fun platformHandler(): InvocationHandler {
        return InvocationHandler { _, method, args ->
            when (method.name) {
                "autoDetectInterfaceControl",
                "clearDNSCache",
                "closeDefaultInterfaceMonitor",
                "closeNeighborMonitor",
                "registerMyInterface",
                "sendNotification",
                "startDefaultInterfaceMonitor",
                "startNeighborMonitor" -> null
                "findConnectionOwner" -> newInstance(CONNECTION_OWNER_CLASS).also { owner ->
                    invoke(owner, "setUserId", -1)
                    invoke(owner, "setUserName", "")
                    invoke(owner, "setProcessPath", "")
                    invoke(owner, "setAndroidPackageNames", emptyStringIterator())
                }
                "getInterfaces" -> emptyIterator(NETWORK_INTERFACE_ITERATOR_CLASS)
                "includeAllNetworks",
                "underNetworkExtension",
                "usePlatformAutoDetectInterfaceControl",
                "useProcFS" -> false
                "localDNSTransport" -> createLocalDnsTransport()
                "openTun" -> throw UnsupportedOperationException("TUN is not supported by WebLibre proxy routing")
                "readWIFIState" -> Class.forName(WIFI_STATE_CLASS)
                    .getConstructor(String::class.java, String::class.java)
                    .newInstance("", "")
                "systemCertificates" -> emptyStringIterator()
                else -> defaultValue(method.returnType, args)
            }
        }
    }

    private fun ensureLogClientConnected() {
        if (commandClient != null) return
        val handlerInterface = runCatching {
            Class.forName(COMMAND_CLIENT_HANDLER_CLASS)
        }.getOrNull() ?: return
        val optionsClass = runCatching {
            Class.forName(COMMAND_CLIENT_OPTIONS_CLASS)
        }.getOrNull() ?: return
        val clientClass = runCatching {
            Class.forName(COMMAND_CLIENT_CLASS)
        }.getOrNull() ?: return

        val handler = Proxy.newProxyInstance(
            handlerInterface.classLoader,
            arrayOf(handlerInterface),
            commandClientHandler()
        )
        val options = optionsClass.getConstructor().newInstance()
        // Subscribe to the log stream (CommandLog == 0 in sing-box/libbox).
        invoke(options, "addCommand", 0)
        // Subscribe to connection events (CommandConnections == 4). Some
        // transports, including WireGuard endpoint routing, don't emit useful
        // per-connection lines through the regular log stream.
        invoke(options, "addCommand", 4)
        val client = clientClass
            .getConstructor(handlerInterface, optionsClass)
            .newInstance(handler, options)
        commandClient = client

        // Connect dials the local command socket with retries; do it off the
        // platform thread so we don't block start().
        val thread = Thread({
            runCatching { invoke(client, "connect") }
                .onFailure { error ->
                    logSink?.invoke(3, "sing-box log stream connection failed: ${error.message}")
                }
        }, "singbox-log-client")
        thread.isDaemon = true
        thread.start()
        logClientThread = thread
    }

    private fun disconnectLogClient() {
        val client = commandClient ?: return
        commandClient = null
        runCatching { invoke(client, "disconnect") }
        logClientThread = null
    }

    private fun commandClientHandler(): InvocationHandler {
        return InvocationHandler { _, method, args ->
            when (method.name) {
                "writeLogs" -> {
                    val iterator = args?.firstOrNull()
                    if (iterator != null) {
                        forwardLogIterator(iterator)
                    }
                    null
                }
                "clearLogs",
                "connected",
                "disconnected",
                "setDefaultLogLevel",
                "writeStatus",
                "writeGroups",
                "writeOutbounds",
                "initializeClashMode",
                "updateClashMode" -> null
                "writeConnectionEvents" -> {
                    val events = args?.firstOrNull()
                    if (events != null) {
                        forwardConnectionEvents(events)
                    }
                    null
                }
                else -> defaultValue(method.returnType, args)
            }
        }
    }

    /**
     * Visible for tests: the reflective reads below are duck-typed by method
     * name, so a plain object exposing `hasNext`/`next`/`getLevel`/`getMessage`
     * stands in for a libbox `LogIterator`.
     */
    internal fun forwardLogIterator(iterator: Any) {
        val sink = logSink ?: return
        runCatching {
            while (invoke(iterator, "hasNext") as? Boolean == true) {
                val entry = invoke(iterator, "next") ?: continue
                val level = (runCatching { invoke(entry, "getLevel") }.getOrNull() as? Number)
                    ?.toInt() ?: 0
                val message = runCatching { invoke(entry, "getMessage") }
                    .getOrNull() as? String ?: continue
                // Deliberately unfiltered: every entry is offered to the sink
                // whatever its level, because the sink reads the text of lines
                // it will not forward (the oversized-packet hint keys off a
                // wire error that carries no guaranteed level). The level gate
                // lives downstream in SingboxRuntimeManager, ahead of the
                // main-thread hop that is the part actually worth avoiding.
                // Reflection here is cached, so a dropped line stays cheap.
                sink(level, message)
            }
        }
    }

    private fun forwardConnectionEvents(events: Any) {
        val sink = logSink ?: return
        // Synthesized as info lines below, so they answer to the same
        // threshold — and skipping early avoids walking the whole event list.
        if (LOG_LEVEL_INFO > maxLogLevel) return
        runCatching {
            val iterator = invokeFirstAvailableResult(events, listOf("iterator", "Iterator")) ?: return
            while (invoke(iterator, "hasNext") as? Boolean == true) {
                val event = invoke(iterator, "next") ?: continue
                val type = (invokeFirstAvailableResult(event, listOf("getType", "type")) as? Number)
                    ?.toInt() ?: continue
                if (type != CONNECTION_EVENT_NEW && type != CONNECTION_EVENT_CLOSED) continue

                val connection = invokeFirstAvailableResult(
                    event,
                    listOf("getConnection", "connection"),
                ) ?: continue
                val eventLabel = if (type == CONNECTION_EVENT_CLOSED) "closed" else "opened"
                sink(4, "connection $eventLabel ${describeConnection(connection)}")
            }
        }
    }

    private fun describeConnection(connection: Any): String {
        val network = stringValue(connection, "getNetwork", "network")
        val source = stringValue(connection, "getSource", "source")
        val destination = stringValue(
            connection,
            "displayDestination",
            "DisplayDestination",
            "getDestination",
            "destination",
        )
        val outbound = stringValue(connection, "getOutbound", "outbound")
        val inbound = stringValue(connection, "getInbound", "inbound")

        return buildString {
            if (network.isNotBlank()) append(network).append(' ')
            if (source.isNotBlank()) append(source).append(" -> ")
            append(destination.ifBlank { "unknown destination" })
            if (outbound.isNotBlank()) append(" via ").append(outbound)
            if (inbound.isNotBlank()) append(" (").append(inbound).append(')')
        }
    }

    private fun stringValue(target: Any, vararg methodNames: String): String {
        return invokeFirstAvailableResult(target, methodNames.toList()) as? String ?: ""
    }

    private fun createLocalDnsTransport(): Any? {
        val iface = runCatching {
            Class.forName(LOCAL_DNS_TRANSPORT_CLASS)
        }.getOrNull() ?: return null

        return Proxy.newProxyInstance(
            iface.classLoader,
            arrayOf(iface),
        ) { _, method, args ->
            when (method.name) {
                "raw" -> true
                "exchange" -> {
                    val ctx = args?.getOrNull(0)
                    val request = args?.getOrNull(1) as? ByteArray
                    if (ctx != null && request != null) {
                        runDohExchange(ctx, request)
                    }
                    null
                }
                // Lookup is only reachable when raw() returns false. We
                // always return true above, so this path is dead.
                "lookup" -> null
                else -> defaultValue(method.returnType, args)
            }
        }
    }

    private fun runDohExchange(ctx: Any, request: ByteArray) {
        val url = bootstrapDohUrl
        if (url == null) {
            // No bootstrap URL configured — return SERVFAIL so sing-box gets a
            // clean failure instead of hanging on a half-initialized bridge.
            logSink?.invoke(3, "DoH bootstrap skipped: no resolver URL configured")
            invokeIfAvailable(ctx, "errorCode", DNS_RCODE_SERVFAIL)
            return
        }

        // One line, once per runtime: it is the only way to tell a bootstrap
        // that is failing from one that sing-box never asked. Without it, both
        // look identical from the log — `context deadline exceeded` and
        // silence on this side.
        if (bootstrapAnnounced.compareAndSet(false, true)) {
            logSink?.invoke(4, "DoH bootstrap resolver active: $url")
        }

        val startedAt = System.nanoTime()
        try {
            val response = dohResolver.exchange(url, request)
            invokeIfAvailable(ctx, "rawSuccess", response)
            val elapsed = elapsedMillis(startedAt)
            // Every lookup the runtime makes waits on this call, and sing-box
            // gives each exchange 10s before reporting `context deadline
            // exceeded` with nothing on our side to explain it. Say so while
            // there is still something to say.
            if (elapsed >= SLOW_EXCHANGE_MILLIS) {
                logSink?.invoke(3, "DoH bootstrap exchange to $url took ${elapsed}ms")
            }
        } catch (error: Throwable) {
            logSink?.invoke(
                3,
                "DoH bootstrap exchange to $url failed after ${elapsedMillis(startedAt)}ms: " +
                    "${error.javaClass.simpleName}: ${error.message ?: "no message"}",
            )
            invokeIfAvailable(ctx, "errorCode", DNS_RCODE_SERVFAIL)
        }
    }

    private fun elapsedMillis(startedAt: Long): Long =
        (System.nanoTime() - startedAt) / 1_000_000

    private fun emptyStringIterator(): Any = emptyIterator(STRING_ITERATOR_CLASS)

    private fun emptyIterator(interfaceName: String): Any {
        val iteratorInterface = Class.forName(interfaceName)
        return Proxy.newProxyInstance(
            iteratorInterface.classLoader,
            arrayOf(iteratorInterface),
        ) { _, method, _ ->
            when (method.name) {
                "hasNext" -> false
                "len" -> 0
                "next" -> null
                else -> defaultValue(method.returnType)
            }
        }
    }

    private fun newInstance(className: String): Any {
        return Class.forName(className).getConstructor().newInstance()
    }

    private fun invoke(target: Any, methodName: String, vararg args: Any?): Any? {
        val method = findMethod(target.javaClass, methodName, args.size)
        return method.invoke(target, *args)
    }

    /** Returns whether [methodName] existed and was called. */
    private fun invokeIfAvailable(
        target: Any,
        methodName: String,
        vararg args: Any?,
    ): Boolean {
        val method = target.javaClass.methods.firstOrNull { candidate ->
            candidate.name == methodName && candidate.parameterTypes.size == args.size
        } ?: return false

        method.invoke(target, *args)
        return true
    }

    private fun invokeFirstAvailable(
        target: Any,
        methodNames: List<String>,
        args: Array<Any?>,
    ) {
        for (name in methodNames) {
            val method = target.javaClass.methods.firstOrNull { candidate ->
                candidate.name == name && candidate.parameterTypes.size == args.size
            }
            if (method != null) {
                method.invoke(target, *args)
                return
            }
        }
    }

    private fun invokeFirstAvailableResult(
        target: Any,
        methodNames: List<String>,
        vararg args: Any?,
    ): Any? {
        for (name in methodNames) {
            val method = target.javaClass.methods.firstOrNull { candidate ->
                candidate.name == name && candidate.parameterTypes.size == args.size
            }
            if (method != null) {
                return method.invoke(target, *args)
            }
        }
        return null
    }

    /**
     * Resolved [findMethod] lookups.
     *
     * `Class.getMethods()` allocates a fresh array on every call, and the log
     * path makes several lookups per entry on a stream that can run to
     * thousands of lines a minute. The classes involved (gomobile bindings and
     * JDK proxies) are stable for the process, so the result caches cleanly.
     */
    private val methodCache = ConcurrentHashMap<Triple<Class<*>, String, Int>, Method>()

    private fun findMethod(clazz: Class<*>, methodName: String, argCount: Int): Method {
        val key = Triple(clazz, methodName, argCount)
        methodCache[key]?.let { return it }

        val resolved = clazz.methods.firstOrNull { method ->
            method.name == methodName && method.parameterTypes.size == argCount
        }
        if (resolved != null) {
            methodCache[key] = resolved
            return resolved
        }

        throw NoSuchMethodError(
            "${clazz.name}.$methodName($argCount args) is missing — linked libbox AAR " +
                "may be incompatible. Available '${methodName}' overloads: " +
                clazz.methods
                    .filter { it.name == methodName }
                    .joinToString { "${it.name}(${it.parameterTypes.joinToString { p -> p.simpleName }})" }
                    .ifEmpty { "<none>" }
        )
    }

    private fun defaultValue(returnType: Class<*>, args: Array<Any?>? = null): Any? {
        return when (returnType) {
            java.lang.Boolean.TYPE -> false
            java.lang.Integer.TYPE -> 0
            java.lang.Long.TYPE -> 0L
            java.lang.Float.TYPE -> 0f
            java.lang.Double.TYPE -> 0.0
            java.lang.Void.TYPE -> null
            else -> args?.firstOrNull()
        }
    }

    private companion object {
        const val LIBBOX_CLASS = "io.nekohasekai.libbox.Libbox"
        const val SETUP_OPTIONS_CLASS = "io.nekohasekai.libbox.SetupOptions"
        const val COMMAND_SERVER_CLASS = "io.nekohasekai.libbox.CommandServer"
        const val COMMAND_SERVER_HANDLER_CLASS = "io.nekohasekai.libbox.CommandServerHandler"
        const val PLATFORM_INTERFACE_CLASS = "io.nekohasekai.libbox.PlatformInterface"
        const val LOCAL_DNS_TRANSPORT_CLASS = "io.nekohasekai.libbox.LocalDNSTransport"
        const val DNS_RCODE_SERVFAIL = 2

        /**
         * Worth reporting even on success: sing-box abandons a DNS exchange
         * after 10s, so anything near that is about to start failing.
         */
        const val SLOW_EXCHANGE_MILLIS = 1_500L
        const val OVERRIDE_OPTIONS_CLASS = "io.nekohasekai.libbox.OverrideOptions"
        const val STRING_ITERATOR_CLASS = "io.nekohasekai.libbox.StringIterator"
        const val NETWORK_INTERFACE_ITERATOR_CLASS = "io.nekohasekai.libbox.NetworkInterfaceIterator"
        const val CONNECTION_OWNER_CLASS = "io.nekohasekai.libbox.ConnectionOwner"
        const val SYSTEM_PROXY_STATUS_CLASS = "io.nekohasekai.libbox.SystemProxyStatus"
        const val WIFI_STATE_CLASS = "io.nekohasekai.libbox.WIFIState"
        const val COMMAND_CLIENT_CLASS = "io.nekohasekai.libbox.CommandClient"
        const val COMMAND_CLIENT_HANDLER_CLASS = "io.nekohasekai.libbox.CommandClientHandler"
        const val COMMAND_CLIENT_OPTIONS_CLASS = "io.nekohasekai.libbox.CommandClientOptions"
        // libbox log levels, from sing/common/logger: lower is more severe.
        const val LOG_LEVEL_WARN = 3
        const val LOG_LEVEL_INFO = 4
        const val CONNECTION_EVENT_NEW = 0
        const val CONNECTION_EVENT_CLOSED = 2
    }
}
