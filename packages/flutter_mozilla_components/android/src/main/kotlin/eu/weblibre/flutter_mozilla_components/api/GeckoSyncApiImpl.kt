package eu.weblibre.flutter_mozilla_components.api

import eu.weblibre.flutter_mozilla_components.GlobalComponents
import eu.weblibre.flutter_mozilla_components.components.WebLibreFxAEntryPoint
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoSyncApi
import eu.weblibre.flutter_mozilla_components.pigeons.SyncAccountInfo
import eu.weblibre.flutter_mozilla_components.pigeons.SyncDevice
import eu.weblibre.flutter_mozilla_components.pigeons.SyncDeviceTabs
import eu.weblibre.flutter_mozilla_components.pigeons.SyncEngineStatus
import eu.weblibre.flutter_mozilla_components.pigeons.SyncEngineValue
import eu.weblibre.flutter_mozilla_components.pigeons.SyncIncomingTab
import eu.weblibre.flutter_mozilla_components.pigeons.SyncRemoteTab
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.launch
import mozilla.components.concept.sync.DeviceCapability
import mozilla.components.concept.sync.DeviceCommandOutgoing
import mozilla.components.concept.sync.TabData
import mozilla.components.service.fxa.SyncEngine
import mozilla.components.service.fxa.manager.SCOPE_PROFILE
import mozilla.components.service.fxa.manager.SCOPE_SYNC
import mozilla.components.service.fxa.manager.SyncEnginesStorage
import mozilla.components.service.fxa.sync.SyncReason
import mozilla.components.service.fxa.sync.getLastSynced

class GeckoSyncApiImpl : GeckoSyncApi {
    companion object {
        private val coroutineScope = CoroutineScope(Dispatchers.IO + SupervisorJob())
    }

    private val components by lazy {
        requireNotNull(GlobalComponents.components) { "Components not initialized" }
    }

    override fun getAccountInfo(callback: (Result<SyncAccountInfo>) -> Unit) {
        coroutineScope.launch {
            try {
                val accountManager = components.backgroundServices.accountManager
                val account = accountManager.authenticatedAccount()
                val needsReauth = accountManager.accountNeedsReauth()
                val profile = account?.getProfile()
                val engineStorage = SyncEnginesStorage(components.profileApplicationContext)
                val engineStatus = engineStorage.getStatus()

                callback(
                    Result.success(
                        SyncAccountInfo(
                            authenticated = account != null && !needsReauth,
                            syncing = accountManager.isSyncActive(),
                            needsReauth = needsReauth,
                            email = profile?.email,
                            displayName = profile?.displayName,
                            lastSyncedAt = getLastSynced(components.profileApplicationContext)
                                .takeIf { it > 0L },
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
                        ),
                    ),
                )
            } catch (e: Exception) {
                callback(Result.failure(e))
            }
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

                storage.setStatus(mapped, enabled)
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
                val deviceNames = loadDeviceDisplayNames()
                components.core.remoteTabsStorage.getAll().entries.mapNotNull { (client, tabs) ->
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
                val account = components.backgroundServices.accountManager.authenticatedAccount()
                    ?: return@runCatching emptyList()

                val constellation = account.deviceConstellation()
                constellation.refreshDevices()
                val state = constellation.state()
                val currentDevice = state?.currentDevice
                val otherDevices = state?.otherDevices.orEmpty()

                (listOfNotNull(currentDevice) + otherDevices).map { device ->
                    SyncDevice(
                        deviceId = device.id,
                        displayName = device.displayName,
                        isCurrentDevice = device.isCurrentDevice,
                        canSendTab = device.capabilities.contains(DeviceCapability.SEND_TAB),
                    )
                }.sortedBy { it.displayName.lowercase() }
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
        callback: (Result<Boolean>) -> Unit,
    ) {
        coroutineScope.launch {
            runCatching {
                components.backgroundServices.awaitStarted()
                val account = components.backgroundServices.accountManager.authenticatedAccount()
                    ?: return@runCatching false

                val constellation = account.deviceConstellation()
                constellation.refreshDevices()
                val state = constellation.state()
                val target = state?.otherDevices?.firstOrNull {
                    it.id == deviceId && it.capabilities.contains(DeviceCapability.SEND_TAB)
                } ?: return@runCatching false

                constellation.sendCommandToDevice(
                    target.id,
                    DeviceCommandOutgoing.SendTab(
                        title = title,
                        url = url,
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

                account.deviceConstellation().refreshDevices()
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
                val account = components.backgroundServices.accountManager.authenticatedAccount()
                    ?: return@runCatching null

                val constellation = account.deviceConstellation()
                constellation.refreshDevices()
                constellation.state()?.currentDevice?.displayName
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

                account.deviceConstellation()
                    .setDeviceName(trimmed, components.profileApplicationContext)
            }.fold(
                onSuccess = { callback(Result.success(it)) },
                onFailure = { callback(Result.failure(it)) },
            )
        }
    }

    private suspend fun loadDeviceDisplayNames(): Map<String, String> {
        components.backgroundServices.awaitStarted()
        val account = components.backgroundServices.accountManager.authenticatedAccount()
            ?: return emptyMap()

        val constellation = account.deviceConstellation()
        constellation.refreshDevices()
        val state = constellation.state() ?: return emptyMap()
        val devices = listOfNotNull(state.currentDevice) + state.otherDevices
        return devices.associate { it.id to it.displayName }
    }
}
