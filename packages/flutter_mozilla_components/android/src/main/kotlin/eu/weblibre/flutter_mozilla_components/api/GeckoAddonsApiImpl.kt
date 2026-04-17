/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.api

import android.content.Context
import eu.weblibre.flutter_mozilla_components.GlobalComponents
import eu.weblibre.flutter_mozilla_components.addons.AddonPrefs
import eu.weblibre.flutter_mozilla_components.ext.toWebPBytes
import eu.weblibre.flutter_mozilla_components.pigeons.AddonDisabledReason
import eu.weblibre.flutter_mozilla_components.pigeons.AddonIncognito
import eu.weblibre.flutter_mozilla_components.pigeons.AddonInfo
import eu.weblibre.flutter_mozilla_components.pigeons.AddonStoreInfo
import eu.weblibre.flutter_mozilla_components.pigeons.AddonUpdateAttemptInfo
import eu.weblibre.flutter_mozilla_components.pigeons.AddonUpdateStatus
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoAddonsApi
import eu.weblibre.flutter_mozilla_components.pigeons.WebExtensionActionType
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import mozilla.components.concept.fetch.MutableHeaders
import mozilla.components.concept.fetch.Request
import mozilla.components.concept.engine.webextension.InstallationMethod
import mozilla.components.concept.engine.webextension.WebExtensionInstallException
import mozilla.components.feature.addons.Addon
import mozilla.components.feature.addons.update.AddonUpdater
import mozilla.components.feature.addons.update.DefaultAddonUpdater
import mozilla.components.feature.addons.ui.displayName
import mozilla.components.feature.addons.ui.summary
import mozilla.components.feature.addons.ui.translateDescription
import org.mozilla.geckoview.WebExtension.InstallException.ErrorCodes.ERROR_POSTPONED
import org.json.JSONObject

class GeckoAddonsApiImpl(private val context: Context) : GeckoAddonsApi {
    private val components by lazy {
        requireNotNull(GlobalComponents.components) { "Components not initialized" }
    }
    private val scope = CoroutineScope(Dispatchers.IO + SupervisorJob())
    private val updateAttemptStorage by lazy {
        DefaultAddonUpdater.UpdateAttemptStorage(context.applicationContext)
    }
    private val prefs by lazy {
        AddonPrefs.get(context.applicationContext)
    }

    companion object {
        private const val LOCAL_ADDON_UPDATE_SOURCE_MISSING_MESSAGE =
            "No remote update source is available for this locally installed extension."
        private const val LOCAL_ADDON_UPDATE_POSTPONED_MESSAGE =
            "Update downloaded and will be applied after restarting the app."
        private const val DEFAULT_AMO_SERVER_URL = "https://addons.mozilla.org"
        private const val PERIODIC_UPDATE_RESTORE_DELAY_MS = 10_000L
    }

    override fun getAddons(allowCache: Boolean, callback: (Result<List<AddonInfo>>) -> Unit) {
        scope.launch {
            runCatching {
                components.core.addonManager.getAddons(allowCache = allowCache)
                    .map { addon ->
                        addon.toPigeon(
                            context = context,
                            isAutoUpdateEnabled = isAutoUpdateEffectivelyEnabledForAddon(addon.id),
                            isLocalFileInstalled = isLocalFileInstalledAddon(addon.id),
                        )
                    }
            }.fold(
                onSuccess = { callback(Result.success(it)) },
                onFailure = { callback(Result.failure(it)) },
            )
        }
    }

    override fun getAddonById(
        addonId: String,
        allowCache: Boolean,
        callback: (Result<AddonInfo?>) -> Unit,
    ) {
        scope.launch {
            runCatching {
                val installedAddon = components.core.addonManager.getAddonByID(addonId)
                (installedAddon ?: components.core.addonManager.getAddons(allowCache = allowCache)
                    .find { it.id == addonId })?.toPigeon(
                        context = context,
                        isAutoUpdateEnabled = isAutoUpdateEffectivelyEnabledForAddon(addonId),
                        isLocalFileInstalled = isLocalFileInstalledAddon(addonId),
                    )
            }.fold(
                onSuccess = { callback(Result.success(it)) },
                onFailure = { callback(Result.failure(it)) },
            )
        }
    }

