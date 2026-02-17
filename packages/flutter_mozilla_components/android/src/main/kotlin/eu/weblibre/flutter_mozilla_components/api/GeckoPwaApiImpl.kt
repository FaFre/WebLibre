/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.api

import android.content.Context
import android.content.Intent
import android.content.pm.ShortcutInfo
import android.content.pm.ShortcutManager
import android.graphics.Bitmap
import android.graphics.drawable.Icon
import android.net.Uri
import android.os.Build
import androidx.core.content.getSystemService
import eu.weblibre.flutter_mozilla_components.GlobalComponents
import eu.weblibre.flutter_mozilla_components.PwaConstants
import eu.weblibre.flutter_mozilla_components.activities.IntentReceiverActivity
import eu.weblibre.flutter_mozilla_components.pigeons.ExternalApplicationResource
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoPwaApi
import eu.weblibre.flutter_mozilla_components.pigeons.PwaIcon
import eu.weblibre.flutter_mozilla_components.pigeons.PwaManifest
import eu.weblibre.flutter_mozilla_components.pigeons.ShareTarget
import eu.weblibre.flutter_mozilla_components.pigeons.ShareTargetFiles
import eu.weblibre.flutter_mozilla_components.pigeons.ShareTargetParams
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import mozilla.components.browser.icons.IconRequest
import mozilla.components.browser.state.selector.findTab
import mozilla.components.browser.state.selector.selectedTab
import mozilla.components.concept.engine.manifest.WebAppManifest
import mozilla.components.support.base.log.logger.Logger
import java.io.File
import java.security.MessageDigest
import java.util.UUID

/**
 * Implementation of GeckoPwaApi that provides PWA install and query functionality.
 *
 * Creates custom shortcuts with profile and container metadata embedded in intent extras,
 * ensuring PWAs reopen with the same profile and container context.
 */
