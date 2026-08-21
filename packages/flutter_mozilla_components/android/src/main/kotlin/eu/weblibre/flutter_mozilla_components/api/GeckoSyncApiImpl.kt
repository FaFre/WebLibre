package eu.weblibre.flutter_mozilla_components.api

import eu.weblibre.flutter_mozilla_components.GlobalComponents
import eu.weblibre.flutter_mozilla_components.components.WebLibreFxAEntryPoint
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoSyncApi
import eu.weblibre.flutter_mozilla_components.pigeons.SyncAccountInfo
import eu.weblibre.flutter_mozilla_components.pigeons.SyncDevice
import eu.weblibre.flutter_mozilla_components.pigeons.SyncDeviceTabs
import eu.weblibre.flutter_mozilla_components.pigeons.SyncEngineValue
import eu.weblibre.flutter_mozilla_components.pigeons.SyncIncomingTab
import eu.weblibre.flutter_mozilla_components.pigeons.SyncRemoteTab
import androidx.work.WorkInfo
import androidx.work.WorkManager
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.launch
import mozilla.components.concept.sync.ConstellationState
import mozilla.components.concept.sync.DeviceCapability
import mozilla.components.concept.sync.DeviceCommandOutgoing
import mozilla.components.concept.sync.TabData
import mozilla.components.concept.sync.TabPrivacy
import mozilla.components.service.fxa.SyncEngine
import mozilla.components.service.fxa.manager.SCOPE_PROFILE
import mozilla.components.service.fxa.manager.SCOPE_SYNC
import mozilla.components.service.fxa.manager.SyncEnginesStorage
import mozilla.components.service.fxa.sync.SyncReason

class GeckoSyncApiImpl : GeckoSyncApi {
    companion object {
        private val coroutineScope = CoroutineScope(Dispatchers.IO + SupervisorJob())

        /**
         * `SyncWorkerName.Immediate.name` from mozilla-components.
         *
         * That enum is private to `WorkManagerSyncManager`, so the value has to be
         * repeated here. If it ever changes upstream this stops matching and the
         * stalled-retry symptom below silently returns.
         */
        private const val IMMEDIATE_SYNC_WORK_NAME = "Immediate"
    }

    private val components by lazy {
        requireNotNull(GlobalComponents.components) { "Components not initialized" }
    }

    override fun getAccountInfo(callback: (Result<SyncAccountInfo>) -> Unit) {
        coroutineScope.launch {
            runCatching {
                // The account manager reports `FxaState.Uninitialized` until `start()`
                // has restored the account from disk, and `authenticatedAccount()`
                // answers null in that state. Reading before then is what made a
                // signed-in profile come back signed out after a restart.
                //
                // Tolerant of the wait failing: if the account manager cannot start
                // (no network for the device check, a 10s timeout), the best answer is
                // still whatever it currently knows, not an error that leaves the sync
                // screen with no state at all. The auth-state event corrects it once
                // the start does complete.
                runCatching { components.backgroundServices.awaitStarted() }

                components.backgroundServices.currentAccountInfo()
            }.fold(
                onSuccess = { callback(Result.success(it)) },
                onFailure = { callback(Result.failure(it)) },
            )
        }
    }

    override fun beginAuthentication(callback: (Result<Unit>) -> Unit) {
        coroutineScope.launch {
            runCatching {
                components.backgroundServices.awaitStarted()
                components.services.accountsAuthFeature.beginAuthentication(
                    context = components.profileApplicationContext,
                    entrypoint = WebLibreFxAEntryPoint.Settings,
                    scopes = setOf(SCOPE_PROFILE, SCOPE_SYNC),
                )
            }.fold(
                onSuccess = { callback(Result.success(Unit)) },
                onFailure = { callback(Result.failure(it)) },
            )
        }
    }

    override fun beginPairingAuthentication(
        pairingUrl: String,
        callback: (Result<Unit>) -> Unit,
    ) {
        coroutineScope.launch {
            runCatching {
                components.backgroundServices.awaitStarted()
                components.services.accountsAuthFeature.beginPairingAuthentication(
                    context = components.profileApplicationContext,
                    pairingUrl = pairingUrl,
                    entrypoint = WebLibreFxAEntryPoint.Settings,
                    scopes = setOf(SCOPE_PROFILE, SCOPE_SYNC),
                )
            }.fold(
                onSuccess = { callback(Result.success(Unit)) },
                onFailure = { callback(Result.failure(it)) },
            )
        }
    }