    override fun getAddonStoreInfo(addonId: String, callback: (Result<AddonStoreInfo?>) -> Unit) {
        scope.launch {
            runCatching {
                fetchAddonStoreInfo(addonId)
            }.fold(
                onSuccess = { callback(Result.success(it)) },
                onFailure = { callback(Result.failure(it)) },
            )
        }
    }

    override fun invokeAddonAction(extensionId: String, actionType: WebExtensionActionType) {
        scope.launch {
            withContext(Dispatchers.Main.immediate) {
                when(actionType) {
                    WebExtensionActionType.BROWSER -> components.features.webExtensionToolbarFeature.invokeAddonBrowserAction(extensionId)
                    WebExtensionActionType.PAGE -> components.features.webExtensionToolbarFeature.invokeAddonPageAction(extensionId)
                }
            }
        }
    }

    override fun enableAddon(addonId: String, callback: (Result<AddonInfo>) -> Unit) {
        withInstalledAddon(addonId, callback) { addon, result ->
            components.core.addonManager.enableAddon(
                addon,
                onSuccess = { updatedAddon ->
                    result(
                        Result.success(
                            updatedAddon.toPigeon(
                                context = context,
                                isAutoUpdateEnabled = isAutoUpdateEffectivelyEnabledForAddon(updatedAddon.id),
                                isLocalFileInstalled = isLocalFileInstalledAddon(updatedAddon.id),
                            ),
                        ),
                    )
                },
                onError = { throwable ->
                    result(Result.failure(throwable))
                },
            )
        }
    }

    override fun disableAddon(addonId: String, callback: (Result<AddonInfo>) -> Unit) {
        withInstalledAddon(addonId, callback) { addon, result ->
            components.core.addonManager.disableAddon(
                addon,
                onSuccess = { updatedAddon ->
                    result(
                        Result.success(
                            updatedAddon.toPigeon(
                                context = context,
                                isAutoUpdateEnabled = isAutoUpdateEffectivelyEnabledForAddon(updatedAddon.id),
                                isLocalFileInstalled = isLocalFileInstalledAddon(updatedAddon.id),
                            ),
                        ),
                    )
                },
                onError = { throwable ->
                    result(Result.failure(throwable))
                },
            )
        }
    }

    override fun setAddonAllowedInPrivateBrowsing(
        addonId: String,
        allowed: Boolean,
        callback: (Result<AddonInfo>) -> Unit,
    ) {
        withInstalledAddon(addonId, callback) { addon, result ->
            components.core.addonManager.setAddonAllowedInPrivateBrowsing(
                addon,
                allowed,
                onSuccess = { updatedAddon ->
                    result(
                        Result.success(
                            updatedAddon.toPigeon(
                                context = context,
                                isAutoUpdateEnabled = isAutoUpdateEffectivelyEnabledForAddon(updatedAddon.id),
                                isLocalFileInstalled = isLocalFileInstalledAddon(updatedAddon.id),
                            ),
                        ),
                    )
                },
                onError = { throwable ->
                    result(Result.failure(throwable))
                },
            )
        }
    }

    override fun setAddonAutoUpdateEnabledForAddon(
        addonId: String,
        enabled: Boolean,
        callback: (Result<AddonInfo>) -> Unit,
    ) {
        withInstalledAddon(addonId, callback) { addon, result ->
            if (enabled && isLocalFileInstalledAddon(addon.id)) {
                result(
                    Result.success(
                        addon.toPigeon(
                            context = context,
                            isAutoUpdateEnabled = false,
                            isLocalFileInstalled = true,
                        ),
                    ),
                )
                return@withInstalledAddon
            }

            setAddonAutoUpdateEnabledForAddonInternal(addon.id, enabled)
            result(
                Result.success(
                    addon.toPigeon(
                        context = context,
                        isAutoUpdateEnabled = isAutoUpdateEffectivelyEnabledForAddon(addon.id),
                        isLocalFileInstalled = isLocalFileInstalledAddon(addon.id),
                    ),
                ),
            )
        }
    }

