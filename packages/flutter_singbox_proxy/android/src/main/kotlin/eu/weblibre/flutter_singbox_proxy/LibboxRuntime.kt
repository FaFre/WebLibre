package eu.weblibre.flutter_singbox_proxy

import android.content.Context
import java.lang.reflect.InvocationHandler
import java.lang.reflect.Method
import java.lang.reflect.Proxy

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

    /**
     * Set the DoH endpoint the platform LocalDNSTransport will use for
     * bootstrap lookups. Pass null to disable the bridge (sing-box's broken
     * /etc/resolv.conf path will run, which is rarely what you want on
     * Android).
     */
    open fun setBootstrapDohUrl(url: String?) {
        bootstrapDohUrl = url?.takeIf { it.isNotBlank() }
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
        invokeFirstAvailable(
            options,
            methodNames = listOf("setOomKillerDisabled", "setOomKillerEnabled"),
            args = arrayOf(true),
        )
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

    private fun forwardLogIterator(iterator: Any) {
        val sink = logSink ?: return
        runCatching {
            while (invoke(iterator, "hasNext") as? Boolean == true) {
                val entry = invoke(iterator, "next") ?: continue
                val level = (runCatching { invoke(entry, "getLevel") }.getOrNull() as? Number)
                    ?.toInt() ?: 0
                val message = runCatching { invoke(entry, "getMessage") }
                    .getOrNull() as? String ?: continue
                sink(level, message)
            }
        }
    }

    private fun forwardConnectionEvents(events: Any) {
        val sink = logSink ?: return
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
            invokeIfAvailable(ctx, "errorCode", DNS_RCODE_SERVFAIL)
            return
        }

        try {
            val response = dohResolver.exchange(url, request)
            invokeIfAvailable(ctx, "rawSuccess", response)
        } catch (error: Throwable) {
            logSink?.invoke(3, "DoH bootstrap exchange failed: ${error.message}")
            invokeIfAvailable(ctx, "errorCode", DNS_RCODE_SERVFAIL)
        }
    }

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

    private fun invokeIfAvailable(target: Any, methodName: String, vararg args: Any?) {
        val method = target.javaClass.methods.firstOrNull { candidate ->
            candidate.name == methodName && candidate.parameterTypes.size == args.size
        }
        method?.invoke(target, *args)
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

    private fun findMethod(clazz: Class<*>, methodName: String, argCount: Int): Method {
        return clazz.methods.firstOrNull { method ->
            method.name == methodName && method.parameterTypes.size == argCount
        } ?: throw NoSuchMethodError(
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
        const val OVERRIDE_OPTIONS_CLASS = "io.nekohasekai.libbox.OverrideOptions"
        const val STRING_ITERATOR_CLASS = "io.nekohasekai.libbox.StringIterator"
        const val NETWORK_INTERFACE_ITERATOR_CLASS = "io.nekohasekai.libbox.NetworkInterfaceIterator"
        const val CONNECTION_OWNER_CLASS = "io.nekohasekai.libbox.ConnectionOwner"
        const val SYSTEM_PROXY_STATUS_CLASS = "io.nekohasekai.libbox.SystemProxyStatus"
        const val WIFI_STATE_CLASS = "io.nekohasekai.libbox.WIFIState"
        const val COMMAND_CLIENT_CLASS = "io.nekohasekai.libbox.CommandClient"
        const val COMMAND_CLIENT_HANDLER_CLASS = "io.nekohasekai.libbox.CommandClientHandler"
        const val COMMAND_CLIENT_OPTIONS_CLASS = "io.nekohasekai.libbox.CommandClientOptions"
        const val CONNECTION_EVENT_NEW = 0
        const val CONNECTION_EVENT_CLOSED = 2
    }
}
