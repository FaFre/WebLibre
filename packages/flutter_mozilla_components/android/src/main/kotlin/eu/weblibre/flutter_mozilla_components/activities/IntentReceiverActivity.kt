/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.activities

import android.app.Activity
import android.app.AlertDialog
import android.content.Intent
import android.os.Bundle
import android.widget.FrameLayout
import eu.weblibre.flutter_mozilla_components.GlobalComponents
import eu.weblibre.flutter_mozilla_components.PwaConstants
import eu.weblibre.flutter_mozilla_components.ui.LoadingScreenManager
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel
import kotlinx.coroutines.delay
import kotlinx.coroutines.isActive
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import mozilla.components.feature.customtabs.CustomTabIntentProcessor
import mozilla.components.feature.intent.ext.getSessionId
import mozilla.components.feature.pwa.intent.WebAppIntentProcessor
import mozilla.components.support.base.log.logger.Logger
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

    private val logger = Logger("IntentReceiverActivity")
    private val coroutineScope = CoroutineScope(Dispatchers.Main + SupervisorJob())
    private var pendingIntent: Intent? = null
    private var loadingScreenManager: LoadingScreenManager? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        val intent = intent?.let { Intent(it) } ?: Intent()

        logger.debug("onCreate: action=${intent.action} data=${intent.dataString}")

        // Strip flags that could interfere with task management
        intent.flags = intent.flags and Intent.FLAG_ACTIVITY_NEW_TASK.inv()
        intent.flags = intent.flags and Intent.FLAG_ACTIVITY_CLEAR_TASK.inv()

        processIntent(intent)
    }

    override fun onDestroy() {
        super.onDestroy()
        coroutineScope.cancel()
        loadingScreenManager?.cleanup()
        loadingScreenManager = null
    }

    private fun processIntent(intent: Intent) {
        val components = GlobalComponents.components
        if (components == null) {
            logger.warn("Components not initialized, waiting for initialization...")
            pendingIntent = intent
            showLoadingIndicator(intent)
            waitForComponentsWithTimeout()
            return
        }

        routeIntent(intent)
    }

    private fun routeIntent(intent: Intent) {
        // Check if this is our custom PWA intent with profile metadata
        val profileUuid = intent.getStringExtra(PwaConstants.EXTRA_PWA_PROFILE_UUID)
        val contextId = intent.getStringExtra(PwaConstants.EXTRA_PWA_CONTEXT_ID)
        if (profileUuid != null) {
            logger.debug("PWA intent with profile metadata: profileUuid=$profileUuid, contextId=$contextId")
            handlePwaIntent(intent, profileUuid, contextId)
            return
        }

        // Fall back to standard intent processors for Custom Tabs and legacy PWAs
        val components = GlobalComponents.components
            ?: run {
                logger.error("Components became null during routing")
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
            logger.debug("Trying $name processor...")
            try {
                val result = processor.process(intent)
                logger.debug("$name processor result: $result")
                if (result) {
                    val sessionId = intent.getSessionId()
                    logger.debug("$name session ID from intent: $sessionId")
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
                        logger.warn("$name processor succeeded but no session ID in intent!")
                    }
                }
            } catch (e: Exception) {
                logger.error("Error in $name processor", e)
            }
        }

        logger.debug("No processor matched, routing to MainActivity")
        handleRegularIntent(intent)
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
            logger.error("PWA intent has no URL")
            handleRegularIntent(intent)
            return
        }

        val currentProfileUuid = getCurrentProfileUuid()

        if (currentProfileUuid != null && currentProfileUuid != profileUuid) {
            logger.debug("Profile mismatch: current=$currentProfileUuid, expected=$profileUuid")
            showProfileMismatchDialog(url, contextId)
        } else {
            logger.debug("Profile match or indeterminate, launching PWA with contextId=$contextId")
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
            logger.error("Failed to read current profile UUID", e)
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
                logger.debug("User chose to open PWA despite profile mismatch")
                launchPwaWithContext(url, contextId)
            }
            .setNegativeButton("Cancel") { _, _ ->
                logger.debug("User cancelled PWA launch due to profile mismatch")
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
                logger.error("Components not available for PWA launch")
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

                logger.debug("Created PWA session: contextId=$contextId, sessionId=$sessionId")

                val externalIntent = ExternalAppBrowserActivity.createIntent(
                    context = this@IntentReceiverActivity,
                    customTabSessionId = sessionId,
                    webAppManifestUrl = url,
                    pwaShortcutId = intent.getStringExtra(PwaConstants.EXTRA_PWA_SHORTCUT_ID),
                )
                startActivity(externalIntent)
                finish()
            } catch (e: Exception) {
                logger.error("Failed to launch PWA with context", e)
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

    /**
     * Shows a branded loading screen immediately based on intent type.
     * This avoids showing a minimal spinner and shows proper placeholders right away.
     */
    private fun showLoadingIndicator(intent: Intent) {
        // Create a container layout
        val container = FrameLayout(this).apply {
            layoutParams = FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.MATCH_PARENT,
                FrameLayout.LayoutParams.MATCH_PARENT
            )
            setBackgroundColor(android.graphics.Color.TRANSPARENT)
        }
        setContentView(container)

        // Initialize loading screen manager and show branded screen immediately
        loadingScreenManager = LoadingScreenManager.forActivity(this, container)
        loadingScreenManager?.showLoadingForIntent(intent)
    }

    /**
     * Waits for GlobalComponents to be initialized with a timeout.
     * Once components are ready, shows branded loading screen before routing.
     * Falls back to MainActivity if timeout is reached (10 seconds).
     */
    private fun waitForComponentsWithTimeout() {
        coroutineScope.launch {
            var elapsedMs = 0L

            while (isActive && elapsedMs < PwaConstants.COMPONENT_INIT_TIMEOUT_MS) {
                if (GlobalComponents.components != null) {
                    logger.debug("Components initialized after ${elapsedMs}ms")
                    pendingIntent?.let { routeIntent(it) }
                    pendingIntent = null
                    return@launch
                }

                delay(PwaConstants.COMPONENT_INIT_CHECK_INTERVAL_MS)
                elapsedMs += PwaConstants.COMPONENT_INIT_CHECK_INTERVAL_MS
            }

            if (isActive) {
                logger.warn("Timeout waiting for components after ${PwaConstants.COMPONENT_INIT_TIMEOUT_MS}ms, falling back to MainActivity")
                pendingIntent?.let { intent ->
                    handleRegularIntent(intent)
                }
                pendingIntent = null
            }
        }
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