class GeckoPwaApiImpl(
    private val context: Context
) : GeckoPwaApi {
    companion object {
        private val coroutineScope = CoroutineScope(Dispatchers.Default + SupervisorJob())
    }

    private val logger = Logger("GeckoPwaApiImpl")
    private val appPrefs by lazy {
        context.applicationContext.getSharedPreferences(
            PwaConstants.PROFILE_MAPPING_PREFS,
            Context.MODE_PRIVATE,
        )
    }

    private val components by lazy {
        requireNotNull(GlobalComponents.components) { "Components not initialized" }
    }

    override fun installWebApp(
        tabId: String?,
        profileUuid: String,
        contextId: String?,
        callback: (Result<Boolean>) -> Unit
    ) {
        logger.debug("installWebApp called for tabId: $tabId, profileUuid: $profileUuid, contextId: $contextId")
        coroutineScope.launch {
            try {
                val store = components.core.store
                val tab = if (tabId != null) {
                    store.state.findTab(tabId)
                } else {
                    store.state.selectedTab
                }

                if (tab == null) {
                    logger.warn("Tab not found for installWebApp: $tabId")
                    callback(Result.success(false))
                    return@launch
                }

                val manifest = tab.content.webAppManifest
                if (manifest == null) {
                    logger.warn("No manifest found for tab ${tab.id}")
                    callback(Result.success(false))
                    return@launch
                }

                logger.debug("Installing web app for tab ${tab.id}: ${manifest.startUrl}")

                val success = createPwaShortcut(
                    manifest = manifest,
                    profileUuid = profileUuid,
                    contextId = contextId,
                )

                if (success) {
                    components.core.webAppManifestStorage.saveManifest(manifest)
                    storeProfileMapping(manifest.startUrl, profileUuid)
                    logger.debug("Web app installation completed for tab ${tab.id}")
                } else {
                    logger.warn("Failed to create PWA shortcut for tab ${tab.id}")
                }

                callback(Result.success(success))
            } catch (e: Exception) {
                logger.error("Failed to install web app", e)
                callback(Result.failure(e))
            }
        }
    }

    /**
     * Creates a PWA shortcut with profile and container metadata in intent extras.
     */
    private suspend fun createPwaShortcut(
        manifest: WebAppManifest,
        profileUuid: String,
        contextId: String?,
    ): Boolean = withContext(Dispatchers.Main) {
        try {
            if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) {
                logger.warn("Pinned shortcuts require Android O or later")
                return@withContext false
            }

            val shortcutManager = context.getSystemService<ShortcutManager>()
                ?: run {
                    logger.error("ShortcutManager not available")
                    return@withContext false
                }

            if (!shortcutManager.isRequestPinShortcutSupported) {
                logger.warn("Pinning shortcuts is not supported")
                return@withContext false
            }

            val (iconBitmap, isMaskable) = loadPwaIcon(manifest)

            val shortcutId = generateShortcutId(manifest.startUrl, profileUuid)
            val launchToken = resolveLaunchToken(
                shortcutManager = shortcutManager,
                shortcutId = shortcutId,
                startUrl = manifest.startUrl,
                profileUuid = profileUuid,
            )

            val appName = manifest.shortName ?: manifest.name ?: "Web App"

            val shortcutIntent = Intent(context, IntentReceiverActivity::class.java).apply {
                action = Intent.ACTION_VIEW
                data = Uri.parse(manifest.startUrl)
                putExtra(PwaConstants.EXTRA_PWA_PROFILE_UUID, profileUuid)
                putExtra(PwaConstants.EXTRA_PWA_CONTEXT_ID, contextId)
                putExtra(PwaConstants.EXTRA_PWA_TOKEN, launchToken)
                putExtra(PwaConstants.EXTRA_PWA_INSTALL_START_URL, manifest.startUrl)
            }

            val shortcut = ShortcutInfo.Builder(context, shortcutId).apply {
                setShortLabel(appName)
                setLongLabel(manifest.name ?: appName)
                setIntent(shortcutIntent)

                if (iconBitmap != null) {
                    // Only use adaptive bitmap for maskable icons (designed for adaptive shapes)
                    // Regular icons should use createWithBitmap to display as-is
                    if (isMaskable && Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                        setIcon(Icon.createWithAdaptiveBitmap(iconBitmap))
                    } else {
                        setIcon(Icon.createWithBitmap(iconBitmap))
                    }
                }
            }.build()

            val success = shortcutManager.requestPinShortcut(shortcut, null)
            logger.debug("PWA shortcut creation result: $success")
            success
        } catch (e: Exception) {
            logger.error("Failed to create PWA shortcut", e)
            false
        }
    }

    /**
     * Generates a collision-resistant shortcut ID from URL + profile using SHA-256.
     */
    private fun generateShortcutId(url: String, profileUuid: String): String {
        val digest = MessageDigest.getInstance("SHA-256")
        val hash = digest.digest("$url::$profileUuid".toByteArray())
        val hex = hash.take(16).joinToString("") { "%02x".format(it) }
        return "pwa_$hex"
    }

    /**
     * Loads the PWA icon from the manifest using BrowserIcons.
     * Returns a pair of (bitmap, isMaskable) to determine proper icon format.
     */
    private suspend fun loadPwaIcon(manifest: WebAppManifest): Pair<Bitmap?, Boolean> = withContext(Dispatchers.IO) {
        try {
            val iconResource = manifest.icons
                .filter { it.purpose.contains(WebAppManifest.Icon.Purpose.MASKABLE) ||
                         it.purpose.contains(WebAppManifest.Icon.Purpose.ANY) }
                .maxByOrNull { (it.sizes?.maxOf { size -> size.width * size.height } ?: 0) }
                ?: manifest.icons.firstOrNull()

            if (iconResource != null) {
                val isMaskable = iconResource.purpose.contains(WebAppManifest.Icon.Purpose.MASKABLE)
                val iconRequest = IconRequest(
                    url = manifest.startUrl,
                    size = IconRequest.Size.LAUNCHER_ADAPTIVE,
                    resources = listOf(
                        IconRequest.Resource(
                            url = iconResource.src,
                            type = IconRequest.Resource.Type.MANIFEST_ICON,
                            sizes = iconResource.sizes?.map { size ->
                                mozilla.components.concept.engine.manifest.Size(size.width, size.height)
                            } ?: emptyList(),
                            mimeType = iconResource.type,
                            maskable = isMaskable
                        )
                    )
                )

                val iconResult = components.core.icons.loadIcon(iconRequest).await()
                Pair(iconResult?.bitmap, isMaskable)
            } else {
                Pair(null, false)
            }
        } catch (e: Exception) {
            logger.error("Failed to load PWA icon", e)
            Pair(null, false)
        }
    }

    override fun getInstalledWebApps(callback: (Result<List<PwaManifest>>) -> Unit) {
        logger.debug("getInstalledWebApps called")
        coroutineScope.launch {
            try {
                val storage = components.core.webAppManifestStorage
                val manifests = storage.loadShareableManifests(System.currentTimeMillis())
                val currentProfileUuid = getCurrentProfileUuid()
                val pwaManifests = manifests.filter { manifest ->
                    val mappedProfile = getProfileMapping(manifest.startUrl)
                    currentProfileUuid == null || mappedProfile == null || mappedProfile == currentProfileUuid
                }.map { manifest ->
                    manifest.toPwaManifest()
                }
                logger.debug("Found ${pwaManifests.size} installed web apps")
                callback(Result.success(pwaManifests))
            } catch (e: Exception) {
                logger.error("Failed to get installed web apps", e)
                callback(Result.failure(e))
            }
        }
    }

    private fun storeProfileMapping(startUrl: String, profileUuid: String) {
        appPrefs.edit()
            .putString(startUrl, profileUuid)
            .apply()
    }

    private fun resolveLaunchToken(
        shortcutManager: ShortcutManager,
        shortcutId: String,
        startUrl: String,
        profileUuid: String,
    ): String {
        val storedToken = getStoredLaunchToken(startUrl, profileUuid)
        val existingShortcutToken = shortcutManager.pinnedShortcuts
            .firstOrNull { shortcut -> shortcut.id == shortcutId }
            ?.intent
            ?.takeIf { shortcutIntent ->
                shortcutIntent.getStringExtra(PwaConstants.EXTRA_PWA_PROFILE_UUID) == profileUuid
            }
            ?.getStringExtra(PwaConstants.EXTRA_PWA_TOKEN)

        if (!existingShortcutToken.isNullOrEmpty()) {
            val committed = storeLaunchToken(startUrl, profileUuid, existingShortcutToken)
            if (!committed) {
                logger.warn("Failed to persist pinned shortcut PWA token for $startUrl")
            }
            return existingShortcutToken
        }

        if (!storedToken.isNullOrEmpty()) {
            val committed = storeLaunchToken(startUrl, profileUuid, storedToken)
            if (!committed) {
                logger.warn("Failed to refresh stored PWA launch token index for $startUrl")
            }
            return storedToken
        }

        val generatedToken = UUID.randomUUID().toString()
        val committed = storeLaunchToken(startUrl, profileUuid, generatedToken)
        if (!committed) {
            logger.warn("Failed to persist PWA launch token for $startUrl")
        }
        return generatedToken
    }

    private fun getStoredLaunchToken(startUrl: String, profileUuid: String): String? {
        val tokenKey = "${PwaConstants.PROFILE_MAPPING_TOKEN_PREFIX}${startUrl}::${profileUuid}"
        return appPrefs.getString(tokenKey, null)
    }

    private fun storeLaunchToken(startUrl: String, profileUuid: String, token: String): Boolean {
        val tokenKey = "${PwaConstants.PROFILE_MAPPING_TOKEN_PREFIX}${startUrl}::${profileUuid}"
        return appPrefs.edit()
            .putString(tokenKey, token)
            .commit()
    }

    private fun getProfileMapping(startUrl: String): String? {
        return appPrefs.getString(startUrl, null)
    }

    private fun getCurrentProfileUuid(): String? {
        return try {
            val startupProfileFile = File(context.filesDir, PwaConstants.CURRENT_PROFILE_FILE)
            if (startupProfileFile.exists()) {
                startupProfileFile.readText().trim().ifEmpty { null }
            } else {
                null
            }
        } catch (e: Exception) {
            logger.error("Failed to read current profile UUID", e)
            null
        }
    }

    private fun WebAppManifest.toPwaManifest(currentUrl: String = startUrl): PwaManifest {
        return PwaManifest(
            startUrl = startUrl,
            currentUrl = currentUrl,
            name = name,
            shortName = shortName,
            display = display?.name?.lowercase(),
            themeColor = themeColor?.let { String.format("#%06X", 0xFFFFFF and it) },
            backgroundColor = backgroundColor?.let { String.format("#%06X", 0xFFFFFF and it) },
            scope = scope,
            description = description,
            icons = icons.map { icon ->
                PwaIcon(
                    src = icon.src,
                    sizes = icon.sizes?.joinToString(" ") { "${it.width}x${it.height}" },
                    type = icon.type,
                )
            },
            dir = dir?.name?.lowercase(),
            lang = lang,
            orientation = orientation?.name?.lowercase(),
            relatedApplications = relatedApplications.map { app ->
                ExternalApplicationResource(
                    platform = app.platform,
                    url = app.url,
                    id = app.id,
                    minVersion = app.minVersion,
                )
            },
            preferRelatedApplications = preferRelatedApplications,
            shareTarget = shareTarget?.let { target ->
                ShareTarget(
                    action = target.action,
                    method = target.method?.name,
                    encType = target.encType?.type,
                    params = target.params?.let { params ->
                        ShareTargetParams(
                            title = params.title,
                            text = params.text,
                            url = params.url,
                            files = params.files.map { file ->
                                ShareTargetFiles(
                                    name = file.name,
                                    accept = file.accept,
                                )
                            },
                        )
                    },
                )
            },
        )
    }
}
