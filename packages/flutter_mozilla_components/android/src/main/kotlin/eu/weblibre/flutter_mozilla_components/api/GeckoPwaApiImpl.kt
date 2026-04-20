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

    private enum class ShortcutKind(
        val shortcutType: String,
        val idPrefix: String,
    ) {
        PWA(PwaConstants.SHORTCUT_TYPE_PWA, "pwa"),
        BASIC(PwaConstants.SHORTCUT_TYPE_BASIC, "shortcut"),
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
        overrideAppName: String?,
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

                val baseManifest = tab.content.webAppManifest ?: run {
                    // Generate a synthetic manifest for sites without one
                    val url = tab.content.url
                    val title = tab.content.title.ifBlank { url }
                    logger.debug("Generating synthetic manifest for tab ${tab.id}: $url")
                    WebAppManifest(
                        name = title,
                        startUrl = url,
                        display = WebAppManifest.DisplayMode.STANDALONE,
                        scope = extractScope(url),
                    )
                }

                val manifest = overrideAppName?.takeIf { it.isNotBlank() }?.let { name ->
                    baseManifest.copy(name = name, shortName = name)
                } ?: baseManifest

                logger.debug("Installing web app for tab ${tab.id}: ${manifest.startUrl}")

                val success = createPwaShortcut(
                    manifest = manifest,
                    profileUuid = profileUuid,
                    contextId = contextId,
                    tabFavicon = tab.content.icon,
                )

                if (success) {
                    // Persist the unmodified manifest so a second install
                    // of the same URL with a different overrideAppName or
                    // contextId does not clobber the first install's
                    // standalone-window metadata. The user-chosen label
                    // lives on the shortcut itself.
                    components.core.webAppManifestStorage.saveManifest(baseManifest)
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
        tabFavicon: Bitmap?,
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

            // Prefer a manifest icon when available; for synthetic manifests
            // (no icons declared) fall back to the tab favicon so we always
            // ship a shortcut icon — some launchers crash when pinning a
            // shortcut without one.
            val iconBitmap = loadPwaIcon(manifest)
                ?: loadTabFaviconBitmap(manifest.startUrl, tabFavicon)

            val appName = manifest.shortName ?: manifest.name ?: "Web App"

            val shortcutId = resolveShortcutId(
                shortcutManager = shortcutManager,
                url = manifest.startUrl,
                profileUuid = profileUuid,
                contextId = contextId,
                shortcutKind = ShortcutKind.PWA,
            )
            val launchToken = resolveLaunchToken(
                shortcutManager = shortcutManager,
                shortcutId = shortcutId,
                startUrl = manifest.startUrl,
                profileUuid = profileUuid,
                contextId = contextId,
            )

            val shortcutIntent = Intent(context, IntentReceiverActivity::class.java).apply {
                action = Intent.ACTION_VIEW
                data = Uri.parse(manifest.startUrl)
                putExtra(PwaConstants.EXTRA_PWA_PROFILE_UUID, profileUuid)
                putExtra(PwaConstants.EXTRA_PWA_CONTEXT_ID, contextId)
                putExtra(PwaConstants.EXTRA_PWA_TOKEN, launchToken)
                putExtra(PwaConstants.EXTRA_PWA_INSTALL_START_URL, manifest.startUrl)
                putExtra(PwaConstants.EXTRA_SHORTCUT_TYPE, ShortcutKind.PWA.shortcutType)
                putExtra(
                    PwaConstants.EXTRA_SHORTCUT_CONTAINER_MODE,
                    resolveShortcutContainerMode(contextId),
                )
            }

            val shortcut = ShortcutInfo.Builder(context, shortcutId).apply {
                setShortLabel(appName)
                setLongLabel(manifest.name ?: appName)
                setIntent(shortcutIntent)

                if (iconBitmap != null) {
                    // Always use createWithBitmap (never createWithAdaptiveBitmap):
                    // Launcher3's pin-preview routes adaptive icons through
                    // AdaptiveIconDrawable + BitmapShader and promotes intermediates
                    // to HARDWARE, crashing the software preview canvas.
                    setIcon(Icon.createWithBitmap(iconBitmap))
                }
            }.build()

            // Update an existing install of the same kind in place. Some
            // launchers reuse cached shortcut metadata unless we explicitly
            // refresh the pinned record first.
            updateExistingShortcut(shortcutManager, shortcut)

            val success = shortcutManager.requestPinShortcut(shortcut, null)
            logger.debug("PWA shortcut creation result: $success")
            success
        } catch (e: Exception) {
            logger.error("Failed to create PWA shortcut", e)
            false
        }
    }

    /**
     * Updates an existing pinned/cached shortcut's intent and metadata.
     * This is necessary because requestPinShortcut may reuse the old cached intent
     * on some launchers instead of the new ShortcutInfo's intent.
     */
    private fun updateExistingShortcut(shortcutManager: ShortcutManager, shortcut: ShortcutInfo) {
        try {
            val existingIds = shortcutManager.pinnedShortcuts.map { it.id }.toSet()
            if (shortcut.id in existingIds) {
                shortcutManager.updateShortcuts(listOf(shortcut))
                logger.debug("Updated existing pinned shortcut: ${shortcut.id}")
            }
        } catch (e: Exception) {
            logger.debug("Could not update existing shortcut (may not exist): ${e.message}")
        }
    }

    /**
     * Resolves the shortcut ID for the current install kind.
     *
     * New installs use a kind-specific ID so a standalone PWA and a regular
     * shortcut for the same site do not overwrite each other. For minimal
     * migration handling, we still reuse the legacy shared ID if a pinned
     * shortcut with that ID already exists for the same kind.
     */
    private fun resolveShortcutId(
        shortcutManager: ShortcutManager,
        url: String,
        profileUuid: String,
        contextId: String? = null,
        shortcutKind: ShortcutKind,
    ): String {
        val typedShortcutId = generateShortcutId(
            url = url,
            profileUuid = profileUuid,
            contextId = contextId,
            shortcutKind = shortcutKind,
        )
        if (shortcutManager.pinnedShortcuts.any { it.id == typedShortcutId }) {
            return typedShortcutId
        }

        val legacyShortcutId = generateLegacyShortcutId(
            url = url,
            profileUuid = profileUuid,
            contextId = contextId,
        )
        val matchingLegacyShortcut = shortcutManager.pinnedShortcuts.firstOrNull { shortcut ->
            if (shortcut.id != legacyShortcutId) {
                return@firstOrNull false
            }

            val shortcutIntent = shortcut.intent ?: return@firstOrNull false
            shortcutIntent.getStringExtra(PwaConstants.EXTRA_PWA_PROFILE_UUID) == profileUuid &&
                shortcutIntent.getStringExtra(PwaConstants.EXTRA_SHORTCUT_TYPE) == shortcutKind.shortcutType
        }
        return matchingLegacyShortcut?.id ?: typedShortcutId
    }

    /**
     * Generates a collision-resistant shortcut ID from (type, url, profile,
     * contextId) using SHA-256. The display label is deliberately excluded
     * because it is presentation, not install identity.
     */
    private fun generateShortcutId(
        url: String,
        profileUuid: String,
        contextId: String? = null,
        shortcutKind: ShortcutKind,
    ): String {
        val digest = MessageDigest.getInstance("SHA-256")
        val key = if (contextId.isNullOrEmpty()) {
            "${shortcutKind.shortcutType}::$url::$profileUuid"
        } else {
            "${shortcutKind.shortcutType}::$url::$profileUuid::$contextId"
        }
        val hash = digest.digest(key.toByteArray())
        val hex = hash.take(16).joinToString("") { "%02x".format(it) }
        return "${shortcutKind.idPrefix}_$hex"
    }

    /**
     * Historical shared shortcut ID used before install kind became part of
     * the identity. Both PWAs and basic shortcuts previously reused this ID.
     */
    private fun generateLegacyShortcutId(
        url: String,
        profileUuid: String,
        contextId: String? = null,
    ): String {
        val digest = MessageDigest.getInstance("SHA-256")
        val key = if (contextId.isNullOrEmpty()) {
            "$url::$profileUuid"
        } else {
            "$url::$profileUuid::$contextId"
        }
        val hash = digest.digest(key.toByteArray())
        val hex = hash.take(16).joinToString("") { "%02x".format(it) }
        return "pwa_$hex"
    }

    private fun resolveShortcutContainerMode(contextId: String?): String {
        return if (contextId.isNullOrEmpty()) {
            PwaConstants.SHORTCUT_CONTAINER_MODE_UNASSIGNED
        } else {
            PwaConstants.SHORTCUT_CONTAINER_MODE_SPECIFIC
        }
    }

    /**
     * Loads the PWA icon from the manifest using BrowserIcons. Requested at
     * plain LAUNCHER size since the shortcut is set as a non-adaptive bitmap.
     */
    private suspend fun loadPwaIcon(manifest: WebAppManifest): Bitmap? = withContext(Dispatchers.IO) {
        try {
            val iconResource = manifest.icons
                .filter { it.purpose.contains(WebAppManifest.Icon.Purpose.MASKABLE) ||
                         it.purpose.contains(WebAppManifest.Icon.Purpose.ANY) }
                .maxByOrNull { (it.sizes?.maxOf { size -> size.width * size.height } ?: 0) }
                ?: manifest.icons.firstOrNull()
                ?: return@withContext null

            val iconRequest = IconRequest(
                url = manifest.startUrl,
                size = IconRequest.Size.LAUNCHER,
                resources = listOf(
                    IconRequest.Resource(
                        url = iconResource.src,
                        type = IconRequest.Resource.Type.MANIFEST_ICON,
                        sizes = iconResource.sizes?.map { size ->
                            mozilla.components.concept.engine.manifest.Size(size.width, size.height)
                        } ?: emptyList(),
                        mimeType = iconResource.type,
                    )
                )
            )

            components.core.icons.loadIcon(iconRequest).await()?.bitmap
        } catch (e: Exception) {
            logger.error("Failed to load PWA icon", e)
            null
        }
    }

    override fun installBasicShortcut(
        tabId: String?,
        profileUuid: String,
        contextId: String?,
        overrideShortcutName: String?,
        callback: (Result<Boolean>) -> Unit
    ) {
        logger.debug("installBasicShortcut called for tabId: $tabId, profileUuid: $profileUuid")
        coroutineScope.launch {
            try {
                val store = components.core.store
                val tab = if (tabId != null) {
                    store.state.findTab(tabId)
                } else {
                    store.state.selectedTab
                }

                if (tab == null) {
                    logger.warn("Tab not found for installBasicShortcut: $tabId")
                    callback(Result.success(false))
                    return@launch
                }

                val success = createBasicShortcut(
                    url = tab.content.url,
                    title = overrideShortcutName ?: tab.content.title,
                    tabIcon = tab.content.icon,
                    profileUuid = profileUuid,
                    contextId = contextId,
                )

                callback(Result.success(success))
            } catch (e: Exception) {
                logger.error("Failed to create basic shortcut", e)
                callback(Result.failure(e))
            }
        }
    }

    /**
     * Creates a basic bookmark-style shortcut that opens in a regular browser tab.
     * Does not require or store a manifest.
     */
    private suspend fun createBasicShortcut(
        url: String,
        title: String,
        tabIcon: Bitmap?,
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

            val shortLabel = title.ifBlank { url }

            val shortcutId = resolveShortcutId(
                shortcutManager = shortcutManager,
                url = url,
                profileUuid = profileUuid,
                contextId = contextId,
                shortcutKind = ShortcutKind.BASIC,
            )
            val launchToken = resolveLaunchToken(
                shortcutManager = shortcutManager,
                shortcutId = shortcutId,
                startUrl = url,
                profileUuid = profileUuid,
                contextId = contextId,
            )

            val shortcutIntent = Intent(context, IntentReceiverActivity::class.java).apply {
                action = Intent.ACTION_VIEW
                data = Uri.parse(url)
                putExtra(PwaConstants.EXTRA_PWA_PROFILE_UUID, profileUuid)
                putExtra(PwaConstants.EXTRA_PWA_CONTEXT_ID, contextId)
                putExtra(PwaConstants.EXTRA_PWA_TOKEN, launchToken)
                putExtra(PwaConstants.EXTRA_PWA_INSTALL_START_URL, url)
                putExtra(PwaConstants.EXTRA_SHORTCUT_TYPE, ShortcutKind.BASIC.shortcutType)
                putExtra(
                    PwaConstants.EXTRA_SHORTCUT_CONTAINER_MODE,
                    resolveShortcutContainerMode(contextId),
                )
            }

            val icon = loadTabIcon(url, tabIcon)

            val shortcut = ShortcutInfo.Builder(context, shortcutId).apply {
                setShortLabel(shortLabel)
                setLongLabel(shortLabel)
                setIntent(shortcutIntent)
                icon?.let { setIcon(it) }
            }.build()

            // Update an existing install of the same kind in place.
            updateExistingShortcut(shortcutManager, shortcut)

            val success = shortcutManager.requestPinShortcut(shortcut, null)
            logger.debug("Basic shortcut creation result: $success")
            success
        } catch (e: Exception) {
            logger.error("Failed to create basic shortcut", e)
            false
        }
    }

    /**
     * Loads a favicon-style bitmap for [url], preferring the in-memory tab icon
     * and falling back to BrowserIcons at LAUNCHER size. Returns a live bitmap
     * (caller is responsible for converting to software before use).
     */
    private suspend fun loadTabFaviconBitmap(
        url: String,
        tabIcon: Bitmap?,
    ): Bitmap? = withContext(Dispatchers.IO) {
        try {
            tabIcon?.takeUnless { it.isRecycled }
                ?: run {
                    val iconRequest = IconRequest(
                        url = url,
                        size = IconRequest.Size.LAUNCHER,
                    )
                    components.core.icons.loadIcon(iconRequest).await()?.bitmap
                }
        } catch (e: Exception) {
            logger.error("Failed to load tab favicon bitmap", e)
            null
        }
    }

    /**
     * Loads an icon for the shortcut from the tab's favicon or BrowserIcons.
     */
    private suspend fun loadTabIcon(url: String, tabIcon: Bitmap?): Icon? {
        val bitmap = loadTabFaviconBitmap(url, tabIcon)
        return bitmap?.takeUnless { it.isRecycled }?.let(Icon::createWithBitmap)
    }

    /**
     * Extracts the scope from a URL (origin + path up to last segment).
     */
    private fun extractScope(url: String): String {
        return try {
            val uri = Uri.parse(url)
            val path = uri.path ?: "/"
            val scopePath = if (path.contains("/")) {
                path.substringBeforeLast("/") + "/"
            } else {
                "/"
            }
            uri.buildUpon().path(scopePath).clearQuery().fragment(null).build().toString()
        } catch (e: Exception) {
            url
        }
    }

    override fun getInstalledWebApps(callback: (Result<List<PwaManifest>>) -> Unit) {
        logger.debug("getInstalledWebApps called")
        coroutineScope.launch {
            try {
                val storage = components.core.webAppManifestStorage
                val currentProfileUuid = getCurrentProfileUuid()

                // Pinned shortcuts are the source of truth for installs: each
                // pinned shortcut carries its own label, profile, and
                // contextId in its intent extras. Two installs of the same
                // URL with different contextIds or labels are two distinct
                // shortcuts here, even though Mozilla's manifest storage
                // keys the underlying manifest by URL only. We join the
                // shared manifest with per-install fields from each shortcut.
                val pwaShortcuts = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    context.getSystemService<ShortcutManager>()?.pinnedShortcuts
                        ?.filter { shortcut ->
                            val intent = shortcut.intent ?: return@filter false
                            intent.getStringExtra(PwaConstants.EXTRA_SHORTCUT_TYPE) ==
                                PwaConstants.SHORTCUT_TYPE_PWA
                        }
                        ?: emptyList()
                } else {
                    emptyList()
                }

                val pwaManifests = pwaShortcuts.mapNotNull { shortcut ->
                    val intent = shortcut.intent ?: return@mapNotNull null
                    val shortcutProfile =
                        intent.getStringExtra(PwaConstants.EXTRA_PWA_PROFILE_UUID)
                    if (currentProfileUuid != null &&
                        shortcutProfile != null &&
                        shortcutProfile != currentProfileUuid
                    ) {
                        return@mapNotNull null
                    }

                    val installStartUrl =
                        intent.getStringExtra(PwaConstants.EXTRA_PWA_INSTALL_START_URL)
                            ?: intent.dataString
                            ?: return@mapNotNull null
                    val manifest = storage.loadManifest(installStartUrl)
                        ?: return@mapNotNull null

                    manifest.toPwaManifest(
                        contextId = intent.getStringExtra(PwaConstants.EXTRA_PWA_CONTEXT_ID),
                        installLabel = shortcut.shortLabel?.toString(),
                    )
                }

                logger.debug("Found ${pwaManifests.size} installed web apps")
                callback(Result.success(pwaManifests))
            } catch (e: Exception) {
                logger.error("Failed to get installed web apps", e)
                callback(Result.failure(e))
            }
        }
    }

    private fun resolveLaunchToken(
        shortcutManager: ShortcutManager,
        shortcutId: String,
        startUrl: String,
        profileUuid: String,
        contextId: String?,
    ): String {
        val storedToken = getStoredLaunchToken(startUrl, profileUuid, contextId)
        val existingShortcutToken = shortcutManager.pinnedShortcuts
            .firstOrNull { shortcut -> shortcut.id == shortcutId }
            ?.intent
            ?.takeIf { shortcutIntent ->
                shortcutIntent.getStringExtra(PwaConstants.EXTRA_PWA_PROFILE_UUID) == profileUuid
            }
            ?.getStringExtra(PwaConstants.EXTRA_PWA_TOKEN)

        if (!existingShortcutToken.isNullOrEmpty()) {
            val committed = storeLaunchToken(startUrl, profileUuid, contextId, existingShortcutToken)
            if (!committed) {
                logger.warn("Failed to persist pinned shortcut PWA token for $startUrl")
            }
            return existingShortcutToken
        }

        if (!storedToken.isNullOrEmpty()) {
            val committed = storeLaunchToken(startUrl, profileUuid, contextId, storedToken)
            if (!committed) {
                logger.warn("Failed to refresh stored PWA launch token index for $startUrl")
            }
            return storedToken
        }

        val generatedToken = UUID.randomUUID().toString()
        val committed = storeLaunchToken(startUrl, profileUuid, contextId, generatedToken)
        if (!committed) {
            logger.warn("Failed to persist PWA launch token for $startUrl")
        }
        return generatedToken
    }

    private fun tokenKey(startUrl: String, profileUuid: String, contextId: String?): String {
        // Keyed by (startUrl, profileUuid, contextId) so multiple installs of
        // the same URL with different storage contexts each keep their own
        // token and don't share or overwrite each other.
        return "${PwaConstants.PROFILE_MAPPING_TOKEN_PREFIX}${startUrl}::${profileUuid}::${contextId.orEmpty()}"
    }

    private fun legacyTokenKey(startUrl: String, profileUuid: String): String {
        return "${PwaConstants.PROFILE_MAPPING_TOKEN_PREFIX}${startUrl}::${profileUuid}"
    }

    private fun getStoredLaunchToken(startUrl: String, profileUuid: String, contextId: String?): String? {
        return appPrefs.getString(tokenKey(startUrl, profileUuid, contextId), null)
            ?: if (contextId.isNullOrEmpty()) {
                appPrefs.getString(legacyTokenKey(startUrl, profileUuid), null)
            } else {
                null
            }
    }

    private fun storeLaunchToken(startUrl: String, profileUuid: String, contextId: String?, token: String): Boolean {
        return appPrefs.edit().apply {
            putString(tokenKey(startUrl, profileUuid, contextId), token)
            if (contextId.isNullOrEmpty()) {
                putString(legacyTokenKey(startUrl, profileUuid), token)
            }
        }.commit()
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

    private fun WebAppManifest.toPwaManifest(
        currentUrl: String = startUrl,
        contextId: String? = null,
        installLabel: String? = null,
    ): PwaManifest {
        return PwaManifest(
            startUrl = startUrl,
            currentUrl = currentUrl,
            contextId = contextId,
            installLabel = installLabel,
            name = name,
            shortName = shortName,
            display = display?.name?.lowercase()?.replace("_", "-"),
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
