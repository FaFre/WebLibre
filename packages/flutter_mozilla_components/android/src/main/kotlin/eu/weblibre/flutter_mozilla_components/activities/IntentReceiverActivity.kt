/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.activities

import android.app.Activity
import android.app.AlertDialog
import android.content.Context
import android.content.Intent
import android.content.pm.ShortcutManager
import android.os.Build
import android.os.Bundle
import android.util.Log
import eu.weblibre.flutter_mozilla_components.Components
import eu.weblibre.flutter_mozilla_components.GlobalComponents
import eu.weblibre.flutter_mozilla_components.PwaConstants
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import mozilla.components.feature.customtabs.CustomTabIntentProcessor
import mozilla.components.feature.intent.ext.getSessionId
import mozilla.components.feature.pwa.intent.WebAppIntentProcessor
import mozilla.components.browser.state.state.ExternalAppType
import java.io.File

/**
 * Lightweight transparent activity that receives all ACTION_VIEW intents and routes them
 * to the appropriate activity:
 * - Custom Tab intents → [ExternalAppBrowserActivity]
 * - PWA launch intents → [ExternalAppBrowserActivity] (with profile/context tracking)
 * - Regular VIEW intents → MainActivity (Flutter)
 *
 * For PWA intents created by our custom installer, checks profile match and shows dialog
 * if the current profile differs from the installation profile.
 */
class IntentReceiverActivity : Activity() {
    companion object {
        private const val TAG = "IntentReceiverActivity"
    }

    private val coroutineScope = CoroutineScope(Dispatchers.Main + SupervisorJob())

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        val intent = intent?.let { Intent(it) } ?: Intent()

        Log.d(TAG, "onCreate: action=${intent.action} data=${intent.dataString}")

        // Strip flags that could interfere with task management
        intent.flags = intent.flags and Intent.FLAG_ACTIVITY_NEW_TASK.inv()
        intent.flags = intent.flags and Intent.FLAG_ACTIVITY_CLEAR_TASK.inv()