    override fun logout(callback: (Result<Unit>) -> Unit) {
        coroutineScope.launch {
            runCatching {
                // Tolerant: a user who asked to sign out must not be held back by an
                // account manager that cannot finish starting.
                runCatching { components.backgroundServices.awaitStarted() }
                components.backgroundServices.accountManager.logout()
            }.fold(
                onSuccess = { callback(Result.success(Unit)) },
                onFailure = { callback(Result.failure(it)) },
            )
        }
    }

    override fun syncNow(callback: (Result<Unit>) -> Unit) {
        coroutineScope.launch {
            runCatching {
                // Not tolerant, unlike the read paths: `syncNow` on an unstarted
                // account manager logs "not in the right state" and returns, so
                // without this the button reported success and did nothing.
                components.backgroundServices.awaitStarted()
                clearStalledImmediateSync()
                components.backgroundServices.accountManager.syncNow(SyncReason.User)
            }.fold(
                onSuccess = { callback(Result.success(Unit)) },
                onFailure = { callback(Result.failure(it)) },
            )
        }
    }

    override fun setEngineEnabled(
        engine: SyncEngineValue,
        enabled: Boolean,
        callback: (Result<Unit>) -> Unit,
    ) {
        coroutineScope.launch {
            runCatching {
                val storage = SyncEnginesStorage(components.profileApplicationContext)
                val mapped = when (engine) {
                    SyncEngineValue.HISTORY -> SyncEngine.History
                    SyncEngineValue.BOOKMARKS -> SyncEngine.Bookmarks
                    SyncEngineValue.TABS -> SyncEngine.Tabs
                }

                // Persist the choice first and unconditionally. It is the user's
                // setting and does not need the account manager; only the sync that
                // propagates it does.
                storage.setStatus(mapped, enabled)

                runCatching { components.backgroundServices.awaitStarted() }
                components.backgroundServices.accountManager.syncNow(SyncReason.EngineChange)
            }.fold(
                onSuccess = { callback(Result.success(Unit)) },
                onFailure = { callback(Result.failure(it)) },
            )
        }
    }

    override fun getSyncedTabs(callback: (Result<List<SyncDeviceTabs>>) -> Unit) {
        coroutineScope.launch {
            runCatching {
                val deviceNames = deviceDisplayNames()
                components.core.remoteTabsStorage.getAll().entries.mapNotNull { (client, tabs) ->
                    // A client with no name is a device that has left the
                    // constellation. Dropped, as Fenix does — the name map is backed
                    // by the cache, so "we know no names at all" is not the failure
                    // this has to survive.
                    val deviceName = deviceNames[client.id] ?: return@mapNotNull null

                    SyncDeviceTabs(
                        deviceId = client.id,
                        deviceName = deviceName,
                        tabs = tabs.map { tab ->
                            val active = tab.active()
                            SyncRemoteTab(
                                title = active.title,
                                url = active.url,
                                iconUrl = active.iconUrl,
                                lastUsed = tab.lastUsed,
                                inactive = tab.inactive,
                            )
                        }.sortedByDescending { it.lastUsed },
                    )
                }.sortedBy { it.deviceName.lowercase() }
            }.fold(
                onSuccess = { callback(Result.success(it)) },
                onFailure = { callback(Result.failure(it)) },
            )
        }
    }

    override fun getDevices(callback: (Result<List<SyncDevice>>) -> Unit) {
        coroutineScope.launch {
            runCatching {
                components.backgroundServices.awaitStarted()
                if (components.backgroundServices.accountManager.authenticatedAccount() == null) {
                    return@runCatching emptyList()
                }

                // Forced: this is the device list, and a device added, removed or
                // renamed on another client only ever reaches us by asking.
                val state = constellationState(forceRefresh = true)

                val devices = if (state != null) {
                    (listOfNotNull(state.currentDevice) + state.otherDevices).map { device ->
                        SyncDevice(
                            deviceId = device.id,
                            // Same override as `getDeviceName`, so the list and the
                            // setting cannot disagree about this device's name.
                            displayName = if (device.isCurrentDevice) {
                                components.backgroundServices.pendingDeviceName
                                    ?: device.displayName
                            } else {
                                device.displayName
                            },
                            isCurrentDevice = device.isCurrentDevice,
                            canSendTab = device.capabilities.contains(DeviceCapability.SEND_TAB),
                        )
                    }
                } else {
                    // The fetch failed and nothing is in memory. The last constellation
                    // we saw is a far better answer than an empty list, which reads as
                    // "you have no other devices".
                    components.backgroundServices.syncStateCache.devices().map { device ->
                        SyncDevice(
                            deviceId = device.deviceId,
                            displayName = device.displayName,
                            isCurrentDevice = device.isCurrentDevice,
                            canSendTab = device.canSendTab,
                        )
                    }
                }

                devices.sortedBy { it.displayName.lowercase() }
            }.fold(
                onSuccess = { callback(Result.success(it)) },
                onFailure = { callback(Result.failure(it)) },
            )
        }
    }

