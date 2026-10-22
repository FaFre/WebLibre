package eu.weblibre.flutter_singbox_proxy

import android.content.Context
import android.net.ConnectivityManager
import android.net.LinkProperties
import android.net.Network
import android.net.NetworkCapabilities
import android.os.Build
import android.os.Handler
import android.os.HandlerThread
import android.util.Log
import java.net.Inet4Address
import java.net.Inet6Address
import java.net.InetAddress
import java.net.NetworkInterface

/** A network as sing-box's platform interface describes one. */
internal data class PlatformNetworkInterface(
    val index: Int,
    val mtu: Int,
    val name: String,
    /** CIDR prefixes, never carrying an IPv6 zone. See [prefixOf]. */
    val addresses: List<String>,
    /** Raw Linux `IFF_*` flags, which libbox decodes itself. */
    val flags: Int,
    /** One of the `INTERFACE_TYPE_*` constants. */
    val type: Int,
    val dnsServers: List<String>,
    val metered: Boolean,
)

/** The network Android currently routes this app's traffic over. */
internal data class DefaultNetworkInterface(
    val name: String,
    val index: Int,
    val expensive: Boolean,
)

/**
 * Tells sing-box which network the device is on, and when that changes.
 *
 * sing-box only learns about the network through its platform interface. With
 * that stubbed out it never noticed a switch between Wi-Fi and mobile data: open
 * connections stayed on the network that had gone, and a WireGuard endpoint kept
 * sending from a socket bound to the old one, so a tunnel that survived the
 * switch carried nothing until the runtime was restarted (issue #669). A
 * reported change is what makes it reset its connections and have its
 * endpoints rebind.
 */
internal class PlatformNetworkMonitor(context: Context) {
    // Lazy: the runtime is built with a mocked context in host-side tests,
    // where there is no system service to ask for.
    private val connectivity: ConnectivityManager? by lazy {
        context.applicationContext?.getSystemService(ConnectivityManager::class.java)
    }

    private val lock = Any()
    private var callbackThread: HandlerThread? = null
    private var callback: ConnectivityManager.NetworkCallback? = null
    private var reporter: DefaultInterfaceReporter? = null
    private var owner: Any? = null

    /** Every network Android has right now, for sing-box's `getInterfaces`. */
    fun interfaces(): List<PlatformNetworkInterface> {
        val connectivity = connectivity ?: return emptyList()
        return runCatching {
            @Suppress("DEPRECATION") // The replacement needs a callback per network.
            connectivity.allNetworks
                .mapNotNull { network -> describe(connectivity, network) }
                .distinctBy { it.name }
        }.getOrElse { error ->
            Log.w(TAG, "Could not list networks", error)
            emptyList()
        }
    }

