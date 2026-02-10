/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.activities

import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.widget.FrameLayout
import androidx.appcompat.app.AppCompatActivity
import androidx.core.view.WindowCompat
import eu.weblibre.flutter_mozilla_components.Components
import eu.weblibre.flutter_mozilla_components.ExternalAppBrowserFragment
import eu.weblibre.flutter_mozilla_components.GlobalComponents
import eu.weblibre.flutter_mozilla_components.PwaConstants
import eu.weblibre.flutter_mozilla_components.R
import eu.weblibre.flutter_mozilla_components.ui.LoadingScreenManager
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel
import kotlinx.coroutines.delay
import kotlinx.coroutines.isActive
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import mozilla.components.browser.state.selector.findCustomTab
import mozilla.components.support.base.feature.UserInteractionHandler
import mozilla.components.support.base.log.logger.Logger

/**
 * Native activity that hosts [ExternalAppBrowserFragment] for Custom Tab and PWA sessions.
 * This is a non-Flutter activity — it renders GeckoView directly in a native layout.
 *
 * Uses an empty taskAffinity so Custom Tabs appear as a separate task from the main app.
 */
class ExternalAppBrowserActivity : AppCompatActivity() {

    private val logger = Logger("ExternalAppBrowserActivity")
    private val coroutineScope = CoroutineScope(Dispatchers.Main + SupervisorJob())
    private var loadingScreenManager: LoadingScreenManager? = null

    private val customTabSessionId: String?
        get() = intent?.getStringExtra(EXTRA_CUSTOM_TAB_SESSION_ID)

    private val webAppManifestUrl: String?
        get() = intent?.getStringExtra(EXTRA_WEB_APP_MANIFEST_URL)

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        val sessionId = customTabSessionId
        if (sessionId == null) {
            logger.error("No custom tab session ID provided, finishing.")
            finish()
            return
        }

        WindowCompat.setDecorFitsSystemWindows(window, false)
        setContentView(R.layout.activity_external_app_browser)

        val components = GlobalComponents.components
        if (components == null) {
            logger.debug("Components not yet initialized, waiting...")
            showLoading()
            waitForComponents(sessionId)
            return
        }

