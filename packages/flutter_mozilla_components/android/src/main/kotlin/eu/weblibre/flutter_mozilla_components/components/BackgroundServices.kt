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
import mozilla.components.concept.sync.DeviceConfig
import mozilla.components.concept.sync.DeviceCapability
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
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoSyncStateEvents
import eu.weblibre.flutter_mozilla_components.pigeons.SyncAccountInfo
import eu.weblibre.flutter_mozilla_components.pigeons.SyncEngineStatus
import eu.weblibre.flutter_mozilla_components.pigeons.SyncEngineValue
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
    }

    data class IncomingTab(
        val title: String,
        val url: String,
        val fromDeviceId: String?,
        val fromDeviceName: String?,
    )

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
    }

    private val sequenceCounter = AtomicLong(0)
    private val syncedTabsIntegrationLaunched = AtomicBoolean(false)

    private fun dispatchAuthState(account: OAuthAccount?, needsReauth: Boolean = false) {
        val events = syncStateEvents ?: return
        authStateScope.launch {
            val profile = account?.getProfile()
            val engineStorage = SyncEnginesStorage(context)
            val engineStatus = engineStorage.getStatus()

            val info = SyncAccountInfo(
                authenticated = account != null && !needsReauth,
                syncing = accountManager.isSyncActive(),
                needsReauth = needsReauth,
                email = profile?.email,
                displayName = profile?.displayName,
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

    val accountManager: FxaAccountManager by lazy {
        FxaAccountManager(
            context = context,
            serverConfig = serverConfig,
            deviceConfig = deviceConfig,
            syncConfig = syncConfig,
            applicationScopes = setOf(SCOPE_SYNC, SCOPE_SESSION),
            crashReporter = null,
        ).also { accountManager ->
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
                    dispatchAuthState(account)
                }

                override fun onAuthenticationProblems() {
                    dispatchAuthState(accountManager.authenticatedAccount(), needsReauth = true)
                }

                override fun onLoggedOut() {
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
                    dispatchAuthState(accountManager.authenticatedAccount())
                    runOnUiThread {
                        events.onSyncStarted(sequenceCounter.incrementAndGet()) { _ -> }
                    }
                }

                override fun onIdle() {
                    val events = syncStateEvents ?: return
                    dispatchAuthState(accountManager.authenticatedAccount())
                    runOnUiThread {
                        events.onSyncCompleted(sequenceCounter.incrementAndGet()) { _ -> }
                    }
                }

                override fun onError(error: Exception?) {
                    val events = syncStateEvents ?: return
                    dispatchAuthState(accountManager.authenticatedAccount())
                    runOnUiThread {
                        events.onSyncError(
                            sequenceCounter.incrementAndGet(),
                            error?.message,
                        ) { _ -> }
                    }
                }
            }, owner = ProcessLifecycleOwner.get(), autoPause = false)

            MainScope().launch {
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

    suspend fun awaitStarted() {
        accountManager
        launchSyncedTabsIntegrationIfNeeded()
        withTimeout(10_000) {
            startedSignal.await()
        }
    }

    private fun launchSyncedTabsIntegrationIfNeeded() {
        if (syncedTabsIntegrationLaunched.compareAndSet(false, true)) {
            SyncedTabsIntegration(accountManager, syncedTabsStorage).launch()
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