    override fun sendTabToDevice(
        deviceId: String,
        title: String,
        url: String,
        private: Boolean,
        callback: (Result<Boolean>) -> Unit
    ) {
        coroutineScope.launch {
            runCatching {
                components.backgroundServices.awaitStarted()
                val account = components.backgroundServices.accountManager.authenticatedAccount()
                    ?: return@runCatching false

                val constellation = account.deviceConstellation()
                val target = constellationState(forceRefresh = false)?.otherDevices?.firstOrNull {
                    it.id == deviceId && it.capabilities.contains(DeviceCapability.SEND_TAB)
                } ?: return@runCatching false

                constellation.sendCommandToDevice(
                    target.id,
                    DeviceCommandOutgoing.SendTab(
                        title = title,
                        url = url,
                        privacy = if (private) TabPrivacy.Private else TabPrivacy.Normal,
                    ),
                )
            }.fold(
                onSuccess = { callback(Result.success(it)) },
                onFailure = { callback(Result.failure(it)) },
            )
        }
    }

    override fun refreshDevices(callback: (Result<Unit>) -> Unit) {
        coroutineScope.launch {
            runCatching {
                components.backgroundServices.awaitStarted()
                val account = components.backgroundServices.accountManager.authenticatedAccount()
                    ?: return@runCatching

                val constellation = account.deviceConstellation()
                constellation.refreshDevices()
                constellation.state()?.let(components.backgroundServices::cacheConstellation)
            }.fold(
                onSuccess = { callback(Result.success(Unit)) },
                onFailure = { callback(Result.failure(it)) },
            )
        }
    }

    override fun pollDeviceCommands(callback: (Result<Unit>) -> Unit) {
        coroutineScope.launch {
            runCatching {
                components.backgroundServices.awaitStarted()
                val account = components.backgroundServices.accountManager.authenticatedAccount()
                    ?: return@runCatching

                account.deviceConstellation().pollForCommands()
            }.fold(
                onSuccess = { callback(Result.success(Unit)) },
                onFailure = { callback(Result.failure(it)) },
            )
        }
    }

    override fun drainIncomingTabs(callback: (Result<List<SyncIncomingTab>>) -> Unit) {
        coroutineScope.launch {
            runCatching {
                components.backgroundServices.drainIncomingTabs().map {
                    SyncIncomingTab(
                        title = it.title,
                        url = it.url,
                        fromDeviceId = it.fromDeviceId,
                        fromDeviceName = it.fromDeviceName,
                    )
                }
            }.fold(
                onSuccess = { callback(Result.success(it)) },
                onFailure = { callback(Result.failure(it)) },
            )
        }
    }

    override fun getDeviceName(callback: (Result<String?>) -> Unit) {
        coroutineScope.launch {
            runCatching {
                components.backgroundServices.awaitStarted()
                if (components.backgroundServices.accountManager.authenticatedAccount() == null) {
                    return@runCatching null
                }

                // A rename this process made outranks the constellation, because the
                // constellation cannot confirm it — see `pendingDeviceName`. After
                // that, live state, and the cache only as a fallback: reading the
                // cache first let it *shadow* reality, so a name that had changed
                // elsewhere could never be seen.
                components.backgroundServices.pendingDeviceName
                    ?: constellationState(forceRefresh = false)?.currentDevice?.displayName
                    ?: components.backgroundServices.syncStateCache.currentDeviceName()
                    // Never "Unknown": this device always has a name it registered
                    // itself under, which is what Fenix falls back to as well.
                    ?: components.backgroundServices.localDeviceName()
            }.fold(
                onSuccess = { callback(Result.success(it)) },
                onFailure = { callback(Result.failure(it)) },
            )
        }
    }