    /**
     * Starts reporting the default network to [onDefaultChanged], replacing any
     * earlier registration — every runtime reload brings a new listener.
     *
     * [owner] identifies the sing-box listener the registration is for, so that
     * [stop] from another one leaves it alone.
     */
    fun start(owner: Any?, onDefaultChanged: (DefaultNetworkInterface?) -> Unit) {
        val connectivity = connectivity ?: return
        synchronized(lock) {
            stopLocked()
            this.owner = owner

            val reporter = DefaultInterfaceReporter(onDefaultChanged)
            this.reporter = reporter

            // Reported before returning, while sing-box is still starting. A
            // first report arriving after it has started reads as a change, and
            // a change resets every connection of a runtime that has only just
            // come up. No network is deliberately not reported here: sing-box
            // pauses on it, and a momentarily unknown default network at
            // startup is not worth that — the callback reports the network the
            // moment there is one.
            //
            // One lookup, not the retries the callback makes: this runs on the
            // runtime's one thread, under the lock, inside every start, stop
            // and reload, and an interface missing just after a network switch
            // held all of them for the whole retry window. The callback's own
            // first report, which follows registration, retries off that thread.
            val initial = connectivity.activeNetwork
            initial
                ?.let { defaultInterfaceOf(connectivity, it, retry = false) }
                ?.let(reporter::update)

            val networkCallback = DefaultNetworkCallback(connectivity, reporter, initial)
            try {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    val thread = HandlerThread("singbox-network").apply { start() }
                    callbackThread = thread
                    connectivity.registerDefaultNetworkCallback(
                        networkCallback,
                        Handler(thread.looper),
                    )
                } else {
                    connectivity.registerDefaultNetworkCallback(networkCallback)
                }
                callback = networkCallback
            } catch (error: RuntimeException) {
                // Without it sing-box behaves as it did before this existed:
                // it keeps working, it just does not see network changes.
                Log.w(TAG, "Could not watch the default network", error)
                callbackThread?.quitSafely()
                callbackThread = null
            }
        }
    }

    /**
     * Stops reporting — unless [owner] names a listener other than the one the
     * current registration is for. Every runtime reload starts a new listener,
     * and a late close of the previous instance's must not unregister it: the
     * running instance would never hear of a network change again.
     */
    fun stop(owner: Any? = null) {
        synchronized(lock) {
            val current = this.owner
            if (owner != null && current != null && owner != current) return
            stopLocked()
        }
    }

    private fun stopLocked() {
        owner = null
        reporter?.close()
        reporter = null
        callback?.let { registered ->
            runCatching { connectivity?.unregisterNetworkCallback(registered) }
        }
        callback = null
        callbackThread?.quitSafely()
        callbackThread = null
    }

    private class DefaultNetworkCallback(
        private val connectivity: ConnectivityManager,
        private val reporter: DefaultInterfaceReporter,
        @Volatile private var current: Network?,
    ) : ConnectivityManager.NetworkCallback() {
        override fun onAvailable(network: Network) {
            current = network
            defaultInterfaceOf(connectivity, network)?.let(reporter::update)
        }

        override fun onLinkPropertiesChanged(network: Network, linkProperties: LinkProperties) {
            if (network != current) return
            defaultInterfaceOf(connectivity, network, linkProperties)?.let(reporter::update)
        }

        override fun onLost(network: Network) {
            // A default-network callback hears about the network it currently
            // tracks; a switch arrives as onAvailable for the new one. Only the
            // current one going away leaves the device without a network.
            if (network != current) return
            current = null
            reporter.update(null)
        }
    }

    internal companion object {
        private const val TAG = "SingboxNetworkMonitor"

        // libbox's InterfaceType* constants.
        const val INTERFACE_TYPE_WIFI = 0
        const val INTERFACE_TYPE_CELLULAR = 1
        const val INTERFACE_TYPE_ETHERNET = 2
        const val INTERFACE_TYPE_OTHER = 3

        // Linux <net/if.h>.
        private const val IFF_UP = 0x1
        private const val IFF_BROADCAST = 0x2
        private const val IFF_LOOPBACK = 0x8
        private const val IFF_POINTOPOINT = 0x10
        private const val IFF_RUNNING = 0x40
        private const val IFF_MULTICAST = 0x1000

        private const val INDEX_LOOKUP_ATTEMPTS = 5
        private const val INDEX_LOOKUP_RETRY_MILLIS = 100L

        /**
         * [address] as a `host/prefix` string sing-box can parse, or null when
         * it cannot be written as one.
         *
         * libbox parses these with Go's `netip.MustParsePrefix`, which panics —
         * taking the whole app down — on anything it rejects. The one thing
         * Android hands out that it rejects is a zone: a link-local IPv6
         * address prints as `fe80::1%wlan0`. Rebuilding the address from its
         * bytes drops the zone.
         */
        fun prefixOf(address: InetAddress, prefixLength: Int): String? {
            val bare = when (address) {
                is Inet6Address -> runCatching { InetAddress.getByAddress(address.address) }
                    .getOrNull() ?: return null
                else -> address
            }
            val maxLength = when (bare) {
                is Inet4Address -> 32
                is Inet6Address -> 128
                else -> return null
            }
            // An IPv4-mapped IPv6 address comes back from getByAddress as IPv4,
            // with a prefix length that no longer fits it.
            if (prefixLength !in 0..maxLength) return null

            val host = bare.hostAddress ?: return null
            if (host.contains('%')) return null
            return "$host/$prefixLength"
        }

        /** A DNS server address without its zone, for the same reason. */
        fun hostOf(address: InetAddress): String? {
            val bare = when (address) {
                is Inet6Address -> runCatching { InetAddress.getByAddress(address.address) }
                    .getOrNull() ?: return null
                else -> address
            }
            return bare.hostAddress?.takeUnless { it.contains('%') }
        }

        fun linkFlags(
            up: Boolean,
            broadcast: Boolean,
            loopback: Boolean,
            pointToPoint: Boolean,
            multicast: Boolean,
        ): Int {
            var flags = 0
            if (up) flags = flags or IFF_UP or IFF_RUNNING
            if (broadcast) flags = flags or IFF_BROADCAST
            if (loopback) flags = flags or IFF_LOOPBACK
            if (pointToPoint) flags = flags or IFF_POINTOPOINT
            if (multicast) flags = flags or IFF_MULTICAST
            return flags
        }

        private fun describe(
            connectivity: ConnectivityManager,
            network: Network,
        ): PlatformNetworkInterface? {
            val linkProperties = connectivity.getLinkProperties(network) ?: return null
            val name = linkProperties.interfaceName ?: return null
            val javaInterface = runCatching { NetworkInterface.getByName(name) }.getOrNull()
                ?: return null
            val capabilities = connectivity.getNetworkCapabilities(network)

            return PlatformNetworkInterface(
                index = javaInterface.index,
                mtu = runCatching { javaInterface.mtu }.getOrDefault(0),
                name = name,
                addresses = linkProperties.linkAddresses.mapNotNull { linkAddress ->
                    prefixOf(linkAddress.address, linkAddress.prefixLength)
                },
                flags = linkFlags(
                    up = runCatching { javaInterface.isUp }.getOrDefault(true),
                    broadcast = runCatching {
                        javaInterface.interfaceAddresses.any { it.broadcast != null }
                    }.getOrDefault(false),
                    loopback = runCatching { javaInterface.isLoopback }.getOrDefault(false),
                    pointToPoint = runCatching { javaInterface.isPointToPoint }
                        .getOrDefault(false),
                    multicast = runCatching { javaInterface.supportsMulticast() }
                        .getOrDefault(false),
                ),
                type = interfaceType(capabilities),
                dnsServers = linkProperties.dnsServers.mapNotNull(::hostOf),
                metered = capabilities?.isMetered() ?: false,
            )
        }

        /**
         * The default interface on [network], or null when it cannot be
         * described *right now* — not when there is no network. Callers skip
         * the report instead of passing null on, because sing-box reads a null
         * interface as "offline" and pauses.
         */
        private fun defaultInterfaceOf(
            connectivity: ConnectivityManager,
            network: Network,
            linkProperties: LinkProperties? = null,
            retry: Boolean = true,
        ): DefaultNetworkInterface? {
            val name = (linkProperties ?: connectivity.getLinkProperties(network))
                ?.interfaceName ?: return null
            val attempts = if (retry) INDEX_LOOKUP_ATTEMPTS else 1
            val index = interfaceIndex(name, attempts) ?: run {
                Log.w(TAG, "No interface index for $name; not reporting it")
                return null
            }

            return DefaultNetworkInterface(
                name = name,
                index = index,
                expensive = connectivity.getNetworkCapabilities(network)?.isMetered() ?: false,
            )
        }

        /**
         * The kernel index of [name]. Right after a network comes up the
         * interface can briefly be missing from the list Java reads, so the
         * lookup is retried for a moment before giving up.
         */
        private fun interfaceIndex(name: String, attempts: Int): Int? {
            repeat(attempts) { attempt ->
                val index = runCatching { NetworkInterface.getByName(name)?.index }.getOrNull()
                if (index != null && index > 0) return index
                if (attempt < attempts - 1) Thread.sleep(INDEX_LOOKUP_RETRY_MILLIS)
            }
            return null
        }

        private fun interfaceType(capabilities: NetworkCapabilities?): Int = when {
            capabilities == null -> INTERFACE_TYPE_OTHER
            capabilities.hasTransport(NetworkCapabilities.TRANSPORT_WIFI) -> INTERFACE_TYPE_WIFI
            capabilities.hasTransport(NetworkCapabilities.TRANSPORT_CELLULAR) ->
                INTERFACE_TYPE_CELLULAR
            capabilities.hasTransport(NetworkCapabilities.TRANSPORT_ETHERNET) ->
                INTERFACE_TYPE_ETHERNET
            else -> INTERFACE_TYPE_OTHER
        }

        private fun NetworkCapabilities.isMetered(): Boolean =
            !hasCapability(NetworkCapabilities.NET_CAPABILITY_NOT_METERED)
    }
}

/**
 * Decides which default-network updates are passed on to sing-box.
 *
 * Only a different interface, or losing the network, counts. sing-box ignores a
 * report for the interface it already has (it compares name and index), but
 * still re-reads every interface from Android for each one — and Android
 * repeats capability updates for the same network constantly, on every change
 * in signal strength.
 *
 * Closed once its runtime instance is gone, so a callback still in flight
 * cannot report into a listener sing-box has already let go of.
 */
internal class DefaultInterfaceReporter(
    private val report: (DefaultNetworkInterface?) -> Unit,
) {
    private var reported = false
    private var last: DefaultNetworkInterface? = null

    @Volatile
    private var closed = false

    @Synchronized
    fun update(next: DefaultNetworkInterface?) {
        if (closed) return
        if (reported && last?.name == next?.name && last?.index == next?.index) return

        reported = true
        last = next
        report(next)
    }

    fun close() {
        closed = true
    }
}