    override fun uninstallAddon(addonId: String, callback: (Result<Unit>) -> Unit) {
        withInstalledAddon(addonId, callback) { addon, result ->
            components.core.addonManager.uninstallAddon(
                addon,
                onSuccess = {
                    clearAddonAutoUpdatePreference(addon.id)
                    clearLocalFileInstalledAddon(addon.id)
                    clearManualUpdateAttempt(addon.id)
                    result(Result.success(Unit))
                },
                onError = { _, throwable ->
                    result(Result.failure(throwable))
                },
            )
        }
    }

    override fun triggerAddonUpdate(
        addonId: String,
        callback: (Result<AddonUpdateAttemptInfo?>) -> Unit,
    ) {
        if (isLocalFileInstalledAddon(addonId)) {
            runLocalFileAddonUpdate(addonId, callback)
            return
        }

        scope.launch {
            try {
                withContext(Dispatchers.Main.immediate) {
                    runManagedAddonUpdate(addonId) { attempt ->
                        callback(Result.success(attempt))
                    }
                }
            } catch (throwable: Throwable) {
                callback(Result.failure(throwable))
            }
        }
    }

    override fun triggerAllAddonUpdates(callback: (Result<Unit>) -> Unit) {
        scope.launch {
            try {
                val addons = components.core.addonManager.getAddons()
                    .filter { it.isInstalled() && it.isSupported() }
                    .filter { addon -> isAddonAutoUpdateEnabledForAddon(addon.id) }
                    .filterNot { addon -> isLocalFileInstalledAddon(addon.id) }

                withContext(Dispatchers.Main.immediate) {
                    addons.forEach { addon ->
                        scheduleManagedAddonUpdate(addon.id)
                    }
                }

                callback(Result.success(Unit))
            } catch (throwable: Throwable) {
                callback(Result.failure(throwable))
            }
        }
    }

    override fun getLastAddonUpdateAttempt(
        addonId: String,
        callback: (Result<AddonUpdateAttemptInfo?>) -> Unit,
    ) {
        scope.launch {
            runCatching {
                val updaterAttempt = updateAttemptStorage.findUpdateAttemptBy(addonId)?.toPigeon()
                val manualAttempt = getManualUpdateAttempt(addonId)
                listOfNotNull(updaterAttempt, manualAttempt)
                    .maxByOrNull { it.dateMillisecondsSinceEpoch }
            }.fold(
                onSuccess = { callback(Result.success(it)) },
                onFailure = { callback(Result.failure(it)) },
            )
        }
    }

    override fun isAddonAutoUpdateEnabled(callback: (Result<Boolean>) -> Unit) {
        callback(Result.success(prefs.getBoolean(AddonPrefs.PREF_AUTO_UPDATE_ENABLED, true)))
    }

    override fun setAddonAutoUpdateEnabled(enabled: Boolean, callback: (Result<Unit>) -> Unit) {
        scope.launch {
            try {
                prefs.edit().putBoolean(AddonPrefs.PREF_AUTO_UPDATE_ENABLED, enabled).apply()

                val addons = components.core.addonManager.getAddons()
                    .filter { it.isInstalled() && it.isSupported() }
                withContext(Dispatchers.Main.immediate) {
                    if (enabled) {
                        addons.forEach { addon ->
                            updateAddonAutoUpdateRegistration(addon.id)
                        }
                    } else {
                        addons.forEach { addon ->
                            components.core.addonUpdater.unregisterForFutureUpdates(addon.id)
                        }
                    }
                }

                callback(Result.success(Unit))
            } catch (throwable: Throwable) {
                callback(Result.failure(throwable))
            }
        }
    }

    override fun installAddon(url: String, callback: (Result<Unit>) -> Unit) {
        val isLocalFileInstall = url.startsWith("file://")
        val installMethod = if (isLocalFileInstall) {
            InstallationMethod.FROM_FILE
        } else {
            null
        }

        scope.launch {
            try {
                withContext(Dispatchers.Main.immediate) {
                    performAddonInstall(url, isLocalFileInstall, callback)
                }
            } catch (throwable: Throwable) {
                callback(Result.failure(throwable))
            }
        }
    }