    override fun setDeviceName(newName: String, callback: (Result<Boolean>) -> Unit) {
        coroutineScope.launch {
            runCatching {
                val trimmed = newName.trim()
                if (trimmed.isEmpty()) {
                    return@runCatching false
                }

                components.backgroundServices.awaitStarted()
                val account = components.backgroundServices.accountManager.authenticatedAccount()
                    ?: return@runCatching false

                val renamed = account.deviceConstellation()
                    .setDeviceName(trimmed, components.profileApplicationContext)

                // AC folds the rename and the refresh that follows it into a single
                // boolean (`rename && refreshDevices()`), so a rename that reached the
                // server still reports failure if the refresh after it did not. Ask
                // the server what the name is now and let that decide — which also
                // reloads the constellation and the cache behind it.
                val observed = constellationState(forceRefresh = true)
                    ?.currentDevice
                    ?.displayName

                val succeeded = renamed || observed == trimmed
                if (succeeded) {
                    // Held until a refresh reports the new name. The refresh above
                    // usually will not: it reads a device list app-services has
                    // cached, so it answers with the name from before the rename.
                    components.backgroundServices.recordDeviceRename(trimmed)
                }

                succeeded
            }.fold(
                onSuccess = { callback(Result.success(it)) },
                onFailure = { callback(Result.failure(it)) },
            )
        }
    }

    /**
     * Clears a sync attempt that is sitting out a retry backoff.
     *
     * `WorkManagerSyncDispatcher.syncNow` enqueues under a unique work name with
     * `ExistingWorkPolicy.KEEP`. A sync that fails with `ServiceStatus.NETWORK_ERROR`
     * returns `Result.retry()`, which leaves that unique work ENQUEUED for an
     * exponential backoff measured in *minutes* — and for as long as it sits there,
     * KEEP silently discards every later request. The symptom is precise: the log
     * says "Immediate sync requested" and no worker ever runs, until the backoff
     * expires on its own.
     *
     * A user pressing Sync Now is an explicit instruction to try now, so a waiting
     * attempt is cancelled to let it through. A RUNNING one is left alone: that is a
     * sync actually in progress, and replacing it would abort real work to start the
     * same work again. Cancelling also finishes the work as far as WorkManager is
     * concerned, so the observer reports idle and a stuck spinner clears with it.
     */
    private fun clearStalledImmediateSync() {
        runCatching {
            val workManager = WorkManager.getInstance(components.profileApplicationContext)
            val waiting = workManager
                .getWorkInfosForUniqueWork(IMMEDIATE_SYNC_WORK_NAME)
                .get()
                .any { !it.state.isFinished && it.state != WorkInfo.State.RUNNING }

            if (waiting) {
                workManager.cancelUniqueWork(IMMEDIATE_SYNC_WORK_NAME).result.get()
            }
        }
    }

    /**
     * The device constellation.
     *
     * `FxaDeviceConstellation.state()` is populated only by a successful
     * `refreshDevices()` and is never persisted, so the first read in a process
     * always goes to the network; after that it is free.
     *
     * [forceRefresh] separates "show me the devices" from "go and look". Reads that
     * only need names must not pay for a request, but anything the user expects to
     * reflect a change made elsewhere — the device list, a rename — has to ask,
     * because nothing pushes constellation updates to us.
     *
     * A successful read is mirrored into the cache, which is what callers fall back
     * to when this returns null.
     */
    private suspend fun constellationState(forceRefresh: Boolean): ConstellationState? {
        components.backgroundServices.awaitStarted()
        val account = components.backgroundServices.accountManager.authenticatedAccount()
            ?: return null

        val constellation = account.deviceConstellation()
        if (forceRefresh || constellation.state() == null) {
            constellation.refreshDevices()
        }

        return constellation.state()?.also(components.backgroundServices::cacheConstellation)
    }

    /** Device names by id, from the live constellation or the last one we saw. */
    private suspend fun deviceDisplayNames(): Map<String, String> {
        val cached = components.backgroundServices.syncStateCache.deviceNames()
        val state = constellationState(forceRefresh = false) ?: return cached

        val live = (listOfNotNull(state.currentDevice) + state.otherDevices)
            .associate { it.id to it.displayName }

        // Live entries win; cached-only entries stay so a device that is briefly
        // absent from a refresh does not lose its name mid-session.
        return cached + live
    }
}