        processIntent(intent)
    }

    override fun onDestroy() {
        super.onDestroy()
        coroutineScope.cancel()
    }

    private fun processIntent(intent: Intent) {
        if (GlobalComponents.components == null) {
            if (GlobalComponents.ensureExternalComponents(applicationContext)) {
                routeIntent(intent)
                return
            }

            Log.w(TAG, "Components not initialized, routing directly to MainActivity")
            handleRegularIntent(intent)
            return
        }

        routeIntent(intent)
    }

    private fun routeIntent(intent: Intent) {
        // Check if this is our custom PWA intent with profile metadata
        val profileUuid = intent.getStringExtra(PwaConstants.EXTRA_PWA_PROFILE_UUID)
        val contextId = intent.getStringExtra(PwaConstants.EXTRA_PWA_CONTEXT_ID)
        val token = intent.getStringExtra(PwaConstants.EXTRA_PWA_TOKEN)
        if (profileUuid != null) {
            if (isTrustedPwaLaunch(intent, profileUuid, token)) {
                Log.d(TAG, "Trusted PWA intent with profile metadata: profileUuid=$profileUuid, contextId=$contextId")
                handlePwaIntent(intent, profileUuid, contextId)
                return
            }

            Log.w(TAG, "Ignoring untrusted PWA profile metadata on VIEW intent")
        }

        // Fall back to standard intent processors for Custom Tabs and legacy PWAs
        val components = GlobalComponents.components
            ?: run {
                Log.e(TAG, "Components became null during routing")
                handleRegularIntent(intent)
                return
            }

        val processors = listOf(
            "CustomTab" to CustomTabIntentProcessor(
                components.useCases.customTabsUseCases.add,
                resources,
                isPrivate = false,
            ),
            "PWA" to WebAppIntentProcessor(
                components.core.store,
                components.useCases.customTabsUseCases.addWebApp,
                components.useCases.sessionUseCases.loadUrl,
                components.core.webAppManifestStorage,
            ),
        )

        for ((name, processor) in processors) {
            Log.d(TAG, "Trying $name processor...")
            try {
                val result = processor.process(intent)
                Log.d(TAG, "$name processor result: $result")
                if (result) {
                    val sessionId = intent.getSessionId()
                        ?: resolveSessionIdFromStore(name, intent, components)
                    Log.d(TAG, "$name session ID from intent: $sessionId")
                    if (sessionId != null) {
                        val externalIntent = ExternalAppBrowserActivity.createIntent(
                            context = this,
                            customTabSessionId = sessionId,
                            webAppManifestUrl = if (name == "PWA") intent.dataString else null,
                        )
                        startActivity(externalIntent)
                        finish()
                        return
                    } else {
                        Log.w(TAG, "$name processor succeeded but no session ID in intent!")
                    }
                }
            } catch (e: Exception) {
                Log.e(TAG, "Error in $name processor", e)
            }
        }

        Log.d(TAG, "No processor matched, routing to MainActivity")
        handleRegularIntent(intent)
    }

    private fun isTrustedPwaLaunch(intent: Intent, profileUuid: String, token: String?): Boolean {
        val intentUrl = intent.dataString ?: return false
        val installStartUrl = intent.getStringExtra(PwaConstants.EXTRA_PWA_INSTALL_START_URL)
        val action = intent.action
        val hasTrustedAction = action == Intent.ACTION_VIEW || action == "mozilla.components.feature.pwa.VIEW_PWA"
        if (!hasTrustedAction || token.isNullOrEmpty()) {
            return false
        }

        val prefs = applicationContext.getSharedPreferences(
            PwaConstants.PROFILE_MAPPING_PREFS,
            Context.MODE_PRIVATE,
        )
        val tokenKey = "${PwaConstants.PROFILE_MAPPING_TOKEN_PREFIX}${intentUrl}::${profileUuid}"
        if (prefs.getString(tokenKey, null) == token) {
            return true
        }

        if (!installStartUrl.isNullOrEmpty() && installStartUrl != intentUrl) {
            val installTokenKey = "${PwaConstants.PROFILE_MAPPING_TOKEN_PREFIX}${installStartUrl}::${profileUuid}"
            if (prefs.getString(installTokenKey, null) == token) {
                return true
            }
        }

        if (isPinnedShortcutTokenMatch(intentUrl, profileUuid, token, installStartUrl)) {
            return true
        }

        Log.w(TAG, "PWA token mismatch for $intentUrl")
        return false
    }

    private fun isPinnedShortcutTokenMatch(
        intentUrl: String,
        profileUuid: String,
        token: String,
        installStartUrl: String?,
    ): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) {
            return false
        }

        val shortcutManager = getSystemService(ShortcutManager::class.java) ?: return false
        return shortcutManager.pinnedShortcuts.any { shortcut ->
            val shortcutIntent = shortcut.intent ?: return@any false
            if (shortcutIntent.getStringExtra(PwaConstants.EXTRA_PWA_PROFILE_UUID) != profileUuid) {
                return@any false
            }

            if (shortcutIntent.getStringExtra(PwaConstants.EXTRA_PWA_TOKEN) != token) {
                return@any false
            }

            val shortcutUrl = shortcutIntent.dataString
            val shortcutInstallUrl = shortcutIntent.getStringExtra(PwaConstants.EXTRA_PWA_INSTALL_START_URL)
            shortcutUrl == intentUrl ||
                (shortcutInstallUrl != null && shortcutInstallUrl == intentUrl) ||
                (!installStartUrl.isNullOrEmpty() && shortcutInstallUrl == installStartUrl && (shortcutUrl == intentUrl || shortcutUrl == installStartUrl))
        }
    }

    private fun resolveSessionIdFromStore(
        processorName: String,
        intent: Intent,
        components: Components,
    ): String? {
        val customTabs = components.core.store.state.customTabs
        if (customTabs.isEmpty()) {
            return null
        }

        return when (processorName) {
            "PWA" -> {
                val targetUrl = intent.dataString
                val pwaTab = customTabs.lastOrNull { tab ->
                    val appType = tab.config.externalAppType
                    val isPwa = appType == ExternalAppType.PROGRESSIVE_WEB_APP ||
                        appType == ExternalAppType.TRUSTED_WEB_ACTIVITY
                    if (!isPwa) {
                        return@lastOrNull false
                    }

                    if (targetUrl == null) {
                        true
                    } else {
                        tab.content.url == targetUrl || tab.content.webAppManifest?.startUrl == targetUrl
                    }
                } ?: customTabs.lastOrNull { tab ->
                    val appType = tab.config.externalAppType
                    appType == ExternalAppType.PROGRESSIVE_WEB_APP ||
                        appType == ExternalAppType.TRUSTED_WEB_ACTIVITY
                }

                pwaTab?.id
            }

            else -> customTabs.lastOrNull()?.id
        }
    }

    /**
     * Handles PWA intents with profile and context metadata.
     * Checks if current profile matches and shows dialog if different.
     */
    private fun handlePwaIntent(
        intent: Intent,
        profileUuid: String,
        contextId: String?,
    ) {
        val url = intent.dataString
        if (url == null) {
            Log.e(TAG, "PWA intent has no URL")
            handleRegularIntent(intent)
            return
        }

        val currentProfileUuid = getCurrentProfileUuid()

        if (currentProfileUuid != null && currentProfileUuid != profileUuid) {
            Log.d(TAG, "Profile mismatch: current=$currentProfileUuid, expected=$profileUuid")
            showProfileMismatchDialog(url, contextId)
        } else {
            Log.d(TAG, "Profile match or indeterminate, launching PWA with contextId=$contextId")
            launchPwaWithContext(url, contextId)
        }
    }

    /**
     * Reads the current profile UUID from the filesystem.
     * The Flutter side persists this as a plain text file at:
     *   <filesDir>/weblibre_profiles/current_profile
     */
    private fun getCurrentProfileUuid(): String? {
        return try {
            val startupProfileFile = File(filesDir, PwaConstants.CURRENT_PROFILE_FILE)
            if (startupProfileFile.exists()) {
                startupProfileFile.readText().trim().ifEmpty { null }
            } else {
                null
            }
        } catch (e: Exception) {
            Log.e(TAG, "Failed to read current profile UUID", e)
            null
        }
    }

    /**
     * Shows a dialog when the current profile doesn't match the PWA's installation profile.
     */
    private fun showProfileMismatchDialog(
        url: String,
        contextId: String?,
    ) {
        val message = "This PWA was originally installed in a different profile. " +
            "Opening it here will use your current profile's data and settings, " +
            "which means you won't see the same content, preferences, or saved data " +
            "that you had in the original profile.\n\n" +
            "Do you want to proceed anyway?"

        AlertDialog.Builder(this)
            .setTitle("PWA Profile Mismatch")
            .setMessage(message)
            .setPositiveButton("Open Anyway") { _, _ ->
                Log.d(TAG, "User chose to open PWA despite profile mismatch")
                launchPwaWithContext(url, contextId)
            }
            .setNegativeButton("Cancel") { _, _ ->
                Log.d(TAG, "User cancelled PWA launch due to profile mismatch")
                finish()
            }
            .setOnCancelListener {
                finish()
            }
            .show()
    }

    /**
     * Launches the PWA with the specified context ID for storage isolation.
     */
    private fun launchPwaWithContext(url: String, contextId: String?) {
        val components = GlobalComponents.components
            ?: run {
                Log.e(TAG, "Components not available for PWA launch")
                handleRegularIntent(intent)
                return
            }

        coroutineScope.launch {
            try {
                val manifest = withContext(Dispatchers.IO) {
                    components.core.webAppManifestStorage.loadManifest(url)
                }

                val sessionId = createPwaSession(
                    url = url,
                    contextId = contextId,
                    manifest = manifest
                )

                Log.d(TAG, "Created PWA session: contextId=$contextId, sessionId=$sessionId")

                val externalIntent = ExternalAppBrowserActivity.createIntent(
                    context = this@IntentReceiverActivity,
                    customTabSessionId = sessionId,
                    webAppManifestUrl = url,
                )
                startActivity(externalIntent)
                finish()
            } catch (e: Exception) {
                Log.e(TAG, "Failed to launch PWA with context", e)
                handleRegularIntent(intent)
            }
        }
    }

    /**
     * Creates a custom tab session for a PWA with the specified context ID.
     */
    private fun createPwaSession(
        url: String,
        contextId: String?,
        manifest: mozilla.components.concept.engine.manifest.WebAppManifest?
    ): String {
        val components = GlobalComponents.components
            ?: throw IllegalStateException("Components not initialized")

        val customTabConfig = mozilla.components.browser.state.state.CustomTabConfig(
            externalAppType = mozilla.components.browser.state.state.ExternalAppType.PROGRESSIVE_WEB_APP
        )

        val tab = mozilla.components.browser.state.state.createCustomTab(
            url = url,
            contextId = contextId,
            config = customTabConfig,
            webAppManifest = manifest,
            source = mozilla.components.browser.state.state.SessionState.Source.Internal.CustomTab,
            private = false
        )

        components.core.store.dispatch(
            mozilla.components.browser.state.action.CustomTabListAction.AddCustomTabAction(tab)
        )

        val loadUrlFlags = mozilla.components.concept.engine.EngineSession.LoadUrlFlags.external()
        components.useCases.sessionUseCases.loadUrl(url, tab.id, loadUrlFlags)

        return tab.id
    }

    private fun handleRegularIntent(intent: Intent) {
        val mainActivityIntent = Intent(intent).apply {
            setClassName(this@IntentReceiverActivity, "eu.weblibre.gecko.MainActivity")
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        }
        startActivity(mainActivityIntent)
        finish()
    }
}