    private fun <T> withInstalledAddon(
        addonId: String,
        callback: (Result<T>) -> Unit,
        block: suspend (Addon, (Result<T>) -> Unit) -> Unit,
    ) {
        scope.launch {
            val addon = runCatching {
                components.core.addonManager.getAddonByID(addonId)
            }.getOrNull()

            if (addon == null) {
                callback(Result.failure(IllegalStateException("Addon $addonId not found")))
                return@launch
            }

            withContext(Dispatchers.Main.immediate) {
                block(addon, callback)
            }
        }
    }

    private fun isAutoUpdateEnabled(): Boolean {
        return prefs.getBoolean(AddonPrefs.PREF_AUTO_UPDATE_ENABLED, true)
    }

    private fun isAddonAutoUpdateEnabledForAddon(addonId: String): Boolean {
        return !getAddonAutoUpdateDisabledIds().contains(addonId)
    }

    private fun isAutoUpdateEffectivelyEnabledForAddon(addonId: String): Boolean {
        return isAddonAutoUpdateEnabledForAddon(addonId) && !isLocalFileInstalledAddon(addonId)
    }

    private fun isLocalFileInstalledAddon(addonId: String): Boolean {
        return getLocalFileAddonIds().contains(addonId)
    }

    private fun getAddonAutoUpdateDisabledIds(): Set<String> {
        return prefs.getStringSet(AddonPrefs.PREF_AUTO_UPDATE_DISABLED_IDS, emptySet()) ?: emptySet()
    }

    private fun getLocalFileAddonIds(): Set<String> {
        return prefs.getStringSet(AddonPrefs.PREF_LOCAL_FILE_ADDON_IDS, emptySet()) ?: emptySet()
    }

    private suspend fun fetchAddonStoreInfo(addonId: String): AddonStoreInfo? {
        val response = components.core.client.fetch(
            Request(
                url = addonStoreInfoUrl(addonId),
                method = Request.Method.GET,
                headers = MutableHeaders("Accept" to "application/json"),
            ),
        )
        if (response.status !in 200..299) {
            return null
        }

        val responseBody = response.body.useStream { stream ->
            String(stream.readAllBytes(), Charsets.UTF_8)
        }
        val json = JSONObject(responseBody)
        val currentVersion = json.optJSONObject("current_version") ?: return null
        val latestVersion = currentVersion.optString("version")
        val latestXpiUrl = currentVersion.optJSONObject("file")?.optString("url").orEmpty()
        if (latestVersion.isBlank() || latestXpiUrl.isBlank()) {
            return null
        }

        return AddonStoreInfo(
            latestVersion = latestVersion,
            latestXpiUrl = latestXpiUrl,
        )
    }

    private fun addonStoreInfoUrl(addonId: String): String {
        val baseUrl = components.addonCollection?.serverURL?.trimEnd('/') ?: DEFAULT_AMO_SERVER_URL
        return "$baseUrl/api/v5/addons/addon/$addonId/"
    }

    private fun saveManualUpdateAttempt(
        addonId: String,
        status: AddonUpdateStatus,
        message: String? = null,
    ) {
        prefs.edit()
            .putLong(manualAttemptTimestampKey(addonId), System.currentTimeMillis())
            .putString(manualAttemptStatusKey(addonId), status.name)
            .putString(manualAttemptMessageKey(addonId), message)
            .apply()
    }

    private fun getManualUpdateAttempt(addonId: String): AddonUpdateAttemptInfo? {
        val timestamp = prefs.getLong(manualAttemptTimestampKey(addonId), -1L)
        if (timestamp < 0) {
            return null
        }

        val status = prefs.getString(manualAttemptStatusKey(addonId), null)
            ?.let { runCatching { AddonUpdateStatus.valueOf(it) }.getOrNull() }

        return AddonUpdateAttemptInfo(
            addonId = addonId,
            dateMillisecondsSinceEpoch = timestamp,
            status = status,
            message = prefs.getString(manualAttemptMessageKey(addonId), null),
        )
    }

    private fun clearManualUpdateAttempt(addonId: String) {
        prefs.edit()
            .remove(manualAttemptTimestampKey(addonId))
            .remove(manualAttemptStatusKey(addonId))
            .remove(manualAttemptMessageKey(addonId))
            .apply()
    }

