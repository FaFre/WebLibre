package eu.weblibre.flutter_mozilla_components.components

import android.content.Context
import android.content.pm.ApplicationInfo
import android.os.Build
import kotlinx.coroutines.CompletableDeferred
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.MainScope
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.launch
import kotlinx.coroutines.withTimeout
import mozilla.components.concept.sync.AccountObserver
import mozilla.components.concept.sync.AuthType
import mozilla.components.concept.sync.Device
import mozilla.components.concept.sync.OAuthAccount
import mozilla.components.concept.sync.Profile
import mozilla.components.concept.sync.TabData
import mozilla.components.browser.storage.sync.PlacesBookmarksStorage
import mozilla.components.browser.storage.sync.PlacesHistoryStorage
import mozilla.components.browser.storage.sync.RemoteTabsStorage
import mozilla.components.concept.sync.ConstellationState
import mozilla.components.concept.sync.DeviceConfig
import mozilla.components.concept.sync.DeviceCapability
import mozilla.components.concept.sync.DeviceConstellationObserver
import mozilla.components.concept.sync.DeviceType
import mozilla.components.feature.accounts.push.SendTabFeature
import mozilla.components.feature.syncedtabs.storage.SyncedTabsStorage
import mozilla.components.service.fxa.PeriodicSyncConfig
import mozilla.components.service.fxa.ServerConfig
import mozilla.components.service.fxa.SyncConfig
import mozilla.components.service.fxa.SyncEngine
import mozilla.components.service.fxa.manager.FxaAccountManager
import mozilla.components.service.fxa.manager.SCOPE_SESSION
import mozilla.components.service.fxa.manager.SCOPE_SYNC
import mozilla.components.service.fxa.manager.SyncEnginesStorage
import mozilla.components.service.fxa.sync.GlobalSyncableStoreProvider
import mozilla.components.service.fxa.sync.SyncReason
import mozilla.components.service.fxa.sync.SyncStatusObserver
import mozilla.components.service.fxa.sync.getLastSynced
import mozilla.components.support.base.log.logger.Logger
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoSyncStateEvents
import eu.weblibre.flutter_mozilla_components.pigeons.SyncAccountInfo
import eu.weblibre.flutter_mozilla_components.pigeons.SyncEngineStatus
import eu.weblibre.flutter_mozilla_components.pigeons.SyncEngineValue
import eu.weblibre.flutter_mozilla_components.feature.ContainerProxyFeature
import eu.weblibre.flutter_mozilla_components.sync.CachedSyncDevice
import eu.weblibre.flutter_mozilla_components.sync.SyncStateCache
import eu.weblibre.flutter_mozilla_components.sync.SyncedTabsIntegration
import mozilla.components.browser.state.store.BrowserStore
import androidx.lifecycle.ProcessLifecycleOwner
import org.mozilla.gecko.util.ThreadUtils.runOnUiThread
import java.util.concurrent.atomic.AtomicBoolean
import java.util.concurrent.atomic.AtomicLong
import java.util.concurrent.TimeUnit