        showFragment(sessionId)
    }

    private fun showLoading() {
        val container = findViewById<FrameLayout>(R.id.container)
        loadingScreenManager = LoadingScreenManager.forActivity(this, container)
        
        // Show branded placeholder immediately based on available data
        // If we have a manifest URL, it's likely a PWA
        val url = webAppManifestUrl ?: ""
        if (url.isNotEmpty()) {
            // Try to show PWA placeholder
            loadingScreenManager?.showLoadingForIntent(
                Intent().apply {
                    data = android.net.Uri.parse(url)
                    putExtra(PwaConstants.EXTRA_PWA_PROFILE_UUID, "placeholder")
                }
            )
        } else {
            // Show Custom Tab placeholder
            loadingScreenManager?.showLoadingForIntent(Intent())
        }
    }

    private fun waitForComponents(sessionId: String) {
        coroutineScope.launch {
            var elapsedMs = 0L

            while (isActive && elapsedMs < PwaConstants.COMPONENT_INIT_TIMEOUT_MS) {
                val components = GlobalComponents.components
                if (components != null) {
                    // Enhance the existing loading screen with actual data
                    enhanceLoadingScreen(components, sessionId)
                    // Brief delay to show the enhanced loading screen
                    delay(200)
                    showFragment(sessionId)
                    return@launch
                }

                delay(PwaConstants.COMPONENT_INIT_CHECK_INTERVAL_MS)
                elapsedMs += PwaConstants.COMPONENT_INIT_CHECK_INTERVAL_MS
            }

            // Timeout reached
            if (isActive) {
                logger.error("Timeout waiting for components after ${PwaConstants.COMPONENT_INIT_TIMEOUT_MS}ms")
                finish()
            }
        }
    }

    /**
     * Enhances the existing loading screen with actual data once components are ready.
     */
    private fun enhanceLoadingScreen(components: Components, sessionId: String) {
        val session = components.core.store.state.findCustomTab(sessionId) ?: return
        val url = session.content.url
        val manifestUrl = webAppManifestUrl

        loadingScreenManager?.let { manager ->
            when (session.config.externalAppType) {
                mozilla.components.browser.state.state.ExternalAppType.PROGRESSIVE_WEB_APP,
                mozilla.components.browser.state.state.ExternalAppType.TRUSTED_WEB_ACTIVITY -> {
                    // Enhance PWA loading with manifest data
                    coroutineScope.launch(Dispatchers.IO) {
                        val manifest = manifestUrl?.let { manifestUrl ->
                            components.core.webAppManifestStorage.loadManifest(manifestUrl)
                        }

                        withContext(Dispatchers.Main) {
                            manifest?.let {
                                manager.enhancePwaLoading(it, components.core.icons, coroutineScope)
                            } ?: manager.enhanceCustomTabLoading(url, components.core.icons, coroutineScope)
                        }
                    }
                }
                else -> {
                    // Enhance Custom Tab loading with favicon
                    manager.enhanceCustomTabLoading(url, components.core.icons, coroutineScope)
                }
            }
        }
    }

    private fun showFragment(sessionId: String) {
        val components = GlobalComponents.components ?: run {
            logger.error("Components still null after waiting, finishing.")
            finish()
            return
        }

        // Verify session exists
        if (components.core.store.state.findCustomTab(sessionId) == null) {
            logger.error("Custom tab session $sessionId not found in store, finishing.")
            finish()
            return
        }

        val fragment = ExternalAppBrowserFragment.create(
            customTabSessionId = sessionId,
            webAppManifestUrl = webAppManifestUrl,
        )

        supportFragmentManager.beginTransaction()
            .replace(R.id.container, fragment)
            .runOnCommit { loadingScreenManager?.hideLoading() }
            .commit()
    }

    override fun onResume() {
        super.onResume()

        // If the session was removed while we were in the background, finish
        val sessionId = customTabSessionId ?: return
        val components = GlobalComponents.components ?: return
        if (components.core.store.state.findCustomTab(sessionId) == null) {
            logger.debug("Custom tab session $sessionId gone, finishing activity.")
            finish()
        }
    }

    override fun onDestroy() {
        super.onDestroy()

        // Cancel any pending coroutines
        coroutineScope.cancel()

        // Clean up loading screen manager
        loadingScreenManager?.cleanup()
        loadingScreenManager = null

        // Only clean up when the activity is actually finishing (user closed it),
        // not when the system temporarily destroys it (e.g. switching to main app).
        if (isFinishing) {
            val sessionId = customTabSessionId
            if (sessionId != null) {
                val components = GlobalComponents.components
                if (components != null) {
                    val customTab = components.core.store.state.findCustomTab(sessionId)
                    if (customTab != null) {
                        components.useCases.customTabsUseCases.remove(sessionId)
                    }
                }
            }
        }
    }

    @Deprecated("Deprecated in Java")
    override fun onBackPressed() {
        val fragment = supportFragmentManager.findFragmentById(R.id.container)
        if (fragment is UserInteractionHandler && fragment.onBackPressed()) {
            return
        }
        super.onBackPressed()
    }

    override fun onPictureInPictureModeChanged(isInPictureInPictureMode: Boolean) {
        super.onPictureInPictureModeChanged(isInPictureInPictureMode)
        val fragment = supportFragmentManager.findFragmentById(R.id.container)
        if (fragment is ExternalAppBrowserFragment) {
            fragment.onPictureInPictureModeChanged(isInPictureInPictureMode)
        }
    }

    companion object {
        const val EXTRA_CUSTOM_TAB_SESSION_ID = "custom_tab_session_id"
        const val EXTRA_WEB_APP_MANIFEST_URL = "web_app_manifest_url"

        fun createIntent(
            context: Context,
            customTabSessionId: String,
            webAppManifestUrl: String? = null,
        ): Intent {
            return Intent(context, ExternalAppBrowserActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_DOCUMENT or Intent.FLAG_ACTIVITY_MULTIPLE_TASK
                putExtra(EXTRA_CUSTOM_TAB_SESSION_ID, customTabSessionId)
                webAppManifestUrl?.let { putExtra(EXTRA_WEB_APP_MANIFEST_URL, it) }
            }
        }
    }
}