    private fun manualAttemptTimestampKey(addonId: String): String {
        return "$AddonPrefs.PREF_MANUAL_UPDATE_ATTEMPT_PREFIX$addonId.timestamp"
    }

    private fun manualAttemptStatusKey(addonId: String): String {
        return "$AddonPrefs.PREF_MANUAL_UPDATE_ATTEMPT_PREFIX$addonId.status"
    }

    private fun manualAttemptMessageKey(addonId: String): String {
        return "$AddonPrefs.PREF_MANUAL_UPDATE_ATTEMPT_PREFIX$addonId.message"
    }

    private fun performAddonInstall(
        url: String,
        isLocalFileInstall: Boolean,
        callback: (Result<Unit>) -> Unit,
    ) {
        val installationMethod = if (isLocalFileInstall) InstallationMethod.FROM_FILE else null

        components.core.addonManager.installAddon(
            url = url,
            installationMethod = installationMethod,
            onSuccess = { installedAddon ->
                applyInstallUpdatePolicy(installedAddon.id, isLocalFileInstall)
                callback(Result.success(Unit))
            },
            onError = { error ->
                callback(Result.failure(error))
            },
        )
    }

    private fun applyInstallUpdatePolicy(addonId: String, isLocalFileInstall: Boolean) {
        if (isLocalFileInstall) {
            markAddonAsLocalFileInstalled(addonId)
            setAddonAutoUpdateEnabledForAddonInternal(addonId, false)
        } else {
            clearLocalFileInstalledAddon(addonId)
            updateAddonAutoUpdateRegistration(addonId)
        }
    }

    private fun runLocalFileAddonUpdate(
        addonId: String,
        callback: (Result<AddonUpdateAttemptInfo?>) -> Unit,
    ) {
        withInstalledAddon(addonId, callback) { addon, result ->
            val storeInfo = fetchAddonStoreInfo(addonId)
            if (storeInfo == null) {
                saveManualUpdateAttempt(
                    addonId = addonId,
                    status = AddonUpdateStatus.ERROR,
                    message = LOCAL_ADDON_UPDATE_SOURCE_MISSING_MESSAGE,
                )
                result(Result.failure(IllegalStateException(LOCAL_ADDON_UPDATE_SOURCE_MISSING_MESSAGE)))
                return@withInstalledAddon
            }

            if (addon.installedState?.version == storeInfo.latestVersion) {
                saveManualUpdateAttempt(
                    addonId = addonId,
                    status = AddonUpdateStatus.NO_UPDATE_AVAILABLE,
                )
                result(Result.success(getManualUpdateAttempt(addonId)))
                return@withInstalledAddon
            }

            components.core.addonManager.uninstallAddon(
                addon,
                onSuccess = {
                    performAddonInstall(
                        url = storeInfo.latestXpiUrl,
                        isLocalFileInstall = false,
                        callback = { installResult ->
                            installResult.fold(
                                onSuccess = {
                                    saveManualUpdateAttempt(
                                        addonId = addonId,
                                        status = AddonUpdateStatus.SUCCESSFULLY_UPDATED,
                                    )
                                    result(Result.success(getManualUpdateAttempt(addonId)))
                                },
                                onFailure = { throwable ->
                                    if (isPostponedInstallException(throwable)) {
                                        clearLocalFileInstalledAddon(addonId)
                                        updateAddonAutoUpdateRegistration(addonId)
                                        saveManualUpdateAttempt(
                                            addonId = addonId,
                                            status = AddonUpdateStatus.SUCCESSFULLY_UPDATED,
                                            message = LOCAL_ADDON_UPDATE_POSTPONED_MESSAGE,
                                        )
                                        result(Result.success(getManualUpdateAttempt(addonId)))
                                        return@fold
                                    }

                                    saveManualUpdateAttempt(
                                        addonId = addonId,
                                        status = AddonUpdateStatus.ERROR,
                                        message = throwable.message,
                                    )
                                    result(Result.failure(throwable))
                                },
                            )
                        },
                    )
                },
                onError = { _, throwable ->
                    saveManualUpdateAttempt(
                        addonId = addonId,
                        status = AddonUpdateStatus.ERROR,
                        message = throwable.message,
                    )
                    result(Result.failure(throwable))
                },
            )
        }
    }