class BackgroundServices(
    private val context: Context,
    private val browserStore: Lazy<BrowserStore>,
    private val historyStorage: Lazy<PlacesHistoryStorage>,
    private val bookmarkStorage: Lazy<PlacesBookmarksStorage>,
    private val remoteTabsStorage: Lazy<RemoteTabsStorage>,
    private val fxaServerOverride: String?,
    private val syncTokenServerOverride: String?,
    private val syncStateEvents: GeckoSyncStateEvents?,
) {
    companion object {
        private const val MIN_STARTUP_SYNC_INTERVAL_MS = 15 * 60 * 1000L
        private val MAX_ACTIVE_TIME_MS = TimeUnit.DAYS.toMillis(14L)

        /**
         * `SecureAbove22AccountStorage`'s two preference files and their keys.
         *
         * Private to mozilla-components, so the names are repeated here. Nothing
         * below writes the account *value* — only a marker in the same files, and
         * only ever to force them to disk — so a rename upstream costs a lost flush
         * and a stale diagnostic, never a corrupted account.
         */
        private const val FXA_SECURE_PREFS_NAME = "fxaStateAC_kp_post_m"
        private const val FXA_STATE_PREFS_NAME = "fxaStatePrefAC"
        private const val FXA_STATE_KEY = "fxaState"
        private const val FXA_STATE_PRESENT_KEY = "fxaStatePresent"

        /**
         * How long to wait for routing before giving up on starting FxA at all.
         * Generous: the cost of waiting is a late sync, the cost of not waiting is
         * a disconnected account.
         */
        private const val ROUTING_WAIT_MS = 30_000L
    }

    data class IncomingTab(
        val title: String,
        val url: String,
        val fromDeviceId: String?,
        val fromDeviceName: String?,
    )

    // Declared ahead of the `init` block below, which logs through it. Kotlin runs
    // property initialisers and init blocks in declaration order.
    private val logger = Logger("BackgroundServices")

    private val incomingTabsLock = Any()
    private val incomingTabsQueue = ArrayDeque<IncomingTab>()
    private val startedSignal = CompletableDeferred<Unit>()
    private val authStateScope = CoroutineScope(SupervisorJob() + Dispatchers.Default)
    private val authStateLock = Any()
    private var lastAuthState: SyncAccountInfo? = null
    private val isDebuggable =
        (context.applicationInfo.flags and ApplicationInfo.FLAG_DEBUGGABLE) != 0

    private val supportedEngines = setOf(
        SyncEngine.History,
        SyncEngine.Bookmarks,
        SyncEngine.Tabs,
    )

    private val syncConfig = SyncConfig(
        supportedEngines,
        periodicSyncConfig = PeriodicSyncConfig(periodMinutes = 240),
    )

    val syncedTabsStorage by lazy {
        SyncedTabsStorage(
            accountManager,
            browserStore.value,
            remoteTabsStorage.value,
            MAX_ACTIVE_TIME_MS,
        )
    }

    val serverConfig: ServerConfig = FxaServer.config(
        context = context,
        serverOverride = fxaServerOverride,
        tokenServerOverride = syncTokenServerOverride,
    )

    private val deviceConfig = DeviceConfig(
        name = "WebLibre ${Build.MANUFACTURER} ${Build.MODEL}",
        type = DeviceType.MOBILE,
        capabilities = setOf(DeviceCapability.SEND_TAB, DeviceCapability.CLOSE_TABS),
        secureStateAtRest = true,
    )

    init {
        GlobalSyncableStoreProvider.configureStore(SyncEngine.History to historyStorage)
        GlobalSyncableStoreProvider.configureStore(SyncEngine.Bookmarks to bookmarkStorage)
        GlobalSyncableStoreProvider.configureStore(SyncEngine.Tabs to remoteTabsStorage)

        reportAccountStorageOnStart()
    }

    private val sequenceCounter = AtomicLong(0)

    /** Last-known profile and devices, so UI reads never depend on the network. */
    internal val syncStateCache by lazy { SyncStateCache(context) }

    private val profileFetchAttempted = AtomicBoolean(false)


    /**
     * What this device was renamed to, until the server is seen agreeing.
     *
     * `refreshDevices()` cannot confirm a rename: it reads app-services' *cached*
     * device list, because AC calls `getDevices()` and that defaults to
     * `ignore_cache = false`. Every refresh after a rename therefore keeps
     * reporting the previous name until that cache expires — which is why the new
     * name only ever appeared after a restart, where there is no cache to read.
     *
     * So the rename is shown on the strength of the server having accepted it,
     * exactly as Fenix does (`AccountSettingsFragment.syncDeviceName` dispatches
     * the typed name and notes the disparity that follows).
     */
    @Volatile
    private var renamedDeviceName: String? = null

    /** The name a rename in this process is still waiting to see confirmed. */
    internal val pendingDeviceName: String? get() = renamedDeviceName

    /** Records a rename the server accepted. */
    internal fun recordDeviceRename(name: String) {
        renamedDeviceName = name
    }

    private val deviceObserver = object : DeviceConstellationObserver {
        override fun onDevicesUpdate(constellation: ConstellationState) {
            cacheConstellation(constellation)
        }
    }

    /**
     * Records a constellation as the fallback for later reads.
     *
     * Called both from [deviceObserver] and from the read paths in `GeckoSyncApiImpl`:
     * the observer can only be registered once an account is authenticated, and a
     * refresh that happened before that still has to land somewhere.
     */
    internal fun cacheConstellation(state: ConstellationState) {
        if (state.currentDevice?.displayName == renamedDeviceName) {
            // The server caught up, so the override has nothing left to say — and
            // must stop shadowing a rename made from another client.
            renamedDeviceName = null
        }

        val devices = (listOfNotNull(state.currentDevice) + state.otherDevices).map { device ->
            CachedSyncDevice(
                deviceId = device.id,
                displayName = device.displayName,
                isCurrentDevice = device.isCurrentDevice,
                canSendTab = device.capabilities.contains(DeviceCapability.SEND_TAB),
            )
        }

        syncStateCache.putDevices(devices)
    }

    /**
     * The name this device registers itself under.
     *
     * The last-resort answer for "what is this device called" — used only when
     * neither the live constellation nor the cache can say anything. It is the name
     * the account manager passes to `initializeDevice`, so it is what the server was
     * told at sign-in; a later rename lives in the cache, which is consulted first.
     * The point is that there is always *a* name, so the setting never reads
     * "Unknown". Fenix seeds the same value for the same reason.
     */
    internal fun localDeviceName(): String = deviceConfig.name

    /**
     * Fetches the account profile when nothing else can name the account.
     *
     * The account manager fetches it exactly once, on reaching `Connected`, and
     * never retries — so a single failed request leaves `accountProfile()` null for
     * the life of the process and the card saying only "Signed in".
     *
     * Bounded to one attempt, re-armed by a completed sync (see the status
     * observer), so a standing failure costs one logged error rather than a stream
     * of them. Once it succeeds the cache answers, including across restarts.
     */
    private fun ensureAccountProfile(account: OAuthAccount) {
        if (accountManager.accountProfile() != null) return
        if (syncStateCache.email() != null) return
        if (!profileFetchAttempted.compareAndSet(false, true)) return

        authStateScope.launch {
            // Returns null rather than throwing on failure.
            val profile = account.getProfile() ?: return@launch

            syncStateCache.putProfile(profile.email, profile.displayName)
            // No [syncing] hint: this completes long after the callback that
            // started it, so the account manager is authoritative again by now.
            dispatchAuthState(account, needsReauth = accountManager.accountNeedsReauth())
        }
    }

    /**
     * The account state as the UI should see it.
     *
     * Deliberately the single builder for both the pushed events and the pulled
     * `getAccountInfo` call: two constructions of this object drift, and a drift
     * here reads as "signed out" on one path and "signed in" on the other.
     */
    internal fun buildAccountInfo(
        account: OAuthAccount?,
        needsReauth: Boolean,
        syncing: Boolean? = null,
    ): SyncAccountInfo {
        // The account manager's *cached* profile, never a fresh fetch. `getProfile()`
        // is a network round trip that yields null on any failure, which is how a
        // signed-in account ended up rendering as "Not signed in" whenever the
        // request was blocked or slow.
        val profile = if (account != null) accountManager.accountProfile() else null
        if (profile != null) {
            syncStateCache.putProfile(profile.email, profile.displayName)
        } else if (account != null) {
            ensureAccountProfile(account)
        }

        val engineStatus = SyncEnginesStorage(context).getStatus()

        return SyncAccountInfo(
            authenticated = account != null && !needsReauth,
            // `WorkManagerSyncDispatcher` notifies its observers *before* it updates
            // `isSyncActive` (WorkManagerSyncManager.kt:154-161), so asking the
            // account manager from inside `onStarted`/`onIdle` returns the state
            // being left, not the one being entered — and the last thing the UI
            // heard after a completed sync was "still syncing". Callers that know
            // say so; only callers outside that window fall back to asking.
            syncing = syncing ?: accountManager.isSyncActive(),
            needsReauth = needsReauth,
            // Falling back to the cache only while an account exists: after a logout
            // there is nothing to describe, and the cache has been cleared anyway.
            email = profile?.email ?: account?.let { syncStateCache.email() },
            displayName = profile?.displayName ?: account?.let { syncStateCache.displayName() },
            lastSyncedAt = getLastSynced(context).takeIf { it > 0L },
            engines = listOf(
                SyncEngineStatus(
                    engine = SyncEngineValue.HISTORY,
                    enabled = engineStatus[SyncEngine.History] ?: true,
                ),
                SyncEngineStatus(
                    engine = SyncEngineValue.BOOKMARKS,
                    enabled = engineStatus[SyncEngine.Bookmarks] ?: true,
                ),
                SyncEngineStatus(
                    engine = SyncEngineValue.TABS,
                    enabled = engineStatus[SyncEngine.Tabs] ?: true,
                ),
            ),
        )
    }

    /** The current account state, for the pull side of the API. */
    internal fun currentAccountInfo(): SyncAccountInfo = buildAccountInfo(
        account = accountManager.authenticatedAccount(),
        needsReauth = accountManager.accountNeedsReauth(),
    )

    private fun dispatchAuthState(
        account: OAuthAccount?,
        needsReauth: Boolean = false,
        syncing: Boolean? = null,
    ) {
        val events = syncStateEvents ?: return
        authStateScope.launch {
            val info = buildAccountInfo(account, needsReauth, syncing)

            val shouldEmit = synchronized(authStateLock) {
                if (lastAuthState == info) {
                    false
                } else {
                    lastAuthState = info
                    true
                }
            }

            if (!shouldEmit) {
                return@launch
            }

            runOnUiThread {
                events.onAuthStateChanged(sequenceCounter.incrementAndGet(), info) { _ -> }
            }
        }
    }

    val accountManager: FxaAccountManager get() = accountManagerDelegate.value

    private val accountManagerDelegate = lazy {
        FxaAccountManager(
            context = context,
            serverConfig = serverConfig,
            deviceConfig = deviceConfig,
            syncConfig = syncConfig,
            applicationScopes = setOf(SCOPE_SYNC, SCOPE_SESSION),
            crashReporter = null,
        ).also { accountManager ->
            // Registered here rather than from `awaitStarted`, matching Fenix. This is
            // what uploads *this* device's tabs into the tabs engine, and it only ever
            // starts from `onAuthenticated` — so it has to be observing before
            // `accountManager.start()` restores the account below. Hanging it off
            // `awaitStarted` meant a launch where nothing called into the sync API
            // never published this device's tabs at all.
            SyncedTabsIntegration(accountManager) { syncedTabsStorage }.launch()

            SendTabFeature(accountManager) { device: Device?, tabs: List<TabData> ->
                synchronized(incomingTabsLock) {
                    tabs.forEach { tab ->
                        incomingTabsQueue.addLast(
                            IncomingTab(
                                title = tab.title,
                                url = tab.url,
                                fromDeviceId = device?.id,
                                fromDeviceName = device?.displayName,
                            ),
                        )
                    }
                }
            }

            accountManager.register(object : AccountObserver {
                override fun onReady(authenticatedAccount: OAuthAccount?) {
                    if (!startedSignal.isCompleted) {
                        startedSignal.complete(Unit)
                    }
                }

                override fun onAuthenticated(account: OAuthAccount, authType: AuthType) {
                    // A restore or a recovery is the same account we cached; anything
                    // else may be a different one, and the profile fetch that would
                    // correct the cache is exactly the request that fails here.
                    val sameAccount =
                        authType == AuthType.Existing || authType == AuthType.Recovered
                    if (!sameAccount) {
                        syncStateCache.clearProfile()
                    }

                    registerDeviceObserver(account)
                    dispatchAuthState(account)
                }

                override fun onAuthenticationProblems() {
                    dispatchAuthState(accountManager.authenticatedAccount(), needsReauth = true)
                }

                override fun onLoggedOut() {
                    // Before dispatching: the cache is the fallback the dispatched
                    // state reads from, so clearing it afterwards would emit the
                    // signed-out account still carrying the old email.
                    syncStateCache.clear()
                    dispatchAuthState(null)
                }

                override fun onProfileUpdated(profile: Profile) {
                    dispatchAuthState(accountManager.authenticatedAccount())
                }

                override fun onFlowError(error: mozilla.components.concept.sync.AuthFlowError) {
                    dispatchAuthState(accountManager.authenticatedAccount(), needsReauth = true)
                }
            })

            accountManager.registerForSyncEvents(object : SyncStatusObserver {
                override fun onStarted() {
                    val events = syncStateEvents ?: return
                    dispatchAuthState(accountManager.authenticatedAccount(), syncing = true)
                    runOnUiThread {
                        events.onSyncStarted(sequenceCounter.incrementAndGet()) { _ -> }
                    }
                }

                override fun onIdle() {
                    val events = syncStateEvents ?: return

                    // A completed sync is proof the network works, which the one
                    // profile fetch allowed per process may well not have had: it
                    // fires during startup, before the proxy extension has a routing
                    // snapshot. Grant another attempt now rather than leave the
                    // account unnamed until the next launch. Still bounded — one
                    // fetch per completed sync, and only while nothing can name the
                    // account at all.
                    profileFetchAttempted.set(false)

                    dispatchAuthState(accountManager.authenticatedAccount(), syncing = false)
                    runOnUiThread {
                        events.onSyncCompleted(sequenceCounter.incrementAndGet()) { _ -> }
                    }
                }

                override fun onError(error: Exception?) {
                    val events = syncStateEvents ?: return
                    dispatchAuthState(accountManager.authenticatedAccount(), syncing = false)
                    runOnUiThread {
                        events.onSyncError(
                            sequenceCounter.incrementAndGet(),
                            error?.message,
                        ) { _ -> }
                    }
                }
            }, owner = ProcessLifecycleOwner.get(), autoPause = false)

            MainScope().launch {
                // Nothing may touch the FxA network before the proxy extension holds
                // routing. Until it does it answers every request with the emergency
                // break, and `accountManager.start()` sends `FxaEvent.Initialize`,
                // whose `ensure_capabilities` call app-services does *not* treat as
                // retriable: a network failure there becomes
                // `(EnsureDeviceCapabilities, CallError) -> Complete(Disconnected)`
                // (`state_machine/internal_machines/uninitialized.rs`), and that
                // disconnected state is then persisted. The account is gone, and only
                // signing in again brings it back.
                //
                // Measured on a real cold start: the call ran at +8.8s, gave up at
                // +13.4s, and routing arrived at +14.3s — under a second too late.
                if (!ContainerProxyFeature.awaitRoutingInstalled(ROUTING_WAIT_MS)) {
                    // Deliberately not starting anyway. If routing never installed
                    // then the network is blocked, so starting would not succeed — it
                    // would only reach the disconnect above. Leaving the account
                    // untouched on disk keeps it recoverable on the next launch,
                    // which is the better of the two failures.
                    logger.error(
                        "Not starting the account manager: the proxy extension never " +
                            "installed routing, so FxA calls would fail and disconnect " +
                            "the account",
                    )
                    if (!startedSignal.isCompleted) {
                        startedSignal.completeExceptionally(
                            IllegalStateException("Routing was never installed"),
                        )
                    }
                    return@launch
                }

                runCatching {
                    accountManager.start()
                }.fold(
                    onSuccess = {},
                    onFailure = { error ->
                        val isDuplicateInitialize = error.message
                            ?.contains("Initialize already sent", ignoreCase = true)
                            ?: false

                        if (isDuplicateInitialize) {
                            return@fold
                        }

                        if (!startedSignal.isCompleted) {
                            startedSignal.completeExceptionally(error)
                        }
                        throw error
                    },
                )
                if (accountManager.authenticatedAccount() != null && shouldSyncOnStartup()) {
                    accountManager.syncNow(SyncReason.Startup)
                }
            }
        }
    }

    /**
     * Shuts the account manager down, if one was ever built.
     *
     * Deliberately never touches the stored account. A close that finds no
     * authenticated account is not evidence that the user signed out: it is equally
     * what a failed restore, a half-finished auth flow, or an uninitialised manager
     * looks like, and clearing on any of those would turn a recoverable state into
     * a permanent sign-out.
     */
    fun close() {
        // Only if one was ever built. Touching the lazy here would construct a
        // whole account manager — reading storage, registering observers, starting
        // it — purely to close it again.
        if (accountManagerDelegate.isInitialized()) {
            runCatching { accountManager.close() }
        }
    }

    /**
     * Records how the account looked on disk before anything read it.
     *
     * The two files separate the ways an account can disappear, and this has to run
     * first because `SecureAbove22AccountStorage.read()` destroys the evidence — it
     * clears the sentinel as soon as it notices the mismatch.
     *
     * - state missing, sentinel set: the write never reached disk, or could not be
     *   decrypted. A durability or Keystore problem.
     * - state missing, sentinel clear: something called `clear()` — a logout, or
     *   AC's `resetAccount` after authentication side effects failed.
     *
     * Presence only; the stored value is an account credential and is never read.
     */
    private fun reportAccountStorageOnStart() {
        runCatching {
            val hasState = context
                .getSharedPreferences(FXA_SECURE_PREFS_NAME, Context.MODE_PRIVATE)
                .contains(FXA_STATE_KEY)
            val expectsState = context
                .getSharedPreferences(FXA_STATE_PREFS_NAME, Context.MODE_PRIVATE)
                .getBoolean(FXA_STATE_PRESENT_KEY, false)

            logger.info("FxA account storage on start: state=$hasState expected=$expectsState")
        }
    }

    suspend fun awaitStarted() {
        accountManager
        withTimeout(10_000) {
            startedSignal.await()
        }
    }

    /**
     * Starts mirroring the device constellation into [syncStateCache].
     *
     * `registerDeviceObserver` goes through a lifecycle-bound observer registry and
     * is `@MainThread`; `onAuthenticated` arrives on whichever thread drove the
     * account state machine, so the hop is not optional. `ObserverRegistry` holds
     * its observers in a set, so re-registering the same instance cannot double up
     * notifications — which is what makes this safe to call on every authentication.
     */
    private fun registerDeviceObserver(account: OAuthAccount) {
        runOnUiThread {
            runCatching {
                account.deviceConstellation().registerDeviceObserver(
                    deviceObserver,
                    ProcessLifecycleOwner.get(),
                    autoPause = false,
                )
            }
        }
    }

    private fun shouldSyncOnStartup(): Boolean {
        val lastSynced = getLastSynced(context)
        if (lastSynced <= 0L) {
            return true
        }

        return (System.currentTimeMillis() - lastSynced) >= MIN_STARTUP_SYNC_INTERVAL_MS
    }

    fun drainIncomingTabs(): List<IncomingTab> {
        synchronized(incomingTabsLock) {
            if (incomingTabsQueue.isEmpty()) {
                return emptyList()
            }

            val values = incomingTabsQueue.toList()
            incomingTabsQueue.clear()
            return values
        }
    }
}