    private fun setAddonAutoUpdateEnabledForAddonInternal(addonId: String, enabled: Boolean) {
        val disabledIds = getAddonAutoUpdateDisabledIds().toMutableSet()
        val changed = if (enabled) {
            disabledIds.remove(addonId)
        } else {
            disabledIds.add(addonId)
        }

        if (changed) {
            prefs.edit().putStringSet(AddonPrefs.PREF_AUTO_UPDATE_DISABLED_IDS, disabledIds).apply()
        }

        updateAddonAutoUpdateRegistration(addonId)
    }

    private fun clearAddonAutoUpdatePreference(addonId: String) {
        val disabledIds = getAddonAutoUpdateDisabledIds().toMutableSet()
        if (disabledIds.remove(addonId)) {
            prefs.edit().putStringSet(AddonPrefs.PREF_AUTO_UPDATE_DISABLED_IDS, disabledIds).apply()
        }
    }

    private fun markAddonAsLocalFileInstalled(addonId: String) {
        val localFileAddonIds = getLocalFileAddonIds().toMutableSet()
        if (localFileAddonIds.add(addonId)) {
            prefs.edit().putStringSet(AddonPrefs.PREF_LOCAL_FILE_ADDON_IDS, localFileAddonIds).apply()
        }
    }

    private fun clearLocalFileInstalledAddon(addonId: String) {
        val localFileAddonIds = getLocalFileAddonIds().toMutableSet()
        if (localFileAddonIds.remove(addonId)) {
            prefs.edit().putStringSet(AddonPrefs.PREF_LOCAL_FILE_ADDON_IDS, localFileAddonIds).apply()
        }
    }

    private fun isPostponedInstallException(throwable: Throwable): Boolean {
        val installThrowable = when (throwable) {
            is WebExtensionInstallException -> throwable.cause
            else -> throwable.cause
        }

        return installThrowable is org.mozilla.geckoview.WebExtension.InstallException &&
            installThrowable.code == ERROR_POSTPONED
    }

    private fun updateAddonAutoUpdateRegistration(addonId: String) {
        if (
            isAutoUpdateEnabled() &&
            isAddonAutoUpdateEnabledForAddon(addonId) &&
            !isLocalFileInstalledAddon(addonId)
        ) {
            components.core.addonUpdater.registerForFutureUpdates(addonId)
        } else {
            components.core.addonUpdater.unregisterForFutureUpdates(addonId)
        }
    }

    private fun scheduleManagedAddonUpdate(addonId: String) {
        val shouldRestorePeriodicRegistration = isAutoUpdateEnabled() &&
            isAddonAutoUpdateEnabledForAddon(addonId)
        if (shouldRestorePeriodicRegistration) {
            components.core.addonUpdater.unregisterForFutureUpdates(addonId)
        }

        components.core.addonUpdater.update(addonId)

        if (shouldRestorePeriodicRegistration) {
            scope.launch {
                delay(PERIODIC_UPDATE_RESTORE_DELAY_MS)
                withContext(Dispatchers.Main.immediate) {
                    updateAddonAutoUpdateRegistration(addonId)
                }
            }
        }
    }

    private fun runManagedAddonUpdate(
        addonId: String,
        onComplete: (AddonUpdateAttemptInfo?) -> Unit,
    ) {
        val shouldRestorePeriodicRegistration = isAutoUpdateEnabled() &&
            isAddonAutoUpdateEnabledForAddon(addonId)
        if (shouldRestorePeriodicRegistration) {
            components.core.addonUpdater.unregisterForFutureUpdates(addonId)
        }

        components.core.addonManager.updateAddon(addonId) { status ->
            val pigeonStatus = status.toPigeon()
            val message = (status as? AddonUpdater.Status.Error)?.message
            saveManualUpdateAttempt(addonId, pigeonStatus, message)
            onComplete(getManualUpdateAttempt(addonId))

            if (shouldRestorePeriodicRegistration) {
                scope.launch {
                    delay(PERIODIC_UPDATE_RESTORE_DELAY_MS)
                    withContext(Dispatchers.Main.immediate) {
                        updateAddonAutoUpdateRegistration(addonId)
                    }
                }
            }
        }
    }
}

private fun Addon.toPigeon(
    context: Context,
    isAutoUpdateEnabled: Boolean,
    isLocalFileInstalled: Boolean,
): AddonInfo {
    val installedState = installedState
    val localizedName = displayName(context)
    val localizedSummary = summary(context)
    val localizedDescription = if (translatableDescription.isNotEmpty()) {
        translateDescription(context)
    } else {
        ""
    }

    return AddonInfo(
        id = id,
        displayName = localizedName,
        summary = localizedSummary,
        description = localizedDescription,
        downloadUrl = downloadUrl,
        version = version,
        installedVersion = installedState?.version,
        translatedPermissions = translatePermissions(context),
        translatedRequiredDataCollectionPermissions =
            translateRequiredDataCollectionPermissions(context),
        authorName = author?.name,
        authorUrl = author?.url,
        homepageUrl = homepageUrl,
        detailUrl = detailUrl,
        ratingUrl = ratingUrl,
        ratingAverage = rating?.average?.toDouble(),
        ratingReviews = rating?.reviews?.toLong(),
        createdAt = createdAt,
        updatedAt = updatedAt,
        icon = provideIcon()?.toWebPBytes(),
        isInstalled = isInstalled(),
        isEnabled = isEnabled(),
        isSupported = isSupported(),
        isAllowedInPrivateBrowsing = isAllowedInPrivateBrowsing(),
        isAutoUpdateEnabled = isAutoUpdateEnabled,
        isLocalFileInstalled = isLocalFileInstalled,
        optionsPageUrl = installedState?.optionsPageUrl,
        openOptionsPageInTab = installedState?.openOptionsPageInTab ?: false,
        disabledReason = installedState?.disabledReason?.toPigeon(),
        incognito = incognito.toPigeon(),
    )
}

private fun Addon.DisabledReason.toPigeon(): AddonDisabledReason {
    return when (this) {
        Addon.DisabledReason.UNSUPPORTED -> AddonDisabledReason.UNSUPPORTED
        Addon.DisabledReason.BLOCKLISTED -> AddonDisabledReason.BLOCKLISTED
        Addon.DisabledReason.USER_REQUESTED -> AddonDisabledReason.USER_REQUESTED
        Addon.DisabledReason.NOT_CORRECTLY_SIGNED -> AddonDisabledReason.NOT_CORRECTLY_SIGNED
        Addon.DisabledReason.INCOMPATIBLE -> AddonDisabledReason.INCOMPATIBLE
        Addon.DisabledReason.SOFT_BLOCKED -> AddonDisabledReason.SOFT_BLOCKED
    }
}

private fun Addon.Incognito.toPigeon(): AddonIncognito {
    return when (this) {
        Addon.Incognito.SPANNING -> AddonIncognito.SPANNING
        Addon.Incognito.SPLIT -> AddonIncognito.SPLIT
        Addon.Incognito.NOT_ALLOWED -> AddonIncognito.NOT_ALLOWED
    }
}

private fun AddonUpdater.UpdateAttempt.toPigeon(): AddonUpdateAttemptInfo {
    return AddonUpdateAttemptInfo(
        addonId = addonId,
        dateMillisecondsSinceEpoch = date.time,
        status = status?.toPigeon(),
        message = (status as? AddonUpdater.Status.Error)?.message,
    )
}

private fun AddonUpdater.Status.toPigeon(): AddonUpdateStatus {
    return when (this) {
        AddonUpdater.Status.NotInstalled -> AddonUpdateStatus.NOT_INSTALLED
        AddonUpdater.Status.SuccessfullyUpdated -> AddonUpdateStatus.SUCCESSFULLY_UPDATED
        AddonUpdater.Status.NoUpdateAvailable -> AddonUpdateStatus.NO_UPDATE_AVAILABLE
        is AddonUpdater.Status.Error -> AddonUpdateStatus.ERROR
    }
}
